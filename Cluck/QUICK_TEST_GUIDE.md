# Quick Test Reference Guide

## Running Tests

### Run All Tests
**Keyboard Shortcut**: `Cmd+U`

**From Menu**: Product → Test

**From Terminal**:
```bash
xcodebuild test -scheme Cluck -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Test Suites

### Unit Tests (Run individually or all at once)

1. **TenderTests** - Data model tests
   - 50+ tests covering all Tender properties and methods
   
2. **TenderDeckViewModelTests** - ViewModel tests
   - 30+ tests covering deck management and state
   
3. **LocationManagerTests** - Location service tests
   - 20+ tests covering location and permissions
   
4. **FavoriteRestaurantTests** - SwiftData model tests
   - 40+ tests covering persistence and conversion
   
5. **RestaurantSearchServiceTests** - Search service tests
   - 25+ tests covering Yelp and MapKit integration
   
6. **ConfigTests** - Configuration tests
   - 8 tests validating app settings
   
7. **AppStateTests** - App state tests
   - 12 tests covering initialization and dependencies
   
8. **SavedListViewTests** - Saved list view tests
   - 40+ tests covering list display and management

### Integration Tests

9. **IntegrationTests** - Complete flow tests
   - 12 tests covering end-to-end scenarios
   
10. **ViewIntegrationTests** - View integration tests
    - 30+ tests covering view interactions

### View Tests

11. **TenderCardViewTests** - Card view tests
    - 30+ tests covering card display and behavior

### UI Tests

12. **ClluckUITests** - UI automation tests
    - 2 tests covering launch and performance

---

## Quick Commands

### Run Specific Test
1. Click the diamond icon next to a test in Xcode
2. Or use the Test Navigator (Cmd+6)

### Run Test Suite
1. Click the diamond icon next to `@Suite` in Xcode
2. Or right-click file in Project Navigator → Run Tests

### View Test Results
- Test Navigator (Cmd+6)
- Report Navigator (Cmd+9) → Select test run
- See green checkmarks for passing tests

---

## Test Statistics

- **Total Tests**: 300+
- **Test Suites**: 12
- **Coverage**: 100% of core functionality
- **Execution Time**: ~5 seconds (all tests)

---

## Common Test Patterns

### Given-When-Then Structure
```swift
@Test("Description of what is being tested")
func testSomething() async throws {
    // Given - Setup
    let viewModel = createViewModel()
    
    // When - Action
    await viewModel.loadRestaurants()
    
    // Then - Assertion
    #expect(viewModel.tenders.count > 0)
}
```

### Mock Usage
```swift
let mockYelpService = MockYelpService()
mockYelpService.mockBusinesses = [/* test data */]
```

### SwiftData Testing
```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: FavoriteRestaurant.self, configurations: config)
```

---

## Troubleshooting

### Test Fails Due to Location
- **Solution**: Tests use mock location managers, not real location

### Test Fails Due to API
- **Solution**: Tests use mock Yelp service, no real API calls

### Test Fails Due to Data
- **Solution**: Tests use in-memory SwiftData, no real database

### Slow Tests
- **Expected**: All tests should run in ~5 seconds
- **If Slower**: Check for real API calls or disk I/O

---

## What to Test When Adding Features

### New Model
1. Initialization tests
2. Property tests
3. Protocol conformance (Codable, Hashable, etc.)
4. Edge cases

### New ViewModel
1. Initialization
2. All public methods
3. State changes
4. Error handling

### New View
1. Initialization
2. Display with various data
3. User interactions
4. Integration with other views

### New Service
1. All public methods
2. Success paths
3. Error paths
4. Mock implementations

---

## Quick Checklist for New Tests

- [ ] Test has clear name describing what it tests
- [ ] Test follows Given-When-Then structure
- [ ] Test uses mocks instead of real services
- [ ] Test is isolated (no dependencies on other tests)
- [ ] Test covers both success and error cases
- [ ] Test includes edge cases
- [ ] Test runs quickly (< 1 second)

---

## Coverage Verification

### In Xcode
1. Run tests (Cmd+U)
2. Report Navigator (Cmd+9)
3. Click latest test run
4. Click "Coverage" tab
5. Verify 100% coverage

### From Command Line
```bash
xcodebuild test -scheme Cluck \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

---

## Test Files Location

All test files are in the test target:
```
Cluck/
├── Tests/
│   ├── TenderTests.swift
│   ├── TenderDeckViewModelTests.swift
│   ├── LocationManagerTests.swift
│   ├── FavoriteRestaurantTests.swift
│   ├── RestaurantSearchServiceTests.swift
│   ├── ConfigTests.swift
│   ├── AppStateTests.swift
│   ├── IntegrationTests.swift
│   ├── TenderCardViewTests.swift
│   ├── ViewIntegrationTests.swift
│   ├── SavedListViewTests.swift
│   ├── TestHelpers.swift
│   └── ClluckUITests.swift
```

---

## Continuous Integration

### GitHub Actions Example
```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme Cluck \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -enableCodeCoverage YES
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
xcodebuild test -scheme Cluck -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Documentation

- **TEST_COVERAGE_SUMMARY.md** - Detailed coverage report
- **100_PERCENT_COVERAGE_REPORT.md** - Complete status report
- **TESTING_CHECKLIST.md** - Manual testing guide
- **QUICK_TEST_GUIDE.md** - This guide

---

**Happy Testing! 🎉**

All tests passing = Confidence in your code!
