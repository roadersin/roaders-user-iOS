// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/search_location/modal_for_name_and_number.dart';
import '../l10n/app_localizations.dart';
import '../services/maps/latLongtoLoc.dart';

class MapSample extends StatefulWidget {
  LatLng center;
  String type;
  String pageFor;
  String pickupDescription;
  String stop1;
  String stop2;
  String stop3;
  String dropDescription;
  String pickupName;

  String pickupPhoneNumber;
  String dropName;
  String dropPhoneNumber;
  List<dynamic> listOfLocation;
  GlobalKey<FormState> formKey;
  int index;
  MapSample({
    super.key,
    required this.center,
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
    required this.listOfLocation,
    required this.formKey,
    required this.index,
  });

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  bool _isDragging = false;

  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController phoneController = TextEditingController();

  TextEditingController nameController = TextEditingController();

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          "${widget.pageFor}\t${AppLocalizations.of(context)!.location}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.center,
              zoom: 19.0, // Adjust initial zoom level here
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              _initialPosition = widget.center;
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                widget.center = position.target;
              });
            },
            onCameraIdle: () {
              if (_initialPosition != null) {
                double distance =
                _calculateDistance(_initialPosition!, widget.center);
                if (distance > 10) {
                  // Set your threshold distance here
                  setState(() {
                    _isDragging = true;
                  });
                } else {
                  // Ignore the drag if within the threshold distance
                  setState(() {
                    _isDragging = false;
                  });
                }
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.37 -
                30, // Adjust as needed
            left: MediaQuery.of(context).size.width * 0.5 -
                50, // Adjust as needed
            child: Column(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 18, 18),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "${AppLocalizations.of(context)!.setS}\t${widget.pageFor}\t${AppLocalizations.of(context)!.location}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  "assets/img/pin.png",
                  width: 50,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 10,
            right: 60, // Ensure the button stretches to the right edge as well
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(246, 255, 255, 255),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                  const Color.fromARGB(255, 233, 233, 233), // Border color
                  width: 1.0, // Border width
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "${AppLocalizations.of(context)!.setAs}\t${widget.pageFor}\t${AppLocalizations.of(context)!.location}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  if (widget.pageFor == "Pickup")
                    Text(
                      AppLocalizations.of(context)!.goodsPickup,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    )
                  else if (widget.pageFor == "Drop")
                    Text(
                      AppLocalizations.of(context)!.goodsDelivered,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    )
                  else
                    Text(
                      widget.stop1.isNotEmpty
                          ? widget.stop1
                          : widget.stop2.isNotEmpty
                          ? widget.stop2
                          : widget.stop3,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  // Text(
                  //   AppLocalizations.of(context)!.goodsDelivered,
                  //   style:
                  //       const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  // ),
                  const SizedBox(height: 20),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        if (_isDragging == true) {
                          // widget.center.latitude}, ${widget.center.longitude
                          String? addrFromDrag = await getAddressFromLatLng(
                              widget.center.latitude, widget.center.longitude);
                          debugPrint(addrFromDrag);

                          List<Map<String, dynamic>>
                          newListOfLocationAfterDrag = [];
                          newListOfLocationAfterDrag
                              .add({'description': addrFromDrag});

                          await showModalForNameAndNum(
                              context,
                              widget,
                              newListOfLocationAfterDrag,
                              widget.formKey,
                              0,
                              nameController,
                              phoneController);
                        } else {
                          await showModalForNameAndNum(
                              context,
                              widget,
                              widget.listOfLocation,
                              widget.formKey,
                              widget.index,
                              nameController,
                              phoneController);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.continueS,
                            style: const TextStyle(
                              fontFamily: "poppins",
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 30),
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
          ),
        ],
      ),
    );
  }
}
