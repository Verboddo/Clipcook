# CORE RULES - Project Kernel (MVP first)

## Missie
Je bent de ontwikkelaar-assistent voor een minimalistische iOS app: **ClipCook**.
Kern: importeer (opslaan) van recepten via Instagram/TikTok/YouTube links en handmatig invoeren en organiseren van recepten. AI-functionaliteit is optioneel en wordt later via feature flags toegevoegd.

## Altijd gelden
1. **MVP eerst, zonder AI.** De app moet volledig werken zonder enige AI-calls of -services.
2. **Keep it minimal.** UI moet minimaal, snel en toegankelijk zijn. Gebruik SwiftUI, system colors, en Light/Dark support.
3. **Architectuur:** MVVM + Repository Pattern + Feature Modules. State management via `@Observable` macro (iOS 17+).
4. **Quality gates:** Altijd SwiftLint en unit tests (XCTest) voor nieuwe modules. Schrijf tests bij iedere feature.
5. **Security/Privacy:** Persoonlijke data nooit loggen in plaintext; gebruikersdata versleuteld in transit (TLS). API-keys & secrets in secret manager. Firestore Security Rules afdwingen.
6. **AI optioneel:** Alle AI-calls moeten via gescheiden servermodules lopen en zitten achter feature flags (Firebase Remote Config). In het MVP zijn AI-modules letterlijk afwezig.
7. **Offline:** Recepten moeten offline beschikbaar zijn via Firestore's ingebouwde offline persistence (standaard ingeschakeld op iOS).
8. **Auth:** Firebase Authentication (Email/Password + Sign in with Apple) vanaf dag 1. Alle data gekoppeld aan geauthenticeerde userId.
9. **Database:** Cloud Firestore als primaire database, direct vanuit iOS client met Security Rules.
10. **Geen custom backend in MVP.** Firebase Auth + Firestore werken direct vanuit de iOS client. Backend (FastAPI/Python) pas bij AI-fase.

## Tech Stack
- **iOS UI:** SwiftUI (iOS 17.0+ deployment target)
- **Build:** Xcode 16.2+, iOS 18 SDK
- **Auth:** Firebase Authentication
- **Database:** Cloud Firestore (met offline persistence)
- **Link metadata:** LPMetadataProvider (LinkPresentation framework)
- **State:** `@Observable` macro (iOS 17+)
- **Dependencies:** Swift Package Manager (SPM)
- **Linting:** SwiftLint
- **Testing:** XCTest + Firebase Emulator Suite
