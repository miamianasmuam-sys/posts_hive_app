# Posts App – Flutter & Hive

## Project Overview
Posts App is a Flutter application that displays posts from JSONPlaceholder API and uses Hive as a local database to store posts and favorite posts.

The application supports online data fetching and offline access using locally cached data.

## Features

- Fetch posts from JSONPlaceholder API.
- Store posts locally using Hive.
- Display cached posts when the API is unavailable.
- Add new posts manually.
- Delete posts.
- Add and remove favorite posts.
- Display favorite posts on a separate screen.
- Preserve posts and favorites after restarting the application.
- Refresh posts using the refresh button or pull-to-refresh.

## Technologies Used

- Flutter
- Dart
- Hive
- Hive Flutter
- HTTP
- JSONPlaceholder API

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── post_model.dart
│   └── post_model.g.dart
├── services/
│   └── post_service.dart
└── screens/
    ├── posts_screen.dart
    └── favorites_screen.dart
```

## API

The application uses:

https://jsonplaceholder.typicode.com/posts

## Local Storage

Hive is used for persistent local storage.

Two boxes are used:

- `postsBox`: Stores posts.
- `favoritesBox`: Stores favorite posts.

## How to Run

1. Install Flutter SDK.
2. Clone or download the project.
3. Open the project folder in VS Code.
4. Run:

```bash
flutter pub get
```

5. Generate Hive adapter files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

6. Run the application:

```bash
flutter run
```

## Offline Mode

When the API request fails, the application attempts to load previously cached posts from Hive.

If no cached posts are available, an error message is displayed.

## Screenshots

Add screenshots of the following:

1. Main Posts Screen.
2. Posts loaded from API.
3. Add Post dialog.
4. Post added successfully.
5. Favorite post selected.
6. Favorites Screen.
7. Favorite removed.
8. Application reopened with saved data.
9. Offline mode displaying cached posts.

## Author

Flutter Assignment – Posts App with Hive and Favorites.