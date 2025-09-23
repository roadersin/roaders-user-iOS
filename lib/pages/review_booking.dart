// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/database.dart';
import '../services/read_local.dart';
import 'payment.dart';
import 'searching_driver.dart';

class ReviewBookingPage extends StatefulWidget {
  final String type;
  final String pickupDescription;
  final String dropDescription;
  String stop1;
  String stop2;
  String stop3;
  final String pickupName;
  final String pickupPhoneNumber;
  final String dropName;
  final String dropPhoneNumber;
  final String vehicleSelected;
  final String vehicleImage;
  final String rentalKmAndTime;
  final double coupon;
  final int estPrice;
  String paymentText;

  // Constructor to receive parameters
  ReviewBookingPage({
    super.key,
    required this.type,
    required this.pickupDescription,
    required this.stop1,
    required this.stop2,
    required this.stop3,
    required this.dropDescription,
    required this.pickupName,
    required this.pickupPhoneNumber,
    required this.dropName,
    required this.dropPhoneNumber,
    required this.vehicleSelected,
    required this.vehicleImage,
    required this.coupon,
    required this.estPrice,
    required this.rentalKmAndTime,
    required this.paymentText,
  });

  @override
  State<ReviewBookingPage> createState() => _ReviewBookingPageState();
}

String generateRandomString(int length) {
  const characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
}

class _ReviewBookingPageState extends State<ReviewBookingPage> {
  String _paymentText = 'Cash';
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _couponController = TextEditingController();

  double walletAmount = 0.0;
  double totalFare = 0;
  double appliedCouponDiscount = 0.0;
  String appliedCouponCode = '';
  bool isValidatingCoupon = false;

  @override
  void initState() {
    super.initState();
    appliedCouponDiscount = widget.coupon;
    _updateTotalFare();
  }

  // Method to calculate and update totalFare based on walletAmount and widget.estPrice
  void _updateTotalFare() async {
    if (widget.paymentText == "Cash") {
      _paymentText = "Cash";
    }
    if (widget.paymentText == "Pay Online") {
      _paymentText = "Pay Online";
    }

    double fetchedWalletAmount = await fetchWalletAmount();
    setState(() {
      walletAmount = fetchedWalletAmount;
      totalFare = widget.estPrice.toDouble();
      if (_paymentText == "Pay Online") {
        totalFare = walletAmount > widget.estPrice
            ? 0.0
            : widget.estPrice - walletAmount;

        if (appliedCouponDiscount > 0) {
          totalFare = widget.estPrice - widget.estPrice * appliedCouponDiscount;
          totalFare = walletAmount > totalFare ? 0.0 : totalFare - walletAmount;
        }
      } else {
        if (appliedCouponDiscount > 0) {
          totalFare = widget.estPrice - widget.estPrice * appliedCouponDiscount;
        }
      }
    });
  }

