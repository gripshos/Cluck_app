# ✅ DoorDash Integration Checklist

## 🚀 Quick Start (5 Minutes)

Follow these steps to complete the DoorDash integration:

---

## Step 1: Configure Info.plist ⚠️ REQUIRED

### ✅ Add URL Scheme Declaration

**Find your Info.plist file:**
- Located in your Xcode project root
- Usually in the project navigator sidebar
- Or in "Supporting Files" group

**Add this configuration:**

#### Option A: Property List Editor (Easiest)
1. ✅ Open `Info.plist` in Xcode
2. ✅ Click the `+` button at the top level
3. ✅ Type: `LSApplicationQueriesSchemes`
4. ✅ Change type to: **Array**
5. ✅ Click disclosure triangle to expand
6. ✅ Click `+` on the array row
7. ✅ Type: `doordash`
8. ✅ Press Enter

#### Option B: Source Code (Advanced)
1. ✅ Right-click `Info.plist` → Open As → Source Code
2. ✅ Add inside `<dict>` tag:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>doordash</string>
   </array>
   ```
3. ✅ Save file

**Verification:**
- [ ] Info.plist contains `LSApplicationQueriesSchemes` key
- [ ] Array contains `doordash` string
- [ ] No Xcode errors shown

---

## Step 2: Verify Files Exist ✅

Check that these files were created:

- [ ] `DeliveryService.swift` - Delivery service handler
- [ ] `ChatDetailView.swift` - Modified with DoorDash button
- [ ] `DOORDASH_INTEGRATION.md` - Full documentation
- [ ] `DOORDASH_COMPLETE.md` - Implementation summary
- [ ] `DOORDASH_VISUAL_GUIDE.md` - Visual reference
- [ ] `DOORDASH_CHECKLIST.md` - This file
- [ ] `Info.plist.template` - Configuration template

**All files should be present in your project!**

---

## Step 3: Build and Run 🏗️

### ✅ Build the Project

1. ✅ Open Xcode
2. ✅ Select your target device (Simulator or device)
3. ✅ Press `Cmd+B` to build
4. ✅ Fix any build errors
5. ✅ Press `Cmd+R` to run

**Expected:** App builds and launches successfully

---

## Step 4: Visual Verification 👀

### ✅ Check Button Appearance

1. ✅ Launch the app
2. ✅ Navigate to any restaurant card
3. ✅ Tap to open detail view
4. ✅ Scroll to action buttons section

**You should see:**
```
[📞 Call]  [🛍️ Order]  [🧭 Directions]  [📤 Share]
            ↑
         NEW!
