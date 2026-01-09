# Tip Jar Implementation Guide

## Overview
This document provides a complete guide for the tip jar feature implementation in Cluck, including setup, testing, and deployment instructions.

## ✅ Implementation Checklist

### Files Created
- [x] `StoreKitService.swift` - Core StoreKit 2 wrapper service
- [x] `TipJarViewModel.swift` - ViewModel for tip jar screen
- [x] `TipJarView.swift` - Tip jar UI component
- [x] `SettingsView.swift` - Settings screen with tip jar access
- [x] `Cluck.storekit` - StoreKit configuration file for local testing

### Files Modified
- [x] `AppState.swift` - Added StoreKitService instance
- [x] `RootView.swift` - Pass StoreKitService to SwipeDeckView
- [x] `SwipeDeckView.swift` - Added settings button and sheet

## 🏗️ Architecture

### StoreKitService
- **Pattern**: Observable service (iOS 17+)
- **Responsibilities**:
  - Load products from App Store using `Product.products(for:)`
  - Handle purchases with `product.purchase()`
  - Verify transactions
  - Finish consumable transactions
  - Error handling for network, permissions, etc.

### TipJarViewModel
- **Pattern**: MVVM
- **Responsibilities**:
  - Interface between view and StoreKitService
  - Track purchase in progress state
  - Handle "thank you" state after successful purchase
  - Auto-dismiss thank you message after 2.5 seconds

### UI Components
- **TipJarView**: Main tip jar interface with three tip tiers
- **SettingsView**: Settings screen with support section
- **CluckHeader**: Updated with settings gear button

## 🎨 Design

