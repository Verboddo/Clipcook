---
document_type: SRS
status: DRAFT
title: "ClipCook Recipes Software Requirements Specification"
subtitle: "Software Requirements Specification"
version: "0.1"
classification: "Internal"
date: "2026-02-19"
authors:
  - "ClipCook Product Team"
  - "Software Architect"
approved_by: "Not yet approved"
distribution:
  - role: "Approver"
    name: "[Manager R&D]"
    purpose: "Final approval"
  - role: "Approving Reviewer"
    name: "[Business Analyst]"
    purpose: "Content review and approval"
  - role: "Approving Reviewer"
    name: "[Software Architect]"
    purpose: "Technical review and approval"
  - role: "Consulting Reviewer"
    name: "[iOS Developer]"
    purpose: "Implementation feasibility review"
  - role: "Consulting Reviewer"
    name: "[Test Specialist]"
    purpose: "Testability review"
  - role: "Consulting Reviewer"
    name: "[UX Designer]"
    purpose: "Usability review"
  - role: "Consulting Reviewer"
    name: "[Security Officer]"
    purpose: "Security review"
  - role: "For Information"
    name: "[Stakeholders]"
    purpose: "Awareness"
version_history:
  - version: "0.1"
    date: "2026-02-19"
    status: "Concept"
    changes: "First version — derived from UI prototype screenshots and domain analysis"
---

## References

| Ref | Title | Version | Date |
|-----|-------|---------|------|
| [1] | ClipCook Architectural Design Document | 0.1 | 2026-02-19 |
| [2] | ClipCook UI Prototype (React/Vite) | 1.0.0 | 2026-02-19 |
| [3] | Apple App Store Review Guidelines | 2025 | — |
| [4] | Firebase Documentation — Firestore Security Rules | — | — |
| [5] | Apple StoreKit 2 Documentation | iOS 17+ | — |

---

# 1. Introduction

## 1.1 Purpose of the Document

This document describes the functional and non-functional requirements for the **ClipCook** iOS application. It serves as a reference for verification, validation, design, development, and implementation. It covers all Product Use Cases, system requirements, data requirements, and non-functional requirements for the MVP and premium feature tiers.

ClipCook enables users to capture, organise, and cook recipes imported from social media platforms (primarily Instagram) or created manually. The MVP delivers full recipe management, shopping list, and meal planning capabilities without AI. AI-powered features (recipe extraction, auto-nutrition, video-to-recipe) are reserved for premium subscribers and gated behind feature flags.

## 1.2 Scope

- **iOS App**: SwiftUI, iOS 17+, distributed via Apple App Store
- **Share Extension**: SwiftUI-based, shares the iOS App Group container for data exchange
- **Backend**: Firebase Authentication + Cloud Firestore (offline persistence enabled)
- **Optional services**: Metadata preview server (Express.js + Docker), AI endpoints (Azure GPT-4x, customer-hosted)
- **Payments**: Apple In-App Purchase (StoreKit 2); RevenueCat optional as subscription management layer

## 1.3 Definitions & Acronyms

| Term | Definition |
|------|------------|
| MVP | Minimum Viable Product — full recipe management without AI |
| IAP | In-App Purchase (Apple StoreKit 2) |
| AI | Artificial Intelligence — Azure GPT-4x integration, premium-only |
| FF | Feature Flag — per-user toggles stored in Firestore |
| App Group | iOS shared container between the main app and Share Extension |
| NoOpAnalyzer | Placeholder class used when AI is disabled |
| PII | Personally Identifiable Information |

---

# 2. Functional Requirements

## 2.1 Scope of the Epic or Domain

The epic "Recipe Capture & Organisation" encompasses the following core flows:

1. Importing a recipe from an Instagram link (via Share Extension or paste) → preview → save or edit
2. Manual creation and editing of recipes (title, photo, ingredients, steps, servings, nutrition)
3. Viewing recipes in detail with interactive cook mode
4. Managing a shopping list (manual items + import from recipes)
5. Planning meals on a daily calendar with macro tracking (premium)
6. User preferences, premium subscription management, and account settings

```mermaid
graph LR
    User((User))
    App[ClipCook iOS App]
    ShareExt[Share Extension]
    Firebase[Firebase Auth + Firestore]
    MetaSrv[Metadata Server]
    AISrv[AI Service]
    IAP[Apple IAP]

    User --> App
    User --> ShareExt
    ShareExt -->|"App Group"| App
    App --> Firebase
    App -->|"optional"| MetaSrv
    App -->|"premium only"| AISrv
    App --> IAP
```

**Screenshot overview — all screens within scope:**

| # | Screenshot | Screen |
|---|-----------|--------|
| 1 | ![Onboarding Slide 1](assets/01-onboarding-slide1.png) | Onboarding — "Clip It" |
| 2 | ![Onboarding Slide 2](assets/01-onboarding-slide2.png) | Onboarding — "Cook It" |
| 3 | ![Onboarding Slide 3](assets/01-onboarding-slide3.png) | Onboarding — "Keep It" |
| 4 | ![Sign In](assets/02-signin.png) | Sign In |
| 5 | ![Home](assets/03-home.png) | Home — Recipe Grid |
| 6 | ![Import](assets/04-import.png) | Import — Initial State |
| 7 | ![Import Success](assets/04-import-success.png) | Import — Success Preview |
| 8 | ![Import Failed](assets/04-import-failed.png) | Import — Failure State |
| 9 | ![Recipe Detail](assets/05-recipe-detail.png) | Recipe Detail |
| 10 | ![Recipe Edit](assets/06-recipe-edit.png) | Recipe Edit |
| 11 | ![Cook Mode](assets/07-cook-mode.png) | Cook Mode |
| 12 | ![Shopping List Empty](assets/08-shopping.png) | Shopping List — Empty |
| 13 | ![Shopping List Filled](assets/08-shopping-filled.png) | Shopping List — With Items |
| 14 | ![Meal Planner](assets/09-planner.png) | Meal Planner — Empty |
| 15 | ![Planner Add Meal](assets/09-planner-add-meal.png) | Meal Planner — Add Meal Sheet |
| 16 | ![Planner With Meal](assets/09-planner-with-meal.png) | Meal Planner — Meal Added |
| 17 | ![Planner Premium](assets/09-planner-premium.png) | Meal Planner — Premium Macro Tracker |
| 18 | ![Settings](assets/10-settings.png) | Settings — Free Mode |
| 19 | ![Settings Premium](assets/10-settings-premium.png) | Settings — Premium Mode |
| 20 | ![Archived Recipes](assets/11-archived-recipes.png) | Archived Recipes |

---

## 2.2 Product Use Cases

### MOD/PUC/001/1.0 Onboarding & Sign-In

| Field | Value |
|-------|-------|
| **Description** | First-time user is presented with a 3-slide onboarding experience explaining ClipCook's value proposition, followed by authentication. |
| **Trigger** | App launched for the first time (no prior onboarding flag). |
| **Precondition** | App installed; user has not completed onboarding. |
| **Related Requirements** | MOD/SYS/001, MOD/SYS/007 |
| **Main Flow** | 1. System displays onboarding slide 1: "Clip It" — save recipes from Instagram (see [01-onboarding-slide1.png](assets/01-onboarding-slide1.png)).<br>2. User taps "Next"; system displays slide 2: "Cook It" — edit ingredients, adjust servings, step-by-step cooking (see [01-onboarding-slide2.png](assets/01-onboarding-slide2.png)).<br>3. User taps "Next"; system displays slide 3: "Keep It" — build collection, plan meals (see [01-onboarding-slide3.png](assets/01-onboarding-slide3.png)).<br>4. User taps "Get Started"; system navigates to Sign In screen.<br>5. User selects authentication method: Google, Apple, or Email (see [02-signin.png](assets/02-signin.png)).<br>6. System authenticates user and navigates to Home screen. |
| **Alternative Flow** | A1: User taps "Skip" during onboarding → navigates directly to Sign In screen. |
| **Exceptional Flow** | E1: Authentication fails → system displays error message and allows retry. |
| **Actors** | End User |

### MOD/PUC/002/1.0 Browse & Search Recipes

