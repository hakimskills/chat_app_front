import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String title;

  const ChatScreen(
      {super.key, required this.conversationId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().openConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().clearCurrentConversation();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    _messageController.clear();
    final success = await context.read<ChatProvider>().sendMessage(text);

    if (!success && mounted) {
      final error = context.read<ChatProvider>().messagesError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not send message.')),
      );
    }

    if (mounted && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.bgBottom,
      appBar: AppBar(
        backgroundColor: colors.bgBottom,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.messagesError != null
                    ? Center(
                        child: Text(
                          chatProvider.messagesError!,
                          style: TextStyle(color: colors.error),
                        ),
                      )
                    : chatProvider.currentMessages.isEmpty
                        ? Center(
                            child: Text(
                              'Say hi 👋',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.pixels <= 40 &&
                                  notification is ScrollUpdateNotification) {
                                context
                                    .read<ChatProvider>()
                                    .loadOlderMessages();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              itemCount: chatProvider.currentMessages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    chatProvider.currentMessages[index];
                                return _MessageBubble(message: message);
                              },
                            ),
                          ),
          ),
          _MessageInput(
              controller: _messageController,
              onSend: _send,
              isSending: chatProvider.isSendingMessage),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMine ? colors.primaryGradient : null,
          color: isMine ? null : colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.replyTo != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isMine ? Colors.white : colors.primaryStart)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.replyTo!.body ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMine
                        ? Colors.white.withOpacity(0.85)
                        : colors.textSecondary,
                  ),
                ),
              ),
            Text(
              message.body ?? '',
              style: TextStyle(
                color: isMine ? Colors.white : colors.textPrimary,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.wasEdited)
                  Text(
                    'edited · ',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: (isMine ? Colors.white : colors.textSecondary)
                          .withOpacity(0.7),
                    ),
                  ),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: (isMine ? Colors.white : colors.textSecondary)
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _MessageInput(
      {required this.controller,
      required this.onSend,
      required this.isSending});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: colors.primaryStart,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isSending ? null : onSend,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
