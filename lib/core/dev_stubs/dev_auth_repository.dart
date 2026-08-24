import 'dart:async';

import 'package:wallet_test/features/auth/auth_repository.dart';

class DevAuthRepository implements IAuthRepository {
  bool _isAuthed = false;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  bool get isAuthed => _isAuthed;

  @override
  Stream<bool> get onAuthChanged => _controller.stream;

  @override
  Future<void> signIn() async {
    _isAuthed = true;
    _controller.add(true);
  }

  @override
  Future<void> signOut() async {
    _isAuthed = false;
    _controller.add(false);
  }

  Future<void> dispose() => _controller.close();
}