| Field | Value |
|-------|-------|
| **Description** | User browses their saved recipe collection with search and category filtering. |
| **Trigger** | User navigates to Home tab. |
| **Precondition** | User is authenticated. |
| **Related Requirements** | MOD/SYS/002 |
| **Main Flow** | 1. System displays recipe grid with thumbnails, titles, cook times, and calorie/protein badges (see [03-home.png](assets/03-home.png)).<br>2. User types in search field; system filters recipes by title in real-time.<br>3. User taps a category chip (All / Favorites / Breakfast / Lunch / Dinner / Snack); system filters accordingly.<br>4. User taps a recipe card; system navigates to Recipe Detail (PUC/004). |
| **Alternative Flow** | A1: No recipes saved → system displays empty state with chef mascot and "Import Recipe" CTA.<br>A2: User taps "+" button → navigates to Import screen (PUC/003).<br>A3: User taps heart icon on a recipe card → toggles favourite status. |
| **Exceptional Flow** | E1: No recipes match search/filter → system displays "No recipes match your search" message. |
| **Actors** | End User |

### MOD/PUC/003/1.0 Import Recipe

| Field | Value |
|-------|-------|
| **Description** | User imports a recipe by pasting a URL (typically Instagram) or via the iOS Share Extension. The system attempts to fetch metadata and presents a preview for saving. |
| **Trigger** | User taps "+" on Home screen, or shares a URL to ClipCook from another app. |
| **Precondition** | User is authenticated. |
| **Related Requirements** | MOD/SYS/003 |
| **Main Flow** | 1. System displays Import screen with URL input field and Share Extension info card (see [04-import.png](assets/04-import.png)).<br>2. User pastes a URL and taps "Import".<br>3. System shows loading animation with chef mascot ("Fetching your recipe...").<br>4. On success (~70% probability): system displays preview bottom sheet with recipe thumbnail, title, cook time, and servings (see [04-import-success.png](assets/04-import-success.png)).<br>5. User taps "Save as-is" → recipe added to collection and user navigates to Recipe Detail.<br>6. Alternatively, user taps "Edit & Save" → recipe added and user navigates to Recipe Edit (PUC/005). |
| **Alternative Flow** | A1 (Share Extension): User shares a URL from Instagram → Share Extension writes to App Group `pendingImports` → Main app shows Pending Imports list on next launch.<br>A2: User taps "Cancel" on preview → returns to Import screen. |
| **Exceptional Flow** | E1 (~30% probability): Metadata extraction fails → system displays error card with sad chef mascot: "Couldn't retrieve metadata" (see [04-import-failed.png](assets/04-import-failed.png)). User can tap "Try Again" to clear the error, or "Edit Manually" to create a blank recipe shell with the URL as source. |
| **Actors** | End User, Metadata Server (optional) |

### MOD/PUC/004/1.0 View Recipe Detail

| Field | Value |
|-------|-------|
| **Description** | User views full recipe details including hero image, prep/cook time, servings adjuster, checkable ingredients list, numbered steps, and expandable nutrition panel. |
| **Trigger** | User taps a recipe card on Home screen. |
| **Precondition** | Recipe exists in user's collection. |
| **Related Requirements** | MOD/SYS/004 |
| **Main Flow** | 1. System displays recipe with hero image, back/favourite/edit/menu buttons overlaid (see [05-recipe-detail.png](assets/05-recipe-detail.png)).<br>2. Title, prep time, cook time, and servings adjuster shown in a card below the hero.<br>3. User can tap +/- to adjust servings count.<br>4. Ingredients listed with checkboxes; tapping marks an ingredient as prepared (strikethrough + green highlight).<br>5. Steps listed numerically with a "Cook Mode" button beside the section header.<br>6. Expandable "Nutrition Info" panel at the bottom shows calorie ring and macro bars (protein, carbs, fats). |
| **Alternative Flow** | A1: User taps "Edit" → navigates to Recipe Edit (PUC/005).<br>A2: User taps "Cook Mode" → navigates to Cook Mode (PUC/006).<br>A3: User taps menu → shows dropdown with "Archive" and "Delete" options. |
| **Exceptional Flow** | E1: User taps "Delete" → recipe removed with undo toast (5 second window).<br>E2: User taps "Archive" → recipe moved to archived list with undo toast. |
| **Actors** | End User |

### MOD/PUC/005/1.0 Edit / Create Recipe

| Field | Value |
|-------|-------|
| **Description** | User edits all fields of a recipe: photo, title, prep/cook time, servings, ingredients, steps, and nutrition values. Premium users have access to AI auto-fill for nutrition. |
| **Trigger** | User taps "Edit" on Recipe Detail, or "Edit & Save" / "Edit Manually" from Import flow. |
| **Precondition** | Recipe exists (either imported or newly created blank shell). |
| **Related Requirements** | MOD/SYS/005 |
| **Main Flow** | 1. System displays edit form with current recipe data populated (see [06-recipe-edit.png](assets/06-recipe-edit.png)).<br>2. Photo section: tap to upload/replace image (JPG, PNG, WEBP).<br>3. Title, Prep Time, Cook Time, Servings fields editable.<br>4. Ingredients section: add/remove ingredients with name + quantity; drag handle for reordering.<br>5. Steps section: add/remove steps with numbered textareas; drag handle for reordering.<br>6. Nutrition section: manual input for calories, protein, carbs, fats.<br>7. User taps "Save" → animated celebration with chef mascot and checkmark → navigates back to Recipe Detail. |
| **Alternative Flow** | A1 (Premium): User taps "AI Auto-fill" button beside Nutrition header → system shows "Calculating nutrition... Analyzing N ingredients with AI" overlay → nutrition fields auto-populated from ingredient analysis. |
| **Exceptional Flow** | E1: User navigates back without saving → changes discarded. |
| **Actors** | End User, AI Service (premium only) |

### MOD/PUC/006/1.0 Cook Mode

| Field | Value |
|-------|-------|
| **Description** | User follows recipe step-by-step with a focused full-screen interface, built-in timer, and progress tracking. |
| **Trigger** | User taps "Cook Mode" button on Recipe Detail. |
| **Precondition** | Recipe has at least one step. |
| **Related Requirements** | MOD/SYS/006 |
| **Main Flow** | 1. System displays Cook Mode with current step number badge, progress bar, and step text (see [07-cook-mode.png](assets/07-cook-mode.png)).<br>2. Header shows recipe title, "Cook Mode" label, and completed/total steps counter.<br>3. Step timer (start/pause/reset) displayed below step content.<br>4. User taps "Done — Next Step" → step marked complete, advances to next step with slide animation.<br>5. Previous/Next navigation buttons available.<br>6. On final step: button changes to "Finish Recipe" (green) → toast "Recipe complete! Enjoy your meal!" → returns to Recipe Detail. |
| **Alternative Flow** | A1: User taps X → exits Cook Mode and returns to Recipe Detail. |
| **Exceptional Flow** | None. |
| **Actors** | End User |

### MOD/PUC/007/1.0 Manage Shopping List

| Field | Value |
|-------|-------|
| **Description** | User manages a shopping list by adding items manually, importing ingredients from saved recipes, and checking off purchased items. |
| **Trigger** | User navigates to Shopping tab. |
| **Precondition** | User is authenticated. |
| **Related Requirements** | MOD/SYS/008 |
| **Main Flow** | 1. System displays Shopping List with item count and "Add item..." input field.<br>2. If list is empty: shows chef mascot empty state with recipe suggestion chips to quickly import ingredients (see [08-shopping.png](assets/08-shopping.png)).<br>3. User types item name and taps + or Enter → item added to list.<br>4. User taps a recipe suggestion chip → all ingredients from that recipe added to the list with recipe name attribution.<br>5. Items displayed with checkboxes; tapping marks as checked (strikethrough) (see [08-shopping-filled.png](assets/08-shopping-filled.png)).<br>6. "Clear checked (N)" button appears when checked items exist → removes all checked items. |
| **Alternative Flow** | None. |
| **Exceptional Flow** | None. |
| **Actors** | End User |

### MOD/PUC/008/1.0 Meal Planning

