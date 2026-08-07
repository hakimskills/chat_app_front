class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String profile = '/profile';

  static const String conversations = '/conversations';

  static String conversationDetail(int id) => '/conversations/$id';
  static String conversationMessages(int id) => '/conversations/$id/messages';
  static String conversationRead(int id) => '/conversations/$id/read';
  static String messageDetail(int conversationId, int messageId) =>
      '/conversations/$conversationId/messages/$messageId';

  static const String googleServerClientId =
      'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
}