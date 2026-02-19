# PROMPTS voor Cursor (MVP-first workflow)

Gebruik deze prompts als context bij codegeneratie voor ClipCook.

## A. Firebase Auth Setup
```
Feature: Firebase Authentication voor ClipCook (MVP)

Context:
- Configureer Firebase Auth met Email/Password en Sign in with Apple.
- Maak AuthService.swift met login, signup, signOut, en auth state listener.
- Maak AuthViewModel.swift met @Observable macro.
- RootView.swift als auth gate: toon LoginView als niet ingelogd, MainTabView als wel ingelogd.
- Gebruik UIApplicationDelegateAdaptor voor FirebaseApp.configure().
- Verbind met Firebase Emulator in DEBUG builds.
```

## B. Share Extension (iOS 18 compatible)
```
Feature: iOS Share Extension to import links/text from Instagram/TikTok (MVP)

Context:
- Create a Share Extension target named "ClipCookShareExtension" that accepts URL and text/plain.
- Use SwiftUI for the extension UI (NOT UIKit storyboard).
- Use UniformTypeIdentifiers (NOT deprecated MobileCoreServices).
- The extension should extract a shared URL or text and save it to the shared App Group container (group.com.clipcook.app) via UserDefaults key "pendingImports".
- Do NOT use extensionContext.open(URL:) — this is deprecated/broken in iOS 18.
- The extension saves raw data and shows a confirmation, user opens main app manually.
- Set proper NSExtensionActivationRule (NOT TRUEPREDICATE) — use NSExtensionActivationSupportsWebURLWithMaxCount: 1.
- Main app reads pendingImports at launch and presents import modal.
```

## C. Recipe CRUD
```
Feature: Recipe CRUD met Firestore (MVP)

Context:
- RecipeRepository.swift met protocol-based abstraction.
- CRUD operaties via Firestore: users/{userId}/recipes/{recipeId}.
- RecipeViewModel.swift met @Observable, real-time listener via snapshotListener.
- Recipe model met Codable conformance voor Firestore serialisatie.
- Ingrediënten als array van {name, amount, unit} objecten.
- Stappen als array van strings.
```

## D. Link Import
```
Feature: Link import met metadata preview (MVP)

Context:
- ImportViewModel.swift die LPMetadataProvider gebruikt voor het ophalen van OG metadata.
- Toon LinkPreviewCard met titel, afbeelding en beschrijving.
- Gebruiker kan metadata handmatig bewerken voor opslaan als recept.
- Detecteer sourceType (instagram, tiktok, youtube, web) op basis van URL domain.
- Cache LPLinkMetadata lokaal voor performance.
```
