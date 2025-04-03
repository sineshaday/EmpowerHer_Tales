# empowerher_tales

## App Purpose

This application serves as a [brief app purpose]. It aims to provide users with [key functionalities and objectives].

### Setup Instructions

Prerequisites

Ensure you have the following installed:

Flutter SDK (latest version)

Dart

Firebase CLI (for authentication and data storage)

Android Studio/Xcode (for emulator or physical device testing)

VS Code or any preferred IDE

Installation Steps

Clone the Repository

```git clone https://github.com/sineshaday/EmpowerHer_Tales.git```

```cd EmpowerHer_Tales```

Install Dependencies

```flutter pub get```

Set Up Firebase

Create a Firebase project at Firebase Console.

Add an Android/iOS app and download the google-services.json or GoogleService-Info.plist.

Place these files in the respective platform directories (android/app/ for Android, ios/Runner/ for iOS).

Enable Firebase Authentication and Firestore in the Firebase Console.

### Run the App

```flutter run```

Database Architecture

The app uses Firebase Firestore for database management. The structure follows:

```Firestore Database
|
├── users (Collection)
│   ├── userId1 (Document)
│   │   ├── name: String
│   │   ├── email: String
│   │   ├── phone: String
│   ├── userId2 (Document)
│   │   ├── ...
│
├── data (Collection)
│   ├── entryId1 (Document)
│   │   ├── field1: Type
│   │   ├── field2: Type
│   ├── ...
```

### Functionalities

User Authentication (Sign up, Login, Logout with Firebase Auth)

Data Management (Store and retrieve user-related data using Firestore)

Form Validation (Ensuring correct input formats)

Multi-Screen Navigation (Seamless transition between pages)

Error Handling & Notifications

