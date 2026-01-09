# Testing Checklist for UI/UX Improvements

Use this checklist to verify that all implemented features are working correctly in the Cluck app.

---

## Pre-Testing Setup

- [ ] **Build the app successfully** (Cmd+B)
- [ ] **Run on a physical device** (for haptic feedback testing)
- [ ] **Grant location permission** when prompted
- [ ] **Configure Yelp API key** in Config.swift
- [ ] **Fresh app install** recommended (for SwiftData schema migration)

---

## Phase 1: Card Enhancements

### Star Rating and Review Count
- [ ] Cards display star rating (1-5 yellow stars)
- [ ] Review count shown in parentheses, e.g., "(234)"
- [ ] Rating appears between name and type/price row
- [ ] Only displays when data is available (Yelp API)
- [ ] Stars are properly aligned and readable

### Distance Display
- [ ] Distance shows in miles with one decimal place
- [ ] Location icon appears next to distance
- [ ] Distance updates correctly for different restaurants
- [ ] Positioned in the info row with type and price
- [ ] Only shows when user location is available

### Card Stack Peek
- [ ] Can see 2-3 cards stacked behind the top card
- [ ] Cards behind are slightly scaled down
- [ ] Cards behind are offset vertically
- [ ] Only the top card responds to touch/gestures
- [ ] Cards animate smoothly when one is removed
- [ ] Z-index ordering is correct (top card always on top)

---

## Phase 2: Haptic Feedback

### Swipe Haptics (Physical Device Only)
- [ ] **Medium impact** felt when card crosses threshold (~100pt)
- [ ] **Success notification** felt on right swipe (save)
- [ ] **Success notification** felt on left swipe (skip)
- [ ] **Light impact** felt when card snaps back to center
- [ ] Haptic triggers only once when crossing threshold
- [ ] No haptics felt in simulator (expected behavior)

---

## Phase 3: Visual Polish

### Enhanced Card Shadows
- [ ] Cards have visible depth/elevation
- [ ] Shadow is prominent but not overwhelming
- [ ] Shadow looks good against gradient background
- [ ] Shadow remains visible during swipe animation

### Enhanced Detail View
- [ ] **Hero image** is taller (350pt)
- [ ] **Parallax effect** works when scrolling (image scales/moves)
- [ ] **Star rating** displays below restaurant name
- [ ] **Circular action buttons** appear in horizontal row:
  - [ ] Call button (blue circle) works
  - [ ] Directions button (green circle) opens Maps
  - [ ] Share button (orange circle) shows share sheet
- [ ] **Open/Closed badge** shows (if data available)
- [ ] **Photo gallery** displays (if additional photos available)
- [ ] All elements are properly spaced and aligned
- [ ] Detail view scrolls smoothly

---

## Phase 4: New Features

### Undo Last Swipe
- [ ] Undo button appears in top-right after swiping
- [ ] Undo button shows "arrow.uturn.backward" icon + "Undo" text
- [ ] Undo button has subtle white capsule background
- [ ] Clicking undo brings back the last card
- [ ] Undo button disappears after being used
- [ ] Can only undo once (not multiple levels)
- [ ] Animation is smooth (spring animation)

### "Open Now" Badge
- [ ] Badge appears on cards (top-right corner)
- [ ] Green badge for "Open" restaurants
- [ ] Red badge for "Closed" restaurants
- [ ] Badge has clock icon
- [ ] Badge is readable against card image
- [ ] Badge has proper shadow/visibility
- [ ] Badge also appears in detail view

### Share Functionality
- [ ] Share button works in detail view
- [ ] Share sheet shows with proper text
- [ ] Message includes restaurant name and address
- [ ] Message includes "Found on Cluck 🍗"
- [ ] All standard share options available (Messages, Mail, etc.)

### Photo Gallery
- [ ] Gallery appears in detail view when photos available
- [ ] Photos load asynchronously
- [ ] Can scroll horizontally through photos
- [ ] Photos are 120x120 with rounded corners
- [ ] Placeholder shows while loading
- [ ] Section only appears when photos exist

---

## Data Integration

### Yelp API Data
- [ ] Restaurant images load from Yelp
- [ ] Star ratings come from Yelp API
- [ ] Review counts are accurate
- [ ] Price range matches Yelp data
- [ ] Restaurant type/category is correct
- [ ] Phone numbers are properly formatted
- [ ] Website URLs work correctly

