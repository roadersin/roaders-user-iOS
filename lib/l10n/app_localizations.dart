import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// This is the name of the app
  ///
  /// In en, this message translates to:
  /// **'Roaders'**
  String get appName;

  /// This is the label for the language selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Select your Language'**
  String get selectLanguage;

  /// This is the welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// This is the tagline of the app
  ///
  /// In en, this message translates to:
  /// **'Speedy Delivery, Your Route to Convenience'**
  String get tagLine;

  /// This is the label for the phone number input field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// This is the hint text for the phone number input field
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneHint;

  /// This is the error message when the phone number is required
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// This is the error message when the phone number is invalid
  ///
  /// In en, this message translates to:
  /// **'Phone Number should be 10 digits'**
  String get phoneInvalid;

  /// This is the label for the email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// This is the hint text for the email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// This is the error message when the email is required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// This is the error message when the email is invalid
  ///
  /// In en, this message translates to:
  /// **'Email is invalid'**
  String get emailInvalid;

  /// This is the button text to request OTP
  ///
  /// In en, this message translates to:
  /// **'Request OTP'**
  String get requestOtp;

  /// This is the message to enter details
  ///
  /// In en, this message translates to:
  /// **'Please Enter your details below'**
  String get enterDetails;

  /// This is the hint text for the name input field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// This is the error message when the name is required
  ///
  /// In en, this message translates to:
  /// **'Name is required for '**
  String get nameRequired;

  /// This is the button text to contact support
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// This is the label for the account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// This is the greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// This is Edit Profile label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// This is the label for the help and support section
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// This is the label for the terms and conditions section
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Title for the user eligibility section in the terms
  ///
  /// In en, this message translates to:
  /// **'1. User Eligibility'**
  String get userEligibility;

  /// Details regarding user eligibility requirements
  ///
  /// In en, this message translates to:
  /// **'1.1. You must be at least 18 years old to use the App.\n1.2. By using the App, you represent and warrant that you have the legal right, authority, and capacity to enter into these Terms and comply with all applicable laws and regulations.'**
  String get userEligibilityDetails;

  /// Title for the account registration section in the terms
  ///
  /// In en, this message translates to:
  /// **'2. Account Registration'**
  String get accountRegistration;

  /// Details about the account registration process
  ///
  /// In en, this message translates to:
  /// **'2.1. To use the App, you must register and create an account.\n2.2. You agree to provide accurate, current, and complete information during the registration process.\n2.3. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.\n2.4. You agree to notify us immediately of any unauthorized use of your account.'**
  String get accountRegistrationDetails;

  /// Title for the services provided section in the terms
  ///
  /// In en, this message translates to:
  /// **'3. Services Provided'**
  String get servicesProvided;

  /// Details regarding the services provided by Roaders
  ///
  /// In en, this message translates to:
  /// **'3.1. Roaders connects users (\"Customers\") with drivers (\"Partners\") for the transportation of goods.\n3.2. We are a platform that facilitates the connection between Customers and Partners; we do not own or operate the vehicles.\n3.3. Services provided by Partners are subject to availability and may vary based on location, vehicle type, and other factors.'**
  String get servicesProvidedDetails;

  /// Title for the booking and payment section in the terms
  ///
  /// In en, this message translates to:
  /// **'4. Booking and Payment'**
  String get bookingAndPayment;

  /// Details regarding booking and payment procedures
  ///
  /// In en, this message translates to:
  /// **'4.1. Customers can book transportation services through the App by providing necessary details, including pickup and drop-off locations, type of goods, and preferred vehicle type.\n4.2. The cost of the service will be calculated based on distance, time, and vehicle type.\n4.3. Customers must pay for the services through the payment methods available in the App.\n4.4. Payments are non-refundable, except as specified in our Cancellation Policy.'**
  String get bookingAndPaymentDetails;

  /// Title for the cancellation policy section in the terms
  ///
  /// In en, this message translates to:
  /// **'5. Cancellation Policy'**
  String get cancellationPolicy;

  /// Details of the cancellation policy
  ///
  /// In en, this message translates to:
  /// **'5.1. Customers may cancel their booking before a Partner is assigned without incurring any charges.\n5.2. If a booking is canceled after a Partner has been assigned, a cancellation fee may apply.\n5.3. Partners have the right to cancel bookings under certain circumstances, such as vehicle unavailability, unsafe conditions, or other unforeseen issues.'**
  String get cancellationPolicyDetails;

  /// Title for the user responsibilities section in the terms
  ///
  /// In en, this message translates to:
  /// **'6. User Responsibilities'**
  String get userResponsibilities;

  /// Details regarding user responsibilities
  ///
  /// In en, this message translates to:
  /// **'6.1. Customers are responsible for ensuring that all goods being transported comply with local laws and regulations.\n6.2. Customers must ensure that goods are properly packaged and do not pose a risk to the vehicle, Partner, or public safety.\n6.3. Partners must provide safe and reliable transportation services and comply with all applicable traffic laws and regulations.\n6.4. Both Customers and Partners must treat each other with respect and courtesy.'**
  String get userResponsibilitiesDetails;

  /// Title for the prohibited activities section in the terms
  ///
  /// In en, this message translates to:
  /// **'7. Prohibited Activities'**
  String get prohibitedActivities;

  /// Details regarding prohibited activities
  ///
  /// In en, this message translates to:
  /// **'7.1. You may not use the App for any illegal or unauthorized purpose.\n7.2. You may not interfere with or disrupt the operation of the App or its servers.\n7.3. You may not engage in any activity that harms or threatens the safety of other users or the public.'**
  String get prohibitedActivitiesDetails;

  /// Title for the limitation of liability section in the terms
  ///
  /// In en, this message translates to:
  /// **'8. Limitation of Liability'**
  String get limitationOfLiability;

  /// Details regarding the limitation of liability
  ///
  /// In en, this message translates to:
  /// **'8.1. Roaders is not responsible for any damage, loss, or theft of goods during transportation.\n8.2. Roaders is not liable for any injuries, accidents, or damages that occur during the provision of services by Partners.\n8.3. Roaders does not guarantee the availability, quality, or timeliness of services provided by Partners.'**
  String get limitationOfLiabilityDetails;

  /// Title for the indemnification section in the terms
  ///
  /// In en, this message translates to:
  /// **'9. Indemnification'**
  String get indemnification;

  /// Details of the indemnification clause
  ///
  /// In en, this message translates to:
  /// **'9.1. You agree to indemnify and hold Roaders, its affiliates, and their respective officers, directors, employees, and agents harmless from any claims, losses, damages, liabilities, and expenses arising out of your use of the App, violation of these Terms, or infringement of any rights of third parties.'**
  String get indemnificationDetails;

  /// Title for the intellectual property section in the terms
  ///
  /// In en, this message translates to:
  /// **'10. Intellectual Property'**
  String get intellectualProperty;

  /// Details regarding intellectual property rights
  ///
  /// In en, this message translates to:
  /// **'10.1. All content and materials in the App, including text, graphics, logos, and software, are the property of Roaders or its licensors and are protected by intellectual property laws.\n10.2. You may not use, reproduce, distribute, or create derivative works based on the App\'s content without our prior written consent.'**
  String get intellectualPropertyDetails;

  /// Title for the termination section in the terms
  ///
  /// In en, this message translates to:
  /// **'11. Termination'**
  String get termination;

  /// Details regarding termination of the agreement
  ///
  /// In en, this message translates to:
  /// **'11.1. We reserve the right to suspend or terminate your account and access to the App at any time, with or without cause or notice.\n11.2. You may terminate your account at any time by following the account deletion procedures in the App.'**
  String get terminationDetails;

  /// Title for the modifications section in the terms
  ///
  /// In en, this message translates to:
  /// **'12. Modifications to the Terms'**
  String get modificationsToTheTerms;

  /// Details about how the terms can be modified
  ///
  /// In en, this message translates to:
  /// **'12.1. We may update these Terms from time to time. Any changes will be effective upon posting the revised Terms in the App.\n12.2. Your continued use of the App after the effective date of the revised Terms constitutes your acceptance of the changes.'**
  String get modificationsToTheTermsDetails;

  /// Title for the governing law section in the terms
  ///
  /// In en, this message translates to:
  /// **'13. Governing Law'**
  String get governingLaw;

  /// Details about the governing law of the agreement
  ///
  /// In en, this message translates to:
  /// **'13.1. These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of laws principles.'**
  String get governingLawDetails;

  /// Title for the dispute resolution section in the terms
  ///
  /// In en, this message translates to:
  /// **'14. Dispute Resolution'**
  String get disputeResolution;

  /// Details regarding dispute resolution process
  ///
  /// In en, this message translates to:
  /// **'14.1. Any disputes arising out of or in connection with these Terms or your use of the App shall be resolved through binding arbitration in accordance with the rules of the Arbitration and Conciliation Act, 1996.\n14.2. The arbitration shall take place in Mumbai, India, and the language of arbitration shall be English.'**
  String get disputeResolutionDetails;

  /// Title for the contact information section in the terms
  ///
  /// In en, this message translates to:
  /// **'15. Contact Information'**
  String get contactInformation;

  /// Details of how to contact Roaders for any concerns
  ///
  /// In en, this message translates to:
  /// **'15.1. If you have any questions or concerns about these Terms, please contact us at:\nEmail: help.roaders.in@gmail.com\nPhone: +91 99693 93190\nAddress: Mumbai, India'**
  String get contactInformationDetails;

  /// This is the label for the account settings section
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// This is the button text to log out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// This is the label for the final step
  ///
  /// In en, this message translates to:
  /// **'Final Step'**
  String get finalStep;

  /// This is the label for the name input field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// This is the label for the address input field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// This is the error message when all fields are required
  ///
  /// In en, this message translates to:
  /// **'Please fill all the fields'**
  String get allFieldsRequired;

  /// This is the button text to submit the form
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// This is the button text to apply a coupon
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// This is the message when there are no applicable coupons
  ///
  /// In en, this message translates to:
  /// **'No applicable coupons'**
  String get noApplicableCoupons;

  /// This is the message for discount on first order
  ///
  /// In en, this message translates to:
  /// **'Discount on first order'**
  String get discountOnFirstOrder;

  /// This is the message for discount on 10 orders
  ///
  /// In en, this message translates to:
  /// **'Discount on 10th orders'**
  String get discountOnTenthOrder;

  /// This is the label for the booking receipt
  ///
  /// In en, this message translates to:
  /// **'Booking Receipt'**
  String get bookingReceipt;

  /// This is the message when the profile is updated successfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// This is the button text to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// This is the label for the pickup location
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// This is the hint text for the pickup location search
  ///
  /// In en, this message translates to:
  /// **'Search Pickup Location...'**
  String get searchPickup;

  /// This is the button text to book now
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// This is the label for the offer section
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// This is the label for the home section
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// This is the label for the wallet section
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// This is the label for the orders section
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// This is the label for the profile section
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// This is the label for the location section
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// This is the button text to set the location
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setS;

  /// This is the button text to set as
  ///
  /// In en, this message translates to:
  /// **'Set as'**
  String get setAs;

  /// This is the message for goods delivery location
  ///
  /// In en, this message translates to:
  /// **'Your goods will be delivered here'**
  String get goodsDelivered;

  /// This is the button text to continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueS;

  /// This is the message when no orders are found
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrders;

  /// This is the label for the stop section
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// This is the button text to view booking details
  ///
  /// In en, this message translates to:
  /// **'View Booking'**
  String get viewBooking;

  /// This is the label for the OTP input field
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// This is the message indicating that an OTP has been sent
  ///
  /// In en, this message translates to:
  /// **'We have sent you an OTP to your email'**
  String get weHaveSent;

  /// This is the button text to verify the OTP
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// This is the message when the payment is successful
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccess;

  /// This is the message when the wallet top-up is successful
  ///
  /// In en, this message translates to:
  /// **'Wallet Top-up Successful'**
  String get walletTopupSuccess;

  /// This is the message when an external wallet is selected
  ///
  /// In en, this message translates to:
  /// **'External Wallet Selected'**
  String get externalWallet;

  /// This is the message when the payment fails
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// This is the label for cash payment option
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// This is the label for online payment option
  ///
  /// In en, this message translates to:
  /// **'Pay Online'**
  String get payOnline;

  /// This is the label for the review booking section
  ///
  /// In en, this message translates to:
  /// **'Review Booking'**
  String get reviewBooking;

  /// This is the label for the address details section
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// This is the button text to view address details
  ///
  /// In en, this message translates to:
  /// **'View Address Details'**
  String get viewAddressDetails;

  /// This is the message for free loading and unloading time
  ///
  /// In en, this message translates to:
  /// **'Free 50 mins loading unloading time'**
  String get freeFifty;

  /// This is the label for offers and discounts section
  ///
  /// In en, this message translates to:
  /// **'Offers and Discounts'**
  String get offersAndDiscounts;

  /// This is the label for the coupon section
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get coupon;

  /// This is the label for the fare summary section
  ///
  /// In en, this message translates to:
  /// **'Fare Summary'**
  String get fareSummary;

  /// This is the label for the trip fare section
  ///
  /// In en, this message translates to:
  /// **'Trip Fare (incl. Toll)'**
  String get tripFare;

  /// This is the label for the net fare section
  ///
  /// In en, this message translates to:
  /// **'Net Fare'**
  String get netFare;

  /// This is the label for the read before you book section
  ///
  /// In en, this message translates to:
  /// **'Read Before You Book'**
  String get readBeforeYouBook;

  /// This is the detailed breakdown of the fare, including the loading/unloading time, charges, and other conditions.
  ///
  /// In en, this message translates to:
  /// **'• Fare doesn\'t include labour charges for loading & unloading.\n• Fare includes 50 mins free loading/unloading time.\n• ₹3.0/min for additional loading/unloading time.\n• Fare may change if route or location changes.\n• Parking charges to be paid by customer.\n• Fare includes toll and permit charges, if any.\n• We don\'t allow overloading.'**
  String get fareDetails;

  /// This is the label for the choose payment method section
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// This is the hint text for the place search
  ///
  /// In en, this message translates to:
  /// **'Search Place...'**
  String get searchPlace;

  /// This is the label for success messages
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// This is the message when a driver is found
  ///
  /// In en, this message translates to:
  /// **'Driver Found!'**
  String get driverFound;

  /// This is the button text for OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// This is the message when the trip is cancelled
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled'**
  String get tripCancelled;

  /// This is the message when searching for a driver
  ///
  /// In en, this message translates to:
  /// **'Searching for Driver...'**
  String get searchingDriver;

  /// This is the message when the trip is cancelled by the user
  ///
  /// In en, this message translates to:
  /// **'Trip was cancelled by you'**
  String get tripWasCancelledByYou;

  /// This is the button text to cancel the trip
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTrip;

  /// This is the button text to proceed
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// This is the label for the select vehicle section
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// This is the message for maximum distance
  ///
  /// In en, this message translates to:
  /// **'Maximum distance 250Km. Try Outstation'**
  String get maximumDistance;

  /// This is the label for the pickup location
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// This is the button text to add multiple stops
  ///
  /// In en, this message translates to:
  /// **'Add Multiple Stops +'**
  String get addMutlipleStops;

  /// This is the label for the drop location
  ///
  /// In en, this message translates to:
  /// **'Drop Location'**
  String get dropLocation;

  /// This is the hint text for the drop location search
  ///
  /// In en, this message translates to:
  /// **'Search Drop Location...'**
  String get searchDropLocation;

  /// This is the message when the pickup location is not set
  ///
  /// In en, this message translates to:
  /// **'Pickup location not set'**
  String get pickupLocationNotSet;

  /// This is the message when the drop location is not set
  ///
  /// In en, this message translates to:
  /// **'Drop location not set'**
  String get dropLocationNotSet;

  /// This is the button text to get the price
  ///
  /// In en, this message translates to:
  /// **'Get Price'**
  String get getPrice;

  /// This is the label for the current wallet balance
  ///
  /// In en, this message translates to:
  /// **'Current Wallet Balance'**
  String get currentWalletBalance;

  /// This is the label for the enter top-up amount section
  ///
  /// In en, this message translates to:
  /// **'Enter Top-up Amount'**
  String get enterTopUpAmount;

  /// This is the label for re-entering the top-up amount
  ///
  /// In en, this message translates to:
  /// **'Please Re-enter Top-up Amount'**
  String get reenterTopUpAmount;

  /// This is the error message when the entered number is not greater than zero
  ///
  /// In en, this message translates to:
  /// **'Please enter a number greater than 0'**
  String get enterNumberGreaterThanZero;

  /// This is the button text to top-up the wallet
  ///
  /// In en, this message translates to:
  /// **'Top-up Wallet'**
  String get topUpWallet;

  /// This is the button text to change the language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// This is the label for transaction history
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// This is the label for all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// This is the label for top up
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// This is the label for commission
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// This is the label for earning
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earning;

  /// This is the message when no transaction found
  ///
  /// In en, this message translates to:
  /// **'No Transaction Found'**
  String get noTransactionFound;

  /// This is the label for failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// This is the label for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// This is the label for none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// This is the label for day
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// This is the label for week
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// This is the label for month
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// This is the label for summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// This is the label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// This is the label for this week
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// This is the label for this month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This is the label for this year
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// This is the label for received
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// This is the label for sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// This is the label for net
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// This is the label for transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// This is the label for app experience
  ///
  /// In en, this message translates to:
  /// **'App Experience'**
  String get appExperience;

  /// This is the label for suggestions
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// This is the label for other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// This is the message for please select rating
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// This is the message for feedback submission failed
  ///
  /// In en, this message translates to:
  /// **'Feedback submission failed, please try again'**
  String get feedbackSubmissionFailed;

  /// This is the label for feedback and rating
  ///
  /// In en, this message translates to:
  /// **'Feedback and Rating'**
  String get feedbackAndRating;

  /// This is the label for how was your experience
  ///
  /// In en, this message translates to:
  /// **'How was your experience with Roaders Partner App?'**
  String get howWasYourExperience;

  /// This is the label for what feedback do you have
  ///
  /// In en, this message translates to:
  /// **'What is your feedback about?'**
  String get whatFeebackAbout;

  /// This is the label for additional comments
  ///
  /// In en, this message translates to:
  /// **'Additional Comments'**
  String get additionalComments;

  /// This is the label for share your experience
  ///
  /// In en, this message translates to:
  /// **'Share your experience or suggestions...'**
  String get shareYourExperience;

  /// This is the button text to submit feedback
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// This is the message for thank you for feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// This is the message for feedback helps us improve
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve our services.'**
  String get feedbackHelpUsImprove;

  /// This is the button text to go back to home
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// This is the message for wallet top-up successful
  ///
  /// In en, this message translates to:
  /// **'Wallet Top-up Successful'**
  String get walletTopUpSuccessful;

  /// This is the button text to try again
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// This is the button text to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// This is the message for external wallet selected
  ///
  /// In en, this message translates to:
  /// **'External Wallet Selected'**
  String get externalWalletSelected;

  /// This is the label for booking
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// This is the label for payment
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// This is the hint text for the transaction search
  ///
  /// In en, this message translates to:
  /// **'Search Transactions...'**
  String get searchTransaction;

  /// This is the label for group by
  ///
  /// In en, this message translates to:
  /// **'Group By'**
  String get groupBy;

  /// This is the label for added
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// This is the label for balance
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// This is the label for payment method
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// This is the label for history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// This is the label for refund
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// This is the label for customer support
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupport;

  /// This is the label for searching
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searching;

  /// This is the message when a driver is assigned
  ///
  /// In en, this message translates to:
  /// **'Driver Assigned'**
  String get driverAssigned;

  /// This is the message when the trip is started
  ///
  /// In en, this message translates to:
  /// **'Trip Started'**
  String get tripStarted;

  /// This is the message when the trip is ended
  ///
  /// In en, this message translates to:
  /// **'Trip Ended'**
  String get tripEnded;

  /// This is the message when the driver has reached the pickup location
  ///
  /// In en, this message translates to:
  /// **'Reached Pickup Location'**
  String get reachedPickupLocation;

  /// This is the message when the driver has reached the drop location
  ///
  /// In en, this message translates to:
  /// **'Reached Drop Location'**
  String get reachedDropLocation;

  /// This is the label for order status
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// This is the button text to track the order
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// This is the label for current status
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// This is the button text to close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// This is the message when the order is cancelled
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// This is the message for order cancelled
  ///
  /// In en, this message translates to:
  /// **'This order has been cancelled and is no longer active.'**
  String get orderCancelledMsg;

  /// This is the hint text for the order search
  ///
  /// In en, this message translates to:
  /// **'Search Orders...'**
  String get searchOrders;

  /// This is the label for filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// This is the button text to reset filters
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// This is the label for status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// This is the label for date range
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// This is the label for selected dates
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get selectedDates;

  /// This is the label for price range
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// This is the label for assigned
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// This is the label for at pickup
  ///
  /// In en, this message translates to:
  /// **'At Pickup'**
  String get atPickup;

  /// This is the label for at drop
  ///
  /// In en, this message translates to:
  /// **'At Drop'**
  String get atDrop;

  /// This is the label for started
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// This is the label for ended
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// This is the label for cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// This is the message when no orders are found
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any bookings yet'**
  String get noOrdersDescription;

  /// This is the message when no matching orders are found
  ///
  /// In en, this message translates to:
  /// **'No matching orders found'**
  String get noMatchingOrders;

  /// This is the message for trying to adjust filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// This is the button text to refresh
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// This is the message when there is no internet connection
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// This is the message for checking internet connection
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get pleaseCheckConnection;

  /// This is the message for no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetMessage;

  /// This is the button text to retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// This is the message when the driver has reached a stop
  ///
  /// In en, this message translates to:
  /// **'Reached Stop 1'**
  String get reachedStop1;

  /// This is the message when the driver has reached a stop
  ///
  /// In en, this message translates to:
  /// **'Reached Stop 2'**
  String get reachedStop2;

  /// This is the message when the driver has reached a stop
  ///
  /// In en, this message translates to:
  /// **'Reached Stop 3'**
  String get reachedStop3;

  /// This is about delete account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// This is the label for order
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// This is the label for order type
  ///
  /// In en, this message translates to:
  /// **'Order Type'**
  String get orderType;

  /// This is the label for vehicle type
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// This is the label for estimated time
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get estimatedTime;

  /// This is the label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// This is the label for time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// This is the label for driver information
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driverInformation;

  /// This is the label for driver name
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverName;

  /// This is the label for driver contact
  ///
  /// In en, this message translates to:
  /// **'Driver Contact'**
  String get driverContact;

  /// This is the label for vehicle number
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// This is the button text to call the driver
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// This is the button text to remove an item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// This is the label for entering a coupon code
  ///
  /// In en, this message translates to:
  /// **'Enter Coupon Code'**
  String get enterCouponCode;

  /// This is the message when no coupon code is entered
  ///
  /// In en, this message translates to:
  /// **'Please enter a coupon code'**
  String get pleaseEnterACouponCode;

  /// This is the message when a discount is applied
  ///
  /// In en, this message translates to:
  /// **'Discount Applied'**
  String get discountApplied;

  /// This is the message when less than 3 characters are entered in search
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 3 characters to search'**
  String get enterThreeCharacters;

  /// This is the message for goods pickup location
  ///
  /// In en, this message translates to:
  /// **'Your goods will be picked up from here'**
  String get goodsPickup;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'gu',
    'hi',
    'kn',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
