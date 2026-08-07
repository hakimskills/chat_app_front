import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final ApiClient _client = ApiClient.instance;

  Future<List<ConversationModel>> getConversations() async {
    final response = await _safeGet(ApiConstants.conversations);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    throw ApiException.fromResponse(response);
  }

  Future<ConversationModel> startPrivateConversation(int userId) async {
    final response = await _safePost(ApiConstants.conversations, {
      'type': 'private',
      'user_id': userId,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ConversationModel.fromJson(data['conversation']);
    }
    throw ApiException.fromResponse(response);
  }

  Future<ConversationModel> createGroup({
    required String name,
    required List<int> participantIds,
  }) async {
    final response = await _safePost(ApiConstants.conversations, {
      'type': 'group',
      'name': name,
      'participant_ids': participantIds,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ConversationModel.fromJson(data['conversation']);
    }
    throw ApiException.fromResponse(response);
  }

  /// Pass [before] (a message id) to page further back in history.
  Future<List<MessageModel>> getMessages(int conversationId,
      {int? before}) async {
    var path = ApiConstants.conversationMessages(conversationId);
    if (before != null) {
      path += '?before=$before';
    }

    final response = await _safeGet(path);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    throw ApiException.fromResponse(response);
  }

  Future<MessageModel> sendMessage(
    int conversationId,
    String body, {
    int? replyToMessageId,
  }) async {
    final response =
        await _safePost(ApiConstants.conversationMessages(conversationId), {
      'body': body,
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MessageModel.fromJson(data['message_data']);
    }
    throw ApiException.fromResponse(response);
  }

  Future<MessageModel> editMessage(
      int conversationId, int messageId, String body) async {
    final response = await _safePut(
      ApiConstants.messageDetail(conversationId, messageId),
      {'body': body},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MessageModel.fromJson(data['message_data']);
    }
    throw ApiException.fromResponse(response);
  }

  Future<void> deleteMessage(int conversationId, int messageId) async {
    final response = await _safeDelete(
        ApiConstants.messageDetail(conversationId, messageId), {});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }
  }

  Future<void> markAsRead(int conversationId) async {
    final response =
        await _safePost(ApiConstants.conversationRead(conversationId), {});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }
  }

  Future<http.Response> _safeGet(String path) async {
    try {
      return await _client.get(path);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  Future<http.Response> _safePost(
      String path, Map<String, dynamic> body) async {
    try {
      return await _client.post(path, body);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  Future<http.Response> _safePut(String path, Map<String, dynamic> body) async {
    try {
      return await _client.put(path, body);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  Future<http.Response> _safeDelete(
      String path, Map<String, dynamic> body) async {
    try {
      return await _client.delete(path, body);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }
}
