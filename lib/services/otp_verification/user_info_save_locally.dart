import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'validate_jwt_api.dart';

void saveJwtToken(String token) async {
  const storage = FlutterSecureStorage();

  // Store the JWT token in the secure storage
  await storage.write(key: 'jwt_token', value: token);

  debugPrint('JWT token saved successfully');
}

Future<String?> getJwtToken() async {
  const storage = FlutterSecureStorage();

  // Retrieve the JWT token from the secure storage
  String? token = await storage.read(key: 'jwt_token');

  return token;
}

Future<void> deleteJwtToken() async {
  const storage = FlutterSecureStorage();

  // delete all storage
  await storage.deleteAll();
}

Future<bool> checkToken() async {
  // deleteJwtToken();

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'jwt_token');
  String? email = await storage.read(key: "email");
  var jwtokk = jsonDecode(await ValidateJwtApi(email!, token!));
  debugPrint("ok");
  if (jwtokk['message'] == "Token is valid, and the email matches.") {
    return true;
  } else {
    return false;
  }
}

void saveKeyLocally(String key, String token) async {
  const storage = FlutterSecureStorage();

  // Store the JWT token in the secure storage
  await storage.write(key: key, value: token);
}
