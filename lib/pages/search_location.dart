// ignore_for_file: must_be_immutable, use_build_context_synchronously, unused_local_variable
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/read_local.dart';
import 'maps.dart';
import 'view_order.dart';

class SearchLocation extends StatefulWidget {
  final String pageFor;
  final String type;
  String pickupDescription;
  String dropDescription;
  String stop1;
  String stop2;
  String stop3;
  String pickupName;
  String pickupPhoneNumber;
  String dropName;
  String dropPhoneNumber;

  SearchLocation({
    super.key,
    required this.pageFor,
    required this.pickupDescription,
    required this.stop1,
    required this.stop2,
    required this.stop3,
    required this.dropDescription,
    required this.pickupName,
    required this.pickupPhoneNumber,
    required this.dropName,
    required this.dropPhoneNumber,
    required this.type,
  });

  @override
  SearchLocationState createState() => SearchLocationState();
}

class SearchLocationState extends State<SearchLocation> {
  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<Map<String, dynamic>> dataList = [];
  String location = "Press the button to get location";

  final DatabaseService _databaseService = DatabaseService();
  Future<void> fetchDataForAddress() async {
    String? email = await getEmailFromLocal();
    List<Map<String, dynamic>> data = await _databaseService
        .readDataByEmailLimitForUserDetails('userDetails', email!);

    setState(() {
      dataList = data;
    });
  }

  List<dynamic> listOfLocation = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
    _initializeState();
    fetchDataForAddress();
  }

  Future<void> _initializeState() async {
    location = await getKeyFromLocal("location") ??
        "(2) Press the button to get location";
  }

  _onChange() {
    // Only start search when length is greater than 3
    if (searchController.text.length >= 3) {
      placeSuggestion(searchController.text);
    } else {
      // Clear the list when search length is 3 or less
      setState(() {
        listOfLocation = [];
      });
    }
  }

  void placeSuggestion(String input) async {
    const String apiKey = "AIzaSyBl7DPAOITMXQfvD9c1D87UaZTJ2vjYwq4";
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$bassedUrl?input=$input, India&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Widget to build location-related buttons
  Widget buildTextButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () async {
        // Add functionality to handle button press
        if (label == "Home") {
          if (dataList[0]['homeAddr'] != null) {
            setState(() {
              searchController.text = dataList[0]['homeAddr'];
            });
          }
        } else if (label == "Current Location") {
          searchController.text = location;
        } else if (label == "Shop") {
          if (dataList[0]['shopAddr'] != null) {
            setState(() {
              searchController.text = dataList[0]['shopAddr'];
            });
          }
        }
      },
      icon: Icon(
        icon,
        color: const Color.fromARGB(255, 19, 118, 232),
        size: 20,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: "poppins",
          fontSize: 12.0,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          widget.pageFor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              style: const TextStyle(fontFamily: "poppins", fontSize: 15),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPlace,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                suffixIcon: const Icon(Icons.search),
                prefixIcon: const Icon(Icons.radio_button_on_sharp, size: 12),
                prefixIconColor: Colors.green,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            // Show helper text when search length is 3 or less
            if (searchController.text.isNotEmpty && searchController.text.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.enterThreeCharacters,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Visibility(
              visible: searchController.text.length > 3 && listOfLocation.isNotEmpty,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listOfLocation.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        String? phoneNum = await getPhoneNumberFromLocal();
                        if (phoneNum != null && !phoneNum.startsWith('+91')) {
                          phoneNum = '+91 $phoneNum';
                        }

                        TextEditingController phoneController =
                        TextEditingController();
                        TextEditingController nameController =
                        TextEditingController();
                        final formKey = GlobalKey<FormState>();

                        if (widget.pageFor != "Pickup" &&
                            widget.pageFor != "Drop") {
                          if (widget.pageFor == "Stop 1") {
                            widget.stop1 = listOfLocation[index]["description"];
                          } else if (widget.pageFor == "Stop 2") {
                            widget.stop2 = listOfLocation[index]["description"];
                          } else if (widget.pageFor == "Stop 3") {
                            widget.stop3 = listOfLocation[index]["description"];
                          }

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
                        } else {
                          Future<LatLng> getLatLngFromAddress(
                              String address) async {
                            const String apiKey =
                                'AIzaSyBl7DPAOITMXQfvD9c1D87UaZTJ2vjYwq4';
                            final String url =
                                'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

                            final response = await http.get(Uri.parse(url));
                            if (response.statusCode == 200) {
                              final Map<String, dynamic> data =
                              json.decode(response.body);
                              if (data['status'] == 'OK') {
                                final Map<String, dynamic> location =
                                data['results'][0]['geometry']['location'];
                                final double lat = location['lat'];
                                final double lng = location['lng'];
                                return LatLng(lat, lng);
                              } else {
                                throw Exception(
                                    'Failed to get latitude and longitude');
                              }
                            } else {
                              throw Exception(
                                  'Failed to fetch data from Google Maps API');
                            }
                          }

                          getLatLngFromAddress(
                              listOfLocation[index]['description'])
                              .then((latLng) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapSample(
                                  center: latLng,
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
                                  listOfLocation: listOfLocation,
                                  formKey: formKey,
                                  index: index,
                                ),
                              ),
                            );
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            listOfLocation[index]["description"],
                            style: const TextStyle(
                                fontFamily: "poppins", fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 50.0,
        color: Colors.grey[100],
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rowWidth = constraints.maxWidth;

            return rowWidth > MediaQuery.of(context).size.width
                ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildTextButton(Icons.home_work_rounded, 'Home'),
                  buildSeparator(),
                  buildTextButton(Icons.location_on, 'Current Location'),
                  buildSeparator(),
                  buildTextButton(Icons.location_on, 'Shop'),
                ],
              ),
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildTextButton(Icons.home_work_rounded, 'Home'),
                buildSeparator(),
                buildTextButton(Icons.location_on, 'Current Location'),
                buildSeparator(),
                buildTextButton(Icons.work, 'Shop'),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget buildSeparator() {
  return Container(
    width: 1.0,
    color: Colors.grey[300],
    margin: const EdgeInsets.symmetric(horizontal: 0.0),
  );
}