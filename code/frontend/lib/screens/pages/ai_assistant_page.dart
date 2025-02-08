import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIAssistantPage extends StatefulWidget {
  @override
  _AIAssistantPageState createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  bool _isLoading = false;
  bool _showSpeechButton = true;
  List<Map<String, String>> _chatHistory = [];
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _fetchInitializationMessage();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    if (!available) {
      _showMessage('Speech recognition not available');
    }
  }

  void _handleSpeechButtonPressed() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            if (_isListening) {  // Only update text if still listening
              setState(() => _textController.text = result.recognizedWords);
            }
          },
          listenFor: Duration(seconds: 15), // Limit listening time
          pauseFor: Duration(seconds: 1), // Pause time before auto-stop
          onSoundLevelChange: (level) => print('Sound level: $level'), // Can be used for UI animations
        );
      } else {
        _showMessage('Speech recognition not available');
      }
    }
  }

  void _stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    setState(() => _isListening = false);
  }

  Future<void> _fetchInitializationMessage() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/startup_message'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _chatHistory.add({'ai': responseData['message']});
          _isLoading = false;
        });
      } else {
        _showMessage('Error: ${response.reasonPhrase}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage('Error: Failed to fetch initialization message. Please ensure the backend is running.');
      setState(() => _isLoading = false);
    }
    _scrollToBottom();
  }

  Future<void> _handleSubmit() async {
    final message = _textController.text.trim();
    if (message.isEmpty) {
      _showMessage('Please enter a message');
      return;
    }

    // Stop listening if active when submitting
    _stopListening();

    setState(() {
      _isLoading = true;
      _chatHistory.add({'user': message});
      _textController.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/handle_command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _chatHistory.add({'ai': responseData['response']});
        });
      } else {
        _showMessage('Error: ${response.reasonPhrase}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage('Error: $e');
      setState(() => _isLoading = false);
    }
    _scrollToBottom();
  }

  Future<void> _handleUserDecision(String decision) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/user_decision'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'decision': decision}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _chatHistory.add({'ai': responseData['response']});
        });
      } else {
        _showMessage('Error: ${response.reasonPhrase}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage('Error: $e');
      setState(() => _isLoading = false);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _stopListening(); // Ensure speech is stopped when disposing
    _animationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Help'),
                content: Text('Type your message or use the microphone to speak. '
                    'Tap send to get AI response.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty
                ? Center(
                    child: Text(
                      'Start a conversation!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _chatHistory.length) {
                        return _TypingIndicator();
                      }
                      
                      final message = _chatHistory[index];
                      final isUser = message.containsKey('user');
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message[isUser ? 'user' : 'ai']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.blue),
                      onPressed: _handleSpeechButtonPressed,
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _handleUserDecision('approve'),
                      child: Text('Approve'),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleUserDecision('modify'),
                      child: Text('Modify'),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleUserDecision('explain'),
                      child: Text('Explain'),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleUserDecision('cancel'),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'AI is typing...',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}