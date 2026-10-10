class Preferences {
  Preferences._();

  //Set Data in Preferences
  static const String is_logged_in = "isLoggedIn";
  static const String name = "name";
  static const String dob = "dob";
  static const String gender = "gender";
  static const String image = "image";
  static const String phone_no = "phone_no";
  static const String email = "email";
  static const String subscription_status = "subscription_status";
  static const String auth_token = "authToken";
  static const String uniqueId = "uniqueId";
  static const String refresh_token = "refresh_token";
  static const String expiresIn = "expiresIn";
  static const String is_filled = "is_filled";

  // Astra gateway (astra.ayureze.in) session cache - separate from the main
  // app's own auth_token/refresh_token/expiresIn above, since Astra is a
  // different host with its own JWT, exchanged from a Firebase ID token.
  static const String astraGatewayAccessToken = "astra_gateway_access_token";
  static const String astraGatewayRefreshToken = "astra_gateway_refresh_token";
  static const String astraGatewayTokenExpiresAt =
      "astra_gateway_token_expires_at";
  static const String astraGatewayUserId = "astra_gateway_user_id";
  // static const String device_token = "device_token";
  static const String notificationPermissionDialog =
      "notificationPermissionDialog";

  // static const String patientVCall="PatientVCall";
  static const String current_language_code = "current_language_code";
  static const String language_name = "language_name";
  static const String patient_name = "patient_name";
  static const String messageToken = "messageToken";
  static const String is_dark_mode = "isDarkMode";
  static const String is_notification_enabled = "isNotificationEnabled";

  //PaymentGateWay - Razorpay is the only processor this app uses.
  static const String COD = "COD";
  static const String RazorPay = "RazorPay";
  static const String razor_key = "razor_key";
  static const String agoraAppId = "agoraAppId";

  static const String doctorAppId = "doctorAppId";
  static const String currency_symbol = "Currency Symbol";
  static const String currency_code = "Currency Code";
  static const String device_platform = "device_platform";

  //Set Hospital Name & Address In Bar
  static const String hospital_name = "hospital_name";
  static const String hospital_address = "hospital_address";

  //update Image Link
  static const String imageLink = "imageLink";

  //Upload pdf
  static String filePath = "";

  static String fileName = "";

  static const String hospitalId = "hospitalId";
  static const String userId = "userId";
  static const String doctorId = "doctorId";

  static const String user_email = "user_email";
  static const String user_name = "user_name";
  // ignore: unused_field
  @Deprecated('Security risk: Never store passwords in SharedPreferences')
  static const String password = "password";
  static const String chat_profile = "profile";
  static const String registration_no = "registration_no";
  static const String registration_state = "registration_state";
}
