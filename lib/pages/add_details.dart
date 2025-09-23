// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/otp_verification/user_info_save_locally.dart';
import '../services/read_local.dart';
import 'home_page.dart';

class AddDetailsPage extends StatefulWidget {
  const AddDetailsPage({super.key});

  @override
  _AddDetailsPageState createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  String _selectedLocation = 'Home';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserDetails();
  }

  Future<void> _checkUserDetails() async {
    String? email = await getEmailFromLocal();

    if (email != null && email.isNotEmpty) {
      final DatabaseService databaseService = DatabaseService();
      final Map<String, dynamic>? userData =
      await getUserByEmail(email, 'userDetails');

      if (userData != null &&
          userData['name'] != null &&
          (userData['homeAddr'] != null ||
              userData['shopAddr'] != null ||
              userData['otherAddr'] != null)) {
        // ✅ Save existing data locally
        saveKeyLocally("name", userData['name']);

        if (userData['homeAddr'] != null) {
          saveKeyLocally("homeAddr", userData['homeAddr']);
        }
        if (userData['shopAddr'] != null) {
          saveKeyLocally("shopAddr", userData['shopAddr']);
        }
        if (userData['otherAddr'] != null) {
          saveKeyLocally("otherAddr", userData['otherAddr']);
        }

        // ✅ Now safely redirect
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.finalStep),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "poppins",
            fontWeight: FontWeight.w600),
        backgroundColor: const Color.fromARGB(255, 255, 102, 0),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.address,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: <Widget>[
                _buildLocationButton('Home'),
                _buildLocationButton('Shop'),
                _buildLocationButton('Other'),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 255, 102, 0),
                      width: 1.0,
                    ),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_nameController.text.isNotEmpty &&
                            _addressController.text.isNotEmpty) {
                          setState(() {
                            _isLoading = true;
                          });

                          String? email = await getEmailFromLocal();
                          String? phoneNum = await getPhoneNumberFromLocal();
                          saveKeyLocally("name", _nameController.text);
                          if (email != "") {
                            debugPrint('Name: ${_nameController.text}');
                            debugPrint('Address: ${_addressController.text}');
                            debugPrint('Location: $_selectedLocation');
                            debugPrint('Email: $email');

                            String addrType;
                            if (_selectedLocation == 'Home') {
                              addrType = 'homeAddr';
                              saveKeyLocally(addrType, _addressController.text);
                            } else if (_selectedLocation == 'Shop') {
                              addrType = 'shopAddr';
                              saveKeyLocally(addrType, _addressController.text);
                            } else {
                              addrType = 'otherAddr';
                              saveKeyLocally(addrType, _addressController.text);
                            }

                            Map<String, dynamic> orderData = {
                              "email": email,
                              addrType: _addressController.text,
                              "name": _nameController.text,
                            };
                            final DatabaseService databaseService =
                                DatabaseService();

                            // Add order
                            await databaseService.addOrUpdateUserByEmail(
                                email!, orderData, 'userDetails');

                            setState(() {
                              _isLoading = false;
                            });

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                    AppLocalizations.of(context)!.emailInvalid),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(AppLocalizations.of(context)!
                                  .allFieldsRequired),
                            ),
                          );
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.submit,
                        style: const TextStyle(
                            fontFamily: "poppins", color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(String location) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      height: 30.0,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedLocation = location;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: 10.0, vertical: 0.0), // No vertical padding
          elevation: 0,
          backgroundColor: _selectedLocation == location
              ? const Color.fromARGB(255, 255, 233, 167)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              color: _selectedLocation == location
                  ? const Color.fromARGB(255, 255, 102, 0)
                  : const Color.fromARGB(255, 77, 77, 77),
              width: 0.8,
            ),
          ),
        ),
        child: Text(
          location,
          style: TextStyle(
              fontFamily: "poppins",
              color: _selectedLocation == location
                  ? const Color.fromARGB(255, 255, 102, 0)
                  : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