| Field | Value |
|-------|-------|
| **Description** | User plans meals for specific days by assigning recipes or quick snacks to meal slots (Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner, Evening Snack). Premium users see a daily macro tracker. |
| **Trigger** | User navigates to Planner tab. |
| **Precondition** | User is authenticated. |
| **Related Requirements** | MOD/SYS/009 |
| **Main Flow** | 1. System displays Meal Planner with date navigation (previous/next arrows, calendar picker, swipe gesture) (see [09-planner.png](assets/09-planner.png)).<br>2. If no meals planned: shows empty state with chef mascot and "Add Meal" CTA.<br>3. User taps "+" → bottom sheet opens with two tabs: "Recipes" and "Quick Add" (see [09-planner-add-meal.png](assets/09-planner-add-meal.png)).<br>4. User selects a recipe or quick snack → sheet advances to "Choose Meal Slot" step with 6 meal type options.<br>5. User selects a meal slot → item added to that day's plan, sheet closes.<br>6. Planned meals displayed grouped by meal type with thumbnail, title, and macro summary (see [09-planner-with-meal.png](assets/09-planner-with-meal.png)).<br>7. User can remove a meal by tapping the X button on the meal card. |
| **Alternative Flow** | A1 (Free mode): Daily Macro Tracker area shows a locked premium upsell banner: "Daily Macro Tracker — upgrade to unlock" (see [09-planner.png](assets/09-planner.png)).<br>A2 (Premium): Daily Macro Tracker shows calorie progress bar + circular macro gauges for protein, carbs, and fats with goal tracking (see [09-planner-premium.png](assets/09-planner-premium.png)). |
| **Exceptional Flow** | None. |
| **Actors** | End User |

### MOD/PUC/009/1.0 Premium Features & Subscription

| Field | Value |
|-------|-------|
| **Description** | User activates premium subscription via Apple IAP to unlock AI-powered features and daily macro tracking. |
| **Trigger** | User taps "Upgrade to Premium" in Settings, or taps a locked premium feature elsewhere. |
| **Precondition** | User is authenticated; Apple IAP products configured. |
| **Related Requirements** | MOD/SYS/010, MOD/SYS/011 |
| **Main Flow** | 1. System displays Premium modal with chef mascot, feature list (AI Recipe Extraction, Auto Nutrition, Video → Recipe), and "Start Free Trial — $4.99/mo" CTA.<br>2. User taps CTA → Apple IAP purchase flow initiated.<br>3. On successful purchase → feature flags updated, premium badge shown in Settings (see [10-settings-premium.png](assets/10-settings-premium.png)).<br>4. Premium features unlocked: AI Auto-fill on Recipe Edit, Daily Macro Tracker on Planner, Daily Nutrition Goals sliders in Settings. |
| **Alternative Flow** | A1: User taps "Maybe later" → modal dismissed.<br>A2: User navigates to Settings → "Premium Mode" toggle available for dev/preview (see [10-settings.png](assets/10-settings.png) vs [10-settings-premium.png](assets/10-settings-premium.png)). |
| **Exceptional Flow** | E1: Purchase fails → system displays error, user can retry.<br>E2: User taps "Restore Purchases" in Settings → system queries App Store for existing subscriptions. |
| **Actors** | End User, Apple IAP |

### MOD/PUC/010/1.0 Settings & Preferences

| Field | Value |
|-------|-------|
| **Description** | User manages app preferences (dark mode, units), account settings, subscription, archived recipes access, and legal information. |
| **Trigger** | User navigates to Settings tab. |
| **Precondition** | User is authenticated. |
| **Related Requirements** | MOD/SYS/012 |
| **Main Flow** | 1. System displays Settings screen with profile card, preferences, premium section, library, subscription, account, legal, and about sections (see [10-settings.png](assets/10-settings.png)).<br>2. User toggles Dark Mode on/off.<br>3. User switches Units between Metric and Imperial.<br>4. Feature flags section shows status of each feature (Free / Locked / Active).<br>5. Library section provides access to Archived Recipes.<br>6. Subscription section: "Manage Subscription" (opens App Store) and "Restore Purchases".<br>7. Account section: Change Email, Change Password, linked sign-in providers (Apple, Google).<br>8. Legal section: Privacy Policy and Terms of Service links.<br>9. About section: app name and version. |
| **Alternative Flow** | A1 (Premium): "Daily Nutrition Goals" section appears with calorie slider and auto-calculated macro sliders (30% P / 40% C / 30% F default split) (see [10-settings-premium.png](assets/10-settings-premium.png)).<br>A2: Danger Zone: "Log Out" and "Delete Account" options. |
| **Exceptional Flow** | E1: Delete Account → confirmation dialog → data deletion per GDPR. |
| **Actors** | End User |

### MOD/PUC/011/1.0 Archive & Restore Recipes

| Field | Value |
|-------|-------|
| **Description** | User manages archived recipes — viewing, restoring to active collection, or permanently deleting them. |
| **Trigger** | User taps "Archived Recipes" in Settings, or archives a recipe from Recipe Detail. |
| **Precondition** | User has access to Settings. |
| **Related Requirements** | MOD/SYS/013 |
| **Main Flow** | 1. System displays Archived Recipes screen with list of archived items showing thumbnail, title, cook time, and calories (see [11-archived-recipes.png](assets/11-archived-recipes.png)).<br>2. Each recipe has a restore button (circular, primary colour) and a delete button (circular, destructive colour).<br>3. User taps restore → recipe moved back to active collection with undo toast.<br>4. User taps delete → recipe permanently removed with undo toast. |
| **Alternative Flow** | A1: No archived recipes → empty state with chef mascot: "No archived recipes". |
| **Exceptional Flow** | None. |
| **Actors** | End User |

---

## 2.3 System Requirements

### MOD/SYS/001/1.0 Onboarding Flow

| Field | Value |
|-------|-------|
| **Description** | The system shall present a 3-slide onboarding carousel on first launch, persisting the completion state so it is not shown again. |
| **Rationale** | Users need to understand the app's value proposition before committing to sign-in. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/001 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Onboarding displays 3 slides: "Clip It", "Cook It", "Keep It" with chef mascot animations | TC-001 |
| Slide indicators (dots) reflect current position | TC-001 |
| "Skip" button available on slides 1 and 2, navigates to Sign In | TC-002 |
| "Get Started" on slide 3 navigates to Sign In | TC-003 |
| Onboarding not shown on subsequent launches after completion | TC-004 |

### MOD/SYS/002/1.0 Recipe Collection Browsing

| Field | Value |
|-------|-------|
| **Description** | The system shall display the user's recipe collection as a 2-column grid with search and category filtering. |
| **Rationale** | Quick visual browsing and filtering are essential for recipe discovery in growing collections. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/002 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Recipes displayed in a 2-column grid with thumbnail, title, cook time, calorie, and protein badges | TC-010 |
| Real-time search filtering by recipe title | TC-011 |
| Category chips: All, Favorites, Breakfast, Lunch, Dinner, Snack | TC-012 |
| Tapping recipe card navigates to Recipe Detail | TC-013 |
| Heart icon toggles favourite status | TC-014 |
| Empty state displays chef mascot and "Import Recipe" CTA when no recipes exist | TC-015 |

### MOD/SYS/003/1.0 Recipe Import

| Field | Value |
|-------|-------|
| **Description** | The system shall accept a URL input, attempt metadata extraction, and present a preview for the user to save or edit. The system shall also accept imports via the iOS Share Extension. |
| **Rationale** | The primary acquisition funnel for recipes is social media links, particularly Instagram. |
| **Actors** | End User, Metadata Server |
| **Related Requirements** | MOD/PUC/003 |
| **Related Risk IDs** | RISK-001 |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| URL input field accepts and validates URLs | TC-020 |
| Loading state displays chef mascot animation during import | TC-021 |
| Successful import shows preview bottom sheet with title, thumbnail, cook time, servings | TC-022 |
| "Save as-is" saves recipe and navigates to detail | TC-023 |
| "Edit & Save" saves recipe and navigates to edit | TC-024 |
| Failed import (~30% chance) shows error card with "Try Again" and "Edit Manually" options | TC-025 |
| Share Extension writes to App Group `pendingImports` and optionally opens app via deep link | TC-026 |
| Pending imports displayed as a list with status indicators | TC-027 |

### MOD/SYS/004/1.0 Recipe Detail View

