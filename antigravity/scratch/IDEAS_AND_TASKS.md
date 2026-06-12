# BodyFit / Fashion Try-On App — Ideas & Task List

Fashion app where users upload **photos + sizes**, and when they upload **photos of a dress** (or other clothing), the app **shows how the dress will look** on them.

---

## ✅ Already implemented

| Feature | Status | Where |
|--------|--------|--------|
| **Onboarding** | Done | Welcome → multi-step questionnaire → optional body photo |
| **User measurements** | Done | Height, weight, bust, waist, hip, shoulders (cm/kg) in `BodyProfile` |
| **Body concerns & fit preference** | Done | Stomach, shoulders, hips, etc. + Loose / Balanced / Fitted in questionnaire |
| **Body shape detection** | Done | Apple, pear, hourglass, rectangle, inverted triangle via `ShapeClassifier` + optional `VisionAnalyzer` |
| **Body photo (optional)** | Done | Stored in onboarding; used for virtual try-on and shape refinement |
| **Add clothing** | Done | Photo + name + category (Top, Bottom, Dress, Outerwear, Activewear) in `ClothingUploadView` |
| **Wardrobe gallery** | Done | Grid of items, tap → Try On in `ClothingGalleryView` |
| **Fit analysis** | Done | `FitEngine`: score, tight/loose areas, suggestions, style advice by shape + category |
| **Virtual try-on** | Done | Hugging Face `yisol/IDM-VTON`: body image + clothing image → result in `TryOnView` |
| **Profile screen** | Done | View/edit measurements, shape, tips in `BodyProfileView` |
| **Settings** | Done | HF API token, reset profile in `SettingsView` |
| **App shell** | Done | Tabs: Home, Wardrobe, Profile, Settings; dark theme, persistence |

**Key files:** `BodyFitApp/` (SwiftUI), Models: `BodyProfile`, `ClothingItem`, `FitRecommendation`, `BodyShape`; Services: `HuggingFaceAPI`, `FitEngine`, `VisionAnalyzer`, `ShapeClassifier`.

---

## ❌ Pending (not implemented)

### Implemented in this pass
- [x] **Clothing size** — Size picker (XS–XXL, One Size) when adding clothing; stored on `ClothingItem`; shown in gallery cards and Try On header.
- [x] **Size in fit logic** — FitEngine uses a size chart and compares garment size to recommended size; score adjustment and `sizeAdvice` / `recommendedSize` in fit card.
- [x] **Dress-first flow** — Home has “Try on a dress” card; recent items and wardrobe list show dresses first.
- [x] **Try-on robustness** — Retry button on error; clear no-token message in try-on section.
- [x] **Body photo guidelines** — “Tips for best results” sheet (pose, lighting, background, frame) in onboarding and Try On.
- [x] **Save try-on results** — “Save Result” saves image; `lastTryOnImagePath` on item; last saved try-on shown on Try On screen.
- [x] **Size recommendation** — “We recommend size M” and comparison with item size in fit analysis.
- [x] **Dress-specific fit rules** — Extra suggestions by shape (length, neckline, sleeve) for dresses in FitEngine.
- [x] **No-token fallback** — Copy in try-on section: fit analysis works without token; add token in Settings for virtual try-on.

### Still pending (nice-to-have)
- [ ] **Multiple garments** — Try on top + bottom or layers (not supported).
- [ ] **Wardrobe filters** — Filter by category or size (dresses are sorted first only).
- [ ] **Imperial units** — Only metric (cm/kg); no inches/lbs.

---

## Quick reference: user flow

1. **Onboarding** → sizes/measurements + optional body photo.
2. **Add dress** → upload photo, name, category (Dress), **+ size (to add)**.
3. **Wardrobe** → tap dress → **Try On** screen: fit analysis + “Try On” button → **see how the dress will look** (HF API).
4. **Profile** → edit measurements; **Settings** → HF token.

Use this doc to track what’s done and what to build next for the fashion try-on app.
