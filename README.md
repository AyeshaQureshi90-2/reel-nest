## Project Information
Project:      ReelNest
Phase:        6,7 & 8
Organization: Genuisoft
Mentore:      Shahwar Khan
Submitted by: Ayesha 
Date:         25 Nov 2026

# reel_nest
1: Project Introduction
ReelNest is a Flutter-based movie discovery application that allows users to explore trending movies, search for entertainment content, view movie details and watch YouTube trailers.

2: Features
- Trending movies
- Indian and Pakistani movies
- Popular anime and cartoons
- Movie search functionality
- Movie details and descriptions
- YouTube trailer playback
- Add and remove favorite movies
- User profile and profile editing
- Light and Dark Mode
- About ReelNest and Help & Support
- Custom splash screen and app icon
2.1: phase 7&8
- User registration and login.
- Firebase email and password authentication.
- Forgot password functionality.
- Form validation.
- User-friendly error and success messages.
- Application theme management.
- Local settings storage
3: Technologies Used
- Flutter
- Dart
- TMDB API
- REST API
- JSON
3.1: phase 7&8
- Firebase
- Provider
4: Packages Used
- http
- shared_preferences
- image_picker
- path_provider
- youtube_player_flutter
- flutter_launcher_icons
- flutter_native_splash
4.1: phase 7&8
- provider
- firebase_core
- firebase_auth

5: Problems Faced and Solutions

1. API Integration and Data Handling
Problem: Fetching movie information from the TMDB API and displaying the received JSON data correctly.
Solution: Implemented HTTP requests, JSON parsing and model classes to organize and display movie information.

2. Favorites and Data Persistence
Problem: Favorite movies and user preferences needed to remain saved even after closing the application.
Solution: Used SharedPreferences to store and retrieve favorites, profile information and app settings locally.

3. App-wide Light and Dark Mode
Problem: Initially, changing the theme affected only the Settings screen, while other screens retained their dark colors.
Solution: Implemented a global theme controller and updated individual screens to use dynamic colors according to the selected theme.

4. Category Screen Compilation Issue
Problem: An unsupported contentTextStyle parameter caused a compilation error in the Category screen's SnackBar.
Solution: Removed the unsupported parameter and applied the text styling directly to the SnackBar's Text widget.

5. Launcher Icon Configuration
Problem: Installing the launcher icon package and adding the image to assets did not automatically change the application icon.
Solution: Added the correct flutter_launcher_icons configuration to pubspec.yaml and generated the Android launcher icons using the package command.

6. Duplicate Splash Screen Appearance
Problem: Android's native splash screen displayed separately before the application's custom Flutter splash screen.
Solution: Configured flutter_native_splash to customize the Android system splash screen and align its appearance with the application's splash d

5.1: phase 7&8
During the development of ReelNest, I faced several technical issues and resolved them through debugging and configuration changes.
Problem 1: Firebase Initialization Issue
Problem: The application faced an issue during Firebase initialization and could not start properly.
Solution: Checked Firebase configuration and corrected the Google Services Gradle plugin setup.
Problem 2: Firebase Android Configuration
Problem: Firebase was not connecting properly with the Android project.
Solution: Verified the google-services.json file and corrected the Gradle configuration.
Problem 3: Dart Compilation Error
Problem: A compilation error occurred because withValues() was used inside a const TextStyle.
Solution: Replaced the dynamic color expression with a fixed Color value.
Problem 4: Managing Application State and Theme
Problem: Application state and theme settings needed to be managed and preserved properly.
Solution: Applied state management concepts and used SharedPreferences to save simple application settings.
Problem 5: Form Validation
Problem: Authentication forms needed proper validation to prevent invalid user input.
Solution: Implemented form validation before submitting login, signup, and password reset requests.
Problem 6: Authentication Error Handling
Problem: Authentication failures needed to be communicated clearly to users.
Solution: Added error handling and user-friendly SnackBar messages for different authentication situations.
6: What I Learned
- Integrating REST APIs in Flutter.
- Fetching and handling JSON data.
- Managing local data with SharedPreferences.
- Implementing navigation between screens.
- Building search and favorites functionality.
- Implementing Light and Dark themes.
- Customizing app icons and splash screens.