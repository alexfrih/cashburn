# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ CRITICAL RULES

**NEVER DELETE THE DATABASE**: Do not run commands to delete the SwiftData database or the app container at `~/Library/Containers/com.solarbeam.Cashburn`. The user's subscription data is valuable and irreplaceable. If schema changes are needed, implement proper SwiftData migrations instead of deleting data.

## Project Overview

Cashburn is a macOS SwiftUI application for tracking monthly subscription costs. Built with Xcode 26.1, targeting macOS 26.1. The app allows users to add, edit, and delete subscriptions, displaying the total monthly cashburn with configurable currency support.

## Build Commands

### Building the Application
```bash
# Build from command line
xcodebuild -project Cashburn.xcodeproj -scheme Cashburn -configuration Debug build

# Build for release
xcodebuild -project Cashburn.xcodeproj -scheme Cashburn -configuration Release build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project Cashburn.xcodeproj -scheme Cashburn

# Run only unit tests
xcodebuild test -project Cashburn.xcodeproj -scheme Cashburn -only-testing:CashburnTests

# Run only UI tests
xcodebuild test -project Cashburn.xcodeproj -scheme Cashburn -only-testing:CashburnUITests

# Run a specific test
xcodebuild test -project Cashburn.xcodeproj -scheme Cashburn -only-testing:CashburnTests/CashburnTests/example
```

## Project Structure

```
Cashburn/
├── Cashburn/                      # Main application target
│   ├── CashburnApp.swift          # App entry point (@main) with SwiftData container
│   ├── ContentView.swift          # Main view with subscription list and total
│   ├── Subscription.swift         # SwiftData model for subscriptions
│   ├── SubscriptionFormView.swift # Add/edit subscription form
│   ├── SettingsView.swift         # Currency selection settings
│   └── Assets.xcassets/           # Asset catalog
├── CashburnTests/                 # Unit tests using Swift Testing framework
└── CashburnUITests/               # UI tests using XCTest
```

## Architecture Notes

### Data Layer
- **SwiftData** for persistence: The app uses SwiftData (Apple's modern persistence framework)
- `Subscription` model stores: name, monthlyCost (Double), createdAt (Date)
- SwiftData container configured in `CashburnApp.swift` with `.modelContainer(for: Subscription.self)`
- All data persists automatically to local storage

### Views
- **ContentView**: Main interface with subscription list, total cashburn display, and toolbar actions
  - Uses `@Query` to fetch subscriptions sorted by name
  - Uses **Liquid Glass** design with `.ultraThinMaterial` backgrounds for macOS Tahoe 26.1
  - Calculates total monthly cost dynamically across all subscriptions
  - Supports tap-to-edit and swipe-to-delete
  - Subscription rows use translucent material cards with rounded corners
- **SubscriptionFormView**: Modal sheet for adding/editing subscriptions
  - Input fields: name, monthly cost
  - Validates name is not empty and cost is positive
  - Reuses same form for both add and edit modes
  - Uses Liquid Glass design with translucent backgrounds
- **SettingsView**: Currency selection interface
  - Supports USD and EUR currencies
  - Currency preference stored via `@AppStorage`
  - Uses Liquid Glass design materials

### Settings & Configuration
- Currency code stored in UserDefaults via `@AppStorage("currencyCode")`
- Default currency: USD
- Currency updates reflect immediately across all views

### Application Entry Point
- `CashburnApp.swift` contains the `@main` entry point using SwiftUI's `App` protocol
- The root scene is a `WindowGroup` containing `ContentView`
- SwiftData model container initialized at app level

### Testing Framework
- **Unit tests**: Use Swift Testing framework (imported as `Testing`)
- **UI tests**: Use XCTest framework with `XCUIApplication`
- Unit tests use `@testable import Cashburn` to access internal APIs

### Swift Configuration
- Uses Swift Approachable Concurrency with `MainActor` as default isolation
- Enables upcoming feature: member import visibility
- Uses whole module optimization in Release builds

### macOS-Specific Settings
- App Sandbox enabled
- Hardened Runtime enabled
- User-selected files access: readonly
- Bundle identifier: `com.solarbeam.Cashburn`
- Development Team: VP9U3RSL2K
