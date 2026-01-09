# 📦 File Organization Script

## Quick Move Commands

Copy and paste these commands in Terminal (from project root):

```bash
# Create folder structure
mkdir -p Documentation/01-QuickStart
mkdir -p Documentation/02-Setup
mkdir -p Documentation/03-Features/DoorDash
mkdir -p Documentation/04-Testing
mkdir -p Documentation/05-Implementation

# Move Quick Start
mv QUICK_START.md Documentation/01-QuickStart/

# Move Setup files
mv YELP_SETUP_GUIDE.md Documentation/02-Setup/
mv SWIFTDATA_MIGRATION_GUIDE.md Documentation/02-Setup/
mv CANVAS_PREVIEW_GUIDE.md Documentation/02-Setup/

# Move Feature documentation
mv FINAL_ENHANCEMENTS_SUMMARY.md Documentation/03-Features/
mv V1_ENHANCEMENTS.md Documentation/03-Features/
mv UI_IMPROVEMENTS_COMPLETED.md Documentation/03-Features/
mv README_UI_IMPROVEMENTS.md Documentation/03-Features/
mv QUICK_START_NEW_FEATURES.md Documentation/03-Features/
mv VISUAL_FEATURE_GUIDE.md Documentation/03-Features/
mv DUPLICATE_PREVENTION.md Documentation/03-Features/
mv DUPLICATE_TESTING_GUIDE.md Documentation/03-Features/

# Move DoorDash documentation
mv DOORDASH_INTEGRATION.md Documentation/03-Features/DoorDash/
mv DOORDASH_COMPLETE.md Documentation/03-Features/DoorDash/
mv DOORDASH_CHECKLIST.md Documentation/03-Features/DoorDash/
mv DOORDASH_VISUAL_GUIDE.md Documentation/03-Features/DoorDash/
mv Info.plist.template Documentation/03-Features/DoorDash/

# Move Testing documentation
mv TESTING_CHECKLIST.md Documentation/04-Testing/
mv TEST_COVERAGE_SUMMARY.md Documentation/04-Testing/
mv 100_PERCENT_COVERAGE_REPORT.md Documentation/04-Testing/
mv QUICK_TEST_GUIDE.md Documentation/04-Testing/

# Move Implementation notes
mv IMPLEMENTATION_NOTES.md Documentation/05-Implementation/
mv FIXES_APPLIED.md Documentation/05-Implementation/
mv REMAINING_TASKS.md Documentation/05-Implementation/

# Copy organization guide to Documentation folder
cp DOCUMENTATION_ORGANIZATION_GUIDE.md Documentation/README.md

echo "✅ Documentation organized!"
echo "📁 All files moved to Documentation/ folder"
echo "📚 See Documentation/README.md for index"
```

---

## Or Move Files Individually

### Quick Start (1 file)
```bash
mv QUICK_START.md Documentation/01-QuickStart/
```

### Setup (3 files)
```bash
mv YELP_SETUP_GUIDE.md Documentation/02-Setup/
mv SWIFTDATA_MIGRATION_GUIDE.md Documentation/02-Setup/
mv CANVAS_PREVIEW_GUIDE.md Documentation/02-Setup/
```

### Features (8 files)
```bash
mv FINAL_ENHANCEMENTS_SUMMARY.md Documentation/03-Features/
mv V1_ENHANCEMENTS.md Documentation/03-Features/
mv UI_IMPROVEMENTS_COMPLETED.md Documentation/03-Features/
mv README_UI_IMPROVEMENTS.md Documentation/03-Features/
mv QUICK_START_NEW_FEATURES.md Documentation/03-Features/
mv VISUAL_FEATURE_GUIDE.md Documentation/03-Features/
mv DUPLICATE_PREVENTION.md Documentation/03-Features/
mv DUPLICATE_TESTING_GUIDE.md Documentation/03-Features/
```

### DoorDash (5 files)
```bash
mv DOORDASH_INTEGRATION.md Documentation/03-Features/DoorDash/
mv DOORDASH_COMPLETE.md Documentation/03-Features/DoorDash/
mv DOORDASH_CHECKLIST.md Documentation/03-Features/DoorDash/
mv DOORDASH_VISUAL_GUIDE.md Documentation/03-Features/DoorDash/
mv Info.plist.template Documentation/03-Features/DoorDash/
```

### Testing (4 files)
```bash
mv TESTING_CHECKLIST.md Documentation/04-Testing/
mv TEST_COVERAGE_SUMMARY.md Documentation/04-Testing/
mv 100_PERCENT_COVERAGE_REPORT.md Documentation/04-Testing/
mv QUICK_TEST_GUIDE.md Documentation/04-Testing/
```

### Implementation (3 files)
```bash
mv IMPLEMENTATION_NOTES.md Documentation/05-Implementation/
mv FIXES_APPLIED.md Documentation/05-Implementation/
mv REMAINING_TASKS.md Documentation/05-Implementation/
```

---

## In Xcode (GUI Method)

1. **Create Groups:**
   - Right-click project → New Group → "Documentation"
   - Inside Documentation:
     - New Group → "01-QuickStart"
     - New Group → "02-Setup"
     - New Group → "03-Features"
     - Inside Features: New Group → "DoorDash"
     - New Group → "04-Testing"
     - New Group → "05-Implementation"

2. **Drag Files:**
   - Select markdown file in project navigator
   - Drag into appropriate group
   - Xcode updates references automatically

3. **Clean Up:**
   - Delete empty groups
   - Refresh project if needed

---

## File Count Summary

Total files to move: **24 markdown files**

- Quick Start: 1 file
- Setup: 3 files
- Features: 8 files
- DoorDash: 5 files
- Testing: 4 files
- Implementation: 3 files

---

## After Moving

Your project root should look like:

```
Cluck/
├── Documentation/              ← All docs here now
│   ├── README.md
│   ├── 01-QuickStart/
│   ├── 02-Setup/
│   ├── 03-Features/
│   ├── 04-Testing/
│   └── 05-Implementation/
├── Cluck/                      ← Source files
│   ├── Views/
│   ├── ViewModels/
│   ├── Models/
│   └── Services/
├── CluckTests/                 ← Test files
├── Cluck.xcodeproj
└── README.md                   ← Keep this at root
```

---

## Undo if Needed

If you need to reverse:

```bash
# Move everything back
mv Documentation/*/*.md .
mv Documentation/*/DoorDash/*.md .

# Remove empty folders
rm -rf Documentation/
```

---

**Total Time:** ~2 minutes
**Difficulty:** Easy
**Impact:** Much cleaner project structure!
