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
│   ├── CashburnApp.swift          # App entry point (@main) with SwiftData container and migration
│   ├── ContentView.swift          # Main view with list selector and subscriptions
│   ├── Subscription.swift         # SwiftData model for subscriptions
│   ├── SubscriptionList.swift     # SwiftData model for organizing subscriptions
│   ├── SubscriptionFormView.swift # Add/edit subscription form
│   ├── ListManagerView.swift      # Manage lists (add/delete/rename)
│   ├── SettingsView.swift         # Currency selection settings
│   └── Assets.xcassets/           # Asset catalog
├── CashburnTests/                 # Unit tests using Swift Testing framework
└── CashburnUITests/               # UI tests using XCTest
```

## Architecture Notes

### Data Layer
- **SwiftData** for persistence: The app uses SwiftData (Apple's modern persistence framework)
- `Subscription` model stores: name, monthlyCost (Double), createdAt (Date), list (SubscriptionList relationship)
- `SubscriptionList` model stores: name, createdAt (Date), subscriptions (one-to-many relationship)
- **Automatic migration**: On app launch, orphaned subscriptions are moved to a default "Personal" list
- SwiftData container configured in `CashburnApp.swift` with both models
- All data persists automatically to local storage

### Views
- **ContentView**: Main interface with list selector, subscriptions, and total
  - **Segmented control**: Pill-style buttons to switch between lists (Personal, Company, etc.)
  - **List manager button**: Ellipsis icon to open list management
  - Filters subscriptions by selected list
  - Uses **Liquid Glass** design with transparent backgrounds for macOS Tahoe 26.1
  - Calculates total monthly cost for selected list only
  - Receipt-style layout with separator before total
  - Supports tap-to-edit and swipe-to-delete subscriptions
- **SubscriptionFormView**: Modal sheet for adding/editing subscriptions
  - Input fields: name, monthly cost
  - Automatically assigns subscription to currently selected list
  - Validates name is not empty and cost is positive
  - Reuses same form for both add and edit modes
- **ListManagerView**: Manage subscription lists
  - Add new lists with custom names
  - Rename existing lists inline
  - Delete lists (protected: can't delete last list)
  - Prevents deleting selected list without switching first
- **SettingsView**: Currency selection interface
  - Supports USD and EUR currencies
  - Currency preference stored via `@AppStorage`

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
