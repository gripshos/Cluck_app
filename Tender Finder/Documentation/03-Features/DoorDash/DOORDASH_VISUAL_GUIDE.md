# Visual Integration Guide

## 🎨 Button Layout in ChatDetailView

### Before (3 buttons)
```
┌─────────────────────────────────────────────┐
│                                             │
│   Restaurant Photo                          │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│   Restaurant Name                           │
│   ⭐⭐⭐⭐⭐ 4.5 (250 reviews)               │
│   🍴 Fast Food         $$                   │
│                                             │
│   ┌─────┐    ┌─────┐    ┌─────┐           │
│   │  📞 │    │  🧭 │    │  📤 │           │
│   │Call │    │Dirs │    │Share│           │
│   └─────┘    └─────┘    └─────┘           │
│                                             │
└─────────────────────────────────────────────┘
```

### After (4 buttons - DoorDash added)
```
┌─────────────────────────────────────────────┐
│                                             │
│   Restaurant Photo                          │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│   Restaurant Name                           │
│   ⭐⭐⭐⭐⭐ 4.5 (250 reviews)               │
│   🍴 Fast Food         $$                   │
│                                             │
│   ┌────┐  ┌────┐  ┌────┐  ┌────┐          │
│   │ 📞 │  │ 🛍️ │  │ 🧭 │  │ 📤 │          │
│   │Call│  │Ordr│  │Dirs│  │Shr │          │
│   └────┘  └────┘  └────┘  └────┘          │
│            ↑                                │
│         NEW!                                │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🎨 Button Visual Specs

### DoorDash Button Details
```
┌─────────────────────┐
│                     │
│    ┌─────────┐      │
│    │         │      │  Circle: 60x60
│    │  🛍️     │      │  Color: DoorDash red gradient
│    │         │      │  Icon: bag.fill
│    └─────────┘      │
│                     │
│      Order          │  Label: "Order"
│                     │  Font: Caption
└─────────────────────┘
```

### Color Breakdown
```
DoorDash Red Gradient:
┌────────────────────┐
│ #FF3008            │ ← Top color
│     ↓              │
│ #E60A00            │ ← Bottom color
└────────────────────┘

RGB Values:
Top:    (255, 48, 8)
Bottom: (230, 10, 0)
```

---

## 📱 User Flow

### Flow Diagram
```
User opens restaurant detail
         ↓
Sees "Order" button (red, with bag icon)
         ↓
Taps button
         ↓
    ┌─────────────┐
    │ iOS checks  │
    │ DoorDash    │
    │ installed?  │
    └─────────────┘
         ↓
    ┌────┴────┐
    │         │
   Yes       No
    │         │
    ↓         ↓
┌──────┐  ┌──────┐
│ Open │  │ Open │
│ App  │  │ Web  │
└──────┘  └──────┘
    │         │
    ↓         ↓
Search for restaurant in DoorDash
```

---

## 📂 File Structure

### Project Layout
```
Cluck/
├── ChatDetailView.swift ← Modified (DoorDash button added)
├── DeliveryService.swift ← NEW (handles deep linking)
├── ContentView.swift
├── RootView.swift
├── SwipeDeckView.swift
├── SavedListView.swift
├── TenderCardView.swift
├── EmptyStateView.swift
├── Models/
│   ├── Tender.swift
│   └── FavoriteRestaurant.swift
├── ViewModels/
│   └── TenderDeckViewModel.swift
├── Services/
│   ├── RestaurantSearchService.swift
│   ├── LocationManager.swift
│   └── DeliveryService.swift ← NEW
└── Resources/
    └── Info.plist ← MUST ADD: LSApplicationQueriesSchemes
```

---

## 🔧 Info.plist Visual Guide

### Before
```xml
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Cluck</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to find restaurants nearby</string>
    
    <!-- Other keys... -->
</dict>
</plist>
```

### After (ADD THIS)
```xml
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Cluck</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to find restaurants nearby</string>
    
    <!-- ⬇️ ADD THIS SECTION ⬇️ -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>doordash</string>
    </array>
    <!-- ⬆️ ADD THIS SECTION ⬆️ -->
    
    <!-- Other keys... -->
