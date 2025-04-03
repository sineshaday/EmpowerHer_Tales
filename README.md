# Empowerher_tales

## App Purpose

This application serves as a The EmpowerHer Tales project aims to create a platform for women to share their stories and hear from one another, fostering a sense of community and inspiration.

## Key Features

### 📦 Database Integration
- Powered by **Firebase Firestore**
- Real-time data sync for stories, comments, and events
- Secure and scalable backend for growing communities

---

### 📝 Story Management
- Users can write, edit, and delete their personal stories
- Stories are categorized for easier discovery (e.g., Mental Health, Career, Motherhood)
- Support for story sharing to encourage openness

---

### 💬 Commenting System
- Readers can comment on stories to offer encouragement or feedback
- Comments are moderated to maintain a safe, respectful environment

---

### 👤 User Profiles
- Users can create and customize a profile (optional)
- View personal stories, saved posts, and bookmarked events

---

### 🌐 Community Forum Infrastructure
- Public discussion boards for various topics (e.g., Advice, Opportunities, Support)
- Threaded replies and upvoting to highlight meaningful discussions
- Admins(the group) moderation tools to maintain a healthy community space through backend updates

---

### 🏠 Home Page
- Dynamic feed with animation and an appealing UI
- Easy navigation to other pages
- Quick access to featured discussions and upcoming events

---

### 📅 Event Calendar
- Displays upcoming webinars, workshops, and meetups
- User can post Women Empowerment related events
- Admins can edit and and manage events page in real-time

---

## 🔐 Authentication & Security
- Firebase Authentication (Email/Password)
- Role-based access control for admin moderation

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

