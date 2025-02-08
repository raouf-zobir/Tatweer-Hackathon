from .speech_to_text import get_transcript
from .text_to_speech import TTS


class ConversationManager:
    def __init__(self, agent):
        self.agent = agent
        # Temporarily disabled speech features
        # self.speech_to_text = SpeechToText()
        # self.text_to_speech = TextToSpeech()

    async def main(self):
        """
        Currently disabled - will be restored later
        Original speech-based conversation loop is commented out for future use
        """
        pass

        # Original speech-based code (kept for reference):
        # while True:
        #     try:
        #         # Convert speech to text
        #         user_input = await self.speech_to_text.listen()
        #         
        #         # Process through agent
        #         response = self.agent.invoke(user_input)
        #         
        #         # Convert response to speech
        #         await self.text_to_speech.speak(response)
        #     except Exception as e:
        #         print(f"Error: {e}")