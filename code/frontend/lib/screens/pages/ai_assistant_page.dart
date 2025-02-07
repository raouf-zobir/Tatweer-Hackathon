import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      _showMessage('Speech recognition not available');
    }
  }

  void _toggleSpeechButton() {
    // First, ensure speech recognition is stopped
    _stopListening();
    
    setState(() {
      _showSpeechButton = !_showSpeechButton;
    });
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.listen(
        onResult: (result) => setState(() => _textController.text = result.recognizedWords),
      );
      setState(() => _isListening = available);
    }
  }

  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
    setState(() => _isListening = false);
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

    // Simulated AI processing
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _chatHistory.add({'ai': 'AI Response to: $message'});
    });
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
            icon: Icon(_showSpeechButton ? Icons.keyboard : Icons.mic),
            onPressed: _toggleSpeechButton,
          ),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.grey[200],
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
                if (_showSpeechButton) 
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: _isListening
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.mic_off, color: Colors.red),
                                onPressed: _stopListening,
                              ),
                              SizeTransition(
                                sizeFactor: _animationController!,
                                axis: Axis.horizontal,
                                child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: Text(
                                    'Listening...',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: Icon(Icons.mic, color: Colors.blue),
                            onPressed: _startListening,
                          ),
                  ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _handleSubmit,
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