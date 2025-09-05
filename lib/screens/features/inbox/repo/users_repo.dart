import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_clone/screens/features/inbox/models/user_profile_model.dart';

class UsersRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<UserProfileModel>> fetchUsers({
    String? lastUserId,
    int pageSize = 10,  // 페이지 크기를 10으로 증가
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .orderBy('name')
        .limit(pageSize);

    if (lastUserId != null) {
      final lastUserDoc = await _db.collection('users').doc(lastUserId).get();
      if (lastUserDoc.exists) {
        query = query.startAfterDocument(lastUserDoc);
      }
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return UserProfileModel.fromJson(data);
    }).toList();
  }

  Future<List<UserProfileModel>> fetchAllUsers() async {
    // 모든 유저를 가져오기 (페이지네이션 없이)
    final snapshot = await _db
        .collection('users')
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return UserProfileModel.fromJson(data);
    }).toList();
  }

  Future<UserProfileModel?> findUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['uid'] = doc.id;
    return UserProfileModel.fromJson(data);
  }
}

final usersRepo = Provider((ref) => UsersRepository());