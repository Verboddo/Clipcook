# Coding Rules — ClipCook (Swift/SwiftUI)

## Taal & Stijl
- Schrijf alle code in **Swift** (geen Objective-C).
- Gebruik **SwiftUI** voor alle views (geen UIKit tenzij strikt noodzakelijk).
- Volg de [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- Gebruik Engelse namen voor code (variabelen, functies, types). Commentaar mag Nederlands of Engels.

## Architectuur
- **MVVM + Repository Pattern**: Views -> ViewModels -> Repositories -> Services.
- **Feature-based** folder organisatie (niet type-based).
- ViewModels gebruiken `@Observable` macro (iOS 17+).
- Repositories abstraheren data access achter protocols voor testbaarheid.
- Services bevatten externe integraties (Firebase, LinkPresentation).

## Naamgeving
- **Types** (structs, classes, enums, protocols): `PascalCase` — bijv. `RecipeViewModel`, `RecipeRepository`
- **Variabelen & functies**: `camelCase` — bijv. `recipeList`, `fetchRecipes()`
- **Booleans**: prefix met `is`, `has`, `should` — bijv. `isLoading`, `hasError`
- **Files**: Type naam = bestandsnaam — bijv. `RecipeViewModel.swift`
- **Directories**: `PascalCase` — bijv. `Features/`, `Recipes/`, `Views/`

## SwiftUI Specifiek
- Gebruik `NavigationStack` (niet deprecated `NavigationView`).
- Gebruik `@State` voor view-lokale state.
- Gebruik `@Environment` voor dependency injection (model context, dismiss, etc.).
- Gebruik `@Observable` ViewModels geïnjecteerd via `.environment()` of als parameter.
- Houd views klein: extraheer subviews naar aparte structs.
- Gebruik `system colors` en `SF Symbols` voor consistente UI.

## Error Handling
- Gebruik `do-catch` met `async/await` voor asynchrone operaties.
- Handle errors aan het begin van functies (guard clauses / early returns).
- Toon gebruikersvriendelijke foutmeldingen via alerts of inline error states.
- Log errors met `os.Logger` (niet `print()` in productie).
- Gebruik `Result<T, Error>` voor functies die falen kunnen.

## Firebase Specifiek
- `FirebaseApp.configure()` alleen in `AppDelegate` via `UIApplicationDelegateAdaptor`.
- Firestore access via `FirestoreService` singleton — niet direct in ViewModels.
- Auth state via `AuthService` met `addStateDidChangeListener`.
- Emulator verbinding alleen in `#if DEBUG` blocks.
- **Nooit** `GoogleService-Info.plist` committen naar publieke repos.

## Testing
- XCTest voor unit tests van ViewModels en Repositories.
- Mock protocols voor Firebase services in tests.
- Firebase Emulator Suite voor integratie tests.
- Streef naar tests voor alle business logic in ViewModels.

## Code Quality
- SwiftLint configuratie in project root (`.swiftlint.yml`).
- Geen force unwraps (`!`) behalve in tests of IBOutlets.
- Geen `print()` in productie code — gebruik `os.Logger`.
- Maximaal 1 verantwoordelijkheid per type (Single Responsibility Principle).
- Prefer `struct` boven `class` waar mogelijk.
- Gebruik `Codable` voor alle Firestore model serialisatie.
