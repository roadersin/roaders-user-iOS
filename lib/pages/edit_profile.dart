// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/otp_verification/user_info_save_locally.dart';
import '../services/read_local.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedLocation = 'Home';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String? loadedEmail = await getEmailFromLocal();
    String? loadedPhoneNum = await getPhoneNumberFromLocal();
    String? loadedName = await getKeyFromLocal('name');
    String? loadedAddress = await getKeyFromLocal('homeAddr');

    setState(() {
      _emailController.text = loadedEmail ?? "";
      _phoneNumController.text = loadedPhoneNum ?? "";
      _nameController.text = loadedName ?? "";
      _addressController.text = loadedAddress ?? "";
      _selectedLocation = 'Home';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 0, 0),
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phone),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.address),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  _buildLocationButton('Home'),
                  _buildLocationButton('Shop'),
                  _buildLocationButton('Other'),
                ],
              ),
              const SizedBox(height: 32),
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
                              _emailController.text.isNotEmpty &&
                              _phoneNumController.text.isNotEmpty &&
                              _addressController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });

                            // Update local storage
                            saveKeyLocally("name", _nameController.text);
                            saveKeyLocally("email", _emailController.text);
                            saveKeyLocally(
                                "phoneNum", _phoneNumController.text);

                            // Determine the address key based on selected location
                            String addrKey;
                            switch (_selectedLocation) {
                              case 'Home':
                                addrKey = 'homeAddr';
                                break;
                              case 'Shop':
                                addrKey = 'shopAddr';
                                break;
                              case 'Other':
                                addrKey = 'otherAddr';
                                break;
                              default:
                                addrKey = 'homeAddr';
                            }

                            saveKeyLocally(addrKey, _addressController.text);

                            // Update remote database
                            final DatabaseService databaseService =
                                DatabaseService();
                            Map<String, dynamic> userData = {
                              "name": _nameController.text,
                              "email": _emailController.text,
                              "phoneNum": _phoneNumController.text,
                              addrKey: _addressController.text,
                              "location": _selectedLocation,
                            };

                            await databaseService.addOrUpdateUserByEmail(
                                _emailController.text, userData, 'userDetails');

                            setState(() {
                              _isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(AppLocalizations.of(context)!
                                    .profileUpdated),
                              ),
                            );

                            Navigator.pop(context);
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
                          AppLocalizations.of(context)!.save,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
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
              ? const Color.fromARGB(255, 255, 233, 214)
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
