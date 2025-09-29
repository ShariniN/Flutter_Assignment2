import 'package:flutter/material.dart';
import '/models/onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    
    final containerSize = isLandscape 
        ? (screenHeight * 0.25).clamp(100.0, 150.0) 
        : (screenHeight * 0.25).clamp(150.0, 200.0);
    
    final horizontalPadding = isLandscape ? 20.0 : 40.0;
    final verticalPadding = isLandscape ? 10.0 : 40.0;
    final iconSize = isLandscape ? 50.0 : 80.0;
    final titleSize = isLandscape ? 22.0 : 28.0;
    final descriptionSize = isLandscape ? 14.0 : 16.0;
    final spacingAfterIcon = isLandscape ? 20.0 : 50.0;
    final spacingAfterTitle = isLandscape ? 10.0 : 20.0;
    
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: mediaQuery.size.height - 
                       (mediaQuery.padding.top + mediaQuery.padding.bottom + 200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: containerSize,
                width: containerSize,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(containerSize / 2),
                ),
                child: Center(
                  child: Text(
                    item.image,
                    style: TextStyle(fontSize: iconSize),
                  ),
                ),
              ),
              SizedBox(height: spacingAfterIcon),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacingAfterTitle),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: descriptionSize,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: isLandscape ? 3 : null,
                overflow: isLandscape ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}