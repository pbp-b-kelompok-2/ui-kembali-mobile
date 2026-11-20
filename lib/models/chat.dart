class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.buyer,
    required this.seller,
    required this.latestMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  final String id;
  final String itemId;
  final String itemName;
  final String buyer;
  final String seller;
  final String? latestMessage;
  final int unreadCount;
  final DateTime updatedAt;

  String counterpart({required bool isSeller}) => isSeller ? buyer : seller;

  factory ChatConversation.fromJson(Map<String, dynamic> json) => ChatConversation(
    id: json['id'] as String,
    itemId: json['item_id'] as String,
    itemName: json['item_name'] as String? ?? '',
    buyer: json['buyer'] as String? ?? '',
    seller: json['seller'] as String? ?? '',
    latestMessage: json['latest_message'] as String?,
    unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.sentAt,
    required this.isRead,
  });

  final String id;
  final int senderId;
  final String senderName;
  final String body;
  final DateTime sentAt;
  final bool isRead;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    senderId: json['sender_id'] as int,
    senderName: json['sender_name'] as String? ?? '',
    body: json['body'] as String,
    sentAt: DateTime.parse(json['sent_at'] as String).toLocal(),
    isRead: json['is_read'] as bool? ?? false,
  );
}