| Field | Value |
|-------|-------|
| **Description** | The system shall display a complete recipe with hero image, metadata, servings adjuster, checkable ingredients, numbered steps, and expandable nutrition panel. |
| **Rationale** | Comprehensive recipe viewing is the core consumption experience. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/004 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Hero image displayed with gradient overlay and action buttons (back, favourite, edit, menu) | TC-030 |
| Servings adjuster (±) updates displayed count | TC-031 |
| Ingredients are checkable with visual strikethrough feedback | TC-032 |
| Steps displayed with numbered badges | TC-033 |
| "Cook Mode" button navigates to step-by-step mode | TC-034 |
| Nutrition panel expands/collapses showing calorie ring and macro bars | TC-035 |
| Menu dropdown offers "Archive" and "Delete" with undo toasts | TC-036 |

### MOD/SYS/005/1.0 Recipe Editing

| Field | Value |
|-------|-------|
| **Description** | The system shall provide a full recipe editor for photo, title, times, servings, ingredients, steps, and nutrition values. |
| **Rationale** | Users need to correct imported data and create recipes from scratch. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/005 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Photo upload/replace via file picker (JPG, PNG, WEBP) | TC-040 |
| Title, prep time, cook time, servings fields are editable | TC-041 |
| Ingredients can be added, removed, and reordered | TC-042 |
| Steps can be added, removed, and reordered | TC-043 |
| Nutrition fields (calories, protein, carbs, fats) manually editable | TC-044 |
| Save triggers celebration animation and returns to detail view | TC-045 |
| Premium: "AI Auto-fill" calculates nutrition from ingredient list | TC-046 |

### MOD/SYS/006/1.0 Cook Mode

| Field | Value |
|-------|-------|
| **Description** | The system shall provide a focused step-by-step cooking interface with timer, progress tracking, and step completion marking. |
| **Rationale** | Hands-free, focused cooking guidance prevents users from losing their place. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/006 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Progress bar and "Step N of M" indicator update on navigation | TC-050 |
| Step text displayed with slide animation on navigation | TC-051 |
| Timer with start/pause/reset; timer resets on step change | TC-052 |
| "Done — Next Step" marks step complete and advances | TC-053 |
| Final step shows "Finish Recipe" button; completion triggers toast and returns to detail | TC-054 |
| Previous/Next buttons allow non-linear navigation | TC-055 |

### MOD/SYS/007/1.0 Authentication

| Field | Value |
|-------|-------|
| **Description** | The system shall support Sign in with Apple, Google, and Email authentication via Firebase Authentication. |
| **Rationale** | Required for user identity, data persistence, and purchase linking. |
| **Actors** | End User, Firebase Auth |
| **Related Requirements** | MOD/PUC/001 |
| **Related Risk IDs** | RISK-003 |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Sign in with Apple flow completes and creates Firebase user | TC-060 |
| Sign in with Google flow completes and creates Firebase user | TC-061 |
| Email sign-in flow completes and creates Firebase user | TC-062 |
| Authentication state persisted across app launches | TC-063 |
| Purchases linked to authenticated user account | TC-064 |

### MOD/SYS/008/1.0 Shopping List

| Field | Value |
|-------|-------|
| **Description** | The system shall allow users to create, manage, and check off shopping list items, with the ability to bulk-import ingredients from saved recipes. |
| **Rationale** | Shopping list bridges recipe planning and actual grocery acquisition. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/007 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| User can add free-text items via input field | TC-070 |
| Items imported from a recipe carry recipe name attribution | TC-071 |
| Items are checkable with visual feedback (strikethrough) | TC-072 |
| "Clear checked" removes all checked items | TC-073 |
| Empty state shows recipe suggestion chips for quick import | TC-074 |
| List persists across app sessions (Firestore sync) | TC-075 |

### MOD/SYS/009/1.0 Meal Planner

| Field | Value |
|-------|-------|
| **Description** | The system shall allow users to plan meals by date with 6 meal slots per day, supporting both recipe assignments and quick-add snacks. |
| **Rationale** | Meal planning drives daily engagement and connects recipes to actual consumption. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/008 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Date navigation via arrows, calendar picker, and swipe gesture | TC-080 |
| "Today" shortcut displayed when viewing a different date | TC-081 |
| Add meal via bottom sheet with Recipes/Quick Add tabs | TC-082 |
| Meal slot selection (6 types: Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner, Evening Snack) | TC-083 |
| Planned meals displayed grouped by meal type with nutrition summary | TC-084 |
| Meals removable via X button | TC-085 |
| Free mode: locked macro tracker banner with premium upsell | TC-086 |
| Premium mode: daily calorie bar + circular macro gauges with goal tracking | TC-087 |

### MOD/SYS/010/1.0 Premium Subscription & IAP

| Field | Value |
|-------|-------|
| **Description** | The system shall manage premium subscription lifecycle via Apple IAP (StoreKit 2), including purchase, restore, and feature flag activation. |
| **Rationale** | Apple App Store requires IAP for digital content subscriptions; premium monetises AI features. |
| **Actors** | End User, Apple IAP |
| **Related Requirements** | MOD/PUC/009 |
| **Related Risk IDs** | RISK-002, RISK-004 |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Premium modal displays feature list and "$4.99/mo" pricing | TC-090 |
| StoreKit purchase flow completes and activates premium | TC-091 |
| Restore Purchases queries App Store and restores entitlements | TC-092 |
| Feature flags updated on premium activation/deactivation | TC-093 |
| Server-side receipt validation confirms subscription status | TC-094 |

### MOD/SYS/011/1.0 Feature Flags

| Field | Value |
|-------|-------|
| **Description** | The system shall gate premium features behind per-user feature flags stored in Firestore, defaulting to disabled. |
| **Rationale** | Feature flags allow granular control, A/B testing, and safe rollout of AI capabilities. |
| **Actors** | System, Admin |
| **Related Requirements** | MOD/SYS/010 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Default flags: all AI features disabled, manual features enabled | TC-100 |
| Premium toggle sets AI flags to enabled for that user | TC-101 |
| Client reads flags at startup and gates UI accordingly | TC-102 |
| Settings screen displays flag status (Free / Locked / Active) | TC-103 |

### MOD/SYS/012/1.0 User Preferences

| Field | Value |
|-------|-------|
| **Description** | The system shall persist user preferences for dark mode, measurement units, and nutrition goals. |
| **Rationale** | Personalisation improves UX and supports diverse dietary contexts. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/010 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Dark mode toggle switches app theme | TC-110 |
| Units toggle (metric/imperial) persists across sessions | TC-111 |
| Nutrition goals (calories, protein, carbs, fats) adjustable via sliders (premium) | TC-112 |
| Macro auto-calculation: adjusting calories redistributes macros by percentage | TC-113 |
| Adjusting one macro redistributes remaining calories between the other two | TC-114 |

### MOD/SYS/013/1.0 Recipe Archival

| Field | Value |
|-------|-------|
| **Description** | The system shall support archiving recipes (soft delete) with the ability to restore or permanently delete from the archive. |
| **Rationale** | Users may want to declutter without permanent loss. |
| **Actors** | End User |
| **Related Requirements** | MOD/PUC/011 |
| **Related Risk IDs** | — |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| Archive action moves recipe from active to archived collection | TC-120 |
| Restore action moves recipe back to active collection | TC-121 |
| Permanent delete removes recipe with no recovery (except undo toast window) | TC-122 |
| Undo toast available for 5 seconds after archive/delete actions | TC-123 |
| Archived recipe count shown in Settings | TC-124 |

### MOD/SYS/014/1.0 Offline-First & Sync

| Field | Value |
|-------|-------|
| **Description** | The system shall operate offline-first with local persistence, synchronising data with Firestore when connectivity is restored. |
| **Rationale** | Users may cook in environments with poor connectivity; data must not be lost. |
| **Actors** | System, Firebase |
| **Related Requirements** | — |
| **Related Risk IDs** | RISK-005 |

**Acceptance Criteria:**

| Description | Test Traceability |
|-------------|-------------------|
| All CRUD operations work offline | TC-130 |
| Data syncs to Firestore within 30 seconds of connectivity restoration | TC-131 |
| Sync status indicator reflects current state (synced, pending, conflict, offline) | TC-132 |
| Conflict resolution modal presents "keep local / keep remote / merge" options | TC-133 |

---

## 2.4 Detailed System Requirements

### MOD/SYS/003.1/1.0 Share Extension URL Handling

