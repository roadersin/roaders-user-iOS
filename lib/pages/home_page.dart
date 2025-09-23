import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/offer.dart';
import '../l10n/app_localizations.dart';
import '../widgets/offercard_widget.dart';
import 'account_page.dart';
import 'orders_page.dart';
import 'search_location.dart';
import 'transaction_history_page.dart';
import 'wallet_page.dart';

// Service class for fetching offers from Firestore
class OffersService {
  static Future<List<Offer>> fetchOffers() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('coupons').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Offer(
          code: data['name'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching offers: $e');
      return [];
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<Offer>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = OffersService.fetchOffers();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
      // Home page
        break;
      case 1:
      // Wallet page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletPage()),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2:
      // Orders page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrdersPage()),
        );
        setState(() {
          _selectedIndex = 0;
        });
        break;

      case 3:
      // Profile page
      // Implement navigation to profile page if needed
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TransactionHistoryPage()),
        );

        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 4:
      // Profile page
      // Implement navigation to profile page if needed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );

        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
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

  Widget _buildOffersSection() {
    return FutureBuilder<List<Offer>>(
      future: _offersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Error loading offers'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _offersFuture = OffersService.fetchOffers();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final offers = snapshot.data!;
          if (offers.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (offers.length / 2).ceil(),
              itemBuilder: (context, index) {
                final left = offers[index * 2];
                final right = (index * 2 + 1 < offers.length)
                    ? offers[index * 2 + 1]
                    : null;
                return OfferCard(
                  leftOffer: left,
                  rightOffer: right, // Pass null instead of empty Offer
                );
              },
            );
          } else {
            return const Center(child: Text('No offers available'));
          }
        } else {
          return const Center(child: Text('No offers available'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(16.0), // Margin around the entire Column
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.pickup,
                    style: const TextStyle(
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchLocation(
                          type: "fixed",
                          pageFor: "Pickup",
                          pickupDescription: "",
                          stop1: "",
                          stop2: "",
                          stop3: "",
                          dropDescription: "",
                          pickupName: "",
                          pickupPhoneNumber: "",
                          dropName: "",
                          dropPhoneNumber: "",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.searchPickup,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.search,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.bookNow,
                    style: const TextStyle(
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // First image, full width, height auto
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchLocation(
                          type: "fixed",
                          pageFor: "Pickup",
                          pickupDescription: "",
                          stop1: "",
                          stop2: "",
                          stop3: "",
                          dropDescription: "",
                          pickupName: "",
                          pickupPhoneNumber: "",
                          dropName: "",
                          dropPhoneNumber: "",
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12.0), // Margin below the first image
                    child: Image.asset(
                      'assets/img/1.png', // Local image
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                // Second and third images side by side with margin between them
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right:
                            6.0), // Margin to the right of the first image
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchLocation(
                                  type: "rental",
                                  pageFor: "Pickup",
                                  pickupDescription: "",
                                  stop1: "",
                                  stop2: "",
                                  stop3: "",
                                  dropDescription: "",
                                  pickupName: "",
                                  pickupPhoneNumber: "",
                                  dropName: "",
                                  dropPhoneNumber: "",
                                ),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/img/2.png', // Local image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left:
                            6.0), // Margin to the left of the second image
                        child: GestureDetector(
                          onTap: () {
                            _showContactModal(context);
                          },
                          child: Image.asset(
                            'assets/img/3.png', // Local image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.offer,
                    style: const TextStyle(
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Replace the hardcoded offers section with database integration
                _buildOffersSection(),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[100],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon:
            const Icon(Icons.home_rounded, size: 20), // Set icon size to 20
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.wallet, size: 20), // Set icon size to 20
            label: AppLocalizations.of(context)!.wallet,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.delivery_dining_rounded,
                size: 20), // Set icon size to 20
            label: AppLocalizations.of(context)!.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_rounded,
                size: 20), // Set icon size to 20
            label: AppLocalizations.of(context)!.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_2_rounded,
                size: 20), // Set icon size to 20
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Labels are always visible
        onTap: _onItemTapped,
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ), // Set font size to 12 for unselected items
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
        ), // Set font size to 12 for selected items
      ),
    );
  }
}
