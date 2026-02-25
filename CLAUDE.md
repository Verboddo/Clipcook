# CLAUDE.md — ClipCook

## Project Overview

ClipCook is een AI-gestuurde iOS-app voor het importeren, organiseren en plannen van recepten vanuit Instagram Reels. De gebruiker plakt een Instagram-link of deelt deze via de iOS Share Extension; de app extraheert automatisch de caption en optioneel de audio-transcriptie, en analyseert deze met een AI-model om ingrediënten, voedingswaarden en bereidingsstappen te identificeren. Gevonden recepten worden opgeslagen in Firestore en kunnen worden toegevoegd aan een persoonlijke maaltijdplanner met calorieën- en macrotracking.

De app-interface is volledig in het **Nederlands**. Alle code (variabelen, functies, types, commentaar) is in het **Engels**.

## Commands

```bash
# Open project
open ClipCook.xcodeproj

# Build (command line)
xcodebuild -scheme ClipCook -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme ClipCook -destination 'platform=iOS Simulator,name=iPhone 16' test

# Lint
swiftlint lint --strict

# Firebase emulators
firebase emulators:start

# Firebase deploy security rules
firebase deploy --only firestore:rules
```

## Tech Stack

- **iOS UI:** SwiftUI (iOS 17.0+ deployment target, Xcode 16.2+, iOS 18 SDK)
- **State:** `@Observable` macro (iOS 17+), `@MainActor` voor ViewModels
- **Architectuur:** MVVM + Repository Pattern + Feature Modules
- **Auth:** Firebase Authentication (Sign in with Apple + Google Sign-In + Email/Password)
- **Database:** Cloud Firestore (offline persistence standaard ingeschakeld)
- **AI:** OpenAI (laatste kleine model, bijv. GPT-4o mini of opvolger) voor productie, Ollama voor lokale ontwikkeling — alle receptextractie is AI-gestuurd
- **Audio-transcriptie:** Backend-component nodig: video downloaden van Instagram → audio extraheren → speech-to-text via Whisper API. Instagram biedt geen transcriptie via hun URL of publieke API.
- **Link metadata:** LPMetadataProvider (LinkPresentation framework)
- **Instagram caption:** Extractie via de best beschikbare methode (Instagram oEmbed API, embed page parsing, of scraping service). De concrete implementatie wordt bepaald tijdens ontwikkeling.
- **Betalingen:** Apple In-App Purchase (StoreKit 2) — gratis proefweek, daarna €4,99/maand. Launch-aanbieding: levenslang €60 (eerste 2 weken)
- **Dependencies:** Swift Package Manager (FirebaseCore, FirebaseAuth, FirebaseFirestore, GoogleSignIn)
- **Linting:** SwiftLint
- **Testing:** XCTest + Firebase Emulator Suite
- **Localisatie:** String Catalogs (`.xcstrings`), app-taal: Nederlands

## Architecture

```
ClipCook/
├── App/                          # App entry point, RootView, AppDelegate
├── Features/                     # Feature modules (elk met View + ViewModel)
│   ├── Auth/                     # SignInView — Apple, Google, Email authenticatie
│   ├── Onboarding/               # 3-slide onboarding (Clip It, Cook It, Keep It)
│   ├── Home/                     # Recept grid, zoeken, categorie filters, favorieten
│   ├── Import/                   # URL import, AI-extractie, preview, opslaan
│   ├── RecipeDetail/             # Hero image, ingrediënten, stappen, voeding, acties
│   ├── RecipeEdit/               # Foto, titel, ingrediënten, stappen, voeding bewerken
│   ├── CookMode/                 # Step-by-step koken met timer en voortgang
│   ├── Shopping/                 # Boodschappenlijst (handmatig + import uit recepten)
│   ├── Planner/                  # Maaltijdplanner per dag, macro tracker, quick-add
│   ├── Settings/                 # Voorkeuren, account, abonnement, voedingsdoelen
│   └── Archived/                 # Gearchiveerde recepten herstellen of verwijderen
├── Models/                       # Data models (Recipe, AppUser, MealSlot, etc.)
├── Repositories/                 # Firestore repositories (protocol-based)
├── Services/                     # Auth, Import, AI Extractor, Premium, Nutrition
├── Shared/                       # Gedeelde componenten, extensions, MainTabView
│   └── Components/               # EmptyStateView, LinkPreviewCard, UndoToast, etc.
├── Theme/                        # AppTheme (kleuren, spacing, fonts), ChefMascotView
├── Resources/                    # Assets, Localizable.xcstrings
ClipCookShareExtension/           # iOS Share Extension (URL delen vanuit Instagram)
ClipCookTests/                    # Unit tests (XCTest)
ClipCookUITests/                  # UI tests
```

