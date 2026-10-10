import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/chat/constants/firestore_constants.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String content;
  String shopId;
  String userType;
  String doctorId;
  String token;
  String userId;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.content, required this.shopId, required this.userType, required this.doctorId, required this.token, required this.userId});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.content: content,
      FirestoreConstants.shopId: shopId,
      FirestoreConstants.userType: userType,
      FirestoreConstants.doctorId: doctorId,
      FirestoreConstants.token: token,
      FirestoreConstants.userId: userId
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    String content = "";
    String shopId = "";
    String userType = "";
    String doctorId = "";
    String token = "";
    String userId = "";

    // doc.get() throws when the field is absent from the document (older
    // chat documents may not have every field) - each catch is intentional,
    // leaving the field at its "" default rather than failing the whole
    // UserChat parse over one missing optional field.
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      content = doc.get(FirestoreConstants.content);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      shopId = doc.get(FirestoreConstants.shopId);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      userType = doc.get(FirestoreConstants.userType);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      doctorId = doc.get(FirestoreConstants.doctorId);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      token = doc.get(FirestoreConstants.token);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    try {
      userId = doc.get(FirestoreConstants.userId);
    } catch (e) {
      // field absent on this document - keep default ""
    }
    return UserChat(userId: userId, id: doc.id, photoUrl: photoUrl, nickname: nickname, content: content, shopId: shopId, userType: userType, doctorId: doctorId, token: token);
  }
}