| Field | Value |
|-------|-------|
| **Description** | The Share Extension shall accept `public.url` and `public.text` content types and write entries to the App Group `pendingImports` store with the schema: `{id, type: url|text, content, createdAt, sourceApp}`. |
| **Related Requirements** | MOD/SYS/003 |
| **Related Risk IDs** | RISK-001 |
| **Test Traceability** | TC-026 |

### MOD/SYS/003.2/1.0 Metadata Server Fallback

| Field | Value |
|-------|-------|
| **Description** | When the metadata server (`GET /metadata?url=<url>`) is unavailable or returns an error, the system shall display the raw URL with a fallback caption. Import shall not be blocked by server unavailability. |
| **Related Requirements** | MOD/SYS/003 |
| **Related Risk IDs** | RISK-001 |
| **Test Traceability** | TC-025, TC-028 |

### MOD/SYS/003.3/1.0 Import Failure Recovery

| Field | Value |
|-------|-------|
| **Description** | When metadata extraction fails, the system shall offer two recovery paths: (a) "Try Again" clears the error state, (b) "Edit Manually" creates a blank recipe shell with the source URL preserved and navigates to Recipe Edit. |
| **Related Requirements** | MOD/SYS/003, MOD/SYS/005 |
| **Related Risk IDs** | — |
| **Test Traceability** | TC-025 |

### MOD/SYS/005.1/1.0 AI Nutrition Auto-Fill

| Field | Value |
|-------|-------|
| **Description** | When the user is premium and taps "AI Auto-fill", the system shall analyse the current ingredient list and populate the nutrition fields (calories, protein, carbs, fats). The system shall show a loading indicator during analysis. If AI is unavailable, the `NoOpAnalyzer` shall return zero values silently. |
| **Related Requirements** | MOD/SYS/005, MOD/SYS/011 |
| **Related Risk IDs** | — |
| **Test Traceability** | TC-046 |

### MOD/SYS/009.1/1.0 Quick Add Snacks

| Field | Value |
|-------|-------|
| **Description** | The meal planner shall provide a pre-defined list of quick-add snack items (Banana, Apple, Greek Yogurt, Protein Bar, Handful of Nuts, Hard Boiled Egg, Rice Cake, Orange) with pre-filled nutrition data, assignable to any meal slot. |
| **Related Requirements** | MOD/SYS/009 |
| **Related Risk IDs** | — |
| **Test Traceability** | TC-082 |

### MOD/SYS/009.2/1.0 Daily Macro Tracker (Premium)

| Field | Value |
|-------|-------|
| **Description** | When the user is premium, the meal planner shall display a daily nutrition summary: total calorie progress bar, and circular gauge for protein, carbs, and fats relative to the user's nutrition goals. The calorie bar shall turn red when exceeding the goal. |
| **Related Requirements** | MOD/SYS/009, MOD/SYS/012 |
| **Related Risk IDs** | — |
| **Test Traceability** | TC-087 |

### MOD/SYS/012.1/1.0 Nutrition Goal Auto-Calculation

| Field | Value |
|-------|-------|
| **Description** | When the user adjusts daily calorie goal, the system shall redistribute macros maintaining the current percentage split (default: 30% protein / 40% carbs / 30% fats by calorie). When the user adjusts a single macro, the system shall redistribute remaining calories between the other two macros proportionally. Conversion factors: 1g protein = 4 kcal, 1g carbs = 4 kcal, 1g fats = 9 kcal. |
| **Related Requirements** | MOD/SYS/012 |
| **Related Risk IDs** | — |
| **Test Traceability** | TC-113, TC-114 |

---

# 3. Data Requirements

## MOD/DATA/001/1.0 User

**Description:** Represents an authenticated user account with preferences and subscription status.

### Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique user identifier (Firebase Auth UID) | string | Required, unique |
| email | User's email address | string | Required, valid email |
| displayName | Display name | string | Optional |
| units | Measurement preference | enum | "metric" \| "imperial", default "metric" |
| darkMode | Theme preference | boolean | Default false |
| isPremium | Premium subscription active | boolean | Default false |
| flags | Feature flag overrides | FeatureFlags | See MOD/DATA/006 |
| nutritionGoals | Daily nutrition targets | NutritionGoals | See MOD/DATA/007 |
| schemaVersion | Data schema version for migrations | integer | Required |
| createdAt | Account creation timestamp | timestamp | Auto-set |
| updatedAt | Last modification timestamp | timestamp | Auto-updated |

### Relationships

- One User has many Recipes (MOD/DATA/002)
- One User has many ShoppingLists (MOD/DATA/003)
- One User has many MealPlans (MOD/DATA/004)
- One User has many PendingImports (MOD/DATA/005)

---

## MOD/DATA/002/1.0 Recipe

**Description:** A cooking recipe with metadata, ingredients, steps, and optional nutrition information.

### Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique recipe identifier | string | Required, unique |
| userId | Owner user ID | string | Required, FK to User |
| title | Recipe title | string | Required, max 200 chars |
| thumbnail | Photo URL or local file path | string \| null | Optional |
| sourceUrl | Original import URL | string \| null | Optional, valid URL |
| sourcePlatform | Origin platform | enum \| null | "instagram" \| "tiktok" \| "youtube" \| null |
| caption | Original post caption | string \| null | Optional |
| prepTime | Preparation time display string | string | Optional, e.g. "10 min" |
| cookTime | Cooking time display string | string | Optional, e.g. "25 min" |
| servings | Number of servings | integer | Required, min 1 |
| category | Recipe category | string | Required: "Breakfast" \| "Lunch" \| "Dinner" \| "Snack" |
| ingredients | List of ingredients | Ingredient[] | Array, may be empty |
| steps | Ordered cooking steps | Step[] | Array, may be empty |
| nutrition | Nutritional information | Nutrition \| null | Optional |
| aiMeta | AI processing metadata | AIMeta \| null | Optional, premium only |
| isArchived | Soft-delete flag | boolean | Default false |
| isFavourite | Favourite flag | boolean | Default false |
| createdAt | Creation timestamp | timestamp | Auto-set |
| updatedAt | Last modification timestamp | timestamp | Auto-updated |

**Ingredient sub-entity:**

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique ingredient identifier | string | Required |
| name | Ingredient name | string | Required |
| amount | Quantity with unit | string | Required, e.g. "500g" |
| notes | Additional notes | string \| null | Optional |

**Step sub-entity:**

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique step identifier | string | Required |
| order | Step sequence number | integer | Required, 1-indexed |
| text | Step instruction text | string | Required |

**Nutrition sub-entity:**

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| calories | Total kilocalories | integer | >= 0 |
| protein | Protein in grams | integer | >= 0 |
| carbs | Carbohydrates in grams | integer | >= 0 |
| fats | Fats in grams | integer | >= 0 |

### Relationships

- Belongs to one User (MOD/DATA/001)
- Referenced by ShoppingItem (MOD/DATA/003) via recipeId
- Referenced by MealSlot (MOD/DATA/004) via recipeId

---

## MOD/DATA/003/1.0 ShoppingList & ShoppingItem

**Description:** A user's shopping list containing individually checkable items, optionally linked to recipes.

### ShoppingItem Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique item identifier | string | Required |
| name | Item description (e.g. "500g Chicken breast") | string | Required |
| recipeId | Source recipe if imported | string \| null | Optional, FK to Recipe |
| recipeName | Source recipe title for display | string \| null | Optional |
| checked | Purchase status | boolean | Default false |

### Relationships

- Belongs to one User (MOD/DATA/001)
- Optionally references one Recipe (MOD/DATA/002) via recipeId

---

## MOD/DATA/004/1.0 MealPlan & MealSlot

**Description:** A daily meal plan consisting of slots assigned to specific meal types with either a recipe reference or a quick-add snack.

### MealSlot Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique slot identifier | string | Required |
| day | Date key | string | Required, format "yyyy-MM-dd" |
| meal | Meal type | enum | Required: "Breakfast" \| "Morning Snack" \| "Lunch" \| "Afternoon Snack" \| "Dinner" \| "Evening Snack" |
| recipeId | Assigned recipe | string \| null | Optional, FK to Recipe |
| quickAdd | Quick-add snack data | QuickAddItem \| null | Optional |

**QuickAddItem sub-entity:**

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| name | Snack name | string | Required |
| calories | Kilocalories | integer | >= 0 |
| protein | Protein in grams | integer | >= 0 |
| carbs | Carbohydrates in grams | integer | >= 0 |
| fats | Fats in grams | integer | >= 0 |

