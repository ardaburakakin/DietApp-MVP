import '../models/user.dart';

class AuthService {
  // Gerçek projede burada API çağrısı olur.
  // Şimdilik test amaçlı sahte login yapıyoruz.
  Future<AppUser> login(String email, String password, bool isDietitian) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      isDietitian: isDietitian,
    );
  }
}
