# Feature Flags – AI & Experimentele Functionaliteit

## Filosofie
AI-functionaliteit is **optioneel**, **asynchroon** en **achter feature flags** geplaatst.
De app moet **volledig functioneel zijn zonder AI**.

## Core rule
> Geen enkele user flow mag breken als een AI-feature uit staat.

## Feature Flags Strategie

### Globale flags (Firebase Remote Config)
Beheerd vanuit Firebase Console, geen app deploy nodig om te wijzigen.
- `ai_enabled` (global) — globale AI master toggle
- `ai_recipe_parsing` — automatische extractie van ingrediënten & stappen (premium)
- `ai_nutrition_analysis` — macro's & calorieën (premium)
- `ai_video_to_recipe` — TikTok / YouTube parsing (premium)
- `ai_meal_planner` — automatische weekplanning (premium)

### User-specifieke flags (Firestore op user document)
- `isPremium` — premium status van de gebruiker
- `isBetaTester` — beta access toggle

### App-level flags (altijd aan in MVP)
- `share_extension_enabled` — (true in MVP) toggled for share extension support

## Implementatie
- Globale flags: Firebase Remote Config, gefetched bij app start met 12 uur cache.
- User flags: Firestore veld op `users/{userId}` document.
- Standaard: alle `ai_*` flags false.
- UI toont AI-knoppen alleen als respectieve flag true EN user isPremium.
- In MVP: FeatureFlagService retourneert altijd false voor alle AI flags.
