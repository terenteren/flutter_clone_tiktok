import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  // 이메일/비밀번호로 계정 생성
  Future<void> emailSignUp(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 이메일/비밀번호로 로그인
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> githubSignIn() async {
    // TODO: Firebase Console에서 GitHub OAuth 설정 필요
    // 1. Firebase Console → Authentication → Sign-in method → GitHub 활성화
    // 2. GitHub OAuth App 생성 및 Client ID/Secret 설정
    try {
      print("GitHub Provider 생성 중...");
      final githubProvider = GithubAuthProvider();
      print("signInWithProvider 호출 중...");
      final result = await _firebaseAuth.signInWithProvider(githubProvider);
      print("GitHub 로그인 성공! User: ${result.user?.email}");
    } catch (e) {
      print("GitHub 로그인 상세 오류: $e");
      print("오류 타입: ${e.runtimeType}");
      rethrow;
    }
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());

// 인증 상태 변경을 감지하는 StreamProvider
final authState = StreamProvider((ref) {
  final repo = ref.read(authRepo);
  return repo.authStateChanges();
});
