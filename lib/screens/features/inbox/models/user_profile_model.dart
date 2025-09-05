class UserProfileModel {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final String link;
  final DateTime? birthday;
  final bool hasAvatar;

  UserProfileModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.link,
    this.birthday,
    required this.hasAvatar,
  });

  UserProfileModel.empty()
      : uid = "",
        email = "",
        name = "",
        bio = "",
        link = "",
        birthday = null,
        hasAvatar = false;

  UserProfileModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] ?? '',
        email = json['email'] ?? '',
        name = json['name'] ?? '',
        bio = json['bio'] ?? '',
        link = json['link'] ?? '',
        birthday = json['birthday'] != null
            ? (json['birthday'] is int 
                ? DateTime.fromMillisecondsSinceEpoch(json['birthday'])
                : (json['birthday'] is String && json['birthday'] != 'undefined'
                    ? DateTime.tryParse(json['birthday'])
                    : null))
            : null,
        hasAvatar = json['hasAvatar'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'link': link,
      'birthday': birthday?.millisecondsSinceEpoch,
      'hasAvatar': hasAvatar,
    };
  }
}