// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart' show AppLocalizations;
import '../../widgets/language_picker_widget.dart';

Column LoginHeaderWidget(Size size, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isSmallScreen = availableWidth < 360;
          final isVerySmallScreen = availableWidth < 280;

          // Adjust text size based on available width
          final fontSize = isSmallScreen ? 16.0 : 18.0;

          // For very small screens, use a column layout
          if (isVerySmallScreen) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12), // Space between text and picker
                const LanguagePickerWidget(),
              ],
            );
          }

          // For normal and small screens, use the row layout with adjusted spacing
          return Row(
            mainAxisAlignment: isSmallScreen
                ? MainAxisAlignment
                    .spaceBetween // Better spacing on small screens
                : MainAxisAlignment.spaceEvenly,
            children: [
              // Use Flexible to allow text to shrink if needed
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.selectLanguage,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Space between elements
              SizedBox(width: isSmallScreen ? 8 : 16),
              // The language picker widget
              const LanguagePickerWidget(),
            ],
          );
        },
      ),
      Align(
        alignment: Alignment.center,
        child: Image(
          image: const AssetImage('assets/img/6209999.jpg'),
          height: size.height * 0.3,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        AppLocalizations.of(context)!.welcome,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        AppLocalizations.of(context)!.tagLine,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    ],
  );
}