</dict>
</plist>
```

---

## 🎯 Button Positioning

### Code Structure in ChatDetailView
```swift
ScrollView {
    VStack {
        // Hero Image (350pt tall)
        
        VStack {
            // Restaurant Name
            // Star Rating
            // Type & Price
            // Open/Closed Badge
            
            Divider()
            
            // ⬇️ ACTION BUTTONS HERE ⬇️
            HStack(spacing: 20) {
                if let phoneNumber { CallButton }
                DoorDashButton ← NEW!
                DirectionsButton
                ShareButton
            }
            // ⬆️ ACTION BUTTONS HERE ⬆️
            
            Divider()
            
            // Address
            // Photos
            // Website
            // Save/Unsave
        }
    }
}
```

---

## 🔄 URL Flow Diagram

### DoorDash Deep Linking
```
User taps "Order" button
         ↓
DeliveryService.openDoorDash(restaurantName: "Popeyes")
         ↓
Encode restaurant name
"Popeyes" → "Popeyes" (already valid)
"Raising Cane's" → "Raising%20Cane's"
         ↓
Create app URL
doordash://search?query=Popeyes
         ↓
Check if can open
UIApplication.shared.canOpenURL(appURL)
         ↓
    ┌────┴────┐
   Yes        No
    │          │
    ↓          ↓
┌────────┐ ┌────────┐
│Open app│ │Open web│
└────────┘ └────────┘
    │          │
    ↓          ↓
doordash://   https://doordash.com/
search?       search/store/
query=...     Popeyes/
```

---

## 🎨 Color Palette Reference

### Current App Colors
```
┌──────────────────────────────────┐
│ Primary Gradient                 │
│ #FF4C33 → #FFCC99                │ ← App branding
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ Action Buttons                   │
│ 📞 Blue:   #007AFF                │ ← Call
│ 🛍️ Red:    #FF3008                │ ← DoorDash (NEW)
│ 🧭 Green:  #34C759                │ ← Directions
│ 📤 Orange: #FF9500                │ ← Share
└──────────────────────────────────┘
```

### Future Delivery Services
```
┌──────────────────────────────────┐
│ DoorDash:  #FF3008               │ ← Implemented
│ Uber Eats: #06C167               │ ← Ready
│ Grubhub:   #F63440               │ ← Ready
└──────────────────────────────────┘
```

---

## 📐 Responsive Layout

### Button Sizing
```
Phone Size      Spacing    Button Size
──────────────────────────────────────
iPhone SE       16pt       55x55
iPhone 14       20pt       60x60  ← Default
iPhone 14 Plus  20pt       60x60
iPad            24pt       70x70
```

### Adaptive Spacing
The buttons use:
- `spacing: 20` in HStack
- Automatically centers if odd number of buttons
- Maintains consistent sizing across devices

---

## 🧪 Testing Scenarios

### Scenario 1: Fresh Install (No DoorDash)
```
1. Install Cluck
2. Open restaurant detail
3. Tap Order button
   ↓
Result: Safari opens → DoorDash website
```

### Scenario 2: DoorDash Installed
```
1. Install DoorDash from App Store
2. Open Cluck
3. Tap Order button
   ↓
Result: DoorDash app opens → Search results
```

### Scenario 3: After Uninstalling DoorDash
```
1. Have used DoorDash app before
2. Uninstall DoorDash
3. Tap Order button
   ↓
Result: Fallback to web (no error)
```

---

## 💡 Implementation Highlights

### Smart Fallback Logic
```swift
// 1. Try app first
if UIApplication.shared.canOpenURL(appURL) {
    UIApplication.shared.open(appURL)
} else {
    // 2. Automatic web fallback
    openDoorDashWeb(restaurantName: name)
}
```

### URL Encoding Safety
```swift
// Handles special characters automatically
guard let encoded = name.addingPercentEncoding(
    withAllowedCharacters: .urlQueryAllowed
) else { return }

// Examples:
// "Popeyes" → "Popeyes"
// "Raising Cane's" → "Raising%20Cane's"
// "Chicken & Waffles" → "Chicken%20%26%20Waffles"
```

---

## 🎯 Quick Reference Card

```
┌─────────────────────────────────────────────┐
│ DoorDash Integration Quick Reference        │
├─────────────────────────────────────────────┤
│ Service:    DeliveryService.swift           │
│ Method:     openDoorDash(restaurantName:)   │
│ Button:     ChatDetailView action buttons   │
│ Color:      #FF3008 (DoorDash red)          │
│ Icon:       bag.fill                        │
│ Label:      "Order"                         │
│ Required:   LSApplicationQueriesSchemes     │
│             in Info.plist                   │
├─────────────────────────────────────────────┤
│ Test:       Tap button → DoorDash opens     │
│ Fallback:   Opens web if app not installed │
└─────────────────────────────────────────────┘
```

---

**Visual Guide Version:** 1.0
**Last Updated:** January 8, 2026
**Corresponds to:** DoorDash Integration v1.0
