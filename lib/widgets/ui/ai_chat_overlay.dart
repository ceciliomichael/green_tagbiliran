import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../constants/colors.dart';
import '../../services/gemini_ai_service.dart';
import '../../services/auth_service.dart';

class AiChatOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const AiChatOverlay({super.key, required this.onClose});

  @override
  State<AiChatOverlay> createState() => _AiChatOverlayState();
}

class _AiChatOverlayState extends State<AiChatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GeminiAiService _aiService = GeminiAiService();
  final AuthService _authService = AuthService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String _streamingMessage = '';
  bool _isStreaming = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeAiService();
    _addWelcomeMessage();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeAiService() async {
    try {
      await _aiService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
      });
      _addBotMessage(
        'Sorry, I\'m having trouble connecting right now. Please check your internet connection.',
      );
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        message:
            '👋 **Hi! I\'m GreenTea Bot, your eco-friendly assistant!**\n\nI can help you with:\n\n• **Waste management** tips\n• **Recycling** guidelines\n• **Collection schedules**\n• **Environmental** advice\n• **App navigation** support\n\n*How can I help you today?* 🌱',
        isUser: false,
      ),
    );
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUser: true));
    });
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading || !_isInitialized) return;

    // Add user message
    _addUserMessage(message);
    _messageController.clear();

    // Show streaming
    setState(() {
      _isLoading = true;
      _isStreaming = true;
      _streamingMessage = '';
    });

    try {
      // Get AI response with user context
      final response = await _aiService.sendMessage(
        message,
        _messages.where((m) => !m.isUser).toList(),
        userBarangay: _authService.currentUser?.barangay,
        userName: _authService.currentUser?.fullName,
      );

      // Simulate streaming effect
      await _streamResponse(response);
    } catch (e) {
      setState(() {
        _isStreaming = false;
        _streamingMessage = '';
      });
      _addBotMessage(
        'I apologize, but I\'m having trouble responding right now. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isStreaming = false;
        _streamingMessage = '';
      });
    }
  }

  Future<void> _streamResponse(String fullResponse) async {
    final words = fullResponse.split(' ');
    _streamingMessage = '';

    for (int i = 0; i < words.length; i++) {
      if (!mounted || !_isStreaming) break;

      setState(() {
        _streamingMessage = words.take(i + 1).join(' ');
      });

      _scrollToBottom();

      // Vary the delay for more natural streaming
      final delay = words[i].length > 6 ? 80 : 40;
      await Future.delayed(Duration(milliseconds: delay));
    }

    // Add the complete message
    if (mounted && _isStreaming) {
      setState(() {
        _isStreaming = false;
        _streamingMessage = '';
      });
      _addBotMessage(fullResponse);
    }
  }

  Future<void> _closeOverlay() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onClose();
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/svgs/ai_robot.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryGreen : AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.message,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        h1: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h2: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h3: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        strong: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        em: const TextStyle(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                        code: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          backgroundColor: AppColors.surfaceLight,
                        ),
                        codeblockPadding: const EdgeInsets.all(8),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        listBullet: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        listIndent: 20,
                        blockquotePadding: const EdgeInsets.only(left: 12),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primaryGreen,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                'assets/svgs/ai_robot.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: _isStreaming && _streamingMessage.isNotEmpty
                  ? MarkdownBody(
                      data: _streamingMessage,
                      selectable: false,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        h1: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h2: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h3: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        strong: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        em: const TextStyle(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                        ),
                        code: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          backgroundColor: AppColors.surfaceLight,
                        ),
                        listBullet: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        listIndent: 20,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'GreenTea Bot is typing...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: _closeOverlay,
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.5 * _fadeAnimation.value,
                ),
              ),
            ),
            // Chat overlay with safe area constraints
            SafeArea(
              child: Transform.translate(
                offset: Offset(
                  0,
                  MediaQuery.of(context).size.height * _slideAnimation.value,
                ),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          32, // Account for margins
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowDark.withValues(alpha: 0.3),
                          offset: const Offset(0, 16),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: SvgPicture.asset(
                                    'assets/svgs/ai_robot.svg',
                                    width: 28,
                                    height: 28,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GreenTea Bot',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Your eco-friendly assistant',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _closeOverlay,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Messages
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  _messages.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length && _isLoading) {
                                  return _buildLoadingIndicator();
                                }
                                return _buildMessage(_messages[index]);
                              },
                            ),
                          ),
                        ),
                        // Input
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.pureWhite,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _messageController,
                                    focusNode: _focusNode,
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Ask me about waste management...',
                                      hintStyle: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    minLines: 1,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: GestureDetector(
                                  onTap: _hasText && _isInitialized
                                      ? _sendMessage
                                      : null,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _hasText && _isInitialized
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.send,
                                      color: _hasText && _isInitialized
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.6),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
