import 'message_model.dart';

class ConversationParticipantPreview {
  final int id;
  final String name;
  final String username;
  final String? avatar;

  ConversationParticipantPreview({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
  });

  factory ConversationParticipantPreview.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantPreview(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class ConversationModel {
  final int id;
  final String type; // 'private' or 'group'
  final String? name;
  final String? avatar;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final List<ConversationParticipantPreview>? participants;

  ConversationModel({
    required this.id,
    required this.type,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    this.participants,
  });

  bool get isGroup => type == 'group';
  bool get isPrivate => type == 'private';

  String get displayName => name ?? 'Unknown';

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participants: json['participants'] != null
          ? (json['participants'] as List<dynamic>)
              .map((p) => ConversationParticipantPreview.fromJson(
                  p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
