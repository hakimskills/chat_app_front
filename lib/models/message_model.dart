class MessageSender {
  final int id;
  final String name;
  final String username;
  final String? avatar;

  MessageSender(
      {required this.id,
      required this.name,
      required this.username,
      this.avatar});

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class ReplyPreview {
  final int id;
  final String? body;
  final String? senderName;

  ReplyPreview({required this.id, this.body, this.senderName});

  factory ReplyPreview.fromJson(Map<String, dynamic> json) {
    return ReplyPreview(
      id: json['id'] as int,
      body: json['body'] as String?,
      senderName: json['sender_name'] as String?,
    );
  }
}

class MessageAttachmentModel {
  final int id;
  final String url;
  final String type;
  final String? fileName;
  final String? thumbnailUrl;

  MessageAttachmentModel({
    required this.id,
    required this.url,
    required this.type,
    this.fileName,
    this.thumbnailUrl,
  });

  factory MessageAttachmentModel.fromJson(Map<String, dynamic> json) {
    return MessageAttachmentModel(
      id: json['id'] as int,
      url: json['url'] as String,
      type: json['type'] as String,
      fileName: json['file_name'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

class MessageModel {
  final int id;
  final int conversationId;
  final MessageSender? sender;
  final bool isMine;
  final String type;
  final String? body;
  final ReplyPreview? replyTo;
  final List<MessageAttachmentModel> attachments;
  final DateTime? editedAt;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.isMine,
    required this.type,
    required this.body,
    required this.replyTo,
    required this.attachments,
    required this.editedAt,
    required this.createdAt,
  });

  bool get wasEdited => editedAt != null;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      sender: json['sender'] != null
          ? MessageSender.fromJson(json['sender'])
          : null,
      isMine: json['is_mine'] as bool? ?? false,
      type: json['type'] as String? ?? 'text',
      body: json['body'] as String?,
      replyTo: json['reply_to'] != null
          ? ReplyPreview.fromJson(json['reply_to'])
          : null,
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map(
              (a) => MessageAttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      editedAt: json['edited_at'] != null
          ? DateTime.tryParse(json['edited_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
