class Setting {
  bool? success;
  Data? data;
  String? msg;

  Setting({this.success, this.data, this.msg});

  Setting.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  int? id;
  String? businessName;
  String? email;
  String? phone;
  String? companyWhiteLogo;
  String? companyLogo;
  String? companyFavicon;
  String? currencySymbol;
  String? currencyCode;
  String? color;
  String? websiteColor;
  int? cod;
  int? razor;
  String? razorKey;
  String? timezone;
  int? defaultCommission;
  int? pharamacyCommission;
  String? defaultBaseOn;
  String? mapKey;
  int? verification;
  int? usingMail;
  int? usingMsg;
  String? cancelReason;
  int? radius;
  String? clinicContent;
  String? doctorContent;
  String? footerContent;
  String? doctorMail;
  String? patientMail;
  String? patientNotification;
  String? doctorNotification;
  String? patientAppId;
  String? patientAuthKey;
  String? patientApiKey;
  String? doctorAppId;
  String? licenseCode;
  String? clientName;
  int? licenseVerify;
  String? createdAt;
  String? agoraAppId;
  String? updatedAt;
  String? companyWhite;
  String? logo;
  String? favicon;

  Data(
      {this.id,
      this.businessName,
      this.email,
      this.phone,
      this.companyWhiteLogo,
      this.companyLogo,
      this.companyFavicon,
      this.currencySymbol,
      this.currencyCode,
      this.color,
      this.websiteColor,
      this.cod,
      this.razor,
      this.razorKey,
      this.timezone,
      this.defaultCommission,
      this.pharamacyCommission,
      this.defaultBaseOn,
      this.mapKey,
      this.verification,
      this.usingMail,
      this.usingMsg,
      this.cancelReason,
      this.radius,
      this.clinicContent,
      this.doctorContent,
      this.footerContent,
      this.doctorMail,
      this.patientMail,
      this.patientNotification,
      this.doctorNotification,
      this.patientAppId,
      this.patientAuthKey,
      this.patientApiKey,
      this.doctorAppId,
      this.licenseCode,
      this.clientName,
      this.licenseVerify,
      this.createdAt,
      this.updatedAt,
      this.agoraAppId,
      this.companyWhite,
      this.logo,
      this.favicon});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessName = json['business_name'];
    email = json['email'];
    phone = json['phone'];
    companyWhiteLogo = json['company_white_logo'];
    companyLogo = json['company_logo'];
    companyFavicon = json['company_favicon'];
    currencySymbol = json['currency_symbol'];
    currencyCode = json['currency_code'];
    color = json['color'];
    websiteColor = json['website_color'];
    cod = json['cod'];
    razor = json['razor'];
    razorKey = json['razor_key'];
    timezone = json['timezone'];
    defaultCommission = json['default_commission'];
    pharamacyCommission = json['pharamacy_commission'];
    defaultBaseOn = json['default_base_on'];
    mapKey = json['map_key'];
    verification = json['verification'];
    usingMail = json['using_mail'];
    usingMsg = json['using_msg'];
    cancelReason = json['cancel_reason'];
    radius = json['radius'];
    clinicContent = json['clinic_content'];
    doctorContent = json['doctor_content'];
    footerContent = json['footer_content'];
    doctorMail = json['doctor_mail'];
    patientMail = json['patient_mail'];
    patientNotification = json['patient_notification'];
    doctorNotification = json['doctor_notification'];
    patientAppId = json['patient_app_id'];
    patientAuthKey = json['patient_auth_key'];
    patientApiKey = json['patient_api_key'];
    doctorAppId = json['doctor_app_id'];
    licenseCode = json['license_code'];
    clientName = json['client_name'];
    licenseVerify = json['license_verify'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    agoraAppId = json['agora_app_id'];
    companyWhite = json['companyWhite'];
    logo = json['logo'];
    favicon = json['favicon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['business_name'] = this.businessName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['company_white_logo'] = this.companyWhiteLogo;
    data['company_logo'] = this.companyLogo;
    data['company_favicon'] = this.companyFavicon;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_symbol'] = this.currencyCode;
    data['color'] = this.color;
    data['website_color'] = this.websiteColor;
    data['cod'] = this.cod;
    data['razor'] = this.razor;
    data['razor_key'] = this.razorKey;
    data['timezone'] = this.timezone;
    data['default_commission'] = this.defaultCommission;
    data['pharamacy_commission'] = this.pharamacyCommission;
    data['default_base_on'] = this.defaultBaseOn;
    data['map_key'] = this.mapKey;
    data['verification'] = this.verification;
    data['using_mail'] = this.usingMail;
    data['using_msg'] = this.usingMsg;
    data['cancel_reason'] = this.cancelReason;
    data['radius'] = this.radius;
    data['clinic_content'] = this.clinicContent;
    data['doctor_content'] = this.doctorContent;
    data['footer_content'] = this.footerContent;
    data['doctor_mail'] = this.doctorMail;
    data['patient_mail'] = this.patientMail;
    data['patient_notification'] = this.patientNotification;
    data['doctor_notification'] = this.doctorNotification;
    data['patient_app_id'] = this.patientAppId;
    data['patient_auth_key'] = this.patientAuthKey;
    data['patient_api_key'] = this.patientApiKey;
    data['doctor_app_id'] = this.doctorAppId;
    data['license_code'] = this.licenseCode;
    data['client_name'] = this.clientName;
    data['license_verify'] = this.licenseVerify;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['agora_app_id'] = this.agoraAppId;
    data['companyWhite'] = this.companyWhite;
    data['logo'] = this.logo;
    data['favicon'] = this.favicon;
    return data;
  }
}