**Patroon:** Views -> ViewModels (`@Observable`) -> Repositories (protocol) -> Firestore

## Features

### Authenticatie
- Sign in with Apple, Google Sign-In, en Email/Password via Firebase Auth
- Onboarding flow (3 slides) voor nieuwe gebruikers
- Gebruikersprofiel aanmaken in Firestore bij eerste login
- Account beheer: e-mail wijzigen, wachtwoord wijzigen, account verwijderen (GDPR)

### Recept Import (AI-gestuurd, standaard voor alle gebruikers)
- Instagram-link plakken of delen via iOS Share Extension
- Caption extractie via best beschikbare methode (oEmbed, embed parsing, scraping)
- Audio-transcriptie als extra informatiebron (vereist backend: video download → Whisper)
- AI-analyse van caption + transcriptie → gestructureerd recept met ingrediënten, stappen, voedingswaarden
- Preview met titel, afbeelding, ingrediënten, stappen — opslaan of bewerken
- Ondersteunde platforms: Instagram, TikTok, YouTube, willekeurige websites

### Share Extension
- iOS Share Extension accepteert URLs vanuit Instagram, Safari, etc.
- Slaat op in App Group (`group.com.clipcook.app`) via UserDefaults (`pendingImports`)
- Main app leest pending imports bij launch en toont import modal

### Receptbeheer
- 2-koloms grid met zoeken en categorie filters (Alles, Favorieten, Ontbijt, Lunch, Diner, Snack)
- Receptdetail: hero image, bereidingstijd, porties aanpassen, checkbare ingrediënten, genummerde stappen
- Expandeerbaar voedingspaneel (calorieën ring, macro bars)
- Bewerken: foto, titel, tijden, ingrediënten, stappen, voeding (handmatig invullen)
- Favorieten, archiveren (soft-delete), permanent verwijderen met undo toast (5 sec)
- Handmatig recept aanmaken

### Kookmodus
- Stap-voor-stap fullscreen interface met timer (start/pauze/reset)
- Voortgangsbalk en stap-navigatie (vorige/volgende, swipe)
- Scherm blijft aan tijdens het koken (idle timer disabled)
- Lokale notificatie bij timer-afloop op achtergrond

### Boodschappenlijst
- Handmatig items toevoegen
- Ingrediënten importeren vanuit opgeslagen recepten
- Afvinken met doorhaling, "Wis afgevinkt" knop
- Recept quick-add chips voor snelle import

### Maaltijdplanner
- Dagelijkse planning met 6 maaltijdslots: Ontbijt, Ochtendsnack, Lunch, Middagsnack, Diner, Avondsnack
- Recepten toewijzen of quick-add items via koppeling met een openbare voedingsdatabase (bijv. Open Food Facts, USDA FoodData Central) voor accurate voedingswaarden
- Datum navigatie (pijlen, kalender picker, swipe)
- **Macro tracker:** dagelijkse calorieën voortgangsbalk + circulaire macro gauges (eiwit, koolhydraten, vetten)
- Premium: eigen streefwaarden instellen; Gratis: vaste standaardwaarden

### Abonnement (Premium)
- Gratis proefweek voor nieuwe gebruikers
- Maandelijks abonnement (€4,99/maand) via Apple StoreKit 2
- **Launch-aanbieding:** eerste 2 weken na release een levenslang abonnement voor €60 (om vroege gebruikers aan te trekken en productiefeedback te verzamelen)
- AI-receptextractie zit in het **standaard** (gratis) abonnement — iedereen kan recepten importeren
- Premium ontgrendelt: eigen macro-doelen instellen, macro tracker in planner, uitgebreidere voedingsrapportages
- Gratis versie: volledige receptimport en -beheer, maar met vaste standaard voedingswaarden

### Instellingen
- Profiel: naam, e-mail
- Voorkeuren: donkere modus, meeteenheden (metrisch/imperiaal)
- Voedingsdoelen (premium): calorieën slider, macro sliders met auto-redistributie
- Bibliotheek: gearchiveerde recepten
- Abonnement: beheren, herstellen
- Account: e-mail wijzigen, wachtwoord wijzigen
- Juridisch: privacybeleid, gebruiksvoorwaarden
- Gevarenzone: uitloggen, account verwijderen

### Donkere modus
- Volledig ondersteund via SwiftUI system colors en semantic color assets
- Toggle in Instellingen, opgeslagen in Firestore gebruikersprofiel

## Data Model (Firestore)

```
users/{userId}                    # AppUser: email, displayName, units, darkMode, isPremium, nutritionGoals
  /recipes/{recipeId}             # Recipe: title, thumbnail, sourceUrl, caption, ingredients[], steps[], nutrition, isArchived, isFavourite
  /shoppingItems/{itemId}         # ShoppingItem: name, recipeId?, recipeName?, checked
  /mealSlots/{slotId}             # MealSlot: day, meal, recipeId?, quickAdd?
  /pendingImports/{importId}      # PendingImport: url, status, title?, caption?
```

