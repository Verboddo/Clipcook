# Project specificaties: MVP → V1 → Full Product (AI-loos MVP)

## MVP (essentieel, geen AI)
- **Authenticatie:** Firebase Auth met Email/Password en Sign in with Apple. Auth state management via `Auth.auth().addStateDidChangeListener`.
- Recept import via paste van een Instagram/TikTok/YouTube link — metadata ophalen via `LPMetadataProvider` (titel, afbeelding, beschrijving). Gebruiker kan handmatig bewerken en opslaan als recept.
- **Share Extension:** ondersteunt 'Delen' vanuit Instagram/TikTok of 'Kopieer link' -> 'Plak in app'. De Share Extension slaat raw URL en caption op in App Group (`group.com.clipcook.app`) via UserDefaults (`pendingImports`). De main app leest pendingImports bij launch en toont import modal. Geen `extensionContext.open(URL:)` (deprecated iOS 18) — gebruiker opent app handmatig.
- Handmatige invoer en bewerking van titel, ingredienten, stappen en servings.
- Recepten opslaan in Cloud Firestore gekoppeld aan userId (`users/{userId}/recipes/{recipeId}`).
- Minimalistische SwiftUI UI: lijst met recepten, details view met ingredienten en stappen, bewerk schermen.
- Light & Dark mode.
- Boodschappenlijst (handmatig toevoegen van ingredienten of via 'voeg toe aan boodschappenlijst' knop). Opgeslagen in Firestore (`users/{userId}/groceryItems/{itemId}`).
- Handmatige macro/calo invoer mogelijkheid per recept (geen automatische berekening).
- Basis settings: user profile, units (metric/imperial), sign out.

## V1 (na MVP, nog steeds zonder AI)
- Zoekfunctie in recepten (titel, tags, ingredienten).
- Recepten categoriseren met tags.
- Recept delen met andere gebruikers.
- Verbeterde link preview met cached afbeeldingen.
- Meal planning (handmatig weekoverzicht).

## Full Product (met AI, achter feature flags)
- AI recipe parsing: automatische extractie van ingredienten & stappen uit links.
- AI nutrition analysis: automatische macro's & calorieën berekening.
- AI video-to-recipe: TikTok/YouTube video parsing.
- AI meal planner: automatische weekplanning op basis van voorkeuren.
- Backend: FastAPI (Python) voor alle AI-verwerking.
