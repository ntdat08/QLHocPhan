# QLHocPhan – Lecturer Management System

A cross-platform lecturer management application developed using **Flutter** and **Firebase**. The system provides a simple and convenient interface for managing lecturer information, supporting authentication, data management, and searching.

## 1. Project Overview

**QLHocPhan** is a mobile and web application designed to simplify lecturer information management. It allows authorized users to log in and perform basic operations on lecturer records through an intuitive user interface.

The application uses Firebase as its backend service, enabling cloud-based data storage and user authentication.

## 2. Features

- **User Authentication:** Secure login using Firebase Authentication (Email/Password).
- **Lecturer Management:** Create, view, update, and delete lecturer records.
- **Search Functionality:** Search lecturers by name or lecturer ID.
- **Vietnamese Text Search:** Support for searching Vietnamese names without requiring exact accent marks.
- **Data Storage:** Store and retrieve lecturer information using Cloud Firestore.
- **Image Support:** Support for handling lecturer images.
- **Cross-Platform:** Run the application on Android and Web.

## 3. Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Main programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database |
| Firebase Core | Firebase integration |
| Android Studio | Android development and emulator |
| Visual Studio Code | Source code development |
| Git & GitHub | Version control and source code management |

## 4. Application Structure

```text
QLHocPhan/
├── android/                  # Android platform configuration
├── ios/                      # iOS platform configuration
├── linux/                    # Linux platform configuration
├── macos/                    # macOS platform configuration
├── web/                      # Web platform configuration
├── windows/                  # Windows platform configuration
│
├── lib/
│   ├── main.dart             # Application entry point
│   ├── firebase_options.dart # Firebase configuration
│   │
│   ├── models/
│   │   └── giangvien.dart    # Lecturer data model
│   │
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── giangvien_list_screen.dart
│   │   └── giangvien_form_screen.dart
│   │
│   └── services/
│       └── giangvien_service.dart
│
├── test/                     # Application tests
├── pubspec.yaml              # Dependencies and project configuration
├── analysis_options.yaml     # Dart analysis configuration
└── README.md
```

## 5. Getting Started

### Prerequisites

Before running the project, make sure you have installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Visual Studio Code](https://code.visualstudio.com/) or Android Studio
- A Firebase project

### Installation

**Step 1: Clone the repository**

```bash
git clone https://github.com/ntdat08/QLHocPhan.git
```

**Step 2: Navigate to the project directory**

```bash
cd QLHocPhan
```

**Step 3: Install dependencies**

```bash
flutter pub get
```

**Step 4: Configure Firebase**

Connect the application to your own Firebase project.

- Configure Firebase Authentication and enable the Email/Password sign-in provider.
- Create a Cloud Firestore database.
- Configure Firebase for the required platforms using FlutterFire CLI.
- Ensure that the Firebase configuration files are correctly generated.

Reference: [Firebase Setup for Flutter](https://firebase.google.com/docs/flutter/setup)

**Step 5: Run the application**

For Android:

```bash
flutter run
```

For Web:

```bash
flutter run -d chrome
```

## 6. Firebase Configuration

The application uses the following Firebase services:

**Firebase Authentication**
- Handles user login.
- Authenticates users using email and password.

**Cloud Firestore**
- Stores lecturer information.
- Supports retrieving, adding, updating, and deleting lecturer records.

> Note: You must configure your own Firebase project and update the application configuration before running the application. Do not upload Firebase Admin SDK service account keys or other private credentials to the repository.

## 7. Future Improvements

- Implement role-based access control for administrators and other users.
- Improve data validation and error handling.
- Add pagination for large lecturer datasets.
- Enhance the user interface and overall user experience.
- Add more advanced filtering and sorting options.

