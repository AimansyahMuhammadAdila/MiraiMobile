import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mirai_mobile/providers/theme_provider.dart';
import 'package:mirai_mobile/utils/constants.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: themeProvider.isDarkMode
            ? AppConstants.textLight
            : AppConstants.primaryPurple,
      ),
      tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
