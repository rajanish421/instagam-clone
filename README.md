# instagram_clone

A new Flutter project.

## Instagram Clone — Flutter + Firebase

A full-featured, production-style Instagram clone built with **Flutter** and **Firebase**. Implements the core social media experience: photo sharing, real-time likes and comments, follow/unfollow, user profiles, and a direct-messaging system — all backed by a real-time NoSQL cloud database.

---

## Screenshots

> Run the app locally (see [Installation](#installation)) and capture screenshots from an emulator or physical device. Suggested captures:

| Screen | Description |
|--------|-------------|
| `Login Screen` | Email/password login with Instagram SVG logo |
| `Sign-Up Screen` | Profile photo picker + username / email / bio form |
| `Feed Screen` | Real-time scrollable post feed with like/comment actions |
| `Post Creation Screen` | Camera or gallery picker + caption input |
| `Search Screen` | User search by username + photo grid of all posts |
| `Profile Screen` | Avatar, post count, followers/following, post grid, follow button |
| `Comment Screen` | Real-time comment thread per post |
| `Messages Screen` | Conversation list with last-message preview |
| `Chat Screen` | Real-time 1-on-1 direct messaging |

---

## Features

- **Email/Password Authentication** — Sign up and log in with Firebase Auth; session persistence via auth state stream.
- **Profile Photo Upload** — Profile picture selected from gallery on registration, stored in Firebase Storage.
- **Real-Time Feed** — Posts loaded from Cloud Firestore via `StreamBuilder`; updates instantly for all users.
- **Create Posts** — Pick an image from camera or gallery, add a caption, and publish to the global feed.
- **Like System** — Double-tap a post image or tap the heart icon to toggle a like; animated heart overlay on double-tap.
- **Comments** — Per-post comment threads stored as Firestore sub-collections; comments load in real-time, ordered by timestamp.
- **Delete Posts** — Post author can delete their own posts from a context menu.
- **Follow / Unfollow** — Follow or unfollow any user; follower/following counts update instantly.
- **User Search** — Search registered users by username prefix; tap a result to view their profile.
- **Photo Grid on Search** — Explore tab displays all posts in a responsive 3-column grid.
- **Profile Screen** — Displays avatar, bio, post count, followers, and following; own profile shows a Sign-Out button instead of Follow.
- **Direct Messaging** — Start a 1-on-1 chat with any user; real-time message bubbles with sender alignment; last-message preview in conversation list.
- **Responsive Layout** — Automatically switches between mobile and web layouts at a 600 px breakpoint using `LayoutBuilder`.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3 / Dart |
| **Authentication** | Firebase Authentication (email & password) |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **File Storage** | Firebase Storage |
| **State Management** | Provider (`ChangeNotifier`) |
| **Image Handling** | `image_picker` |
| **SVG Rendering** | `flutter_svg` |
| **Unique IDs** | `uuid` (v1 time-based) |
| **Date Formatting** | `intl` |
| **Staggered Grid** | `flutter_staggered_grid_view` |
| **Linting** | `flutter_lints` |

---

## Architecture Overview

The project follows a **service-layer + Provider** pattern:

```
┌────────────────────────────────────────────────────┐
│                   Flutter UI Layer                  │
│  Screens ◄──► Widgets ◄──► Provider (UserProvider)  │
└────────────────────┬───────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────────┐
│                 Resources Layer                     │
│  authMethods │ FirestoreMethods │ StorageMethods    │
└────────────────────┬───────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────────┐
│                Firebase Backend                     │
│  Firebase Auth │ Cloud Firestore │ Firebase Storage │
└────────────────────────────────────────────────────┘
```

- **Screens** handle all UI and delegate data operations to the resource layer.
- **Widgets** are stateless or stateful reusable components (PostCard, LikeAnimation, CommentsCard, FollowButton, TextFieldInput).
- **UserProvider** (`ChangeNotifier`) holds the currently authenticated user in memory and refreshes it on each navigation.
- **Resources** are plain Dart service classes that wrap Firebase SDK calls and return plain strings (`'success'` or error messages) to the UI.
- **ResponsiveLayout** uses `LayoutBuilder` with a 600 px breakpoint to serve a `MobileScreenLayout` (PageView + CupertinoTabBar) or a `WebScreenLayout`.

---

## Firestore Data Model

```
users/
  {uid}/
    email, username, uid, bio, photoUrl,
    followers: [], following: []

post/
  {postId}/
    description, username, uid, postId,
    datePublished, postUrl, profileUrl,
    likes: []
    comments/
      {commentId}/
        name, text, profilePic, uid, dataPublished

chat/
  {uid}/
    chatId, participants: [], timeStamp
    messages/
      {messageId}/
        messageID, senderId, lastMessage
        msg/
          {msgId}/
            senderId, text, timeStamp
```

---

## Folder Structure

```
lib/
├── main.dart                     # App entry point; Firebase init; auth state router
├── firebase_options.dart         # Auto-generated per-platform Firebase config
│
├── models/
│   ├── userModel.dart            # User data model with toJson / fromSnap
│   └── PostModel.dart            # Post data model with toJson / fromSnap
│
├── resources/
│   ├── auth_methods.dart         # signUpUser, userLogin, signOut, getUserData
│   ├── FirestoreMethods.dart     # uploadPost, likePost, postComments, deletePost,
│   │                             #   followUser, createChatRoom, createMessageRoom,
│   │                             #   addNewUser, sendMessage
│   └── storage_methods.dart      # uploadImageToStorage (profile pic & post images)
│
├── Providers/
│   └── UserProvider.dart         # ChangeNotifier; holds current user; refreshUser()
│
├── screens/
│   ├── login_screen.dart         # Email/password login
│   ├── singup_screen.dart        # Registration with profile photo picker
│   ├── Feed_screen.dart          # Real-time global post feed
│   ├── PostScreen.dart           # Image picker + caption → publish post
│   ├── Search_screen.dart        # Username search + photo grid
│   ├── Profile_screen.dart       # User profile (own or others)
│   ├── Comment_screen.dart       # Real-time comment thread
│   ├── Message_screen.dart       # Conversation list
│   ├── Search_user_screen.dart   # User picker for new conversations
│   └── Specific_User_screen.dart # 1-on-1 real-time chat
│
├── Widgets/
│   ├── post_card.dart            # Full post card (image, actions, description)
│   ├── Like_Animation.dart       # ScaleTransition heart animation
│   ├── Comments_card.dart        # Single comment row
│   ├── Follow_button.dart        # Reusable follow / unfollow / sign-out button
│   └── text_field_input.dart     # Reusable styled text input
│
├── responsive/
│   ├── Responsive.dart           # LayoutBuilder; triggers user data refresh on load
│   ├── mobile_screen_layout.dart # PageView + CupertinoTabBar (5 tabs)
│   └── web_screen_layout.dart    # Web layout placeholder
│
└── utils/
    ├── Colors.dart               # App-wide color constants (dark theme)
    ├── dimensions.dart           # webScreen breakpoint constant (600)
    └── utils.dart                # showSnackBar helper; imagePick wrapper
```

---

## Installation

### Prerequisites
- Flutter SDK ≥ 3.5.4 (`flutter --version`)
- A Firebase project with **Authentication** (email/password), **Firestore**, and **Storage** enabled
- `firebase_options.dart` generated via the FlutterFire CLI

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/rajanish421/instagam-clone.git
cd instagam-clone

# 2. Install dependencies
flutter pub get

# 3. Connect your Firebase project
#    Install the FlutterFire CLI if you haven't already:
dart pub global activate flutterfire_cli
#    Then configure (this overwrites firebase_options.dart):
flutterfire configure

# 4. Run the app
flutter run
```

### Firebase Setup Checklist

1. **Authentication** → Enable *Email/Password* sign-in method.
2. **Cloud Firestore** → Create a database; apply the security rules below (start with test mode for development).
3. **Storage** → Enable Firebase Storage; allow authenticated reads/writes.

#### Recommended Firestore Security Rules (development)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Environment / Configuration

All Firebase credentials are stored in the auto-generated `lib/firebase_options.dart`. **Never commit real API keys to a public repository.** Regenerate this file locally using `flutterfire configure` with your own Firebase project.

---

## Key Implementation Details

| Concern | Implementation |
|---------|---------------|
| Auth state routing | `StreamBuilder` on `FirebaseAuth.instance.authStateChanges()` in `main.dart` |
| Current user in memory | `UserProvider.refreshUser()` called once on `ResponsiveLayout.initState()` |
| Post image deduplication | `uuid` v1 ID appended to Firebase Storage path when `isPost == true` |
| Like toggle | `FieldValue.arrayUnion` / `arrayRemove` on `likes` field |
| Follow toggle | Symmetric `arrayUnion` / `arrayRemove` on both `followers` and `following` |
| Real-time updates | Feed and comments use `StreamBuilder`; profile/search use `FutureBuilder` |
| Like animation | `AnimationController` + `ScaleTransition` (1.0 → 1.2 → 1.0) in 150 ms |
| Responsive breakpoint | `constraints.maxWidth > 600` in `LayoutBuilder` |
| Image upload | `putData(Uint8List)` → `getDownloadURL()` pattern via `StorageMethods` |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a pull request

---

## License

This project is for educational purposes. Feel free to use it as a reference or starting point for your own projects.