  Future<double> fetchWalletAmount() async {
    try {
      String? email = await getEmailFromLocal();
      if (email != null) {
        double walletAmount =
        (await _databaseService.readWallet(email, "userDetails"))
            .toDouble();
        return walletAmount;
      } else {
        throw Exception('Email is null');
      }
    } catch (e) {
      debugPrint("Error fetching wallet amount: $e");
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByEmail() async {
    try {
      final DatabaseService databaseService = DatabaseService();
      String? email = await getEmailFromLocal();
      return await databaseService.readDataByEmail("booking", email!);
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> validateCoupon(String couponCode) async {
    try {
      // Fetch coupon from Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('name', isEqualTo: couponCode.toUpperCase())
          .get();

      if (snapshot.docs.isEmpty) {
        return {'valid': false, 'message': 'Invalid coupon code'};
      }

      final couponData = snapshot.docs.first.data() as Map<String, dynamic>;

      // Get discount from Firestore amount field, convert to percentage
      String amountStr = couponData['amount'] ?? '0';
      double discountPercentage = double.tryParse(amountStr) ?? 0.0;
      double discount =
          discountPercentage / 100; // Convert to decimal (e.g., 6 -> 0.06)

      return {
        'valid': true,
        'discount': discount,
        'discountPercentage': discountPercentage,
        'description': couponData['description'] ?? '',
        'message': 'Coupon applied successfully!'
      };
    } catch (e) {
      debugPrint('Error validating coupon: $e');
      return {'valid': false, 'message': 'Error validating coupon'};
    }
  }

  void _showCouponModal() {
    _couponController.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.applyCoupon,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Current applied coupon display
                  if (appliedCouponCode.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appliedCouponCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${(appliedCouponDiscount * 100).toInt()}% ${AppLocalizations.of(context)!.discountApplied}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                appliedCouponCode = '';
                                appliedCouponDiscount = 0.0;
                                _updateTotalFare();
                              });
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.remove),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.enterCouponCode,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.local_offer),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValidatingCoupon
                          ? null
                          : () async {
                        if (_couponController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .pleaseEnterACouponCode),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setModalState(() {
                          isValidatingCoupon = true;
                        });

                        final result = await validateCoupon(
                            _couponController.text.trim());

                        setModalState(() {
                          isValidatingCoupon = false;
                        });

                        if (result!['valid']) {
                          setState(() {
                            appliedCouponCode = _couponController.text
                                .trim()
                                .toUpperCase();
                            appliedCouponDiscount = result['discount'];
                            _updateTotalFare();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${result['discountPercentage'].toInt()}% ${AppLocalizations.of(context)!.discountApplied}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isValidatingCoupon
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        AppLocalizations.of(context)!.applyCoupon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(AppLocalizations.of(context)!.cash),
                onTap: () {
                  setState(() {
                    _updateTotalFare();
                    _paymentText = 'Cash';
                    widget.paymentText = 'Cash';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(AppLocalizations.of(context)!.payOnline),
                onTap: () {
                  setState(() {
                    _updateTotalFare();
                    _paymentText = 'Pay Online';
                    widget.paymentText = 'Pay Online';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var randomPrice = widget.estPrice;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.reviewBooking,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        body: Stack(children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            widget.vehicleImage,
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vehicleSelected,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const SizedBox(height: 20),
                                            Text(
                                                AppLocalizations.of(context)!
                                                    .addressDetails,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(Icons.local_shipping,
                                                    size: 40),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(widget.vehicleSelected,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                            _buildAddressTile(
                                                context,
                                                widget.pickupName,
                                                widget.pickupPhoneNumber,
                                                widget.pickupDescription,
                                                Icons.circle),
                                            if (widget.stop1.isNotEmpty)
                                              _buildAddressTile(
                                                  context,
                                                  widget.pickupName,
                                                  widget.pickupPhoneNumber,
                                                  widget.stop1,
                                                  Icons.location_on,
                                                  1),
                                            if (widget.stop2.isNotEmpty)
                                              _buildAddressTile(
                                                  context,
                                                  widget.pickupName,
                                                  widget.pickupPhoneNumber,
                                                  widget.stop2,
                                                  Icons.location_on,
                                                  2),
                                            if (widget.stop3.isNotEmpty)
                                              _buildAddressTile(
                                                  context,
                                                  widget.pickupName,
                                                  widget.pickupPhoneNumber,
                                                  widget.stop3,
                                                  Icons.location_on,
                                                  3),
                                            _buildAddressTile(
                                                context,
                                                widget.dropName,
                                                widget.dropPhoneNumber,
                                                widget.dropDescription,
                                                Icons.location_on_sharp),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .viewAddressDetails,
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.freeFifty,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(
                      top: 16.0, left: 16, right: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.offersAndDiscounts,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _showCouponModal,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.local_offer,
                            color: Colors.green,
                            size: 20,
                          ),
                          title: Text(
                            appliedCouponCode.isEmpty
                                ? AppLocalizations.of(context)!.applyCoupon
                                : 'Coupon: $appliedCouponCode',
                            style: TextStyle(
                              fontSize: 12,
                              color: appliedCouponCode.isEmpty
                                  ? Colors.black
                                  : Colors.green,
                              fontWeight: appliedCouponCode.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: appliedCouponCode.isNotEmpty
                              ? Text(
                            '${(appliedCouponDiscount * 100).toInt()}% discount applied',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                            ),
                          )
                              : null,
                          trailing: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 20,
                          ),
                          dense: true,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fareSummary,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.tripFare,
                              style: const TextStyle(fontSize: 12)),
                          Text('₹ $randomPrice',
                              style: const TextStyle(
                                  fontFamily: "Arial", fontSize: 13)),
                        ],
                      ),
                      // coupon
                      if (appliedCouponDiscount > 0) const SizedBox(height: 10),

                      if (appliedCouponDiscount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.coupon,
                                style: const TextStyle(fontSize: 12)),
                            Text(
                              '- ₹ ${(widget.estPrice * appliedCouponDiscount).toDouble().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontFamily: "Arial",
                                  fontSize: 13,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      if (_paymentText == "Pay Online")
                        const SizedBox(height: 10),
                      if (_paymentText == "Pay Online")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.wallet,
                                style: const TextStyle(fontSize: 12)),
                            Text(
                                '- ₹ ${walletAmount > widget.estPrice ? widget.estPrice.toString() : walletAmount.toString()}',
                                style: const TextStyle(
                                    fontFamily: "Arial",
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 222, 17, 3))),
                          ],
                        ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.netFare,
                              style: const TextStyle(fontSize: 12)),
                          Text('₹ ${totalFare.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontFamily: "Arial", fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.readBeforeYouBook,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.fareDetails,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 178, 178, 178), width: 0.3),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 16, right: 28, left: 28),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.choosePaymentMethod,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _showPaymentOptions,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color.fromARGB(255, 183, 183, 183),
                                    width: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    _paymentText == "Cash"
                                        ? Icons.payments_outlined
                                        : Icons.credit_card,
                                    color: Colors.green),
                                const SizedBox(width: 10),
                                Text(_paymentText,
                                    style:
                                    const TextStyle(color: Colors.black)),
                                const Icon(
                                  Icons.arrow_drop_up,
                                  size: 40,
                                  color: Color.fromARGB(255, 223, 191, 10),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${totalFare.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontFamily: "Arial",
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_paymentText == "Pay Online" && totalFare > 0) {
                              String? email = await getEmailFromLocal();
                              String? phoneNum =
                              await getPhoneNumberFromLocal();

                              Map<String, dynamic> orderData = {
                                'type': widget.type,
                                'email': email,
                                'phoneNum': phoneNum,
                                'pickupDescription': widget.pickupDescription,
                                'stop1': widget.stop1,
                                'stop2': widget.stop2,
                                'stop3': widget.stop3,
                                'dropDescription': widget.dropDescription,
                                'pickupName': widget.pickupName,
                                'pickupPhoneNumber': widget.pickupPhoneNumber,
                                'dropName': widget.dropName,
                                'dropPhoneNumber': widget.dropPhoneNumber,
                                'vehicleSelected': widget.vehicleSelected,
                                'rentalKmAndTime': widget.rentalKmAndTime,
                                'estPrice': appliedCouponDiscount > 0
                                    ? widget.estPrice -
                                    widget.estPrice * appliedCouponDiscount
                                    : widget.estPrice,
                                'topupAmount': totalFare,
                                'appliedCoupon': appliedCouponCode,
                                'couponDiscount': appliedCouponDiscount,
                              };

                              final Payment payment =
                              Payment(context, orderData, "online");

                              payment.initiatePayment(phoneNum, email);
                            }
                            if (_paymentText == "Cash" || totalFare < 1) {
                              String? email = await getEmailFromLocal();
                              String? phoneNum =
                              await getPhoneNumberFromLocal();

                              Map<String, dynamic> orderData = {
                                'type': widget.type,
                                'email': email,
                                'phoneNum': phoneNum,
                                'pickupDescription': widget.pickupDescription,
                                'stop1': widget.stop1,
                                'stop2': widget.stop2,
                                'stop3': widget.stop3,
                                'dropDescription': widget.dropDescription,
                                'pickupName': widget.pickupName,
                                'pickupPhoneNumber': widget.pickupPhoneNumber,
                                'dropName': widget.dropName,
                                'dropPhoneNumber': widget.dropPhoneNumber,
                                'vehicleSelected': widget.vehicleSelected,
                                'rentalKmAndTime': widget.rentalKmAndTime,
                                'estPrice': appliedCouponDiscount > 0
                                    ? widget.estPrice -
                                    widget.estPrice * appliedCouponDiscount
                                    : widget.estPrice,
                                'topupAmount': totalFare,
                                'appliedCoupon': appliedCouponCode,
                                'couponDiscount': appliedCouponDiscount,
                              };

                              // Add order
                              orderData['date'] = DateTime.now();
                              String randomString = generateRandomString(12);

                              orderData['paymentId'] = "Cash$randomString";
                              orderData['paymentStatus'] = 'Unpaid';
                              orderData['booking_status'] = 'Searching';

                              if (totalFare < 1) {
                                orderData['paymentId'] = "wallet$randomString";
                                orderData['paymentStatus'] = 'online';
                                orderData['booking_status'] = 'Searching';

                                // reduce the amount used from the wallet
                                var walletAmt = orderData['estPrice'] -
                                    orderData['topupAmount'];
                                double reduceWalletAmount =
                                    walletAmt - walletAmt * 2;
                                await _databaseService.topupWallet(
                                    orderData['email'],
                                    "userDetails",
                                    reduceWalletAmount);

                                if (_paymentText == "Cash" && totalFare >= 1) {
                                  // Record transaction for cash booking
                                  await recordBookingTransaction(
                                      orderData['email'],
                                      orderData['estPrice'].toDouble(),
                                      'cash',
                                      orderData['paymentId'],
                                      'pending');
                                }

                                if (totalFare < 1) {
                                  // Calculate the actual amount used from wallet
                                  double walletAmountUsed =
                                      walletAmt - walletAmt * 2;

                                  // Record wallet transaction with negative amount (deduction)
                                  await recordWalletTransaction(
                                      orderData['email'],
                                      walletAmountUsed.abs(),
                                      orderData['paymentId']);
                                }

                                if (_paymentText == "Pay Online" &&
                                    walletAmount > 0 &&
                                    walletAmount < widget.estPrice) {
                                  // Record wallet transaction for the portion paid by wallet
                                  await recordWalletTransaction(
                                      orderData['email'],
                                      walletAmount,
                                      orderData['paymentId']);
                                }
                              }

                              await _databaseService.addOrder(
                                  orderData, 'booking');

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const SearchingDriver()),
                                    (Route<dynamic> route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                            const Color.fromARGB(255, 255, 102, 0),
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
                          child: Text(AppLocalizations.of(context)!.bookNow,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ]));
  }
}

Widget _buildAddressTile(BuildContext context, String name, String phone,
    String address, IconData icon,
    [int? stopNumber]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 15),
            if (stopNumber != null)
              Text(
                stopNumber.toString(),
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(phone),
              Text(address),
            ],
          ),
        ),
      ],
    ),
  );
}