### Relationships

- Belongs to one User (MOD/DATA/001)
- Optionally references one Recipe (MOD/DATA/002) via recipeId

---

## MOD/DATA/005/1.0 PendingImport

**Description:** A queued import item received from the Share Extension, awaiting processing by the main app.

### Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| id | Unique import identifier | string | Required |
| url | Source URL | string | Required |
| status | Processing state | enum | "importing" \| "ready" \| "failed" |
| title | Extracted title (if available) | string \| null | Optional |
| thumbnail | Extracted preview image URL | string \| null | Optional |
| caption | Extracted caption | string \| null | Optional |
| createdAt | Import creation timestamp | timestamp | Auto-set |

### Relationships

- Belongs to one User (MOD/DATA/001)
- Transitions to a Recipe (MOD/DATA/002) on successful processing

---

## MOD/DATA/006/1.0 FeatureFlags

**Description:** Per-user feature flag configuration controlling access to premium and experimental features.

### Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| ai_enabled | Master AI toggle | boolean | Default false |
| ai_recipe_parsing | AI recipe extraction | boolean | Default false |
| ai_nutrition_analysis | AI nutrition calculation | boolean | Default false |
| ai_video_to_recipe | AI video conversion | boolean | Default false |
| ai_meal_planner | AI meal suggestions | boolean | Default false |
| share_extension_enabled | Share Extension active | boolean | Default true |

### Relationships

- Embedded in User (MOD/DATA/001) as a sub-document

---

## MOD/DATA/007/1.0 NutritionGoals

**Description:** User-configured daily nutrition targets for macro tracking (premium feature).

### Attributes

| Attribute | Description | Type | Constraints |
|-----------|-------------|------|-------------|
| calories | Daily calorie target | integer | Range 1200–4000, default 2200 |
| protein | Daily protein target (grams) | integer | >= 0, default 120 |
| carbs | Daily carbohydrate target (grams) | integer | >= 0, default 250 |
| fats | Daily fat target (grams) | integer | >= 0, default 70 |

### Relationships

- Embedded in User (MOD/DATA/001) as a sub-document

---

# 4. Non-Functional Requirements

## 4.1 Base Non-Functional Requirements

The following base non-functional requirements apply to all ClipCook development activities:

- All code shall be reviewed before merging to the main branch.
- All public-facing builds shall be signed and distributed via TestFlight or App Store.
- The project shall maintain a minimum of 70% unit test coverage for core modules (ViewModels, Repositories).

## 4.2 Security

### MOD/SEC/001/1.0 Transport Layer Security

| Field | Value |
|-------|-------|
| **Description** | All network communication shall use TLS 1.2 or higher (HTTPS). |
| **Motivation** | Prevent man-in-the-middle attacks and data interception. |
| **Fit Criteria** | No HTTP (non-TLS) requests permitted in production builds; verified by network traffic inspection. |
| **Product Use Case(s)** | All PUCs involving network communication |
| **References** | Apple ATS (App Transport Security) requirements |

### MOD/SEC/002/1.0 Firestore Access Control

| Field | Value |
|-------|-------|
| **Description** | Firestore security rules shall ensure users can only read and write their own documents (`request.auth.uid == userId`). |
| **Motivation** | Prevent cross-user data access. |
| **Fit Criteria** | Security rules tested in Firebase emulator; peer-reviewed before deployment. |
| **Product Use Case(s)** | All PUCs involving data persistence |
| **References** | [4] Firebase Firestore Security Rules |

### MOD/SEC/003/1.0 Secret Management

| Field | Value |
|-------|-------|
| **Description** | API keys and secrets shall never be stored in the client app binary or source repository. AI service keys shall be stored server-side only. |
| **Motivation** | Prevent credential leakage and unauthorised API access. |
| **Fit Criteria** | CI/CD pipeline secret scanning passes; no keys in committed code. |
| **Product Use Case(s)** | MOD/PUC/009 (AI features) |
| **References** | — |

### MOD/SEC/004/1.0 Receipt Validation

| Field | Value |
|-------|-------|
| **Description** | In-app purchase receipts shall be validated server-side (via Cloud Functions or RevenueCat) before granting premium access. |
| **Motivation** | Prevent subscription fraud and jailbreak bypasses. |
| **Fit Criteria** | No premium features accessible without validated receipt. |
| **Product Use Case(s)** | MOD/PUC/009 |
| **References** | [5] Apple StoreKit 2 |

### MOD/SEC/005/1.0 Rate Limiting

| Field | Value |
|-------|-------|
| **Description** | The metadata server and AI endpoints shall implement rate limiting to prevent abuse. |
| **Motivation** | Protect server resources and prevent denial-of-service. |
| **Fit Criteria** | Rate limit responses (HTTP 429) returned when thresholds exceeded; limits configurable. |
| **Product Use Case(s)** | MOD/PUC/003, MOD/PUC/005 |
| **References** | — |

## 4.3 Look and Feel

### MOD/LOOK/001/1.0 Design System Consistency

| Field | Value |
|-------|-------|
| **Description** | The app shall use SF (San Francisco) system fonts, system colours where applicable, and maintain consistent spacing tokens, border radii (rounded-2xl = 16pt), and component patterns as shown in the UI prototype screenshots. |
| **Motivation** | Consistent visual language builds trust and reduces cognitive load. |
| **Fit Criteria** | Design review confirms adherence to spacing tokens and component library across all screens. |
| **Product Use Case(s)** | All PUCs |

### MOD/LOOK/002/1.0 Light & Dark Mode

| Field | Value |
|-------|-------|
| **Description** | The app shall support both Light and Dark modes, togglable in Settings, using SwiftUI colour tokens and semantic colour assets. |
| **Motivation** | Dark mode reduces eye strain and is expected by iOS users. |
| **Fit Criteria** | All screens render correctly in both modes; no hard-coded colours. |
| **Product Use Case(s)** | MOD/PUC/010 |

### MOD/LOOK/003/1.0 Chef Mascot

| Field | Value |
|-------|-------|
| **Description** | The animated chef mascot shall appear contextually across empty states, loading indicators, onboarding, and celebrations with mood variations (happy, cooking, sad, excited). |
| **Motivation** | Adds personality, guides users, and softens error states. |
| **Fit Criteria** | Mascot appears in at least: onboarding, sign-in, import loading, import error, empty states (home, shopping, planner, archived), and save celebration. |
| **Product Use Case(s)** | MOD/PUC/001, MOD/PUC/003, MOD/PUC/005, MOD/PUC/007, MOD/PUC/008 |

## 4.4 Usability

### MOD/USE/001/1.0 Accessibility

| Field | Value |
|-------|-------|
| **Description** | The app shall support Dynamic Type, VoiceOver, and maintain minimum 44pt tap targets for all interactive elements. |
| **Motivation** | Accessibility enables use by people with visual or motor impairments and is required for WCAG AA compliance. |
| **Fit Criteria** | VoiceOver audit passes on all screens; no tap target below 44pt verified by accessibility inspector. |
| **Product Use Case(s)** | All PUCs |

### MOD/USE/002/1.0 Gesture Navigation

| Field | Value |
|-------|-------|
| **Description** | The meal planner shall support swipe gestures for date navigation. Cook mode shall support swipe gestures for step navigation. |
| **Motivation** | Gesture-based navigation feels natural on iOS and is faster than tapping buttons. |
| **Fit Criteria** | Horizontal swipe (>50pt threshold) navigates to previous/next day or step. |
| **Product Use Case(s)** | MOD/PUC/006, MOD/PUC/008 |

### MOD/USE/003/1.0 Undo on Destructive Actions

| Field | Value |
|-------|-------|
| **Description** | All destructive actions (delete, archive, clear checked) shall provide a 5-second undo toast. |
| **Motivation** | Prevents accidental data loss without requiring confirmation dialogs that slow down the UX. |
| **Fit Criteria** | Toast with "Undo" action button displayed for 5 seconds; tapping undoes the action. |
| **Product Use Case(s)** | MOD/PUC/004, MOD/PUC/007, MOD/PUC/011 |

### MOD/USE/004/1.0 Screen Wake Lock in Cook Mode

