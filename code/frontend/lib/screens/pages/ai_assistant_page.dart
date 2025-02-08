import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../constants/style.dart';
import '../components/dashboard_header.dart';
import '../../widgets/copyable_text.dart';
import '../../widgets/operational_status_card.dart';
import '../../utils/message_parser.dart';
import '../../widgets/loading_spinner.dart';

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
  bool _isSending = false;
  bool _isInitializing = true;
  bool _isLoadingData = false;
  Map<String, dynamic>? _currentChanges;
  Map<String, dynamic>? _currentIssues;
  Map<String, dynamic>? _systemStatus;
  Map<String, dynamic>? _operationalData;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _connectToWebSocket();
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _connectToWebSocket() async {
    setState(() => _isLoadingData = true);
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws'),
      );
      setState(() => _isConnected = true);

      _channel.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            _isConnected = false;
            _isLoadingData = false;
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            _isConnected = false;
            _isLoadingData = false;
          });
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      setState(() {
        _isConnected = false;
        _isLoadingData = false;
      });
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    final data = jsonDecode(message);
    final messageType = data['type'];

    setState(() {
      _isLoadingData = false;
      switch (messageType) {
        case 'startup':
          final parsedData = MessageParser.parseStartupMessage(data['message']);
          _operationalData = {
            'schedule': parsedData['schedule'] ?? [],
            'issues': parsedData['issues'] ?? [],
            'actions': parsedData['actions'] ?? [],
          };
          _messages.add(ChatMessage(
            text: data['message'],
            isUser: false,
            isFirstMessage: true,
          ));
          break;
        case 'response':
          _messages.add(ChatMessage(
            text: data['message'],
            isUser: false,
          ));
          break;

        case 'change_proposal':
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
         timestamp: _getFormattedTime(),
        ));
        _isSending = true;
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
      setState(() {
        _isSending = false;
      });
    }
  }

  String _getFormattedTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: LoadingSpinner(message: 'Initializing AI Assistant...'),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(title: "AI Assistant"),
            SizedBox(height: defaultPadding),
            if (_isLoadingData)
              Container(
                height: 200,
                child: LoadingSpinner(message: 'Processing...'),
              )
            else if (_operationalData != null)
              OperationalStatusCard(
                schedule: List<Map<String, dynamic>>.from(_operationalData!['schedule']),
                issues: List<Map<String, dynamic>>.from(_operationalData!['issues']),
                proposedActions: List<Map<String, dynamic>>.from(_operationalData!['actions']),
              ),
            SizedBox(height: defaultPadding),
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConnectionStatus(),
                  SizedBox(height: defaultPadding),
                  _buildMessageList(),
                  SizedBox(height: defaultPadding),
                  _buildInputSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(width: defaultPadding / 2),
            Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _isConnected ? null : () => _connectToWebSocket(),
          color: primaryColor,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _isLoadingData
          ? LoadingSpinner(message: 'Loading messages...')
          : ListView.builder(
              padding: EdgeInsets.all(defaultPadding),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
    );
  }

  Widget _buildInputSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _messageController,
              enabled: !_isLoadingData && _isConnected,
              decoration: InputDecoration(
                hintText: _isLoadingData 
                    ? 'Processing...' 
                    : _isConnected 
                        ? 'Type your message...'
                        : 'Connecting...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(defaultPadding),
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        SizedBox(width: defaultPadding),
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: _isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.send, color: Colors.white),
            onPressed: (_isLoadingData || !_isConnected || _isSending) 
                ? null 
                : _sendMessage,
          ),
        ),
      ],
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
  final String timestamp;
  final bool isFirstMessage;

  ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    String? timestamp,
    this.isFirstMessage = false,
  }) : timestamp = timestamp ?? DateFormat('HH:mm').format(DateTime.now()),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) 
                Padding(
                  padding: const EdgeInsets.only(right: defaultPadding / 2),
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: const Icon(Icons.computer, color: Colors.white, size: 16),
                    radius: 16,
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: isUser ? primaryColor : const Color.fromARGB(255, 253, 253, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: !isUser && isFirstMessage
                      ? CopyableText(
                          text: text,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(left: defaultPadding / 2),
                  child: CircleAvatar(
                    backgroundColor: secondaryColor,
                    child: const Icon(Icons.person, color: primaryColor, size: 16),
                    radius: 16,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: defaultPadding / 4),
            child: Text(
              timestamp,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