```

**Verify:**
- [ ] Red circular button appears
- [ ] Bag icon visible
- [ ] "Order" label below button
- [ ] Button is positioned second from left (after Call, before Directions)

---

## Step 5: Functional Testing 🧪

### Test A: With DoorDash App Installed

**Prerequisites:**
- [ ] Install DoorDash from App Store
- [ ] Open DoorDash once to initialize

**Steps:**
1. ✅ Open Cluck app
2. ✅ Open any restaurant detail
3. ✅ Tap the red "Order" button
4. ✅ Observe behavior

**Expected Result:**
- [ ] DoorDash app opens immediately
- [ ] Search results show (may not exact match)
- [ ] No error messages
- [ ] Can return to Cluck using back gesture or app switcher

---

### Test B: Without DoorDash App

**Prerequisites:**
- [ ] Uninstall DoorDash app (or use Simulator)

**Steps:**
1. ✅ Open Cluck app
2. ✅ Open any restaurant detail
3. ✅ Tap the red "Order" button
4. ✅ Observe behavior

**Expected Result:**
- [ ] Safari opens
- [ ] DoorDash website loads
- [ ] Search page visible
- [ ] URL contains restaurant name
- [ ] Can return to Cluck

---

### Test C: Special Characters

**Test these restaurant names:**

1. ✅ **Apostrophe:** "Raising Cane's" or "Popeyes"
   - [ ] URL encodes correctly
   - [ ] Search works

2. ✅ **Ampersand:** "Chicken & Waffles" (if available)
   - [ ] URL encodes correctly (&  becomes %26)
   - [ ] Search works

3. ✅ **Spaces:** "Buffalo Wild Wings"
   - [ ] URL encodes correctly (space becomes %20)
   - [ ] Search works

---

## Step 6: Edge Case Testing 🔍

### ✅ Various Scenarios

1. **Long Restaurant Name**
   - [ ] Test with 50+ character name
   - [ ] Verify URL encoding
   - [ ] Check if opens correctly

2. **Airplane Mode**
   - [ ] Turn on Airplane Mode
   - [ ] Tap Order button
   - [ ] Verify graceful handling (Safari shows no connection)

3. **Multiple Taps**
   - [ ] Rapidly tap Order button 3-4 times
   - [ ] Verify only one app/browser window opens
   - [ ] No app crashes

4. **Return to App**
   - [ ] Open DoorDash/Safari
   - [ ] Return to Cluck
   - [ ] Verify state preserved
   - [ ] Can open again

---

## ✅ Success Criteria

### All Tests Passing
- [ ] Info.plist configured correctly
- [ ] App builds without errors
- [ ] Button appears in detail view
- [ ] Button has correct appearance (red, bag icon, "Order" label)
- [ ] Opens DoorDash app when installed
- [ ] Falls back to web when app not installed
- [ ] Special characters encode correctly
- [ ] No crashes or errors

---

## 🐛 Troubleshooting

### Issue: Button doesn't appear
**Solution:**
1. Check ChatDetailView.swift for DoorDash button code
2. Rebuild project (Cmd+Shift+K, then Cmd+B)
3. Clean build folder

### Issue: Tapping does nothing
**Solution:**
1. Verify Info.plist has `LSApplicationQueriesSchemes`
2. Verify `doordash` string is in the array
3. Rebuild project
4. Check console for errors

### Issue: Opens Safari instead of app
**Expected behavior if:**
- DoorDash not installed
- Info.plist not configured (falls back to web)

**To fix:**
- Install DoorDash from App Store
- Verify Info.plist configuration

### Issue: Search doesn't find restaurant
**This is normal:**
- DoorDash search may not exact-match
- Restaurant might not be on DoorDash
- Try different restaurant names
- Web fallback should still work

### Issue: Build errors
**Common fixes:**
1. Clean build folder (Cmd+Shift+K)
2. Restart Xcode
3. Check file is added to target
4. Verify import statements

---

## 📊 Completion Status

### Required Tasks
- [ ] Info.plist configured
- [ ] DeliveryService.swift exists
- [ ] ChatDetailView.swift updated
- [ ] App builds successfully
- [ ] Button appears correctly
- [ ] Basic functionality works

### Optional Enhancements (Future)
- [ ] Add Uber Eats button
- [ ] Add Grubhub button
- [ ] Add analytics tracking
- [ ] Add user preference for default service
- [ ] Add loading indicators

---

## 🎉 You're Done!

If all checkboxes are marked ✅, congratulations! DoorDash integration is complete.

### What Users Can Now Do:
1. 🍗 Browse restaurants in Cluck
2. 👀 View detailed information
3. 🛍️ **Order food with one tap via DoorDash**
4. 📍 Get directions
5. 💛 Save favorites
6. 📤 Share with friends

---

## 📚 Additional Resources

- **Full Documentation:** `DOORDASH_INTEGRATION.md`
- **Visual Guide:** `DOORDASH_VISUAL_GUIDE.md`
- **Summary:** `DOORDASH_COMPLETE.md`
- **Info.plist Template:** `Info.plist.template`

---

## 🆘 Need Help?

### Common Questions

**Q: Do I need a DoorDash Developer Account?**
A: No! This uses public URL schemes.

**Q: Does this share user data with DoorDash?**
A: No, only the restaurant name in the URL.

**Q: Will this work on Simulator?**
A: Web fallback will work. App deep linking requires physical device with DoorDash.

**Q: Can I customize the button color?**
A: Yes, edit the gradient colors in ChatDetailView.swift

**Q: How do I add more delivery services?**
A: See `DOORDASH_INTEGRATION.md` → Future Enhancements section

---

**Checklist Version:** 1.0
**Last Updated:** January 8, 2026
**Estimated Completion Time:** 5-10 minutes
