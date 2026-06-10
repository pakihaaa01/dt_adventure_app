import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _googleSignIn = GoogleSignIn(
    clientId:
        '134884799362-qnjv41fc8vijbkdn4hifuovk65nsq91q.apps.googleusercontent.com',
  );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future<void> logout() => _googleSignIn.signOut();
  static Future<void> disconnect() => _googleSignIn.disconnect();
  static Future<GoogleSignInAccount?> silentSignIn() =>
      _googleSignIn.signInSilently();
}