Security Rules: gebruikers kunnen alleen hun eigen data lezen/schrijven (`request.auth.uid == userId`).

## Conventions

- **Architectuur:** MVVM + Repository Pattern + Feature Modules
- **State:** `@Observable` voor ViewModels (met `@MainActor`), `@State` voor view-lokale state
- **Naamgeving:** Types `PascalCase`, variabelen/functies `camelCase`, booleans `is`/`has`/`should` prefix
- **Bestanden:** typenaam = bestandsnaam (bijv. `RecipeViewModel.swift`)
- **Views:** klein houden, subviews extraheren, `NavigationStack` (niet `NavigationView`)
- **Modern SwiftUI:** `foregroundStyle()`, `clipShape(.rect(cornerRadius:))`, `Tab` API, `Button` boven `onTapGesture()`
- **Errors:** guard clauses / early returns, `do-catch` met `async/await`, `os.Logger` (nooit `print()`)
- **Firebase:** `FirebaseApp.configure()` in AppDelegate, Firestore via Repository laag, emulator in `#if DEBUG`
- **Serialisatie:** `Codable` voor alle Firestore models
- **Types:** prefer `struct` boven `class`
- **Accessibility:** Dynamic Type, VoiceOver, minimum 44pt tap targets, Reduce Motion support
- **Localisatie:** alle user-facing strings in `.xcstrings` String Catalogs, app-taal Nederlands
- **Afbeeldingen:** lazy loading, caching, thumbnails (400px grid, 1200px detail), uploads max 1MB

## Rules

- Alle receptextractie verloopt via AI (OpenAI / Ollama). Geen lokale regex-fallback.
- API-keys en secrets **nooit** in de app-code of repository. AI keys server-side of via environment variables.
- `GoogleService-Info.plist` nooit committen naar publieke repos.
- Geen `print()` in productie code — gebruik `os.Logger`.
- Geen force unwraps (`!`) behalve in tests.
- Alle Firestore data access via Repository laag, nooit direct in ViewModels.
- Alle netwerkcommunicatie via HTTPS (TLS 1.2+).
- Destructieve acties (verwijderen, archiveren) altijd met 5-seconden undo toast.
- Premium features checken via `isPremium` boolean op het user document. Geen feature flag systeem.
- De app moet volledig offline werken via Firestore's ingebouwde offline persistence.
- Cook Mode: `UIApplication.shared.isIdleTimerDisabled = true` bij start, herstellen bij exit.
- Geen UIKit tenzij strikt noodzakelijk.
- AI-receptextractie is een standaard feature voor alle gebruikers, niet premium-only.

## Test URLs (Instagram Reels)

Gebruik deze links om de import- en AI-extractie flow te testen:

```
https://www.instagram.com/reel/DMuXeR5uRdA/?igsh=bzV2amZ1enl2dzJh
https://www.instagram.com/reel/DTBJYBPiH5Z/?igsh=MTh4Mm14Y2p4OTM3eQ==
https://www.instagram.com/reel/DQ1tuOGiTd5/?igsh=MTdwa29vMzQycGUyNg==
https://www.instagram.com/reel/DNVFPXwPqta/?igsh=MWM3dzhhZjVndjdkZw==
https://www.instagram.com/reel/DNTU0DRIrsA/?igsh=cW1nN3d2Ynd0ZHU1
https://www.instagram.com/reel/DNAfCOzOu5z/?igsh=MTk2MWt2M3ZhemxsNQ==
https://www.instagram.com/reel/DSBUsBHkrYh/?igsh=NWhmcDViOHEwODhh
https://www.instagram.com/reel/DMlgiI9zZ7d/?igsh=MXhnMzZzMWp3cXkwcQ==
https://www.instagram.com/reel/DPt_iQoEooo/?igsh=MTFueTM3aGZhb2Uxbw==
https://www.instagram.com/reel/DHMQXAbsJzT/?igsh=ZGhmb2dhaGw1bzky
```

## Verification

Na elke wijziging, controleer:

1. **Build slaagt:** `xcodebuild -scheme ClipCook -destination 'platform=iOS Simulator,name=iPhone 16' build`
2. **Tests slagen:** `xcodebuild -scheme ClipCook -destination 'platform=iOS Simulator,name=iPhone 16' test`
3. **Lint schoon:** `swiftlint lint --strict`
4. **Geen hardcoded strings:** alle user-facing tekst in `.xcstrings`
5. **Dark mode:** test beide modes visueel in simulator
6. **Offline:** schakel netwerk uit en verifieer dat bestaande data beschikbaar blijft
7. **AI import:** test met minstens 2 test URLs hierboven
