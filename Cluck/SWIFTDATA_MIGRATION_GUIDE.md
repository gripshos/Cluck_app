# SwiftData Schema Migration Guide

## Overview
The UI/UX improvements added new properties to the `FavoriteRestaurant` SwiftData model. This document explains how to handle the schema migration.

---

## What Changed

### New Properties in FavoriteRestaurant
```swift
var rating: Double?              // Star rating (1.0 to 5.0)
var reviewCount: Int?            // Number of reviews
var isOpenNow: Bool?            // Current open/closed status
var additionalPhotosData: Data? // JSON encoded photo URLs
```

---

## Migration Options

### Option 1: Fresh Install (Recommended for Development)

**Steps:**
1. Delete the app from your device/simulator
2. Clean build folder in Xcode (Shift+Cmd+K)
3. Build and run the app
4. All favorites will be empty (fresh start)

**Pros:**
- Simple and guaranteed to work
- No migration code needed
- Clean slate for testing

**Cons:**
- Users lose saved favorites
- Only acceptable during development

---

### Option 2: Automatic Migration (SwiftData Default)

**How it works:**
SwiftData automatically migrates your schema when you add optional properties (marked with `?`). Since all new properties are optional, migration should work automatically.

**Steps:**
1. Build and run the app
2. SwiftData detects schema changes
3. Existing favorites get `nil` for new properties
4. New favorites get populated values

**Pros:**
- Users keep their favorites
- No code changes needed
- Works automatically

**Cons:**
- Existing favorites won't have ratings/reviews/photos
- Only new saves will have complete data

**Expected Behavior:**
```swift
// Existing favorite (saved before update)
FavoriteRestaurant {
    name: "Raising Cane's"
    rating: nil              // ← Won't display star rating
    reviewCount: nil         // ← Won't show review count
    isOpenNow: nil          // ← Won't show open badge
    additionalPhotosData: nil // ← Won't show photo gallery
}

// New favorite (saved after update)
FavoriteRestaurant {
    name: "Popeyes"
    rating: 4.5              // ✓ Shows star rating
    reviewCount: 234         // ✓ Shows review count
    isOpenNow: true         // ✓ Shows "Open" badge
    additionalPhotosData: <data> // ✓ Shows photo gallery
}
```

---

### Option 3: Manual Migration (For Production Apps)

If you need to preserve existing favorites AND add new data, you'll need custom migration logic.

**Implementation:**
```swift
// In CluckApp.swift or a dedicated migration file

import SwiftData

@MainActor
func migrateSchema() async {
    let container = try! ModelContainer(for: FavoriteRestaurant.self)
    let context = container.mainContext
    
    let descriptor = FetchDescriptor<FavoriteRestaurant>()
    let favorites = try! context.fetch(descriptor)
    
    for favorite in favorites {
        // Skip if already has rating (already migrated)
        guard favorite.rating == nil else { continue }
        
        // Attempt to fetch updated data from Yelp
        // This requires network call and Yelp API
        if let tender = await fetchUpdatedData(for: favorite) {
            favorite.rating = tender.rating
            favorite.reviewCount = tender.reviewCount
            favorite.isOpenNow = tender.isOpenNow
            // ... update other fields
        }
    }
    
    try! context.save()
}

@MainActor
func fetchUpdatedData(for favorite: FavoriteRestaurant) async -> Tender? {
    // Use YelpService to search by name and coordinates
    // Return updated Tender with all new fields
    // This is a network operation and may fail
    return nil // Implement based on your needs
}
```

**Pros:**
- Users keep favorites with updated data
- Complete information for all restaurants

**Cons:**
- Complex to implement
- Requires network calls
- May hit API rate limits
- Migration can take time

---

## Recommended Approach

### For Development/Beta Testing:
**Use Option 1 (Fresh Install)**
- Simple and reliable
- Acceptable to lose test data
- Ensures clean slate

### For Production Release:
**Use Option 2 (Automatic Migration)**
- No development effort
- Users keep their favorites
- Existing favorites just won't show new UI elements
- New favorites will have full functionality

### For Premium User Experience:
**Use Option 3 (Manual Migration)**
- Best user experience
- Requires significant development
- Consider as a future enhancement

---

## Testing Migration

### Test Case 1: Fresh Install
1. Delete app
2. Install new version
3. Add favorites
4. Verify all new fields display

**Expected Result:** ✅ All new UI elements work

### Test Case 2: Upgrade with Existing Data
1. Install old version
2. Add some favorites
3. Install new version (without deleting)
4. Check existing favorites
5. Add new favorites

**Expected Results:**
- ✅ Old favorites still appear in list
- ℹ️ Old favorites missing ratings/reviews in detail view
- ✅ New favorites have full data

### Test Case 3: Schema Conflict
If you get a SwiftData error about schema mismatch:

1. Check console for specific error message
2. Delete app and reinstall
3. If problem persists, verify:
   - All properties are optional (`?`)
   - Property types match exactly
   - No @Transient properties added

---

## Rollback Plan

If migration causes issues in production:

### Quick Fix
```swift
// In FavoriteRestaurant.swift
// Temporarily comment out new properties

// var rating: Double?
// var reviewCount: Int?
// var isOpenNow: Bool?
// var additionalPhotosData: Data?
```

Then rebuild and redeploy. This reverts to old schema.

### Proper Fix
1. Investigate specific migration error
2. Add migration code if needed
3. Test thoroughly before re-deploying

---

## User Communication

### In-App Message (Optional)
If you expect migration issues, consider showing:

```swift
if !UserDefaults.standard.bool(forKey: "hasSeenMigrationMessage") {
    // Show alert
    "We've improved how we save your favorite restaurants! 
     Your saved places are safe, but may be missing some new 
     information like ratings and photos. These will be added 
     when you save new favorites."
    
    UserDefaults.standard.set(true, forKey: "hasSeenMigrationMessage")
}
```

---

## Technical Details

### SwiftData Migration Behavior

**Automatic Migration Works When:**
- Adding optional properties
- Adding default values for required properties
- Renaming properties (with migration hints)

**Manual Migration Required When:**
- Changing property types
- Adding required properties without defaults
- Complex data transformations
- Relationship changes

**Our Case:**
All new properties are **optional**, so SwiftData handles migration automatically.

---

## FAQ

**Q: Will my app crash on launch after updating?**  
A: No, SwiftData handles optional property additions automatically.

**Q: Will users lose their favorites?**  
A: No, all existing favorites will be preserved.

**Q: Will old favorites show the new UI elements?**  
A: No, they'll have `nil` values for new fields. UI handles this gracefully.

**Q: How do I force a fresh database?**  
A: Delete and reinstall the app, or use ModelConfiguration with `isStoredInMemoryOnly: true` for testing.

**Q: Can I migrate data in the background?**  
A: Yes, but requires implementing Option 3 (Manual Migration) with network calls.

---

## Summary

✅ **For most cases:** Do nothing, SwiftData handles it  
✅ **For testing:** Fresh install recommended  
✅ **For production:** Automatic migration is fine  
🔄 **For perfect UX:** Implement manual migration (future enhancement)

---

**Last Updated:** January 7, 2026  
**SwiftData Version:** iOS 17+  
**Migration Status:** Automatic (No Action Required)
