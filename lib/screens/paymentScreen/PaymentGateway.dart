import 'dart:convert';

import 'package:doctro/constant/app_string.dart';
import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:flutter/material.dart';
import 'package:doctro/widgets/osler_toast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../model/purchaseSubscription.dart';

enum SingingCharacter { RazorPay, COD }

class PaymentGatewayScreen extends StatefulWidget {
  //Get Data
  final String? plan;
  final int? value;
  final int? id;
  final String? name;

  PaymentGatewayScreen({this.plan, this.value, this.id, this.name});

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  SingingCharacter? _character;

  //All Payment Token Get
  String? aPaymentToken = "";

  //check payment status 0 or 1
  int? cod;
  int? razor;

  //payment type split
  late var str;
  var parts;
  var startPart;
  var paymentType;

  //decode pass id
  String? plan;
  int? value;
  int? id;

  /// settings parameter ///
  String? businessName;
  String? email;
  String? phone;
  String? razorKey;

  ///razorpay payment///
  late Razorpay _razorpay;

  String totalAmount = '';

  /// Radio Button ///
  int? selectedRadio;

  @override
  void initState() {
    super.initState();

    id = widget.id;
    plan = widget.plan;
    value = widget.value;

    var amountData = json.decode(plan!);

    totalAmount = amountData[value]['price'];

    settingRequest();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  ///RazorPay Payment///
  void openCheckout() async {
    String? mobileNo = SharedPreferenceHelper.getString(Preferences.phone_no);
    String? email = SharedPreferenceHelper.getString(Preferences.email);

    var parseData = json.decode(plan!);

    var options = {
      'key': SharedPreferenceHelper.getString(Preferences.razor_key),
      'amount': num.parse("${parseData[value]['price']}") * 100,
      'name': 'Doctro',
      'description': '',
      'currency': SharedPreferenceHelper.getString(Preferences.currency_code),
      'prefill': {'contact': mobileNo, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    cod = SharedPreferenceHelper.getInt(Preferences.COD);
    razor = SharedPreferenceHelper.getInt(Preferences.RazorPay);

    return Scaffold(
      backgroundColor: AyurezeTheme.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AyurezeTheme.canvas,
        elevation: 0,
        title: Text(
          getTranslated(context, AppString.payment_method_heading).toString(),
          style: TextStyle(
            color: AyurezeTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace_outlined,
            color: AyurezeTheme.forestDeep,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: AyurezeTheme.canvas,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 96, 16, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: AyurezeTheme.heroDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Choose the payment path that fits your clinic.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The payment methods below now sit inside the same Ayureze workspace language as the rest of the app.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                razor == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AyurezeTheme.textSecondary.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                                color: AyurezeTheme.surface),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/razorpay.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                      ),
                                      Text(
                                          getTranslated(
                                                  context,
                                                  AppString
                                                      .payment_gateway_razorpay)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.RazorPay,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),
                cod == 1
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AyurezeTheme.textSecondary.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                                color: AyurezeTheme.surface),
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(05, 0, 0, 0),
                              child: Center(
                                child: RadioListTile<SingingCharacter>(
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02,
                                      ),
                                      Text(
                                          getTranslated(context,
                                                  AppString.payment_gateway_cod)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16, color: colorBlack)),
                                    ],
                                  ),
                                  value: SingingCharacter.COD,
                                  activeColor: colorBlack,
                                  groupValue: _character,
                                  onChanged: (SingingCharacter? value) {
                                    setState(() {
                                      _character = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: GestureDetector(
            onTap: () {
              str = "$_character";
              parts = str.split(".");
              startPart = parts[0].trim();
              paymentType = parts.sublist(1).join('.').trim();

              if (_character!.index == 0) {
                openCheckout();
              } else if (_character!.index == 1) {
                purchaseSubscriptions();
                Navigator.pushNamed(context, "loginHome");
              }
            },
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: AyurezeTheme.textSecondary.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3)),
              ], borderRadius: BorderRadius.circular(20), color: AyurezeTheme.forestDeep),
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              child: Center(
            child: Text(
                  getTranslated(context, AppString.payment_gateway_pay)
                      .toString(),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Setting>> settingRequest() async {
    Setting response;
    try {
      response =
          await RestClient(await RetroApi().dioData(context)).settingRequest();
      if (response.success == true) {
        if (response.data!.cod != null) {
          SharedPreferenceHelper.setInt(Preferences.COD, response.data!.cod!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.COD, 0);
        }

        if (response.data!.razor != null) {
          SharedPreferenceHelper.setInt(
              Preferences.RazorPay, response.data!.razor!);
        } else {
          SharedPreferenceHelper.setInt(Preferences.RazorPay, 0);
        }

        setState(() {
          businessName = response.data!.businessName;
          email = response.data!.email;
          phone = response.data!.phone;
          razorKey = response.data!.razorKey;
        });
      }
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PurchaseSubscription>> purchaseSubscriptions() async {
    var parseData = json.decode(plan!);

    Map<String, dynamic> body = {
      "subscription_id": id,
      "payment_token": _character!.index == 1 ? '' : aPaymentToken,
      "payment_status": _character!.index == 1 ? 0 : 1,
      "payment_type": paymentType,
      "duration": ("${parseData[value]['month']}"),
      "amount": ("${parseData[value]['price']}"),
    };

    PurchaseSubscription response;

    try {
      response = await RestClient(await RetroApi().dioData(context))
          .purchaseSubscriptionRequest(body);
      setState(() {
        SharedPreferenceHelper.setInt(Preferences.subscription_status, 1);
        Navigator.pushNamed(context, "loginHome");
        OslerToast.success(context, getTranslated(context, AppString.payment_success).toString());
      });
    } catch (error) {
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // RazorPay Success Method //

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    aPaymentToken = response.paymentId;
    aPaymentToken != ""
        ? purchaseSubscriptions()
        : OslerToast.error(context, getTranslated(context, AppString.payment_not_complete).toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {}

  void _handleExternalWallet(ExternalWalletResponse response) {
    OslerToast.warning(context, "EXTERNAL_WALLET: " + response.walletName!);
  }
}
