# 🍗 Cluck

**Swipe right on chicken tenders.**

Cluck is a swipe-style iOS app that helps you discover nearby restaurants serving chicken tenders. Swipe through options, save your favorites, and get directions—all with a playful, modern interface designed for one-handed use.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Swipe Discovery** — Browse nearby chicken tender spots with intuitive left/right swipe gestures
- **Location-Based Search** — Automatically finds restaurants within 5km using Apple's MapKit
- **Save Favorites** — Swipe right to save restaurants you want to try
- **Restaurant Details** — View address, phone number, website, and price range
- **Get Directions** — One tap to open Apple Maps with directions
- **No Account Required** — Start swiping immediately, all data stored locally

## Screenshots

*Coming soon*

## Tech Stack

- **SwiftUI** — Modern declarative UI framework
- **MapKit** — Free, native restaurant discovery via `MKLocalSearch`
- **CoreLocation** — User location for nearby results
- **MVVM Architecture** — Clean separation of concerns
- **iOS 17+** — Leverages latest SwiftUI features including `@Observable`

## Architecture

```
Cluck/
├── CluckApp.swift          # App entry point
├── ContentView.swift       # Main view with all components
│   ├── Models              # Tender data model
│   ├── LocationManager     # CoreLocation wrapper
│   ├── RestaurantSearchService  # MapKit search
│   ├── TenderDeckViewModel # State management
│   ├── SwipeDeckView       # Card stack with gestures
│   ├── TenderCardView      # Individual restaurant card
│   ├── SavedListView       # Favorites list
│   └── ChatDetailView      # Restaurant details
└── Assets.xcassets         # Images and colors
```

## Roadmap

### V1 (Current)
- [x] Location-based restaurant discovery
- [x] Swipe gestures with animations
- [x] Save favorites locally
- [x] Restaurant details with directions
- [x] Smart image fallbacks

### V2.0 (Future)
- [ ] User reviews and ratings
- [ ] Social sharing
- [ ] Onboarding flow
- [ ] CloudKit sync

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and Apple's native frameworks
- Inspired by the universal love of chicken tenders 🍗

---

**Made with ❤️ by Steven Gripshover**
