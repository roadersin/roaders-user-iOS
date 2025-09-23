// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../pages/otp_verification.dart';
import '../../services/req_otp.dart';

Form loginFormWidget(
  TextEditingController emailController,
  TextEditingController phoneController,
  GlobalKey<FormState> formKey,
  BuildContext context,
  bool Function(String)? emailValidator,
  bool Function(String)? phoneValidator,
) {
  return Form(
    key: formKey,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.phone),
              labelText: AppLocalizations.of(context)!.phone,
              hintText: AppLocalizations.of(context)!.phoneHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.phoneRequired;
              } else if (value.length != 10) {
                return AppLocalizations.of(context)!.phoneInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline_outlined),
              labelText: AppLocalizations.of(context)!.email,
              hintText: AppLocalizations.of(context)!.emailHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.emailRequired;
              } else if (emailValidator != null && !emailValidator(value)) {
                return AppLocalizations.of(context)!.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String userEmail = emailController.text;
                  String userPhone = phoneController.text;
                  requestOtp(userEmail, userPhone);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtpVerification(
                        userEmail: userEmail,
                        userPhone: userPhone,
                      ),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 255, 102, 0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.requestOtp,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
