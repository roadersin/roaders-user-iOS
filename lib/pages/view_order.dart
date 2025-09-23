// ignore_for_file: must_be_immutable, non_constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously, sized_box_for_whitespace, unused_local_variable
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/maps/findDistance.dart';
import 'review_booking.dart';
import 'search_location.dart';

class ViewOrder extends StatefulWidget {
  final String type;
  final String pageFor;
  final String pickupDescription;
  final String dropDescription;
  String stop1;
  String stop2;
  String stop3;
  final String pickupName;
  final String pickupPhoneNumber;
  final String dropName;
  final String dropPhoneNumber;

  // Constructor to receive parameters
  ViewOrder({
    super.key,
    required this.type,
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
  });

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  List<String> stops = [];

  String StopText(i) {
    if (i + 1 == 1 && widget.stop1 != "") {
      return widget.stop1;
    } else if (i + 1 == 2 && widget.stop2 != "") {
      return widget.stop2;
    } else if (i + 1 == 3 && widget.stop3 != "") {
      return widget.stop3;
    }
    return "Search for Stop ${i + 1}...";
  }

  void stopManagement() {
    if (widget.stop1 != "" && stops.isEmpty) {
      setState(() {
        stops.add('Stop ${stops.length + 1}');
      });
    }
    if (widget.stop2 != "" && stops.length < 2) {
      setState(() {
        stops.add('Stop ${stops.length + 1}');
      });
      if (widget.stop1 == "" && stops.length < 2) {
        addStop();
        removeStop(0);
      }
    }
    if (widget.stop3 != "" && stops.length < 3) {
      setState(() {
        stops.add('Stop ${stops.length + 1}');
      });

      if (widget.stop1 == "" && stops.length < 2) {
        addStop();
        removeStop(0);
      }
      if (widget.stop2 == "" && stops.length < 3) {
        addStop();

        removeStop(1);
      }
    }
  }

