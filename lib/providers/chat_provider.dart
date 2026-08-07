import 'package:flutter/foundation.dart';

import '../core/api_exception.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Conversation list (Home screen)
  List<ConversationModel> conversations = [];
  bool isLoadingConversations = false;
  String? conversationsError;

  // Currently open conversation (Chat screen)
  int? currentConversationId;
  List<MessageModel> currentMessages = [];
  bool isLoadingMessages = false;
  bool isSendingMessage = false;
  String? messagesError;

  Future<void> loadConversations() async {
    isLoadingConversations = true;
    conversationsError = null;
    notifyListeners();

    try {
      conversations = await _chatService.getConversations();
    } catch (e) {
      conversationsError =
          e is ApiException ? e.message : 'Could not load conversations.';
    }

    isLoadingConversations = false;
    notifyListeners();
  }

  Future<ConversationModel?> startPrivateChat(int userId) async {
    try {
      final conversation = await _chatService.startPrivateConversation(userId);

      final existingIndex =
          conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex == -1) {
        conversations = [conversation, ...conversations];
      }
      notifyListeners();

      return conversation;
    } catch (e) {
      conversationsError =
          e is ApiException ? e.message : 'Could not start conversation.';
      notifyListeners();
      return null;
    }
  }

  Future<void> openConversation(int conversationId) async {
    currentConversationId = conversationId;
    currentMessages = [];
    isLoadingMessages = true;
    messagesError = null;
    notifyListeners();

    try {
      currentMessages = await _chatService.getMessages(conversationId);
      // Fire-and-forget — don't block message rendering on this.
      unawaited(_chatService.markAsRead(conversationId));
      _clearUnreadLocally(conversationId);
    } catch (e) {
      messagesError =
          e is ApiException ? e.message : 'Could not load messages.';
    }

    isLoadingMessages = false;
    notifyListeners();
  }

  Future<void> loadOlderMessages() async {
    if (currentConversationId == null || currentMessages.isEmpty) return;

    try {
      final oldest = currentMessages.first;
      final older = await _chatService.getMessages(currentConversationId!,
          before: oldest.id);
      if (older.isNotEmpty) {
        currentMessages = [...older, ...currentMessages];
        notifyListeners();
      }
    } catch (_) {
      // Silently ignore — pagination failures shouldn't disrupt the view.
    }
  }

  Future<bool> sendMessage(String body, {int? replyToMessageId}) async {
    if (currentConversationId == null || body.trim().isEmpty) return false;

    isSendingMessage = true;
    notifyListeners();

    try {
      final message = await _chatService.sendMessage(
        currentConversationId!,
        body.trim(),
        replyToMessageId: replyToMessageId,
      );
      currentMessages = [...currentMessages, message];
      _bumpConversationToTop(currentConversationId!, message);
      isSendingMessage = false;
      notifyListeners();
      return true;
    } catch (e) {
      messagesError = e is ApiException ? e.message : 'Could not send message.';
      isSendingMessage = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    if (currentConversationId == null) return;

    final previous = currentMessages;
    currentMessages = currentMessages.where((m) => m.id != messageId).toList();
    notifyListeners();

    try {
      await _chatService.deleteMessage(currentConversationId!, messageId);
    } catch (_) {
      currentMessages = previous; // revert on failure
      notifyListeners();
    }
  }

  void clearCurrentConversation() {
    currentConversationId = null;
    currentMessages = [];
    messagesError = null;
  }

  void _clearUnreadLocally(int conversationId) {
    conversations = conversations.map((c) {
      if (c.id == conversationId) {
        return ConversationModel(
          id: c.id,
          type: c.type,
          name: c.name,
          avatar: c.avatar,
          lastMessage: c.lastMessage,
          unreadCount: 0,
          updatedAt: c.updatedAt,
          participants: c.participants,
        );
      }
      return c;
    }).toList();
  }

  void _bumpConversationToTop(int conversationId, MessageModel latest) {
    final index = conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final existing = conversations[index];
    final updated = ConversationModel(
      id: existing.id,
      type: existing.type,
      name: existing.name,
      avatar: existing.avatar,
      lastMessage: latest,
      unreadCount: 0,
      updatedAt: DateTime.now(),
      participants: existing.participants,
    );

    conversations = [
      updated,
      ...conversations.where((c) => c.id != conversationId)
    ];
  }
}
