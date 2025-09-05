class MessageModel {
  final String? id;  // Firestore document ID 추가
  final String text;
  final String userId;
  final int createdAt;
  final bool isDeleted;  // 삭제 여부 추가

  MessageModel({
    this.id,
    required this.text,
    required this.userId,
    required this.createdAt,
    this.isDeleted = false,
  });

  MessageModel.fromJson(Map<String, dynamic> json, {String? docId})
    : id = docId,
      text = json['isDeleted'] == true ? '[deleted message]' : json['text'],
      createdAt = json['createdAt'],
      userId = json['userId'],
      isDeleted = json['isDeleted'] ?? false;

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt,
    'userId': userId,
    'isDeleted': isDeleted,
  };
}
