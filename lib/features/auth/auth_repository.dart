abstract class IAuthRepository {
  bool get isAuthed;
  Stream<bool> get onAuthChanged;

  Future<void> signIn();
  Future<void> signOut();
}
