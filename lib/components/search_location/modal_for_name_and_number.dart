// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../pages/view_order.dart';

Future<dynamic> showModalForNameAndNum(
    BuildContext context,
    widget,
    listOfLocation,
    GlobalKey<FormState> _formKey,
    int index,
    TextEditingController nameController,
    TextEditingController phoneController) {
  return showModalBottomSheet(
    backgroundColor: Colors.white,

    context: context,
    isScrollControlled: true, // Ensures the modal adjusts for the keyboard
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 235, 148, 8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        width: 250, // Set your desired width here
                        child: Text(
                          listOfLocation[index]["description"],
                          style: const TextStyle(
                            fontFamily: "poppins",
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow:
                              TextOverflow.clip, // Handle overflow if needed
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.enterDetails,
                  style: const TextStyle(fontFamily: "poppins", fontSize: 12),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: nameController,
                  style: const TextStyle(fontFamily: "poppins", fontSize: 15),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.nameHint,
                    prefixIcon: const Icon(Icons.person_2_rounded, size: 20),
                    prefixIconColor: Colors.grey,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.nameRequired +
                          widget.pageFor;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  style: const TextStyle(fontFamily: "poppins", fontSize: 15),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.phoneHint,
                    prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                    prefixIconColor: Colors.grey,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        10), // Limit to 10 characters
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  keyboardType:
                      TextInputType.phone, // Set the keyboard type to phone
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.phoneRequired;
                    } else if (value.length != 10) {
                      return AppLocalizations.of(context)!.phoneInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20, width: double.infinity),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // If all fields are valid, proceed

                        String name = nameController.text.trim();
                        String phone = phoneController.text.trim();

                        if (widget.pageFor == "Pickup") {
                          widget.pickupName = name;
                          widget.pickupPhoneNumber = phone;
                          widget.pickupDescription =
                              listOfLocation[index]["description"];
                        } else if (widget.pageFor == "Drop") {
                          widget.dropName = name;
                          widget.dropPhoneNumber = phone;
                          widget.dropDescription =
                              listOfLocation[index]["description"];
                        } else if (widget.pageFor == "Stop 1") {
                          widget.stop1 = listOfLocation[index]["description"];
                        } else if (widget.pageFor == "Stop 2") {
                          widget.stop2 = listOfLocation[index]["description"];
                        } else if (widget.pageFor == "Stop 3") {
                          widget.stop3 = listOfLocation[index]["description"];
                        }

                        // Proceed with your logic, e.g., navigate to the next screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewOrder(
                              type: widget.type,
                              pageFor: widget.pageFor,
                              pickupDescription: widget.pickupDescription,
                              stop1: widget.stop1,
                              stop2: widget.stop2,
                              stop3: widget.stop3,
                              dropDescription: widget.dropDescription,
                              pickupName: widget.pickupName,
                              pickupPhoneNumber: widget.pickupPhoneNumber,
                              dropName: widget.dropName,
                              dropPhoneNumber: widget.dropPhoneNumber,
                            ),
                          ),
                        );
                        // Navigate or do further processing
                      }
                    },
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25, width: double.infinity),

                // Add more widgets here as needed
              ],
            ),
          ),
        ),
      );
    },
  );
}
