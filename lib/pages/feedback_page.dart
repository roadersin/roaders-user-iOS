// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';
import '../services/read_local.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  String _selectedCategory = '';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasSubmitted = false;

  // List of feedback categories
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize categories with localized strings
    _categories = [
      AppLocalizations.of(context)?.appExperience ?? 'App Experience',
      AppLocalizations.of(context)?.earning ?? 'Earnings',
      AppLocalizations.of(context)?.customerSupport ?? 'Customer Support',
      AppLocalizations.of(context)?.orders ?? 'Orders',
      AppLocalizations.of(context)?.suggestions ?? 'Suggestions',
      AppLocalizations.of(context)?.other ?? 'Other',
    ];

    if (_selectedCategory.isEmpty && _categories.isNotEmpty) {
      _selectedCategory = _categories[0];
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)?.pleaseSelectRating ??
                'Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String? email = await getEmailFromLocal();
      if (email == null) {
        throw Exception('User email not found');
      }

      // First create a document reference to get the ID
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection('feedback').doc();

      // Get the ID that Firebase generated
      final String docId = docRef.id;

      // Create feedback document with the ID included
      final Map<String, dynamic> feedbackData = {
        'id': docId, // Store the document ID in the document itself
        'email': email,
        'rating': _rating,
        'category': _selectedCategory,
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'device_info': 'Roaders Users App',
      };

      // Use set() to write to the specific document with the ID we got
      await docRef.set(feedbackData);

      setState(() {
        _hasSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.feedbackSubmissionFailed ??
                'Failed to submit feedback. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)?.feedbackAndRating ??
              'Feedback & Ratings',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _hasSubmitted ? _buildThankYouContent() : _buildFeedbackForm(),
    );
  }

  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Text(
            AppLocalizations.of(context)?.howWasYourExperience ??
                'How was your experience with Roaders Partner?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Rating stars
          Center(
            child: _buildRatingStars(),
          ),

          const SizedBox(height: 32),

          // Category selector
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.whatFeebackAbout ??
                        'What is your feedback about?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategorySelector(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Feedback text field
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.additionalComments ??
                        'Additional Comments',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)?.shareYourExperience ??
                              'Share your experience or suggestions...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      AppLocalizations.of(context)?.submitFeedback ??
                          'Submit Feedback',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: index < _rating ? Colors.amber : Colors.grey,
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          selectedColor:
              const Color.fromARGB(255, 255, 102, 0).withOpacity(0.2),
          backgroundColor: Colors.grey.shade200,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategory = category;
              }
            });
          },
          labelStyle: TextStyle(
            color: isSelected
                ? const Color.fromARGB(255, 255, 102, 0)
                : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          avatar: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: Color.fromARGB(255, 255, 102, 0),
                  size: 18,
                )
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildThankYouContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.thankYouForFeedback ??
                  'Thank you for your feedback!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.feedbackHelpUsImprove ??
                  'Your feedback helps us improve our service for you and other partners.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 102, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.backToHome ?? 'Back to Home',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
