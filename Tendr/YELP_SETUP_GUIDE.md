# Yelp API Integration Setup Guide

## Overview

Your Tendr app now integrates with the **Yelp Fusion API** to fetch real restaurant data with images! Yelp provides high-quality photos, ratings, reviews, and detailed business information.

## 🔑 Getting Your Yelp API Key

### Step 1: Create a Yelp Fusion Account

1. Go to [https://www.yelp.com/developers](https://www.yelp.com/developers)
2. Click **"Get Started"** or **"Sign Up"**
3. Sign in with your existing Yelp account or create a new one

### Step 2: Create an App

1. Once logged in, go to [https://www.yelp.com/developers/v3/manage_app](https://www.yelp.com/developers/v3/manage_app)
2. Click **"Create New App"**
3. Fill out the form:
   - **App Name**: "Tendr" (or any name you prefer)
   - **Industry**: Food & Restaurants
   - **Contact Email**: Your email
   - **Description**: "A dating app for finding the best chicken tenders nearby"
   - **Website**: (optional, can leave blank)
4. Agree to the Terms of Service
5. Click **"Create New App"**

### Step 3: Get Your API Key

1. After creating your app, you'll be taken to your app's page
2. Look for **"API Key"** - it's a long string of characters
3. Click the **"Show"** button or copy icon to reveal and copy your API key
4. Keep this key private! Don't share it publicly or commit it to public repositories

## 📝 Adding Your API Key to the App

### Open `Config.swift`

Find this line:
```swift
static let yelpAPIKey = "YOUR_YELP_API_KEY_HERE"
```

Replace `"YOUR_YELP_API_KEY_HERE"` with your actual API key:
```swift
static let yelpAPIKey = "your_actual_api_key_from_yelp"
```

**Example:**
```swift
static let yelpAPIKey = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
```

## 🧪 Testing the Integration

1. **Build and run** your app in the simulator or on a device
2. Grant location permission when prompted
3. You should now see restaurant cards with actual photos from Yelp!

### What to Expect

- **✅ Success**: Cards appear with restaurant photos, names, ratings, and details
- **⚠️ Fallback**: If Yelp API fails (network issues, invalid key, etc.), the app will fall back to MapKit search (without images)
- **❌ No Results**: Check the Xcode console for error messages

## 🔍 Troubleshooting

### No Images Appearing

1. **Check API Key**: Make sure you copied the entire key correctly
2. **Check Console**: Look for error messages in Xcode's console
3. **Network Connection**: Ensure the simulator/device has internet access
4. **API Limits**: Yelp Fusion has a daily limit of 5,000 API calls (very generous for development)

### Common Error Messages

| Error | Solution |
|-------|----------|
| "UNAUTHENTICATED_USER" | Your API key is invalid - double-check it in Config.swift |
| "LOCATION_NOT_FOUND" | Location services aren't working - check Info.plist |
| "Invalid response from Yelp API" | Network connection issue or Yelp service down |

### Testing in Console

Add this to check if Yelp is working:
```swift
// In TenderDeckViewModel.loadRestaurants()
print("📍 Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
print("🔍 Searching for restaurants...")
```

## 📊 Yelp API Features Now Available

Your app now has access to:

- ✅ **High-quality restaurant photos**
- ✅ **Accurate business information** (name, address, phone)
- ✅ **Pricing indicators** ($, $$, $$$, $$$$)
- ✅ **Category information** (Fast Food, Fine Dining, etc.)
- ✅ **Business URLs** (link to Yelp page)
- 🔜 **Ratings & Reviews** (ready to implement - data is available)
- 🔜 **Hours of operation** (ready to implement - data is available)

## 🎯 Future Enhancements

You can easily extend this integration to show:

1. **Star Ratings**: Display Yelp's 1-5 star rating on cards
2. **Review Count**: Show how many reviews the restaurant has
3. **Open/Closed Status**: Display if the restaurant is currently open
4. **Multiple Photos**: Swipe through multiple restaurant photos
5. **Filtering**: Filter by price range, rating, or distance

## 🔒 Security Best Practices

⚠️ **Important**: For a production app, you should:

1. **Never commit API keys to version control**
2. Use **Xcode Configuration Files** (.xcconfig) for keys
3. Add **Config.swift to .gitignore** if using Git
4. Consider using a **backend server** to proxy API requests
5. Implement **rate limiting** to avoid hitting API quotas

### Quick .gitignore Addition

Add this to your `.gitignore`:
```
Config.swift
*.xcconfig
```

## 📚 Resources

- [Yelp Fusion API Documentation](https://www.yelp.com/developers/documentation/v3/get_started)
- [Yelp Business Search API](https://www.yelp.com/developers/documentation/v3/business_search)
- [Yelp API Rate Limits](https://www.yelp.com/developers/faq)

## 🎉 What's Different Now?

### Before (MapKit Only)
- Restaurant names and locations
- Generic gradient backgrounds
- Basic category information
- Limited data accuracy

### After (MapKit + Yelp)
- Everything from before, PLUS:
- Real restaurant photos
- Accurate pricing ($, $$, etc.)
- Business phone numbers and websites
- Better restaurant categorization
- Ready for ratings and reviews

---

**Enjoy finding the best chicken tenders with real photos!** 🍗📸
