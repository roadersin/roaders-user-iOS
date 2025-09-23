import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/otp_verification/user_info_save_locally.dart';
import '../services/read_local.dart';
import 'edit_profile.dart';
import 'feedback_page.dart';
import 'login_page.dart';
import 'select_language_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

void _makeCall(String phoneNumber) async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not make the call.');
  }
}

void _showContactModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.contactSupport,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            ListTile(
              leading: const Icon(Icons.phone,
                  color: Color.fromARGB(255, 255, 102, 0)),
              title: const Text('+91 08062177391'),
              onTap: () => _makeCall('+91 08062177391'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone,
                  color: Color.fromARGB(255, 255, 102, 0)),
              title: const Text('+91 7977365697'),
              onTap: () => _makeCall('+91 7977365697'),
            ),
            const Divider(),
            const ListTile(
              leading:
                  Icon(Icons.email, color: Color.fromARGB(255, 255, 102, 0)),
              title: Text('help.roaders.in@gmail.com'),
            ),
          ],
        ),
      );
    },
  );
}

class _AccountPageState extends State<AccountPage> {
  String? email = "";
  String? name = "";

  String? phoneNum = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String? loadedEmail = await getEmailFromLocal();
    String? loadedPhoneNum = await getPhoneNumberFromLocal();
    String? loadedName = await getKeyFromLocal('name');
    setState(() {
      email = loadedEmail;
      phoneNum = loadedPhoneNum;
      name = loadedName ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          AppLocalizations.of(context)!.account,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.hello} ${name!}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Action for editing profile

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ignore: prefer_const_constructors
                      builder: (context) => EditProfilePage(),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.editProfile,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(
              AppLocalizations.of(context)!.helpAndSupport,
            ),
            onTap: () {
              _showContactModal(context);

              // Action for help and support
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: Text(
              AppLocalizations.of(context)!.termsAndConditions,
            ),
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .termsAndConditions,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              // User Eligibility Section
                              Text(AppLocalizations.of(context)!
                                  .userEligibility),
                              Text(AppLocalizations.of(context)!
                                  .userEligibilityDetails),
                              const SizedBox(height: 20),

                              // Account Registration Section
                              Text(AppLocalizations.of(context)!
                                  .accountRegistration),
                              Text(AppLocalizations.of(context)!
                                  .accountRegistrationDetails),
                              const SizedBox(height: 20),

                              // Services Provided Section
                              Text(AppLocalizations.of(context)!
                                  .servicesProvided),
                              Text(AppLocalizations.of(context)!
                                  .servicesProvidedDetails),
                              const SizedBox(height: 20),

                              // Booking and Payment Section
                              Text(AppLocalizations.of(context)!
                                  .bookingAndPayment),
                              Text(AppLocalizations.of(context)!
                                  .bookingAndPaymentDetails),
                              const SizedBox(height: 20),

                              // Cancellation Policy Section
                              Text(AppLocalizations.of(context)!
                                  .cancellationPolicy),
                              Text(AppLocalizations.of(context)!
                                  .cancellationPolicyDetails),
                              const SizedBox(height: 20),

                              // User Responsibilities Section
                              Text(AppLocalizations.of(context)!
                                  .userResponsibilities),
                              Text(AppLocalizations.of(context)!
                                  .userResponsibilitiesDetails),
                              const SizedBox(height: 20),

                              // Prohibited Activities Section
                              Text(AppLocalizations.of(context)!
                                  .prohibitedActivities),
                              Text(AppLocalizations.of(context)!
                                  .prohibitedActivitiesDetails),
                              const SizedBox(height: 20),

                              // Limitation of Liability Section
                              Text(AppLocalizations.of(context)!
                                  .limitationOfLiability),
                              Text(AppLocalizations.of(context)!
                                  .limitationOfLiabilityDetails),
                              const SizedBox(height: 20),

                              // Indemnification Section
                              Text(AppLocalizations.of(context)!
                                  .indemnification),
                              Text(AppLocalizations.of(context)!
                                  .indemnificationDetails),
                              const SizedBox(height: 20),

                              // Intellectual Property Section
                              Text(AppLocalizations.of(context)!
                                  .intellectualProperty),
                              Text(AppLocalizations.of(context)!
                                  .intellectualPropertyDetails),
                              const SizedBox(height: 20),

                              // Termination Section
                              Text(AppLocalizations.of(context)!.termination),
                              Text(AppLocalizations.of(context)!
                                  .terminationDetails),
                              const SizedBox(height: 20),

                              // Modifications to the Terms Section
                              Text(AppLocalizations.of(context)!
                                  .modificationsToTheTerms),
                              Text(AppLocalizations.of(context)!
                                  .modificationsToTheTermsDetails),
                              const SizedBox(height: 20),

                              // Governing Law Section
                              Text(AppLocalizations.of(context)!.governingLaw),
                              Text(AppLocalizations.of(context)!
                                  .governingLawDetails),
                              const SizedBox(height: 20),

                              // Dispute Resolution Section
                              Text(AppLocalizations.of(context)!
                                  .disputeResolution),
                              Text(AppLocalizations.of(context)!
                                  .disputeResolutionDetails),
                              const SizedBox(height: 20),

                              // Contact Information Section
                              Text(AppLocalizations.of(context)!
                                  .contactInformation),
                              Text(AppLocalizations.of(context)!
                                  .contactInformationDetails),

                              const SizedBox(height: 16.0),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.accountSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.changeLanguage),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectLanguagePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(AppLocalizations.of(context)!.feedbackAndRating),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              deleteJwtToken();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:  Text(AppLocalizations.of(context)!.deleteAccount),
                    content: const Text(
                      "Your account and all associated data will be permanently deleted after 14 days. "
                          "If you log in again during this period, your account will be reactivated.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          deleteJwtToken();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
          )

        ],
      ),
    );
  }
}
