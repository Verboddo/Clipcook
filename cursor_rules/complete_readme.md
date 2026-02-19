# ClipCook — Project README

## Over het project
ClipCook is een minimalistische iOS app voor het opslaan en organiseren van recepten. Recepten kunnen worden geïmporteerd via links van Instagram, TikTok, YouTube en andere websites, of handmatig worden ingevoerd. De app is ontworpen als MVP-first zonder AI, met de mogelijkheid om later AI-features toe te voegen via feature flags.

## Tech Stack
- **iOS:** SwiftUI, iOS 17.0+ deployment target, Xcode 16.2+
- **Architectuur:** MVVM + Repository Pattern + Feature Modules
- **Auth:** Firebase Authentication (Email/Password + Sign in with Apple)
- **Database:** Cloud Firestore (met ingebouwde offline persistence)
- **Link metadata:** LPMetadataProvider (LinkPresentation framework)
- **Dependencies:** Swift Package Manager
- **Linting:** SwiftLint
- **Testing:** XCTest + Firebase Emulator Suite

## Aan de slag
1. Open het Xcode project in `ClipCook/ClipCook.xcodeproj`.
2. Voeg je eigen `GoogleService-Info.plist` toe (download uit Firebase Console).
3. Installeer Firebase Emulator Suite: `brew install firebase-cli` of `npm install -g firebase-tools`.
4. Start emulators: `firebase emulators:start` (vanuit project root).
5. Build & run in Xcode op simulator of device.

## Project structuur
- `cursor_rules/` — Projectdocumentatie en Cursor rules
- `ClipCook/` — Xcode project met alle Swift source files
- `ClipCookShareExtension/` — Share Extension target
- `ClipCookTests/` — Unit tests
- `ClipCookUITests/` — UI tests

## Workflow
- Cursor leest de `.cursorrules` en `cursor_rules/*.md` bestanden als context.
- Gebruik de prompts in `cursor_rules/prompts_to_cursor.md` voor feature-requests.
- AI-gerelateerde code wordt pas later toegevoegd, achter feature flags (Firebase Remote Config).
- Backend (FastAPI/Python) wordt pas opgezet wanneer AI-features nodig zijn.
