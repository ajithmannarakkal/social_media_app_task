# Social Media App

A fully functional offline social media app built with Flutter, GetX, and Hive.

## Features Implemented

### 1. Feed Screen
- **Displays Posts**: Lists posts from local Hive storage.
- **Sorting**: Newest posts appear at the top.
- **Post Card**: Shows user avatar, timestamp (e.g., "Just now", "2m ago"), visibility icon, content, and media.
- **Interactions**:
    - **Like**: Toggles like status and count locally.
    - **Comment**: Opens a placeholder bottom sheet.

### 2. Create Post Screen
- **Input**: Multiline text field for "What's on your mind?".
- **Mentions & Hashtags**: Smart suggestions for `@users` and `#tags`.
- **Media Picker**: Select multiple images/videos from the gallery.
- **Media Preview**: Horizontal scrollable list of selected media with a remove button (X) for each.
- **Visibility**: Dropdown to select "Public", "Friends", or "Only Me".
- **Validation**: "Post" button is disabled if both text and media are empty.
- **Submission**: Saves post to Hive and refreshes the feed automatically.

### 3. Architecture & Tech Stack
- **State Management**: `GetX` (Controllers: `FeedController`, `CreatePostController`).
- **Local Storage**: `Hive` (Box: `posts`).
- **Navigation**: GetX named routes / simple navigation.
- **Model**: `PostModel` with Hive annotations.
- **Structure**:
    - `lib/models`: Data models.
    - `lib/views`: UI screens and widgets.
    - `lib/controllers`: Business logic.
    - `lib/services`: Storage handling.

## How to Run

1.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Generate Adapters**:
    ```bash
    flutter packages pub run build_runner build
    ```

3.  **Run App**:
    ```bash
    flutter run
    ```

## Development Highlights

- **Modern Theme**: Minimalist black/white aesthetic with electric blue accents.
- **Performance**: Optimized image loading with `cacheWidth`.
- **Robustness**: Proper state management handles edge cases (e.g., empty feeds, validation).

## Recent Improvements

### Feed Interactions
- **Share Button**: Removed from the post card as requested.
- **Delete Post**: Added a "Delete" option to the "More" menu on the post card.

### Text Highlighting
- **Implementation**: Custom `SocialTextEditingController`.
- **Features**: Automatically detects and colors mentions (`@username`) and hashtags (`#hashtag`) in blue while typing.

### Comment Flow
- **Behavior**: The bottom sheet automatically closes after a comment is successfully posted.
- **Constraint**: Limited the maximum height of the comment bottom sheet to 75% of the screen height.