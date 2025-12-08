import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../widgets/ai/ai_response_widgets.dart';
import '../../../../core/localization/localization_manager.dart';

class ExploreAIPage extends StatefulWidget {
  /// Optional initial image to attach (e.g., from Unknown Fish flow)
  final File? initialImage;

  /// Optional initial prompt to auto-send (e.g., species identification request)
  final String? initialPrompt;

  const ExploreAIPage({
    super.key,
    this.initialImage,
    this.initialPrompt,
  });

  @override
  State<ExploreAIPage> createState() => _ExploreAIPageState();
}

class _ExploreAIPageState extends State<ExploreAIPage> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _localStorageService = getIt<LocalStorageService>();
  final LocalizationManager _loc = LocalizationManager();

  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  File? _selectedImage;
  String _selectedLanguage = 'en';

  // Chat History State
  String? _currentSessionId;
  List<Map<String, dynamic>> _chatHistory = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> get _suggestions => [
        _loc.translate('explore_ai_identify_fish'),
        _loc.translate('explore_ai_cook_hilsa'),
        _loc.translate('explore_ai_rohu_healthy'),
        _loc.translate('explore_ai_best_frying'),
      ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _loc.currentLanguageCode;
    _loadHistory();

    // If initial image and prompt provided, auto-send after build
    if (widget.initialImage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoSendInitialMessage();
      });
    }
  }

  /// Auto-send the initial message with attached image
  void _autoSendInitialMessage() {
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      final prompt = widget.initialPrompt ??
          _loc.translate('explore_ai_unknown_fish_prompt');
      _sendMessage(text: prompt);
    }
  }

  void _loadHistory() {
    setState(() {
      _chatHistory = _localStorageService.getChatSessions();
    });
  }

  void _createNewSession() {
    setState(() {
      _messages.clear();
      _currentSessionId = null;
      _selectedImage = null;
      _controller.clear();
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // Close drawer
    }
  }

  void _loadSession(Map<String, dynamic> session) {
    setState(() {
      _currentSessionId = session['id'];
      _messages = (session['messages'] as List).map((m) {
        return ChatMessage(
          rawText: m['text'],
          isUser: m['isUser'],
          image: m['imagePath'] != null ? File(m['imagePath']) : null,
        );
      }).toList();
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // Close drawer
    }
    _scrollToBottom();
  }

  Future<void> _deleteSession(String sessionId) async {
    await _localStorageService.deleteChatSession(sessionId);
    _loadHistory();
    if (_currentSessionId == sessionId) {
      _createNewSession();
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_messages.isEmpty) return;

    if (_currentSessionId == null) {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Create title from first message
    String title = "New Chat";
    if (_messages.isNotEmpty) {
      title = _messages.first.rawText;
      if (title.length > 30) {
        title = "${title.substring(0, 30)}...";
      }
    }

    final sessionData = {
      'id': _currentSessionId,
      'title': title,
      'timestamp': DateTime.now().toIso8601String(),
      'messages': _messages
          .map((m) => {
                'text': m.rawText,
                'isUser': m.isUser,
                'imagePath': m.image?.path,
              })
          .toList(),
    };

    await _localStorageService.saveChatSession(sessionData);
    _loadHistory();
  }

  Future<void> _sendMessage({String? text}) async {
    final userText = text ?? _controller.text;
    if (userText.trim().isEmpty && _selectedImage == null) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    final userImage = _selectedImage;

    setState(() {
      _messages.add(ChatMessage(
        rawText: userText,
        isUser: true,
        image: userImage,
      ));
      _isLoading = true;
      _controller.clear();
      _selectedImage = null;
    });

    _scrollToBottom();
    _saveCurrentSession(); // Save after user message

    try {
      // Convert existing messages to Gemini Content history
      // We filter out system messages or error messages if needed,
      // but generally we want the conversation flow.
      List<Content> history = _messages.where((m) => m.image == null).map((m) {
        return m.isUser
            ? Content.text(m.rawText)
            : Content.model([TextPart(m.rawText)]);
      }).toList();

      // Remove the last added user message from history because it's sent as 'prompt'
      if (history.isNotEmpty && _messages.last.isUser) {
        history.removeLast();
      }

      final response = await _geminiService.generateContent(
        userText.isEmpty ? "What is this fish?" : userText,
        image: userImage,
        language: _selectedLanguage,
        history: history,
      );

      // Clean markdown
      String cleanResponse = response;
      if (response.contains('```json')) {
        cleanResponse =
            response.replaceAll('```json', '').replaceAll('```', '');
      } else if (response.contains('```')) {
        cleanResponse = response.replaceAll('```', '');
      }

      setState(() {
        _messages.add(ChatMessage(rawText: cleanResponse, isUser: false));
        _isLoading = false;
      });
      _saveCurrentSession(); // Save after AI response
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            rawText: jsonEncode({
              "type": "general",
              "message":
                  "Sorry, I encountered an error. Please check your internet connection.",
              "data": null
            }),
            isUser: false));
        _isLoading = false;
      });
      _saveCurrentSession(); // Save error message too
    }

    _scrollToBottom();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEEF2FF), // Very light indigo
                Color(0xFFE0E7FF), // Light indigo
                Color(0xFFF3E8FF), // Light purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        // leading:
        title: Row(
          children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937))),
            // IconButton(
            //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
            //   onPressed: () => Navigator.pop(context),
            // ),
            IconButton(
              icon: const Icon(Iconsax.menu_1, color: Color(0xFF1F2937)),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Text(
              _loc.translate('explore_ai_jalsetu'),
              style: GoogleFonts.outfit(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle, color: Color(0xFF6366F1)),
            onPressed: _createNewSession,
            tooltip: _loc.translate('explore_ai_new_chat'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Language',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'en',
                        child: Text('English', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'hi',
                        child: Text('हिन्दी', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'gu',
                        child: Text('ગુજરાતી', style: TextStyle(fontSize: 12))),
                  ],
                  value: _selectedLanguage,
                  onChanged: (value) {
                    if (value != null)
                      setState(() => _selectedLanguage = value);
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    height: 30,
                    width: 80,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Iconsax.language_circle,
                        color: Color(0xFF6366F1), size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEEF2FF), // Very light indigo
              Color(0xFFE0E7FF), // Light indigo
              Color(0xFFF3E8FF), // Light purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildWelcomeView() : _buildChatList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.clock, color: Color(0xFF6366F1)),
                const SizedBox(width: 12),
                Text(
                  _loc.translate('explore_ai_history'),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _chatHistory.isEmpty
                ? Center(
                    child: Text(
                      _loc.translate('explore_ai_no_history'),
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final session = _chatHistory[index];
                      final isSelected = session['id'] == _currentSessionId;
                      final date = DateTime.parse(session['timestamp']);
                      final dateStr = DateFormat('MMM d, h:mm a').format(date);

                      return Dismissible(
                        key: Key(session['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.withOpacity(0.1),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Iconsax.trash, color: Colors.red),
                        ),
                        onDismissed: (_) => _deleteSession(session['id']),
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: const Color(0xFFEEF2FF),
                          leading: Icon(
                            Iconsax.message,
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.grey,
                          ),
                          title: Text(
                            session['title'] ?? "New Chat",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          subtitle: Text(
                            dateStr,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () => _loadSession(session),
                          trailing: IconButton(
                            icon: const Icon(Iconsax.trash,
                                size: 18, color: Colors.grey),
                            onPressed: () => _deleteSession(session['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewSession,
                icon: const Icon(Iconsax.add, color: Colors.white),
                label: Text(
                  _loc.translate('explore_ai_new_chat'),
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loc.translate('explore_ai_greetings'),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loc.translate('explore_ai_how_assist'),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              // Vertical Suggestions
              ..._suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _sendMessage(text: suggestion),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          suggestion,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: const Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding:
          const EdgeInsets.fromLTRB(16, 100, 16, 16), // Top padding for AppBar
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }
        return ChatBubble(message: _messages[index]);
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF8F9FD).withOpacity(0.0),
            const Color(0xFFF8F9FD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 156, 8, 205).withOpacity(0.5),
              const Color.fromARGB(255, 13, 142, 222),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImage != null)
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  height: 80,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _loc.translate('explore_ai_image_attached'),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ],
                  ),
                ),
              // Top Row: Text Field + Send Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4, // Grows up to 4 lines then scrolls
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1F2937),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: _loc.translate('explore_ai_ask_anything'),
                        hintStyle:
                            GoogleFonts.outfit(color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_upward_rounded,
                          color: Color(0xFF1F2937), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom Row: Icons
              Row(
                children: [
                  _buildInputIcon(Iconsax.gallery, _pickImage),
                  const Spacer(),
                  _buildInputIcon(
                      Iconsax.microphone_2, () {}), // Mic placeholder
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: const Color(0xFF1F2937),
        size: 24,
      ),
    );
  }
}

class ChatMessage {
  final String rawText;
  final bool isUser;
  final File? image;

  ChatMessage({required this.rawText, required this.isUser, this.image});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(message.image!, height: 150),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937), // Dark pill for user
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.rawText,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI Response
    try {
      final jsonResponse = jsonDecode(message.rawText);
      final type = jsonResponse['type'];
      final msg = jsonResponse['message'] as String?;
      final data = jsonResponse['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'fish_info':
          return FishInfoCard(data: data ?? {}, message: msg);
        case 'recipe':
          return RecipeCard(data: data ?? {}, message: msg);
        case 'general':
        default:
          return GeneralMessageBubble(
              message: msg ?? message.rawText, isUser: false);
      }
    } catch (e) {
      return GeneralMessageBubble(message: message.rawText, isUser: false);
    }
  }
}
