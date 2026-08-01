class ApiConstants {
  // IMPORTANT — pick the right base URL for where you're running:
  //
  // - Android emulator:  http://10.0.2.2:8000/api
  //     (10.0.2.2 is the emulator's alias for your host machine's localhost)
  // - iOS simulator:     http://127.0.0.1:8000/api  (or http://localhost:8000/api)
  // - Real physical device (Android or iOS): use your machine's LAN IP,
  //     e.g. http://192.168.1.42:8000/api — find it with `ipconfig` on
  //     Windows, and make sure `php artisan serve --host=0.0.0.0` is used
  //     so Laravel accepts connections from other devices on the network.
  static const String baseUrl = 'http://192.168.100.101:8000/api';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Must match GOOGLE_CLIENT_ID in your Laravel .env — but this one is the
  // "Web client ID" from Google Cloud Console, used by google_sign_in as
  // the serverClientId so it returns a verifiable idToken.
  static const String googleServerClientId =
      'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
}
