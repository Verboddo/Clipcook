# Release Plan — ClipCook

## Fase 1: Project Scaffolding
**Doel:** Werkend project met Firebase Auth + Firestore, klaar om features op te bouwen.

- [ ] Xcode project aanmaken (SwiftUI, iOS 17.0 target)
- [ ] Firebase SDK toevoegen via SPM (FirebaseCore, FirebaseAuth, FirebaseFirestore)
- [ ] `-ObjC` linker flag toevoegen
- [ ] Firebase project aanmaken in Firebase Console
- [ ] Auth (Email/Password + Apple) activeren in Firebase Console
- [ ] Firestore database aanmaken in Firebase Console
- [ ] GoogleService-Info.plist toevoegen aan Xcode project
- [ ] AppDelegate + FirebaseApp.configure() opzetten
- [ ] Firebase Emulator Suite installeren en configureren
- [ ] Emulator verbinding in DEBUG builds
- [ ] Firestore Security Rules deployen
- [ ] Share Extension target toevoegen
- [ ] App Group configureren (group.com.clipcook.app)
- [ ] Feature-based folder structuur neerzetten
- [ ] SwiftLint configuratie toevoegen

## Fase 2: Core Features (MVP)
**Doel:** Alle MVP features werkend.

- [ ] Auth flow: LoginView, SignUpView, auth state management
- [ ] Sign in with Apple integratie
- [ ] RootView als auth gate
- [ ] User profile aanmaken in Firestore bij eerste login
- [ ] Recipe model + RecipeRepository + FirestoreService
- [ ] RecipeListView met real-time Firestore listener
- [ ] RecipeDetailView met ingrediënten en stappen
- [ ] RecipeEditView voor aanmaken en bewerken
- [ ] Recept verwijderen met confirmatie
- [ ] Link import: URL plakken, LPMetadataProvider metadata ophalen
- [ ] LinkPreviewCard component
- [ ] Source type detectie (instagram, tiktok, youtube, web)
- [ ] Share Extension (SwiftUI, iOS 18 compatible, App Groups)
- [ ] pendingImports lezen bij app launch
- [ ] Boodschappenlijst CRUD
- [ ] "Voeg toe aan boodschappenlijst" vanuit recept
- [ ] Settings: profiel bewerken, units, sign out
- [ ] Handmatige macro/calorie invoer per recept

## Fase 3: Polish & App Store
**Doel:** App klaar voor App Store submission.

- [ ] Light & Dark mode verfijning
- [ ] Empty states voor alle lijsten
- [ ] Loading states en error handling
- [ ] SwiftLint warnings oplossen
- [ ] Unit tests voor ViewModels en Repositories
- [ ] App icon ontwerpen
- [ ] Launch screen
- [ ] App Store screenshots
- [ ] Privacy policy opstellen
- [ ] App Store listing (beschrijving, keywords)
- [ ] TestFlight beta testing
- [ ] App Store submission

## Fase 4: V1 Verbeteringen (na App Store launch)
**Doel:** Gebruikerservaring verbeteren zonder AI.

- [ ] Zoekfunctie in recepten
- [ ] Tags en categorisatie
- [ ] Recept delen
- [ ] Verbeterde link preview caching
- [ ] Meal planning (handmatig weekoverzicht)

## Fase 5: AI Features (toekomst)
**Doel:** AI-powered features toevoegen achter feature flags.

- [ ] FastAPI backend opzetten
- [ ] Firebase Remote Config integreren
- [ ] AI recipe parsing
- [ ] AI nutrition analysis
- [ ] AI video-to-recipe
- [ ] AI meal planner
- [ ] Premium/monetisatie model
