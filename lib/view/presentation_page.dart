import 'package:fenix/model/event.dart';
import 'package:fenix/model/polls.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PresentationPage extends StatefulWidget {
  final Event? event;
  final List<Poll>? polls;

  const PresentationPage({super.key, this.event, this.polls});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  bool showChat = true;

  // === ЧАТ ===
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _chatScrollController = ScrollController();

  WebSocketChannel? _channel;
  String currentUsername = "Вы";
  bool isConnected = false;

  late final presentation = Align(
    alignment: Alignment.center,
    child: SizedBox(
      width: 388,
      height: 238,
      child: widget.event?.presentationBytes != null
          ? ClipRect(
        child: SfPdfViewer.memory(
          widget.event!.presentationBytes!,
          canShowScrollHead: false,
          canShowScrollStatus: false,
          pageSpacing: 0,
          enableDoubleTapZooming: false,
        ),
      )
          : const Center(child: Text('Презентация не загружена')),
    ),
  );

  Widget get materials => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Материалы",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF484C52),
            ),
          ),
        ),
        if (widget.polls == null || widget.polls!.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Материалы отсутствуют"),
            ),
          )
        else
          Column(
            children: widget.polls!.map((poll) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    poll.title ?? "Без названия",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    poll.url ?? "",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.blue),
                  onTap: () async {
                    final url = poll.url;
                    if (url != null && url.isNotEmpty) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
      ],
    ),
  );

  // ==================== ЧАТ ====================
  Future<void> _connectToChat() async {
    print('🔌 [CHAT] Попытка подключения к WebSocket...');

    final storage = const FlutterSecureStorage();
    final String? token = await storage.read(key: 'jwt_token');

    if (token == null || widget.event?.id == null) {
      print('❌ [CHAT] Ошибка: токен или ID встречи отсутствует');
      _addSystemMessage("Ошибка: токен или ID встречи отсутствует");
      return;
    }

    final meetingId = widget.event!.id;

    final wsUrl = Uri(
      scheme: 'ws',
      host: 'llvvvnnn.fvds.ru',
      port: 8080,
      path: '/ws',
      queryParameters: {
        'meeting_id': meetingId,
        'token': token,
      },
    );

    print('🌐 [CHAT] Подключение к: $wsUrl');

    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
          (data) {
        print('📨 [CHAT] Получено сообщение: $data');
        try {
          final json = jsonDecode(data);
          final sender = json['username'] ?? 'system';
          final text = json['text'] ?? json['message'] ?? '';

          setState(() {
            if (sender == 'system') {
              _messages.add(ChatMessage(text: text, isMine: false, isSystem: true));
            } else if (sender != currentUsername) {
              _messages.add(ChatMessage(
                text: text,
                sender: sender,
                isMine: false,
              ));
            }
          });

          _scrollToBottom();
        } catch (e) {
          print('❌ [CHAT] Ошибка парсинга сообщения: $e');
        }
      },
      onDone: () {
        print('🔌 [CHAT] Соединение закрыто');
        setState(() => isConnected = false);
      },
      onError: (e) {
        print('❌ [CHAT] Ошибка WebSocket: $e');
        setState(() => isConnected = false);
      },
    );

    setState(() => isConnected = true);
    print('✅ [CHAT] УСПЕШНО ПОДКЛЮЧЕНО к чату');
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    if (_channel == null || !isConnected) {
      _addSystemMessage("Ошибка: нет подключения к чату");
      return;
    }

    _channel!.sink.add(jsonEncode({
      "type": "chat",
      "text": text,
    }));

    setState(() {
      _messages.add(ChatMessage(text: text, isMine: true));
    });

    _chatController.clear();
    _scrollToBottom();
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMine: false,
        isSystem: true,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (showChat) {
      _connectToChat();
    }
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    _channel?.sink.close();
    _chatController.dispose();
    super.dispose();
  }

  // ==================== UI ====================
  Widget get chat => Column(
    children: [
      // Область сообщений
      Expanded(
        child: Container(
          color: Colors.white,
          child: _messages.isEmpty
              ? const Center(
            child: Text(
              "Чат с докладчиком\nПока сообщений нет",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(_messages[index]);
            },
          ),
        ),
      ),

      // Поле ввода
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                decoration: InputDecoration(
                  hintText: "Введите сообщение...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Image.asset(
                "assets/images/presentation/send.png",
                width: 34,
                height: 34,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          msg.text,
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMine ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!msg.isMine && msg.sender != null)
              Text(
                msg.sender!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isMine ? const Color(0xFF1976D2) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ← Меняем на false
      appBar: AppBar(
        title: Text(widget.event?.title ?? "Презентация"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF484C52),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // ← Главное
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              presentation,
              const SizedBox(height: 10),

              // Переключатели
              SizedBox(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => showChat = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: showChat ? const Color(0xFFC67C4E) : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Вопрос докладчику",
                          style: TextStyle(fontSize: 16, color: Color(0xFF484C52)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => showChat = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: !showChat ? const Color(0xFFC67C4E) : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "материалы",
                          style: TextStyle(fontSize: 16, color: Color(0xFF484C52)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Основная область
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFD9D9D9),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: showChat ? chat : materials,
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Модель сообщения
class ChatMessage {
  final String text;
  final String? sender;
  final bool isMine;
  final bool isSystem;

  ChatMessage({
    required this.text,
    this.sender,
    this.isMine = false,
    this.isSystem = false,
  });
}