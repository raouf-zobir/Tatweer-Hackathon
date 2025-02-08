import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({Key? key}) : super(key: key);

  @override
  _AIAssistantPageState createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late WebSocketChannel _channel;
  bool _isConnected = false;
  Map<String, dynamic>? _currentChanges;
  Map<String, dynamic>? _currentIssues;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws'),
      );
      setState(() => _isConnected = true);

      _channel.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          print('WebSocket error: $error');
          setState(() => _isConnected = false);
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() => _isConnected = false);
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      setState(() => _isConnected = false);
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    final data = jsonDecode(message);
    final messageType = data['type'];

    setState(() {
      switch (messageType) {
        case 'startup':
        case 'response':
          _messages.add(ChatMessage(
            text: data['message'],
            isUser: false,
          ));
          break;

        case 'change_proposal':
          _currentChanges = data['changes'];
          _currentIssues = data['issues'];
          _messages.add(ChatMessage(
            text: "${data['message']}\n\nDo you want to approve these changes?",
            isUser: false,
          ));
          break;

        case 'changes_applied':
        case 'change_cancelled':
          _currentChanges = null;
          _currentIssues = null;
          _messages.add(ChatMessage(
            text: data['message'],
            isUser: false,
          ));
          break;

        case 'error':
          _messages.add(ChatMessage(
            text: "Error: ${data['message']}",
            isUser: false,
          ));
          break;
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      setState(() {
        _messages.add(ChatMessage(
          text: message,
          isUser: true,
        ));
      });
      
      if (_isConnected) {
        // If there are pending changes, send as change confirmation
        if (_currentChanges != null && _currentIssues != null) {
          _channel.sink.add(jsonEncode({
            'type': 'change_confirmation',
            'changes': _currentChanges,
            'issues': _currentIssues,
            'user_response': message,
          }));
        } else {
          // Regular message
          _channel.sink.add(jsonEncode({
            'type': 'message',
            'content': message,
          }));
        }
      }
      
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _isConnected ? null : _connectToWebSocket,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
