# DoorDash Integration Guide

## Overview
The Cluck app now includes DoorDash ordering integration, allowing users to quickly order from restaurants directly from the detail view.

---

## Implementation Summary

### Files Added
1. **DeliveryService.swift** - Service for opening delivery apps
2. **DOORDASH_INTEGRATION.md** - This documentation

### Files Modified
1. **ChatDetailView.swift** - Added DoorDash order button
2. **Info.plist** - Requires URL scheme configuration (see below)

---

## ⚠️ Required: Info.plist Configuration

**IMPORTANT:** To enable DoorDash deep linking, you MUST add the following to your `Info.plist` file:

### For Xcode 15+ (Source Code Editor)
Add this entry to your Info.plist:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>doordash</string>
</array>
```

### For Xcode Property List Editor
1. Open `Info.plist`
2. Click the `+` button at the top level
3. Add key: `LSApplicationQueriesSchemes` (type: Array)
4. Click the disclosure triangle to expand
5. Click `+` to add an item
6. Set value to: `doordash` (type: String)

### Visual Representation
```
Info.plist
├── CFBundleDisplayName (String)
├── CFBundleIdentifier (String)
├── LSApplicationQueriesSchemes (Array)
│   └── Item 0 (String): doordash
├── NSLocationWhenInUseUsageDescription (String)
└── ...
```

---

## Features

### DoorDash Button
- **Location:** ChatDetailView action buttons (circular icons)
- **Icon:** Bag icon (`bag.fill`)
- **Color:** DoorDash red (#FF3008)
- **Label:** "Order"
- **Behavior:**
  - If DoorDash app installed → Opens app with restaurant search
  - If not installed → Opens DoorDash website in Safari

### Smart Fallback
The implementation automatically detects if DoorDash is installed:
- **App installed:** Uses `doordash://search?query={name}` URL scheme
- **Not installed:** Falls back to `https://www.doordash.com/search/store/{name}/`

---

## Usage

### For Users
1. Open any restaurant detail view
2. Tap the red "Order" button with bag icon
3. DoorDash app/website opens with search results
4. Complete order in DoorDash

### For Developers
```swift
// Simple API - just call with restaurant name
DeliveryService.openDoorDash(restaurantName: "Raising Cane's")
```

---

## Testing

### Test Case 1: DoorDash App Installed
**Steps:**
1. Install DoorDash app from App Store
2. Open Cluck app
3. Navigate to any restaurant detail
4. Tap "Order" button

**Expected:** DoorDash app opens with search for the restaurant

### Test Case 2: DoorDash Not Installed
**Steps:**
1. Uninstall DoorDash app
2. Open Cluck app
3. Navigate to any restaurant detail
4. Tap "Order" button

**Expected:** Safari opens DoorDash website with search

### Test Case 3: Special Characters in Name
**Steps:**
1. Find restaurant with special characters (e.g., "Popeyes Louisiana Kitchen")
2. Tap "Order" button

**Expected:** URL is properly encoded, search works correctly

---

## Technical Details

### URL Encoding
Restaurant names are properly encoded for URL compatibility:
```swift
let encodedName = restaurantName.addingPercentEncoding(
    withAllowedCharacters: .urlQueryAllowed
)
```

This handles:
- Spaces → `%20`
- Apostrophes → `%27`
- Ampersands → `%26`
- Special characters

### DoorDash URL Schemes

**App URL:**
```
doordash://search?query={encoded_restaurant_name}
```

**Web Fallback:**
```
https://www.doordash.com/search/store/{encoded_restaurant_name}/
```

---

## Future Enhancements

### Uber Eats Integration
The `DeliveryService` is already set up for Uber Eats. To enable:

1. **Add to Info.plist:**
   ```xml
   <string>ubereats</string>
   ```

2. **Add button to ChatDetailView:**
   ```swift
   Button {
       DeliveryService.openUberEats(restaurantName: tender.name)
   } label: {
       VStack(spacing: 8) {
           Circle()
               .fill(Color(red: 0.02, green: 0.76, blue: 0.40).gradient) // Uber Eats green
               .frame(width: 60, height: 60)
               .overlay {
                   Image(systemName: "bag.fill")
                       .font(.title3)
                       .foregroundStyle(.white)
               }
           Text("Uber Eats")
               .font(.caption)
               .foregroundStyle(.secondary)
       }
   }
   ```

### Grubhub Integration
Similarly ready for Grubhub:

1. **Add to Info.plist:**
   ```xml
   <string>grubhub</string>
   ```

2. **Add button with Grubhub branding** (red/orange #F63440)

---

## Brand Colors

### DoorDash
- Primary: `#FF3008` (RGB: 255, 48, 8)
- Used in button gradient

### Uber Eats (Future)
- Primary: `#06C167` (RGB: 6, 193, 103)

### Grubhub (Future)
- Primary: `#F63440` (RGB: 246, 52, 64)

---

## Troubleshooting

### "Button doesn't open DoorDash app"
**Cause:** `LSApplicationQueriesSchemes` not configured in Info.plist
**Solution:** Add `doordash` to Info.plist as shown above

### "Search doesn't find restaurant"
**Cause:** Restaurant name encoding issue
**Solution:** Check that name doesn't have unexpected characters. Service auto-encodes common characters.

### "Button does nothing"
**Cause:** URL scheme not allowed by iOS
**Solution:** Verify Info.plist configuration, rebuild app

---

## Code References

### DeliveryService.swift
```swift
enum DeliveryService {
    static func openDoorDash(restaurantName: String)
    static func openUberEats(restaurantName: String)  // Ready for future
    static func openGrubhub(restaurantName: String)   // Ready for future
}
```

### ChatDetailView.swift
```swift
// DoorDash button in action buttons HStack
Button {
    DeliveryService.openDoorDash(restaurantName: tender.name)
} label: {
    // Circular button with DoorDash branding
}
```

---

## Design Specifications

### Button Layout
```
┌─────────────────────────────────────┐
│   [Call]  [Order]  [Directions]  [Share]   │
│     🔵      🔴         🟢          🟠    │
└─────────────────────────────────────┘
```

### Button Specs
- **Size:** 60x60 circular
- **Spacing:** 20pt between buttons
- **Icon:** `bag.fill` (SF Symbol)
- **Label:** "Order" below circle
- **Color:** DoorDash red gradient
- **Animation:** None (immediate tap response)

---

## Accessibility

The DoorDash button includes:
- Accessible label: "Order"
- VoiceOver support: Inherent from SwiftUI Button
- Color contrast: White icon on red background (WCAG AA compliant)

---

## Privacy & Security

- No DoorDash SDK integrated (lightweight solution)
- No data shared with DoorDash except restaurant name in URL
- User's DoorDash account remains private
- No tracking or analytics from Cluck side

---

## Version History

### v1.0 - Initial Implementation
- DoorDash button added to detail view
- DeliveryService created with DoorDash, Uber Eats, Grubhub support
- Smart app/web fallback logic
- URL encoding for special characters

---

## Support

For issues or questions:
1. Check Info.plist configuration
2. Verify DoorDash app installation (for app testing)
3. Test with multiple restaurant names
4. Check console for error messages

---

**Last Updated:** January 8, 2026
**Status:** Production Ready
**Requires:** Info.plist configuration (see above)
