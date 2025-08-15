import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get token => _auth.currentUser?.uid;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('用户 ${userCredential.user?.email} 登录成功');
      return {'success': true, 'message': '登录成功'};
    } on FirebaseAuthException catch (e) {
      String errorMessage = '登录失败';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '用户不存在，请先注册';
          break;
        case 'wrong-password':
          errorMessage = '密码错误';
          break;
        case 'invalid-email':
          errorMessage = '邮箱格式无效';
          break;
        case 'user-disabled':
          errorMessage = '账户已被禁用';
          break;
        case 'too-many-requests':
          errorMessage = '请求过于频繁，请稍后再试';
          break;
        default:
          errorMessage = '登录失败: ${e.message}';
      }
      debugPrint('登录失败: ${e.code} - ${e.message}');
      return {'success': false, 'message': errorMessage, 'code': e.code};
    } catch (e) {
      debugPrint('登录过程中出错: $e');
      return {'success': false, 'message': '登录过程中出错: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint('用户 ${userCredential.user?.email} 注册成功');
      return {'success': true, 'message': '注册成功'};
    } on FirebaseAuthException catch (e) {
      String errorMessage = '注册失败';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '该邮箱已被注册';
          break;
        case 'invalid-email':
          errorMessage = '邮箱格式无效';
          break;
        case 'weak-password':
          errorMessage = '密码强度太弱，至少需要6位字符';
          break;
        case 'operation-not-allowed':
          errorMessage = '邮箱密码注册功能未启用';
          break;
        default:
          errorMessage = '注册失败: ${e.message}';
      }
      debugPrint('注册失败: ${e.code} - ${e.message}');
      return {'success': false, 'message': errorMessage, 'code': e.code};
    } catch (e) {
      debugPrint('注册过程中出错: $e');
      return {'success': false, 'message': '注册过程中出错: $e'};
    }
  }

  // 添加Google登录方法
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 触发Google登录流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': '用户取消了Google登录'};
      }

      // 获取Google认证信息
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 创建Firebase认证凭据
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用Firebase进行认证
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      debugPrint('Google用户 ${userCredential.user?.email} 登录成功');
      return {
        'success': true,
        'message': 'Google登录成功',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google登录失败';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = '该邮箱已被其他方式注册';
          break;
        case 'invalid-credential':
          errorMessage = '无效的认证凭据';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google登录功能未启用';
          break;
        case 'user-disabled':
          errorMessage = '账户已被禁用';
          break;
        case 'user-not-found':
          errorMessage = '用户不存在';
          break;
        case 'network-request-failed':
          errorMessage = '网络连接失败';
          break;
        default:
          errorMessage = 'Google登录失败: ${e.message}';
      }
      debugPrint('Google登录失败: ${e.code} - ${e.message}');
      return {'success': false, 'message': errorMessage, 'code': e.code};
    } catch (e) {
      debugPrint('Google登录过程中出错: $e');
      return {'success': false, 'message': 'Google登录过程中出错: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': '用户未登录'};
      }

      // 重新认证用户
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 更新密码
      await user.updatePassword(newPassword);

      debugPrint('密码修改成功');
      return {'success': true, 'message': '密码修改成功'};
    } on FirebaseAuthException catch (e) {
      String errorMessage = '密码修改失败';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '当前密码错误';
          break;
        case 'weak-password':
          errorMessage = '新密码强度太弱，至少需要6位字符';
          break;
        case 'requires-recent-login':
          errorMessage = '需要重新登录才能修改密码';
          break;
        default:
          errorMessage = '密码修改失败: ${e.message}';
      }
      debugPrint('密码修改失败: ${e.code} - ${e.message}');
      return {'success': false, 'message': errorMessage, 'code': e.code};
    } catch (e) {
      debugPrint('密码修改过程中出错: $e');
      return {'success': false, 'message': '密码修改过程中出错: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': '用户未登录'};
      }

      // 重新认证用户
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // 删除账户
      await user.delete();

      debugPrint('账户删除成功');
      return {'success': true, 'message': '账户删除成功'};
    } on FirebaseAuthException catch (e) {
      String errorMessage = '账户删除失败';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '密码错误';
          break;
        case 'requires-recent-login':
          errorMessage = '需要重新登录才能删除账户';
          break;
        default:
          errorMessage = '账户删除失败: ${e.message}';
      }
      debugPrint('账户删除失败: ${e.code} - ${e.message}');
      return {'success': false, 'message': errorMessage, 'code': e.code};
    } catch (e) {
      debugPrint('账户删除过程中出错: $e');
      return {'success': false, 'message': '账户删除过程中出错: $e'};
    }
  }

  // 登出时同时登出Google
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('用户已登出');
  }

  Future<bool> checkAuthStatus() async {
    return _auth.currentUser != null;
  }
}