  void addStop() {
    if (stops.length < 3) {
      setState(() {
        stops.add('Stop ${stops.length + 1}');
      });
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void removeStop(int index) {
    if (index + 1 == 1) {
      widget.stop1 = "";
      widget.stop1 = widget.stop2;
      widget.stop2 = "";
      widget.stop2 = widget.stop3;
      widget.stop3 = "";
    } else if (index + 1 == 2) {
      widget.stop2 = "";
      widget.stop2 = widget.stop3;
      widget.stop3 = "";
    } else if (index + 1 == 3) {
      widget.stop3 = "";
    }

    setState(() {
      stops.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> rates = {
      "2-Wheelers": {
        "img": "/vehicles/1.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 60,
          "Sunday, 2-8pm": 70,
          "Mon-Sat, 8pm-6am": 60,
          "Sunday, 8pm-6am": 70,
        },
        "Distance Charges": {
          "0-20km": {"per km": 10, "per 100 meters": 1},
          "20-50km": {"per km": 10, "per 100 meters": 1},
          "50-80km": {"per km": 10, "per 100 meters": 1},
          "80-100km": {"per km": 10, "per 100 meters": 1},
          "Above 100km": {"per km": 0, "per 100 meters": 0}
        },
        "Dimensions": "40 x 40 x 40 cm",
      },
      "3-Wheelers": {
        "img": "/vehicles/2.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 260,
          "Sunday, 2-8pm": 360,
          "Mon-Sat, 8pm-6am": 360,
          "Sunday, 8pm-6am": 460
        },
        "Distance Charges": {
          "0-20km": {"per km": 20, "per 100 meters": 2},
          "20-50km": {"per km": 25, "per 100 meters": 2.5},
          "50-80km": {"per km": 30, "per 100 meters": 3},
          "80-100km": {"per km": 30, "per 100 meters": 3},
          "Above 100km": {"per km": 0, "per 100 meters": 0}
        },
        "Notes": "No 3Wheeler to be shown above 100km",
        "Dimensions": "500 kg - 5.5 x 4.5 x 5 ft",
        "Multiple Stops Charge": 50
      },
      "Tata Ace 7ft": {
        "img": "/vehicles/3.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 320,
          "Mon-Sat, 8pm-6am": 420,
          "Sunday, 2-8pm": 420,
          "Sunday, 8pm-6am": 520
        },
        "Distance Charges": {
          "0-20km": {"per km": 20, "per 100 meters": 2},
          "20-50km": {"per km": 25, "per 100 meters": 2.5},
          "50-80km": {"per km": 30, "per 100 meters": 3},
          "80-100km": {"per km": 30, "per 100 meters": 3},
          "Above 100km": {"per km": 35, "per 100 meters": 3.5}
        },
        "Dimensions": "750 kg - 7 x 4 x 5 ft",
        "Multiple Stops Charge": 50
      },
      "Tata Ace 8ft": {
        "img": "/vehicles/4.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 370,
          "Mon-Sat, 8pm-6am": 470,
          "Sunday, 2-8pm": 470,
          "Sunday, 8pm-6am": 570
        },
        "Distance Charges": {
          "0-20km": {"per km": 20, "per 100 meters": 2},
          "20-50km": {"per km": 25, "per 100 meters": 2.5},
          "50-80km": {"per km": 30, "per 100 meters": 3},
          "80-100km": {"per km": 30, "per 100 meters": 3},
          "Above 100km": {"per km": 35, "per 100 meters": 3.5}
        },
        "Dimensions": "1000 kg - 8 x 4.5 x 5.5 ft",
        "Multiple Stops Charge": 50
      },
      "Pickup 8ft": {
        "img": "/vehicles/5.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 435,
          "Mon-Sat, 8pm-6am": 535,
          "Sunday, 2-8pm": 535,
          "Sunday, 8pm-6am": 635
        },
        "Distance Charges": {
          "0-20km": {"per km": 30, "per 100 meters": 3},
          "20-50km": {"per km": 30, "per 100 meters": 3},
          "50-80km": {"per km": 35, "per 100 meters": 3.5},
          "80-100km": {"per km": 40, "per 100 meters": 4},
          "Above 100km": {"per km": 40, "per 100 meters": 4}
        },
        "Dimensions": "1250 kg - 8 x 4.5 x 5.5 ft",
        "Multiple Stops Charge": 50
      },

      "Tata 407": {
        "img": "/vehicles/6.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 915,
          "Mon-Sat, 8pm-6am": 1165,
          "Sunday, 2-8pm": 1165,
          "Sunday, 8pm-6am": 1415
        },
        "Distance Charges": {
          "0-20km": {"per km": 35, "per 100 meters": 3.5},
          "20-50km": {"per km": 45, "per 100 meters": 4.5},
          "50-80km": {"per km": 50, "per 100 meters": 5},
          "80-100km": {"per km": 55, "per 100 meters": 5.5},
          "Above 100km": {"per km": 55, "per 100 meters": 5.5}
        },
        "Dimensions": "2500 kg - 10 x 5.5 x 6 ft",
        "Multiple Stops Charge": 100
      },

      "Tata 14ft": {
        "img": "/vehicles/7.png",
        "Starting Price": {
          "Mon-Sat, 2-8pm": 1430,
          "Mon-Sat, 8pm-6am": 1680,
          "Sunday, 2-8pm": 1680,
          "Sunday, 8pm-6am": 1930
        },
        "Distance Charges": {
          "0-20km": {"per km": 40, "per 100 meters": 4},
          "20-50km": {"per km": 50, "per 100 meters": 5},
          "50-80km": {"per km": 50, "per 100 meters": 5},
          "80-100km": {"per km": 50, "per 100 meters": 5},
          "Above 100km": {"per km": 50, "per 100 meters": 5}
        },
        "Dimensions": "3500 kg - 14 x 6 x 6 ft",
        "Multiple Stops Charge": 100
      },

