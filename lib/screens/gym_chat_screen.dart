import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import paket markdown
import '../models/chat_message.dart';

class GymChatScreen extends StatefulWidget {
  const GymChatScreen({super.key});

  @override
  State<GymChatScreen> createState() => _GymChatScreenState();
}

class _GymChatScreenState extends State<GymChatScreen> {
  // --- KONFIGURASI GEMINI ---
  // API Key Anda (Sudah benar)
  static const apiKey = 'AIzaSyCt_JMj-maho5vSwAb11hAdoE0oXyICFDE';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initGemini();
  }

  void _initGemini() {
    _model = GenerativeModel(
      // PERBAIKAN: "gemini-3" tidak ada. Gunakan 'gemini-1.5-flash' agar stabil.
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      // INSTRUKSI PERSONA:
      systemInstruction: Content.system(
        'Kamu adalah "IronCoach", seorang pelatih gym profesional dan ahli nutrisi yang bersemangat. '
        'Jawab pertanyaan seputar latihan beban, kardio, dan diet. '
        'Gunakan gaya bahasa yang memotivasi, energik, dan to-the-point ("Bro", "Man", "Sobat Gym"). '
        'Gunakan format Markdown seperti **bold** untuk poin penting dan * list untuk langkah-langkah.'
        'Jika ditanya di luar topik kebugaran, arahkan kembali ke latihan.',
      ),
    );
    _chatSession = _model.startChat();

    // Pesan sambutan awal
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "Halo Man! Siap untuk membakar kalori atau membesarkan otot hari ini? Tanya saya apa saja tentang gym!",
          isUser: false,
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText =
          response.text ?? "Maaf, otot otak saya sedang kram. Coba lagi!";

      setState(() {
        _messages.add(ChatMessage(text: responseText, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Error: Gagal terhubung. Cek koneksi internet Anda.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.fitness_center,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            SizedBox(width: 10),
            Text('IRONDIMS AI'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.lightGreenAccent),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tanya jadwal latihan...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: Colors.lightGreenAccent,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                    : const Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              msg.isUser
                  ? Colors.lightGreenAccent.withOpacity(0.2)
                  : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
          border:
              msg.isUser
                  ? Border.all(color: Colors.lightGreenAccent.withOpacity(0.5))
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.isUser ? "Kamu" : "Coach",
              style: TextStyle(
                fontSize: 10,
                color: msg.isUser ? Colors.lightGreenAccent : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // --- INI BAGIAN UTAMA YANG DIUBAH (MARKDOWN) ---
            MarkdownBody(
              data: msg.text,
              selectable: true, // Agar teks bisa dicopy
              styleSheet: MarkdownStyleSheet(
                // Pengaturan Warna Teks
                p: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ), // Teks biasa
                strong: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                ), // Bold
                listBullet: const TextStyle(
                  color: Colors.lightGreenAccent,
                ), // Bullet point
                h1: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                h2: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                blockquote: const TextStyle(color: Colors.grey),
                code: const TextStyle(
                  color: Colors.orangeAccent,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            // ------------------------------------------------
          ],
        ),
      ),
    );
  }
}