### Color Scheme
- Primary accent: `Color(red: 1.0, green: 0.3, blue: 0.2)` (matches app's coral/orange)
- Background: Soft gradient from cream to white
- Cards: White with subtle shadows

### UX Patterns
- Non-invasive: Only accessible from Settings (gear icon in header)
- Appreciative tone: Warm, grateful copy
- Clear pricing: Displays localized prices from StoreKit
- Feedback: Loading states, success animation, error messages
- Quick exit: "Done" button always available

## 📱 Local Testing Setup

### 1. Enable StoreKit Testing in Xcode

1. Open your project scheme:
   - Product → Scheme → Edit Scheme (or ⌘ + <)

2. Select "Run" in the left sidebar

3. Go to the "Options" tab

4. Under "StoreKit Configuration", select `Cluck.storekit`

5. Click "Close"

### 2. Test Purchase Flow

The `Cluck.storekit` file includes three test products:
- Small Tip: $0.99
- Medium Tip: $4.99
- Large Tip: $9.99

**Test Steps:**
1. Run the app in the simulator or on a device
2. Tap the gear icon in the header
3. Tap "Support Cluck"
4. Verify all three tip tiers load correctly
5. Tap any tip button to test purchase flow
6. Confirm purchase in the StoreKit dialog
7. Verify "Thank You" message appears
8. Verify message auto-dismisses after ~2.5 seconds

**Error Testing:**
You can enable StoreKit errors in the configuration file to test:
- Product loading failures
- Purchase failures
- Network errors
- Verification errors

### 3. Transaction Manager

View StoreKit transactions during testing:
- Debug → StoreKit → Manage Transactions
- View all test purchases
- Clear purchase history
- Test refunds

## 🚀 App Store Connect Setup

### 1. Create In-App Purchases

Navigate to App Store Connect → Your App → In-App Purchases → Create

**Small Tip:**
- Product ID: `com.sag.cluck.tip.small`
- Type: Consumable
- Reference Name: Small Tip
- Price: Tier 1 ($0.99)
- Display Name: Small Tip
- Description: "A small tip to support Cluck development"

**Medium Tip:**
- Product ID: `com.sag.cluck.tip.medium`
- Type: Consumable
- Reference Name: Medium Tip
- Price: Tier 5 ($4.99)
- Display Name: Medium Tip
- Description: "A medium tip to support Cluck development"

**Large Tip:**
- Product ID: `com.sag.cluck.tip.large`
- Type: Consumable
- Reference Name: Large Tip
- Price: Tier 10 ($9.99)
- Display Name: Large Tip
- Description: "A large tip to support Cluck development"

### 2. Review Information

For each product, add review notes:
```
Optional tip jar for users who want to support the developer. 
No features are unlocked or gated behind this purchase.
```

### 3. Localization (Optional)

Add localizations for additional languages if your app supports them.

## 🧪 TestFlight Testing

### 1. Enable Sandbox Testing

1. On your test device, sign out of the App Store
2. Go to Settings → App Store
3. Under "Sandbox Account", add a sandbox tester account (create in App Store Connect → Users and Access → Sandbox Testers)

### 2. Test Real Purchase Flow

1. Install via TestFlight
2. Launch the app
3. Navigate to Settings → Support Cluck
4. Attempt a purchase
5. Sign in with sandbox account when prompted
6. Complete purchase
7. Verify thank you message appears

**Note**: Sandbox purchases never charge real money.

### 3. Verify Product Loading

- Products should load from App Store Connect
- Prices should be localized to sandbox account's region
- Product names and descriptions should match App Store Connect

## 🔒 Error Handling

### Network Errors
- Caught: `StoreKitError.networkError`
- Message: "Network error. Please check your connection and try again."

### User Cancellation
- Caught: `PurchaseResult.userCancelled`
- Behavior: Silent (no error message)

### Not Available
- Caught: `StoreKitError.notAvailableInStorefront`
- Message: "This purchase is not available in your region."

### Unknown Errors
- Caught: Generic errors
- Message: "Purchase failed. Please try again."

### Transaction Verification Failure
- Caught: `VerificationResult.unverified`
- Throws error (logged but not shown to user)

## 📋 Pre-Release Checklist

- [ ] All three products created in App Store Connect
- [ ] Product IDs match exactly: `com.sag.cluck.tip.*`
- [ ] Products set to "Ready to Submit"
- [ ] Review notes added to each product
- [ ] TestFlight testing completed successfully
- [ ] Purchase flow works on real device
- [ ] Thank you message displays correctly
- [ ] Error states tested (network off, etc.)
- [ ] Products load with correct localized prices
- [ ] Settings screen accessible from header
- [ ] No features are gated behind tips

## 🐛 Troubleshooting

### Products Not Loading

**Problem**: Products array is empty
**Solutions**:
- Verify product IDs match exactly
- Check StoreKit configuration file is selected in scheme
- Ensure products are "Ready to Submit" in App Store Connect
- Wait a few minutes after creating products (can take time to sync)
- Try clearing build folder (Cmd + Shift + K)

### Purchase Fails Immediately

**Problem**: Purchase returns error instantly
**Solutions**:
- Check device/simulator has internet connection
- Verify StoreKit configuration is valid JSON
- Test with Transaction Manager to see detailed errors
- Check sandbox account is properly configured

### Settings Button Not Visible

**Problem**: Gear icon doesn't appear
**Solutions**:
- Ensure app has finished initial loading
- Check `viewModel.isLoading` is false
- Verify `CluckHeader` is receiving `onSettings` callback

### Thank You Message Doesn't Appear

**Problem**: Purchase succeeds but no thank you
**Solutions**:
- Check `showThankYou` state in TipJarViewModel
- Verify purchase was successful (check logs)
- Test Task.sleep duration (may be too fast in simulator)

## 📝 Code Review Notes

### Key Features
- ✅ Uses native StoreKit 2 (no external dependencies)
- ✅ Modern async/await throughout
- ✅ Observable pattern (iOS 17+)
- ✅ MVVM architecture
- ✅ Proper transaction verification
- ✅ Consumables properly finished
- ✅ No features gated behind tips
- ✅ Non-invasive UI (settings only)
- ✅ Graceful error handling
- ✅ Loading and success states
- ✅ SwiftUI-first design

### Security
- Transaction verification with `checkVerified(_:)`
- No client-side logic for unlocking features
- Proper error handling for verification failures

### UX
- Warm, appreciative tone
- No guilt-inducing copy
- Quick access to dismiss
- Auto-dismiss success message
- Clear pricing with StoreKit localization
- Disabled state during purchase

## 🔮 Future Enhancements

### Optional Additions
- [ ] Add haptic feedback on successful purchase
- [ ] Track tip history (optional analytics)
- [ ] Add more tip tiers ($1.99, $19.99)
- [ ] Add custom thank you messages per tier
- [ ] Add confetti animation on success
- [ ] Add share prompts after large tips
- [ ] Localize UI strings

### Not Recommended
- ❌ Don't gate features behind tips
- ❌ Don't show tip prompts on app launch
- ❌ Don't show tip prompts during critical flows
- ❌ Don't use aggressive or guilt-inducing copy

## 📞 Support

### Apple Resources
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [StoreKit Testing](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

### Common Questions

**Q: Do tips need to be approved by Apple?**
A: Yes, each in-app purchase must be reviewed. Include clear notes that it's an optional tip jar.

**Q: Can I change tip prices later?**
A: Yes, in App Store Connect, but existing products keep their ID.

**Q: What's the fee for tips?**
A: Standard 30% App Store fee (15% for small businesses in App Store Small Business Program).

**Q: Should I use consumables or non-consumables?**
A: Consumables - they don't persist and users can tip multiple times.

**Q: How do refunds work?**
A: Users can request refunds through App Store. Apple handles this automatically.

---

**Implementation Date**: January 2026  
**iOS Target**: 17.0+  
**Framework**: StoreKit 2  
**Pattern**: MVVM + Observable