      // Add other vehicle rates here
    };

    void showVehicleModal(BuildContext context, String vehicle,
        String rentalKmAndTime, int price, String imagePath) {
      showModalBottomSheet(
        backgroundColor: Colors.white,

        context: context,
        isScrollControlled: true, // Allows the modal to be scrollable
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vehicle,
                    style: const TextStyle(
                      fontFamily: "poppins",
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewBookingPage(
                              type: widget.type,
                              pickupDescription: widget.pickupDescription,
                              stop1: widget.stop1,
                              stop2: widget.stop2,
                              stop3: widget.stop3,
                              dropDescription: widget.dropDescription,
                              pickupName: widget.pickupName,
                              pickupPhoneNumber: widget.pickupPhoneNumber,
                              dropName: widget.dropName,
                              dropPhoneNumber: widget.dropPhoneNumber,
                              vehicleSelected: vehicle,
                              rentalKmAndTime: rentalKmAndTime,
                              vehicleImage: imagePath,
                              estPrice: price,
                              coupon: 0.0,
                              paymentText: "",
                            ),
                          ),
                        );
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.proceed,
                            style: const TextStyle(
                              fontFamily: "poppins",
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }

    void showPriceModal(BuildContext context, List<String> stops) async {
      int km = 10; // Assume km as 10 for now

      final DistanceMatrixService service = DistanceMatrixService();

      if (widget.stop1 == "" && stops.isNotEmpty) {
        removeStop(0);
      }
      if (widget.stop2 == "" && stops.length >= 2) {
        removeStop(1);
      }
      if (widget.stop3 == "" && stops.length >= 3) {
        removeStop(2);
      }

      var distance = 0.0;
      if (widget.stop1 == "") {
        distance += await service.getDistanceInKm(
          origin: widget.pickupDescription,
          destination: widget.dropDescription,
        );
      }

      if (widget.stop1 != "") {
        distance += await service.getDistanceInKm(
          origin: widget.pickupDescription,
          destination: widget.stop1,
        );
        if (widget.stop2 == "") {
          distance += await service.getDistanceInKm(
            origin: widget.stop1,
            destination: widget.dropDescription,
          );
        }
      }

      if (widget.stop2 != "") {
        distance += await service.getDistanceInKm(
          origin: widget.stop1,
          destination: widget.stop2,
        );

        if (widget.stop3 == "") {
          distance += await service.getDistanceInKm(
            origin: widget.stop2,
            destination: widget.dropDescription,
          );
        }
      }

      if (widget.stop3 != "") {
        distance += await service.getDistanceInKm(
          origin: widget.stop2,
          destination: widget.dropDescription,
        );
      }

      debugPrint(distance.toString());

      // Calculate prices for all vehicles
      Map<String, int> vehiclePrices = {};
      Map<String, String> vehicleStorage = {};

      DateTime now = DateTime.now();
      String day = DateFormat('EEEE').format(now); // Get the current day
      if (day != "Sunday") {
        day = "Mon-Sat";
      }
      int hour = now.hour;

      // Determine time period
      String timePeriod;
      if (hour >= 2 && hour < 20) {
        timePeriod = "2-8pm";
      } else {
        timePeriod = "8pm-6am";
      }

      var deduction = 0.0;

      if (hour >= 6 && hour < 8) {
        deduction = 0.14; // 14% deduction for 6am-8am
      } else if (hour >= 8 && hour < 11) {
        deduction = 0.09; // 9% deduction for 8am-11am
      } else if (hour >= 11 && hour < 14) {
        deduction = 0.05; // 5% deduction for 11am-2pm
      }

      double reducePrice;
      if (hour >= 6 && hour < 8) {
        reducePrice = 0.14;
      } else if (hour >= 8 && hour > 11) {
        reducePrice = 0.09;
      } else if (hour >= 11 && hour > 14) {
        reducePrice = 0.05;
      } else {
        reducePrice = 0.0;
      }

      debugPrint("$day, $timePeriod");

      rates.forEach((vehicle, details) {
        int basePrice;
        if (vehicle == "2-Wheelers") {
          basePrice = details["Starting Price"]["$day, $timePeriod"];

          reducePrice = 0;
        } else if (vehicle == "3-Wheelers") {
          basePrice = details["Starting Price"]["$day, $timePeriod"];
        } else {
          basePrice = details["Starting Price"]["$day, $timePeriod"];
        }

        var distanceCharge = 0.0;

        if (distance < 20) {
          distanceCharge = details.containsKey("Distance Charges")
              ? details["Distance Charges"]["0-20km"]["per km"] * distance
              : 0;
        } else if (distance < 50) {
          distanceCharge = details.containsKey("Distance Charges")
              ? details["Distance Charges"]["20-50km"]["per km"] * distance
              : 0;
        } else if (distance < 80) {
          distanceCharge = details.containsKey("Distance Charges")
              ? details["Distance Charges"]["50-80km"]["per km"] * distance
              : 0;
        } else if (distance < 100) {
          distanceCharge = details.containsKey("Distance Charges")
              ? details["Distance Charges"]["80-100km"]["per km"] * distance
              : 0;
        } else if (distance > 100) {
          distanceCharge = details.containsKey("Distance Charges")
              ? details["Distance Charges"]["Above 100km"]["per km"] * distance
              : 0;
        }

        var stopCharge = details.containsKey("Multiple Stops Charge")
            ? details["Multiple Stops Charge"] * (stops.length)
            : 0;

        var totalPrice = basePrice + distanceCharge + stopCharge;
        totalPrice = totalPrice - (totalPrice * reducePrice).toInt();
        totalPrice = totalPrice - (totalPrice * deduction).toInt();
        vehiclePrices[vehicle] = 0;

        if (distance > 100) {
          if (vehicle == "2-Wheelers" || vehicle == "3-Wheelers") {
            vehiclePrices.remove(vehicle);
          } else {
            vehiclePrices[vehicle] = totalPrice.toInt();
          }
        } else {
          vehiclePrices[vehicle] = totalPrice.toInt();
        }

        vehicleStorage[vehicle] = details['Dimensions'];
      });

      if (distance > 250) {
        _showSnackbar(context, "Maximum distance 250Km. Try Outstation");
      } else {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 16.0, left: 15, right: 15),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                          width:
                          8), // Adjust the space between the icon and the text

                      Text(
                        AppLocalizations.of(context)!.selectVehicle,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "poppins"),
                      ),
                      const SizedBox(
                          width:
                          8), // Adjust the space between the icon and the text

                      const Icon(
                        Icons
                            .online_prediction_outlined, // You can choose any icon you like
                        size: 30,
                        color: Color.fromARGB(255, 89, 160, 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                      child: ListView.builder(
                        itemCount: vehiclePrices.length,
                        itemBuilder: (context, index) {
                          String vehicle = vehiclePrices.keys.elementAt(index);
                          int? price = vehiclePrices[vehicle];
                          String? dimensions = vehicleStorage[vehicle];
                          String imagePath = 'assets/vehicles/$vehicle.png';

                          return GestureDetector(
                            onTap: () => showVehicleModal(
                                context, vehicle, "", price!, imagePath),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 2.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 246, 246, 246),
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(0.0)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading: Image.asset(
                                    imagePath,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    vehicle,
                                    style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dimensions!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: "poppins",
                                    ),
                                  ),
                                  trailing: Text(
                                    '₹${price.toString()}',
                                    style: const TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 14.0,
                                      color: Color.fromARGB(255, 18, 18, 18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                ],
              ),
            );
          },
        );
      }
    }

    void showKmAndTimePriceModal(
        BuildContext context, String vehicle, double distance) async {
      Map<String, dynamic> rates;

      if (vehicle == "Tata Ace 7ft") {
        rates = {
          "2 Hrs, 10 KM": 900,
          "3 Hrs, 20 KM": 1200,
          "4 Hrs, 30 KM": 1500,
          "6 Hrs, 40 KM": 1900,
          "8 Hrs, 60 KM": 2200,
          "10 Hrs, 80 KM": 2500,
        };
      } else {
        rates = {
          "2 Hrs, 10 KM": 1000,
          "3 Hrs, 20 KM": 1300,
          "4 Hrs, 30 KM": 1600,
          "6 Hrs, 40 KM": 2000,
          "8 Hrs, 60 KM": 2300,
          "10 Hrs, 80 KM": 2600,
        };
      }

      // Filter rates based on distance
      Map<String, dynamic> filteredRates = Map.fromEntries(
        rates.entries.where((entry) {
          int km = int.parse(entry.key.split(', ')[1].split(' ')[0]);
          return km >= distance;
        }),
      );

      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 16.0, left: 15, right: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.timelapse_sharp,
                      size: 30,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$vehicle Rates',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRates.length,
                    itemBuilder: (context, index) {
                      String rateKey = filteredRates.keys.elementAt(index);
                      int rateValue = filteredRates[rateKey];
                      return GestureDetector(
                        onTap: () {
                          showVehicleModal(context, vehicle, rateKey, rateValue,
                              "assets/vehicles/$vehicle.png");
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 2.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              rateKey,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              '₹$rateValue',
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14.0,
                                color: Color.fromARGB(255, 18, 18, 18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget buildVehicleCard(BuildContext context, String vehicle,
        String imagePath, double distance) {
      return GestureDetector(
        onTap: () {
          showKmAndTimePriceModal(context, vehicle, distance);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 246, 246, 246),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                vehicle,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                vehicle == "Tata Ace 7ft"
                    ? "750 kg - 7 x 4 x 5 ft"
                    : "1000 kg - 8 x 4.5 x 5.5 ft",
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> showRentalModal(BuildContext context) async {
      final DistanceMatrixService service0 = DistanceMatrixService();
      double distance = await service0.getDistanceInKm(
        origin: widget.pickupDescription,
        destination: widget.dropDescription,
      );

      // debugPrint(distance as String?);

      if (distance > 250) {
        _showSnackbar(context, AppLocalizations.of(context)!.maximumDistance);
      } else {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 16.0, left: 15, right: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.selectVehicle,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins"),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.online_prediction_outlined,
                        size: 30,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        buildVehicleCard(context, "Tata Ace 7ft",
                            'assets/vehicles/Tata Ace 7ft.png', distance),
                        buildVehicleCard(context, "Tata Ace 8ft",
                            'assets/vehicles/Tata Ace 8ft.png', distance),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }

    stopManagement();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.pickupLocation,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "poppins",
                  fontSize: 14),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                // Add your onTap code here!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchLocation(
                      type: widget.type,
                      pageFor: "Pickup",
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
                debugPrint("Button Pressed");
              },
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 220, 220, 220),
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Color.fromARGB(255, 4, 111, 233),
                      size: 16.0, // Adjust the size as needed
                    ),
                    const SizedBox(
                        width: 5), // Add some space between the icon and text
                    Flexible(
                      child: Text(
                        widget.pickupDescription,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // -------------------STOPS------------------------------------
            for (int i = 0; i < stops.length; i++)
              GestureDetector(
                onTap: () {
                  // Add your onTap code here!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchLocation(
                        type: widget.type,
                        pageFor: "Stop ${i + 1}",
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
                  debugPrint("Button Pressed");
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stop ${i + 1} ",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: "poppins",
                          fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(255, 220, 220, 220),
                          width: 1.0,
                        ),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Color.fromARGB(255, 233, 107, 4),
                            size: 16.0, // Adjust the size as needed
                          ),
                          const SizedBox(
                              width:
                              5), // Add some space between the icon and text
                          Flexible(
                            child: Container(
                              // padding: EdgeInsets.symmetric(horizontal: 10),
                              width: double.infinity,
                              child: Text(
                                StopText(i),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                          InkWell(
                            child: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 20,
                            ),
                            onTap: () {
                              removeStop(i);
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            Visibility(
                visible: (widget.type) == "fixed" ? stops.length < 3 : false,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight, // Aligns child to the right
                  child: OutlinedButton(
                    onPressed: addStop,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Border radius
                      ),
                      side: const BorderSide(
                        width: 0.8,
                        color: Color.fromARGB(0, 237, 95, 1), // Border color
                      ),
                      backgroundColor: const Color.fromARGB(
                          0, 255, 233, 222), // Background color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0), // Padding
                    ),
                    child: Stack(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.addMutlipleStops,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            color:
                            Color.fromARGB(255, 197, 105, 0), // Text color
                            decoration:
                            TextDecoration.none, // Remove default underline
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 10,
                          bottom: 0,
                          child: Container(
                            height: 1.5, // Adjust line height here
                            color: Colors.orange, // Underline color
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            GestureDetector(
              onTap: () {
                // Add your onTap code here!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchLocation(
                      type: widget.type,
                      pageFor: "Drop",
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
                debugPrint("Button Pressed");
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dropLocation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "poppins",
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 220, 220, 220),
                        width: 1.0,
                      ),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Color.fromARGB(255, 4, 111, 233),
                          size: 16.0, // Adjust the size as needed
                        ),
                        const SizedBox(
                            width:
                            5), // Add some space between the icon and text
                        Flexible(
                          child: Text(
                            widget.dropDescription == ""
                                ? AppLocalizations.of(context)!
                                .searchDropLocation
                                : widget.dropDescription,
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins",
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.dropDescription != "" &&
                      widget.pickupDescription != "") {
                    if (widget.type == "rental") {
                      showRentalModal(context);
                    } else {
                      showPriceModal(context, stops);
                    }
                  } else {
                    if (widget.pickupDescription == "") {
                      _showSnackbar(context,
                          AppLocalizations.of(context)!.pickupLocationNotSet);
                    }
                    if (widget.dropDescription == "") {
                      _showSnackbar(context,
                          AppLocalizations.of(context)!.dropLocationNotSet);
                    }
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.getPrice,
                      style: const TextStyle(
                        fontFamily: "poppins",
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