| Field | Value |
|-------|-------|
| **Description** | The app shall prevent the device screen from auto-locking while Cook Mode is active. The screen shall remain on and interactive until the user explicitly exits Cook Mode or the recipe is completed. |
| **Motivation** | Users cooking have wet or messy hands and cannot tap to wake the screen. Losing the current step mid-recipe causes frustration and potential safety issues (e.g., missing a timer for hot oil). |
| **Fit Criteria** | `UIApplication.shared.isIdleTimerDisabled = true` set on Cook Mode entry and restored on exit; verified by leaving the device idle for 5+ minutes during Cook Mode without screen dimming. |
| **Product Use Case(s)** | MOD/PUC/006 |

### MOD/USE/005/1.0 Reduced Motion Support

| Field | Value |
|-------|-------|
| **Description** | The app shall respect the iOS "Reduce Motion" accessibility setting. When enabled, all non-essential animations (screen transitions, mascot animations, slide effects, spring physics) shall be replaced with simple fade or instant transitions. |
| **Motivation** | Users with vestibular disorders or motion sensitivity experience discomfort from animations. iOS guidelines require honouring this system preference. |
| **Fit Criteria** | With "Reduce Motion" enabled in iOS Settings, no parallax, spring, or slide animations occur; transitions use cross-fade or instant cut. Verified via Accessibility Inspector. |
| **Product Use Case(s)** | All PUCs |

## 4.5 Performance

### MOD/PERF/001/1.0 App Launch Time

| Field | Value |
|-------|-------|
| **Description** | The app shall launch and display the first meaningful screen within 1.5 seconds on supported devices. |
| **Motivation** | Fast launch time is critical for user retention and App Store quality standards. |
| **Fit Criteria** | 95th percentile launch-to-interactive < 1.5s measured on iPhone 14 or equivalent. |
| **Product Use Case(s)** | All PUCs |

### MOD/PERF/002/1.0 UI Frame Rate

| Field | Value |
|-------|-------|
| **Description** | UI interactions (list scrolling, animations, screen transitions) shall maintain 60fps on supported devices. |
| **Motivation** | Dropped frames create a perception of poor quality. |
| **Fit Criteria** | Instruments profiling shows no sustained frame drops below 60fps during normal usage. |
| **Product Use Case(s)** | All PUCs |

### MOD/PERF/003/1.0 Screen Load Time

| Field | Value |
|-------|-------|
| **Description** | Screen loads for cached data shall complete in under 300ms (95th percentile). |
| **Motivation** | Responsive navigation is essential for a smooth cooking experience. |
| **Fit Criteria** | Time from tap to full render < 300ms measured via performance traces. |
| **Product Use Case(s)** | All PUCs |

### MOD/PERF/004/1.0 Metadata Fetch Timeout

| Field | Value |
|-------|-------|
| **Description** | The metadata server request shall time out after 7 seconds with a graceful fallback. |
| **Motivation** | Prevent indefinite loading states from degrading import UX. |
| **Fit Criteria** | After 7s without response, fallback display shown; no spinner remains. |
| **Product Use Case(s)** | MOD/PUC/003 |

### MOD/PERF/005/1.0 Image Performance

| Field | Value |
|-------|-------|
| **Description** | Recipe images shall be lazy-loaded and cached. List virtualisation shall be used for recipe collections exceeding 50 items. |
| **Motivation** | Prevent memory issues and scrolling jank with large collections. |
| **Fit Criteria** | Memory usage stable during scroll of 100+ recipe list; images not re-downloaded on re-visit. |
| **Product Use Case(s)** | MOD/PUC/002, MOD/PUC/004 |

### MOD/PERF/006/1.0 Push Notifications for Timers

| Field | Value |
|-------|-------|
| **Description** | When Cook Mode is active and the user backgrounds the app, the system shall schedule a local notification to fire when the step timer reaches its target duration. Meal planner reminders shall be schedulable as local notifications for planned meal times. |
| **Motivation** | Users may switch apps or lock the screen while cooking; timer alerts must still reach them. Meal reminders drive daily engagement. |
| **Fit Criteria** | Local notification fires within 1 second of timer completion while app is backgrounded; notification includes step number and recipe title. Meal reminders fire at configured times. |
| **Product Use Case(s)** | MOD/PUC/006, MOD/PUC/008 |

### MOD/PERF/007/1.0 Image Optimisation & Bandwidth

| Field | Value |
|-------|-------|
| **Description** | Recipe images shall be served and cached in appropriate resolutions (thumbnail for grid, full for detail). Images uploaded by users shall be compressed to a maximum of 1MB before upload. The app shall not download full-resolution images on the Home grid. |
| **Motivation** | Recipe grids display many images simultaneously; unoptimised images waste bandwidth and memory, particularly on cellular connections. |
| **Fit Criteria** | Grid thumbnails served at max 400px width; detail images at max 1200px width; user-uploaded images compressed below 1MB; total data for Home grid load < 2MB for 20 recipes. |
| **Product Use Case(s)** | MOD/PUC/002, MOD/PUC/004, MOD/PUC/005 |

## 4.6 Operational & Environment

### MOD/OPER/001/1.0 CI/CD Pipeline

| Field | Value |
|-------|-------|
| **Description** | The project shall have a CI pipeline that runs build, lint (SwiftLint), and unit tests on every pull request. |
| **Motivation** | Automated quality gates prevent regressions. |
| **Fit Criteria** | PR cannot merge if CI fails; pipeline completes in < 10 minutes. |
| **Product Use Case(s)** | All PUCs |

### MOD/OPER/002/1.0 Environment Strategy

| Field | Value |
|-------|-------|
| **Description** | Three environments shall be maintained: Development, Staging, and Production, each with isolated Firebase projects. |
| **Motivation** | Environment isolation prevents test data from affecting production. |
| **Fit Criteria** | Each environment has its own Firebase project and configuration file. |
| **Product Use Case(s)** | All PUCs |

### MOD/OPER/003/1.0 Metadata Server Deployment

| Field | Value |
|-------|-------|
| **Description** | The optional metadata preview server shall be containerised with Docker and deployable to managed hosting with autoscaling. |
| **Motivation** | Containerisation ensures consistent deployment and scalability. |
| **Fit Criteria** | Docker image builds successfully; deployment scales to handle traffic spikes. |
| **Product Use Case(s)** | MOD/PUC/003 |

### MOD/OPER/004/1.0 App Binary Size

| Field | Value |
|-------|-------|
| **Description** | The initial App Store download size (thin binary + on-demand resources) shall not exceed 50MB. Asset catalogs shall use app thinning to deliver only the resources required for the target device. |
| **Motivation** | iOS prompts users for Wi-Fi download consent above certain size thresholds; a lean binary improves first-install conversion and reduces cellular data usage. |
| **Fit Criteria** | App Store Connect size report shows thin download size <= 50MB for all supported devices; verified on each release candidate build. |
| **Product Use Case(s)** | All PUCs |

## 4.7 Maintainability and Support

### MOD/MAIN/001/1.0 Code Quality

| Field | Value |
|-------|-------|
| **Description** | SwiftLint shall be enforced in CI. Unit test coverage shall target a minimum of 70% for core modules (ViewModels, Repositories, Services). |
| **Motivation** | Consistent code style and test coverage reduce maintenance burden. |
| **Fit Criteria** | SwiftLint passes with zero violations; coverage report shows >= 70% for targeted modules. |
| **Product Use Case(s)** | All PUCs |

### MOD/MAIN/002/1.0 Schema Versioning

| Field | Value |
|-------|-------|
| **Description** | Data schema changes shall be tracked via `schemaVersion` on User documents and `aiMeta.modelVersion` for AI outputs, with migration logic for version upgrades. |
| **Motivation** | Prevents data corruption during schema evolution. |
| **Fit Criteria** | Migration tests cover all version transitions; old-version data loads correctly in new app version. |
| **Product Use Case(s)** | All PUCs |

## 4.8 Logging

### MOD/LOG/001/1.0 Client Logging

| Field | Value |
|-------|-------|
| **Description** | The iOS app shall log errors and crashes via Firebase Crashlytics. Logs shall not contain PII. |
| **Motivation** | Crash diagnostics are essential for maintaining app stability. |
| **Fit Criteria** | Crashlytics integrated; crash-free sessions target > 99%; no PII found in log samples. |
| **Product Use Case(s)** | All PUCs |

### MOD/LOG/002/1.0 Server Logging

