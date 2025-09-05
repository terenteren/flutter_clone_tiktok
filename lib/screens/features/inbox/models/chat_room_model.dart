class ChatRoomModel {
  final String id;
  final String personA;
  final String personB;
  final String personAName;
  final String personBName;
  final DateTime createdAt;
  final DateTime? lastMessageTime;

  ChatRoomModel({
    required this.id,
    required this.personA,
    required this.personB,
    required this.personAName,
    required this.personBName,
    required this.createdAt,
    this.lastMessageTime,
  });

  ChatRoomModel.fromJson({
    required Map<String, dynamic> json,
    required String chatRoomId,
  })  : id = chatRoomId,
        personA = json['personA'] ?? '',
        personB = json['personB'] ?? '',
        personAName = json['personAName'] ?? '',
        personBName = json['personBName'] ?? '',
        createdAt = json['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
            : DateTime.now(),
        lastMessageTime = json['lastMessageTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'])
            : null;

  Map<String, dynamic> toJson() {
    return {
      'personA': personA,
      'personB': personB,
      'personAName': personAName,
      'personBName': personBName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
    };
  }
}