# CCET Coderz Club (C3) Flutter App

A modern, community-focused Flutter + Firebase application for CCET where students, staff, and admin can share projects, discuss ideas, and participate in coding contests.

## Implemented Features

- **Role-based auth flows** for Student, Staff, and Admin.
- **Social login** options: Google, GitHub, LinkedIn.
- **Strict admin restriction**: only verified `t.gugan2005@gmail.com` can keep admin role.
- **Profile social account linking** for Google/GitHub/LinkedIn.
- **Project sharing module** with title, description, tags, image URLs, links, author metadata.
- **Discussion thread** under each project.
- **Star/favorite support** for projects.
- **Featured Projects** section on Home.
- **Best Project of the Week** highlighted on Home.
- **Authorization rule in UI**: only Staff/Admin can mark best project of week.
- **Coding contests module** with listing, participation toggle, and details screen.

## Tech Stack

- Flutter (Material 3)
- Firebase Auth
- Cloud Firestore
- Firebase Storage (dependency included for project media usage)

## Folder Structure (Feature-oriented)

```text
lib/
  core/
    constants.dart
  features/
    auth/
    contests/
    home/
    profile/
    projects/
  main.dart
```

## Firebase Setup Notes

1. Create a Firebase project.
2. Enable authentication providers:
   - Google
   - GitHub
   - LinkedIn (via OAuth/OIDC provider as `linkedin.com`)
3. Add Flutter app(s) and generate `firebase_options.dart` if you use FlutterFire CLI.
4. Configure Firestore + Storage.
5. Add proper Firestore security rules for role-based writes.

## Suggested Firestore Collections

- `users/{uid}`
- `projects/{projectId}`
  - `comments/{commentId}`
- `contests/{contestId}`

## Role Capabilities

- **Student**: browse, upload, discuss, star.
- **Staff**: all student actions + mark Best Project of Week.
- **Admin**: full control (enforced by verified email check).

## Run

```bash
flutter pub get
flutter run
```

> This repository includes app-level role checks and workflows. For production safety, mirror these constraints in Firestore Security Rules and Cloud Functions.
