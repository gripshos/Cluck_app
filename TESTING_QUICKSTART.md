# Quick Start: Testing the Tip Jar

## Enable StoreKit Testing (One-Time Setup)

1. In Xcode, press `⌘ + <` to open scheme settings
2. Select **Run** on the left
3. Click the **Options** tab
4. Under **StoreKit Configuration**, choose `Cluck.storekit`
5. Click **Close**

✅ You're ready to test!

## Test the Tip Jar

1. **Run the app** (Simulator or device)
2. **Tap the gear icon** ⚙️ in the top-right header
3. **Tap "Support Cluck"**
4. **Try purchasing** any tip tier
5. **Confirm** the StoreKit purchase dialog
6. **See the thank you message** 🎉

## View Test Transactions

- In Xcode: **Debug → StoreKit → Manage Transactions**
- Clear history, view purchases, test refunds

## What You Should See

### ✅ Success Flow
1. Settings opens with white background
2. "Support Cluck" button with heart icon
3. Tip Jar shows 3 tiers: 🍗, 🍗🍗, 🍗🍗🍗
4. Prices show: $0.99, $4.99, $9.99
5. Tap purchase → StoreKit dialog appears
6. Confirm → "Thank You!" message with 🎉
7. Auto-dismisses after ~2.5 seconds

### ⚠️ Common Issues

**Products not loading?**
- Check StoreKit config is enabled in scheme
- Clean build folder: `⌘ + Shift + K`
- Restart Xcode

**Settings button not showing?**
- Wait for app to finish loading restaurants
- Header only appears after initial load

**Purchase fails?**
- Check internet connection
- View errors in Transaction Manager

## Next Steps

Before App Store release:
1. Create real IAPs in App Store Connect
2. Test with TestFlight + Sandbox account
3. Submit IAPs for review with app

---

**Quick Tips:**
- Test purchases are **free** (no real charges)
- Can purchase same tip multiple times
- No features unlock (it's just a tip jar!)
- Settings accessible via gear icon in header

🐔 Happy testing!
