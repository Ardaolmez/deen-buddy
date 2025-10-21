# Fastlane Screenshot Automation

This directory contains automated screenshot generation setup for the myDeen app using Fastlane's `snapshot` tool.

## 📸 What's Inside

- **Snapfile** - Configuration for devices, languages, and output settings
- **screenshots/** - Output directory for generated screenshots (git-ignored)
- **SnapshotHelper.swift** - Helper moved to `Deen Buddy AdvancedUITests/`

## 🚀 Usage

### Generate Screenshots

Run from the project root directory:

```bash
cd /Users/mertba/deen-buddy
fastlane snapshot
```

This will:
1. Build the app in Debug configuration
2. Run UI tests on iPhone 15 Pro Max and iPhone 15 Plus
3. Generate screenshots for each view
4. Save to `fastlane/screenshots/en-US/`

### Output

Screenshots are saved with these names:
- `01-TodaysJourney.png` - Main dashboard with daily streak and verse
- `02-QuranReading.png` - Quran reading interface
- `03-PrayerTimes.png` - Prayer times and tracking
- `04-DailyQuiz.png` - Daily Islamic knowledge quiz
- `05-Explore.png` - Explore view

**Device Sizes:**
- iPhone 15 Pro Max: 1290 × 2796px (6.7" display)
- iPhone 15 Plus: 1290 × 2796px (6.7" display)

Perfect for App Store submission!

## 🛠️ Configuration

### Devices

Edit `Snapfile` to add/remove devices:

```ruby
devices([
  "iPhone 15 Pro Max",
  "iPhone 15 Plus",
  "iPad Pro (12.9-inch)"  # Add iPads if needed
])
```

### Languages

Add more languages for localization:

```ruby
languages([
  "en-US",
  "ar-SA"  # Arabic
])
```

### Status Bar

The status bar is automatically set to 9:41 AM with full battery and signal.

## 📝 Modifying Screenshot Tests

Edit `/Deen Buddy AdvancedUITests/Deen_Buddy_AdvancedUITests.swift`:

```swift
func testGenerateScreenshots() {
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()

    // Navigate and capture
    snapshot("ScreenshotName")
}
```

## 🔧 Troubleshooting

### Build Fails
- Make sure the scheme "Deen Buddy Advanced" is shared
- Check that UI tests are enabled in the scheme

### Screenshots Missing
- Verify the test runs successfully in Xcode first
- Check sleep times - some views may need more time to load
- Look at fastlane logs for specific errors

### Simulator Issues
- Run `xcrun simctl list` to see available simulators
- Make sure iOS 18.1 simulators are installed

## 📚 Resources

- [Fastlane Snapshot Docs](https://docs.fastlane.tools/actions/snapshot/)
- [XCUITest Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)

## 🗂️ Project Structure

```
deen-buddy/
├── fastlane/
│   ├── Snapfile              # Configuration
│   ├── README.md            # This file
│   └── screenshots/         # Output (git-ignored)
│       └── en-US/
│           ├── 01-TodaysJourney.png
│           ├── 02-QuranReading.png
│           ├── 03-PrayerTimes.png
│           ├── 04-DailyQuiz.png
│           └── 05-Explore.png
└── Deen Buddy AdvancedUITests/
    ├── SnapshotHelper.swift
    └── Deen_Buddy_AdvancedUITests.swift
```
