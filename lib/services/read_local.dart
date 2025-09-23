import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getEmailFromLocal() async {
  const storage = FlutterSecureStorage();
  String? email = await storage.read(key: "email");
  debugPrint(email);
  return email;
}

Future<String?> getPhoneNumberFromLocal() async {
  const storage = FlutterSecureStorage();
  String? phoneNum = await storage.read(key: "phoneNum");
  debugPrint(phoneNum);
  return phoneNum;
}

Future<String?> getKeyFromLocal(String key) async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: key);
  return token;
}
