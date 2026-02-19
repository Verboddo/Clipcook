# Firestore Database Structuur — ClipCook

## Collecties & Documenten

### users/{userId}
Het root-document voor elke geauthenticeerde gebruiker.

| Veld | Type | Beschrijving |
|------|------|-------------|
| email | string | Email adres van de gebruiker |
| displayName | string | Weergavenaam |
| units | string | `"metric"` of `"imperial"` |
| isPremium | bool | Premium status (default: false) |
| isBetaTester | bool | Beta access (default: false) |
| createdAt | timestamp | Aanmaakdatum |
| updatedAt | timestamp | Laatst bijgewerkt |

### users/{userId}/recipes/{recipeId}
Recepten subcollectie per gebruiker.

| Veld | Type | Beschrijving |
|------|------|-------------|
| title | string | Titel van het recept |
| sourceURL | string? | Originele link (Instagram/TikTok/YouTube) |
| sourceType | string | `"manual"`, `"instagram"`, `"tiktok"`, `"youtube"`, `"web"` |
| imageURL | string? | URL van de afbeelding (uit OG metadata) |
| ingredients | array | `[{ name: string, amount: string, unit: string }]` |
| steps | array | `[string]` — Bereidingsstappen |
| servings | int? | Aantal porties |
| calories | int? | Calorieën (handmatig ingevoerd) |
| macros | map? | `{ protein: int, carbs: int, fat: int }` (handmatig) |
| tags | array | `[string]` — Tags voor categorisatie |
| notes | string? | Persoonlijke notities |
| createdAt | timestamp | Aanmaakdatum |
| updatedAt | timestamp | Laatst bijgewerkt |

### users/{userId}/groceryItems/{itemId}
Boodschappenlijst items per gebruiker.

| Veld | Type | Beschrijving |
|------|------|-------------|
| name | string | Naam van het item |
| amount | string? | Hoeveelheid |
| unit | string? | Eenheid (g, ml, stuks, etc.) |
| isChecked | bool | Afgevinkt ja/nee |
| recipeId | string? | Optionele link naar recept |
| createdAt | timestamp | Aanmaakdatum |

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /recipes/{recipeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /groceryItems/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Indexen
Voor de MVP zijn geen custom Firestore indexen nodig. Firestore maakt automatisch single-field indexen aan. Bij complexe queries (bijv. filteren op tags + sorteren op createdAt) kunnen composite indexen nodig zijn — Firestore geeft een foutmelding met een directe link om de index aan te maken.