### Location Services
- [ ] App requests location permission on first launch
- [ ] Restaurants load based on current location
- [ ] Distance calculations are accurate
- [ ] Search radius is appropriate (~5km)
- [ ] Works in simulator with simulated location
- [ ] Works on device with real GPS

### Persistence (SwiftData)
- [ ] Favorited restaurants save correctly
- [ ] All new fields persist (rating, reviewCount, etc.)
- [ ] Saved restaurants display in "Saved" tab
- [ ] Can unfavorite from detail view
- [ ] Favorites persist across app launches
- [ ] No crashes on save/load

---

## Swipe Gestures

### Basic Swipe Functionality
- [ ] Can swipe right (save to favorites)
- [ ] Can swipe left (skip)
- [ ] Card rotates while dragging
- [ ] Card snaps back if not swiped far enough
- [ ] Swipe animation is smooth
- [ ] Next card appears after swipe

### Advanced Interactions
- [ ] Can tap card to see detail view
- [ ] Cards in background don't respond to tap
- [ ] Drag threshold is comfortable (~100pt)
- [ ] Animation timing feels natural (0.3s)
- [ ] Cards don't get stuck mid-swipe

---

## Navigation & UI

### Tab Bar
- [ ] "Discover" tab shows swipe deck
- [ ] "Saved" tab shows favorites list
- [ ] Tab icons are visible and appropriate
- [ ] Selected tab is highlighted
- [ ] Tab bar matches app color scheme

### Empty States
- [ ] Loading state shows progress indicator
- [ ] "No restaurants found" shows appropriate message
- [ ] Error states show helpful text
- [ ] Empty saved list shows appropriate message
- [ ] Can refresh to try loading again

### Overall Polish
- [ ] App color scheme is consistent (orange/red gradient)
- [ ] All text is readable with proper contrast
- [ ] Icons are appropriate and recognizable
- [ ] Spacing and padding feel balanced
- [ ] No visual glitches or layout issues
- [ ] Works in both light and dark mode (if applicable)

---

## Performance

- [ ] Cards animate at 60fps
- [ ] No lag when swiping
- [ ] Images load quickly
- [ ] App doesn't crash during normal use
- [ ] Memory usage is reasonable
- [ ] Battery drain is acceptable

---

## Edge Cases

### Data Scenarios
- [ ] Works when restaurant has no image (gradient fallback)
- [ ] Works when restaurant has no rating (doesn't display)
- [ ] Works when restaurant has no reviews (doesn't display)
- [ ] Works when restaurant has no website (Google search fallback)
- [ ] Works when restaurant has no phone number (no call button)
- [ ] Works when no additional photos (gallery doesn't show)

### User Scenarios
- [ ] Works without location permission (shows error)
- [ ] Works when location services disabled
- [ ] Works with no internet connection (cached data)
- [ ] Works when Yelp API fails (MapKit fallback)
- [ ] Works when all cards are swiped (empty state)
- [ ] Works when no favorites saved yet

---

## Testing Summary

**Total Items:** ~90 checkpoints

**Categories:**
- Card Enhancements: 15 items
- Haptic Feedback: 6 items
- Visual Polish: 12 items
- New Features: 18 items
- Data Integration: 18 items
- Swipe Gestures: 11 items
- Navigation & UI: 10 items

**Priority Testing:**
1. ⭐ Card stack and swipe gestures
2. ⭐ Star ratings and distance display
3. ⭐ Undo functionality
4. ⭐ Detail view enhancements
5. ⭐ Haptic feedback (on device)

---

## Bug Reporting Template

If you find issues, document them with:

**Issue:** [Brief description]  
**Steps to Reproduce:** [How to trigger the bug]  
**Expected Behavior:** [What should happen]  
**Actual Behavior:** [What actually happens]  
**Device:** [iPhone model, iOS version]  
**Screenshot:** [If applicable]

---

## Success Criteria

✅ **Must Have:**
- All cards display with ratings and distance
- Swipe gestures work smoothly
- Detail view shows all information
- Undo button functions correctly
- App doesn't crash

✅ **Should Have:**
- Haptic feedback works on device
- Open/Closed badges display
- Photo gallery shows when available
- Share functionality works

✅ **Nice to Have:**
- All Yelp data displays correctly
- Parallax scroll effect is smooth
- Animations feel polished

---

**Last Updated:** January 7, 2026  
**Version:** 1.0 with UI/UX Enhancements
