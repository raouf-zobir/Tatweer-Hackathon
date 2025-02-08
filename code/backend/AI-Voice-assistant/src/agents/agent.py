from colorama import Fore, init
from litellm import completion
import time
from tenacity import retry, stop_after_attempt, wait_exponential

# Initialize colorama for colored terminal output
init(autoreset=True)


class Agent:
    def __init__(self, name, model, tools=None, system_prompt=""):
        self.name = name
        self.model = model
        self.messages = []
        self.tools = tools if tools is not None else []
        self.tools_schemas = self.get_openai_tools_schema() if self.tools else None
        self.system_prompt = system_prompt
        if self.system_prompt and not self.messages:
            self.handle_messages_history("system", self.system_prompt)
        self.retry_count = 3
        self.base_wait = 20  # base wait time in seconds
        self.consecutive_failures = 0
        self.max_consecutive_failures = 3
        self.base_wait_time = 20
        self.response_cache = {}
        self.batch_operations = []

    def handle_rate_limit(self):
        """Handle rate limit with exponential backoff"""
        self.consecutive_failures += 1
        wait_time = min(self.base_wait_time * (2 ** self.consecutive_failures), 120)
        print(Fore.YELLOW + f"\nRate limit hit. Waiting {wait_time} seconds...")
        time.sleep(wait_time)

    @retry(stop=stop_after_attempt(3), 
           wait=wait_exponential(multiplier=20, min=20, max=120),
           reraise=True)
    def call_llm(self):
        """Call LLM with retry logic for rate limits"""
        try:
            response = completion(
                model=self.model,
                messages=self.messages,
                tools=self.tools_schemas,
                temperature=0.1,
            )
            self.consecutive_failures = 0  # Reset on success
            message = response.choices[0].message
            if message.tool_calls is None:
                message.tool_calls = []
            if message.function_call is None:
                message.function_call = {}
            self.handle_messages_history(
                "assistant", message.content, tool_calls=message.tool_calls
            )
            return message
        except Exception as e:
            if "rate_limit" in str(e).lower():
                self.handle_rate_limit()
                raise  # Let retry decorator handle it
            print(Fore.RED + f"\nError in LLM call: {str(e)}")
            return type('Message', (), {'content': 'I encountered an error. Please try again in a moment.', 'tool_calls': []})()

    def invoke(self, message):
        print(Fore.GREEN + f"\nCalling Agent: {self.name}")
        self.handle_messages_history("user", message)
        result = self.execute()
        return result

    def execute(self):
        try:
            response_message = self.call_llm()
            response_content = response_message.content
            tool_calls = response_message.tool_calls
            if tool_calls:
                try:
                    response_content = self.run_tools(tool_calls)
                except Exception as e:
                    print(Fore.RED + f"\nError in tool execution: {e}\n")
                    response_content = "I encountered an error while executing the requested action. Please try again."
            return response_content or "I'm sorry, I couldn't process that request."
        except Exception as e:
            print(Fore.RED + f"\nError in execution: {e}\n")
            return "I encountered an error. Please try again in a moment."

    def run_tools(self, tool_calls):
        for tool_call in tool_calls:
            self.execute_tool(tool_call)
        response_content = self.execute()
        return response_content

    def batch_similar_operations(self, operations):
        """Batch similar operations together to reduce API calls"""
        batched = {}
        for op in operations:
            key = f"{op['tool']}_{op['action']}"
            if key not in batched:
                batched[key] = []
            batched[key].append(op)
        return batched

    def execute_tool(self, tool_call):
        function_name = tool_call.function.name
        func = next(
            iter([func for func in self.tools if func.__name__ == function_name])
        )

        if not func:
            return f"Error: Function {function_name} not found."

        try:
            print(Fore.GREEN + f"\nCalling Tool: {function_name}")
            print(Fore.GREEN + f"Arguments: {tool_call.function.arguments}\n")
            cache_key = f"{function_name}_{tool_call.function.arguments}"
            if cache_key in self.response_cache:
                return self.response_cache[cache_key]

            if self.batch_operations:
                # Batch similar operations
                batched = self.batch_similar_operations(self.batch_operations)
                self.batch_operations = []
                
                results = []
                for ops in batched.values():
                    if len(ops) > 1:
                        # Execute batch operation
                        result = self.execute_batch(ops)
                        results.extend(result)
                    else:
                        # Execute single operation
                        result = self.execute_single(ops[0])
                        results.append(result)
                
                return results

            # Regular single operation execution
            func = func(**eval(tool_call.function.arguments))
            output = func.run()

            # Convert output to string if it's not already
            if isinstance(output, (dict, list)):
                output = str(output)

            tool_message = {
                "role": "tool",
                "name": function_name,
                "tool_call_id": tool_call.id,
                "content": output
            }
            self.messages.append(tool_message)

            self.response_cache[cache_key] = output
            return output
        except Exception as e:
            error_msg = f"Error executing {function_name}: {str(e)}"
            print(Fore.RED + error_msg)
            return error_msg

    async def execute_batch(self, operations):
        """Execute multiple similar operations in a single call"""
        if not operations:
            return []
            
        tool_name = operations[0]['tool']
        results = []
        
        try:
            # Group operations by tool
            if tool_name == 'CalendarTool':
                # Batch calendar operations
                edits = [{'event_id': op['event_id'], 'delay_hours': op['delay_hours']} 
                        for op in operations]
                result = await direct_tool_call(CalendarTool, 
                                              action="batch_edit",
                                              edits=edits)
                results.append(result)
            elif tool_name == 'EmailingTool':
                # Batch email operations
                notifications = [{'recipient': op['recipient'],
                                'subject': op['subject'],
                                'body': op['body']}
                               for op in operations]
                result = await direct_tool_call(EmailingTool,
                                              action="batch_send",
                                              notifications=notifications)
                results.append(result)
                
        except Exception as e:
            print(f"Error in batch execution: {e}")
            
        return results

    def get_openai_tools_schema(self):
        return [
            {"type": "function", "function": tool.openai_schema} for tool in self.tools
        ]

    def reset(self):
        self.memory.clear_messages()
        self.messages = []
        if self.system_prompt:
            self.handle_messages_history("system", self.system_prompt)

    def handle_messages_history(self, role, content, tool_calls=None, tool_output=None):
        if content is None:
            content = ""  # Ensure content is never None
            
        message = {"role": role, "content": content}
        
        if tool_calls:
            message["tool_calls"] = self.parse_tool_calls(tool_calls)
        if tool_output:
            message["name"] = tool_output["name"]
            message["tool_call_id"] = tool_output["tool_call_id"]
            
        self.messages.append(message)

    def parse_tool_calls(self, calls):
        parsed_calls = []
        for call in calls:
            parsed_call = {
                "function": {
                    "name": call.function.name,
                    "arguments": call.function.arguments,
                },
                "id": call.id,
                "type": call.type,
            }
            parsed_calls.append(parsed_call)
        return parsed_calls
