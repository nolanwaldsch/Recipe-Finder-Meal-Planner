# Recipe Finder & Meal Planner

A Flutter application for discovering recipes, managing ingredients, and tracking daily calorie intake — powered by the Spoonacular API and Firebase.

## Features

- **Recipe Search** — Search by name or filter by ingredients using the Spoonacular API
- **Ingredients Manager** — Build and manage a personal ingredient list for recipe filtering
- **Calorie Tracker** — Log meals (Breakfast, Lunch, Dinner, Snack) and track daily calorie totals

## Color Palette

| Role       | Color         | Hex       |
|------------|---------------|-----------|
| Primary    | Deep Blue     | `#1E3A5F` |
| Secondary  | Cool Gray     | `#90A4AE` |
| Accent     | Teal          | `#26A69A` |
| Background | Light Gray    | `#F5F7FA` |
| Text       | Near-Black    | `#1C1C1C` |

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.9.2 or later**
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- A [Spoonacular API key](https://spoonacular.com/food-api) (free tier available)
- [Firebase CLI](https://firebase.google.com/docs/cli) (only needed if reconfiguring Firebase)
- For iOS/macOS: Xcode and [CocoaPods](https://cocoapods.org/)
- For Android: Android Studio and a connected device or emulator

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/Recipe-Finder-Meal-Planner.git
cd Recipe-Finder-Meal-Planner/recipe_finder_meal_plan
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add your Spoonacular API key

Open [lib/spoonacular/spoonacular_config.dart](lib/spoonacular/spoonacular_config.dart) and replace the placeholder with your own key:

```dart
const String spoonacularApiKey = 'YOUR_API_KEY_HERE';
```

Get a free key at [spoonacular.com/food-api](https://spoonacular.com/food-api).

### 4. Firebase setup

Firebase is already configured for this project. The required files are included:

- **Android**: `android/app/google-services.json`
- **iOS / macOS**: `ios/Runner/GoogleService-Info.plist` / `macos/Runner/GoogleService-Info.plist`
- **Web / Windows**: configuration is handled in `lib/firebase_options.dart`

No additional Firebase setup is needed unless you want to connect your own Firebase project.

### 5. iOS / macOS — install CocoaPods dependencies

```bash
cd ios && pod install && cd ..
# or for macOS:
cd macos && pod install && cd ..
```

---

## Running the App

```bash
# Run on a connected device or emulator
flutter run

# Run on a specific platform
flutter run -d chrome       # Web
flutter run -d macos        # macOS desktop
flutter run -d android      # Android
flutter run -d ios          # iOS (requires Xcode)
```

---

## Building for Release

```bash
# Web (output in build/web/)
flutter build web

# Android APK
flutter build apk --release

# iOS (requires Xcode signing)
flutter build ios --release

# macOS
flutter build macos --release
```

---

## Running Tests

```bash
flutter test
```

---

## Project Structure

```text
lib/
├── main.dart                  # App entry point and Firebase init
├── firebase_options.dart      # Firebase platform configuration
├── spoonacular/
│   ├── spoonacular_api.dart   # Spoonacular API calls
│   ├── spoonacular_config.dart # API key configuration
│   └── recipe_summary.dart    # Recipe data model
├── ingredients/
│   ├── ingredients_page.dart  # Ingredients UI
│   └── ingredients_repository.dart
└── calorie_tracker/
    └── calorie_tracker_page.dart
```

---

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Spoonacular API docs](https://spoonacular.com/food-api/docs)
- [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)