| Field | Value |
|-------|-------|
| **Description** | Server-side logs (metadata server, Cloud Functions) shall use structured JSON format and shall not contain PII. |
| **Motivation** | Structured logs enable efficient monitoring and debugging. |
| **Fit Criteria** | All log entries are valid JSON; PII redaction verified by log audit. |
| **Product Use Case(s)** | MOD/PUC/003, MOD/PUC/005 |

### MOD/LOG/003/1.0 Audit Trail

| Field | Value |
|-------|-------|
| **Description** | Minimal action logs (recipe created/edited/deleted, purchases) shall be maintained per user with a configurable retention period. |
| **Motivation** | Supports debugging, user support, and compliance audits. |
| **Fit Criteria** | Action log entries created for CRUD operations; retention policy applied. |
| **Product Use Case(s)** | All PUCs |

## 4.9 Compliance

### MOD/COMP/001/1.0 GDPR Compliance

| Field | Value |
|-------|-------|
| **Description** | The system shall provide user data export and account deletion endpoints. A privacy policy shall be accessible in-app and on the App Store listing. |
| **Motivation** | GDPR requires data portability and the right to be forgotten. |
| **Fit Criteria** | Data export produces complete user data in JSON format; account deletion removes all user data from Firestore within 30 days; privacy policy link functional. |
| **Product Use Case(s)** | MOD/PUC/010 |
| **References** | GDPR Articles 15, 17, 20 |

### MOD/COMP/002/1.0 Apple App Store Compliance

| Field | Value |
|-------|-------|
| **Description** | All digital premium features shall be purchased exclusively via Apple IAP. No external payment gating of digital content is permitted. AI feature descriptions shall accurately reflect current capabilities. |
| **Motivation** | App Store rejection prevention; required by Apple guidelines. |
| **Fit Criteria** | App Review passes without payment-related rejections; no misleading AI claims. |
| **Product Use Case(s)** | MOD/PUC/009 |
| **References** | [3] Apple App Store Review Guidelines |

### MOD/COMP/003/1.0 Accessibility Standards

| Field | Value |
|-------|-------|
| **Description** | The app shall meet WCAG AA contrast ratios and provide full VoiceOver compatibility. |
| **Motivation** | Regulatory accessibility requirements and inclusive design. |
| **Fit Criteria** | All text meets 4.5:1 contrast ratio (normal) or 3:1 (large); VoiceOver audit passes. |
| **Product Use Case(s)** | All PUCs |
| **References** | WCAG 2.1 Level AA |

### MOD/COMP/004/1.0 Localisation Readiness

| Field | Value |
|-------|-------|
| **Description** | All user-facing strings shall be externalised into `.xcstrings` / String Catalog files. The initial release shall ship with English (en). The architecture shall support adding additional locales without code changes — only new translation files. |
| **Motivation** | A recipe app has global appeal; early internationalisation reduces retrofitting cost. String Catalogs are the modern Xcode approach for localisation. |
| **Fit Criteria** | Zero hard-coded user-facing strings in Swift source; adding a new `.xcstrings` locale and translations produces a fully localised build with no code changes; verified by enabling pseudo-localisation in Xcode scheme. |
| **Product Use Case(s)** | All PUCs |

---

## Appendix A: Traceability Matrix

| Product UC | System Req | Detailed Req | Data Entity | Test Cases |
|------------|------------|--------------|-------------|------------|
| PUC/001 | SYS/001, SYS/007 | — | DATA/001 | TC-001..TC-004, TC-060..TC-064 |
| PUC/002 | SYS/002 | — | DATA/002 | TC-010..TC-015 |
| PUC/003 | SYS/003 | SYS/003.1, SYS/003.2, SYS/003.3 | DATA/002, DATA/005 | TC-020..TC-028 |
| PUC/004 | SYS/004 | — | DATA/002 | TC-030..TC-036 |
| PUC/005 | SYS/005 | SYS/005.1 | DATA/002 | TC-040..TC-046 |
| PUC/006 | SYS/006 | — | DATA/002 | TC-050..TC-055 |
| PUC/007 | SYS/008 | — | DATA/003 | TC-070..TC-075 |
| PUC/008 | SYS/009 | SYS/009.1, SYS/009.2 | DATA/004, DATA/007 | TC-080..TC-087 |
| PUC/009 | SYS/010, SYS/011 | — | DATA/006 | TC-090..TC-103 |
| PUC/010 | SYS/012 | SYS/012.1 | DATA/001, DATA/007 | TC-110..TC-114 |
| PUC/011 | SYS/013 | — | DATA/002 | TC-120..TC-124 |
| — | SYS/014 | — | All | TC-130..TC-133 |

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| ClipCook | The iOS recipe management application |
| Recipe | A stored cooking recipe with ingredients, steps, and metadata |
| Share Extension | iOS extension allowing users to share content from other apps to ClipCook |
| App Group | iOS shared data container between the main app and its extensions |
| Meal Slot | A position in the daily meal plan (e.g., Breakfast, Dinner) |
| Quick Add | A pre-defined snack item with known nutrition values |
| Feature Flag | A per-user toggle controlling access to specific features |
| Cook Mode | Full-screen step-by-step cooking guidance interface |
| Macro Tracker | Premium daily nutrition tracking widget showing calories and macronutrient progress |
| NoOpAnalyzer | Placeholder class that does nothing when AI is disabled |

## Appendix C: Risks & Mitigations

| Risk ID | Risk | Impact | Likelihood | Mitigation |
|---------|------|--------|------------|------------|
| RISK-001 | Share Extension behaviour inconsistent across iOS versions | High | Medium | Extensive testing on real devices across iOS 17–18 |
| RISK-002 | App Store rejection due to payment or misleading AI claims | High | Low | Use IAP exclusively; clearly label AI as optional/premium |
| RISK-003 | Firestore security rules misconfigured, causing data leaks | Critical | Low | Write and test rules in Firebase emulator; peer review all rule changes |
| RISK-004 | Subscription fraud via receipt manipulation | Medium | Low | Server-side receipt validation; RevenueCat as additional layer |
| RISK-005 | Data conflicts after extended offline periods | Medium | Medium | Conflict resolution modal with keep local/remote/merge options |

## Appendix D: Screenshot Index

All screenshots referenced in this document are located in the `docs/assets/` directory:

| File | Description | Referenced In |
|------|-------------|---------------|
| `01-onboarding-slide1.png` | Onboarding — "Clip It" slide with chef mascot | PUC/001 |
| `01-onboarding-slide2.png` | Onboarding — "Cook It" slide with chef mascot | PUC/001 |
| `01-onboarding-slide3.png` | Onboarding — "Keep It" slide with chef mascot | PUC/001 |
| `02-signin.png` | Sign In screen with Google, Apple, Email options | PUC/001 |
| `03-home.png` | Home screen — 2-column recipe grid with search and filters | PUC/002 |
| `04-import.png` | Import screen — URL input, Share Extension info | PUC/003 |
| `04-import-success.png` | Import success — preview bottom sheet with recipe data | PUC/003 |
| `04-import-failed.png` | Import failure — error card with sad chef mascot | PUC/003 |
| `05-recipe-detail.png` | Recipe detail — hero image, ingredients, steps, nutrition | PUC/004 |
| `06-recipe-edit.png` | Recipe edit — form with photo, ingredients, steps, nutrition | PUC/005 |
| `07-cook-mode.png` | Cook mode — step-by-step with timer and progress | PUC/006 |
| `08-shopping.png` | Shopping list — empty state with recipe suggestions | PUC/007 |
| `08-shopping-filled.png` | Shopping list — items with checkboxes and recipe attribution | PUC/007 |
| `09-planner.png` | Meal planner — empty with locked macro tracker | PUC/008 |
| `09-planner-add-meal.png` | Meal planner — add meal bottom sheet (recipes tab) | PUC/008 |
| `09-planner-with-meal.png` | Meal planner — meal added to timeline | PUC/008 |
| `09-planner-premium.png` | Meal planner — premium macro tracker with gauges | PUC/008 |
| `10-settings.png` | Settings — free mode with preferences and feature flags | PUC/010 |
| `10-settings-premium.png` | Settings — premium mode with nutrition goal sliders | PUC/009, PUC/010 |
| `11-archived-recipes.png` | Archived recipes — list with restore/delete actions | PUC/011 |
