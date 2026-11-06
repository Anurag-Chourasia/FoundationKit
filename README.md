# FoundationKit

Core architectural primitives, testable system abstractions, thread-safe dispatching, and deterministic formatting utilities for multi-app Swift ecosystems.

![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B%20%7C%20macOS%2014.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange)
![Toolchain](https://img.shields.io/badge/Xcode-27.1-purple)
![CI](https://img.shields.io/badge/CI-Passing-brightgreen)
![SwiftLint](https://img.shields.io/badge/SwiftLint-0.65.1%20Strict-green)
![Version](https://img.shields.io/badge/Release-v0.2.0-blueviolet)
![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(Pure%20Foundation)-success)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 1. Executive Summary & Purpose

`FoundationKit` provides foundational abstractions over system services that frequently impede testability when used directly. It abstracts system clocks, thread dispatching, feature flags, and formatted strings to guarantee 100% deterministic unit testing and eliminate singleton anti-patterns across the codebase.

### Key Engineering Objectives:
- **Testable System Abstractions**: Replaces direct calls to `Date()` or `DispatchQueue.main` with injectible protocols (`AppClock`, `MainQueueDispatching`).
- **Deterministic Formatting**: Pre-configured factories (`DateFormatterFactory`, `NumberFormatterFactory`) enforce Gregorian calendars, POSIX locales, and GMT/UTC offsets, preventing subtle bugs caused by user device calendar overrides.
- **Structured Logging & Diagnostics**: Standardized logging abstractions (`AppLogger`) with granular log levels and subsystem categories.
- **Environment & Feature Flagging**: Explicit build environment models (`.debug`, `.staging`, `.release`) and runtime feature toggling (`FeatureFlags`).

---

## 2. Architecture & Design Principles

```mermaid
flowchart TD
    Consumer["Application / Domain Layer (ShowBook / myTV / Motivation Daily)"] --> FoundationKit["FoundationKit"]
    FoundationKit --> Logging["Structured Logging (AppLogger, ConsoleLogger, LogLevel)"]
    FoundationKit --> Environment["Environment & Flags (BuildEnvironment, FeatureFlags)"]
    FoundationKit --> Abstractions["System Abstractions (AppClock, MainQueueDispatching)"]
    FoundationKit --> Formatters["Deterministic Formatters (Date & Number Factories)"]
    FoundationKit --> Utilities["String Formatting & Cleansing"]
```

### Architectural Tenets:
1. **Zero External Dependencies**: Implemented strictly using Apple's `Foundation` framework.
2. **Swift 6 Strict Concurrency**: All models and protocols conform to `Sendable`. Time and dispatch abstractions are thread-safe and non-blocking.
3. **No Singleton Enforcement**: Default implementations are provided for convenience (`SystemClock`), but all consuming services must accept protocol abstractions via constructor injection.

---

## 3. Dependency Graph & Consumer Matrix

| Direction | Package / Project | Responsibility |
|---|---|---|
| **Upstream Dependencies** | *None* | Zero third-party or internal dependencies. Pure Apple `Foundation`. |
| **Downstream Consumers** | **CommonNetworkingKit** | Consumes logging abstractions and time tracking utilities. |
| | **ShowBook** | Injects `AppClock` and `DateFormatterFactory` into Core Data bookmark and metadata engines. |
| | **myTV** | Injects time providers into stream timeout monitors and catalog refresh schedulers. |
| | **Motivation Daily** | Injects clocks into daily quote rotation and session randomization logic. |

---

## 4. API Contracts & Practical Code Examples

### 1. Eliminating System Time Coupling with `AppClock`
```swift
import Foundation
import FoundationKit

final class ExpiringSessionService {
    private let clock: AppClock
    private let timeoutInterval: TimeInterval

    // Injected clock: defaults to SystemClock in production, FixedClock in tests
    init(clock: AppClock = SystemClock(), timeoutInterval: TimeInterval = 3600) {
        self.clock = clock
        self.timeoutInterval = timeoutInterval
    }

    func isSessionExpired(startedAt: Date) -> Bool {
        return clock.now.timeIntervalSince(startedAt) > timeoutInterval
    }
}
```

### 2. Deterministic Date Formatting
```swift
import Foundation
import FoundationKit

struct TransactionReceipt {
    static func formatTimestamp(_ date: Date) -> String {
        // Enforces POSIX locale and UTC calendar to prevent regional parsing bugs
        let formatter = DateFormatterFactory.iso8601()
        return formatter.string(from: date)
    }
}
```

### 3. Feature Flagging and Environment Configuration
```swift
import FoundationKit

let config = AppConfiguration(
    environment: .staging,
    featureFlags: [
        "enable_new_feed_ui": true,
        "enable_biometrics": false
    ]
)

if config.isFeatureEnabled("enable_new_feed_ui") {
    // Render modern card feed
}
```

---

## 5. Verification & Testing

The package includes tests verifying mock clocks, main queue dispatching under asynchronous conditions, and formatter isolation across thread boundaries.

```sh
# Run tests locally
swift test

# Build for macOS and iOS simulator
swift build
```

---

## 6. End-to-End Ecosystem Connectivity

```mermaid
graph TD
    subgraph CoreServices ["Shared Core Services (SPMs)"]
        FoundationKit["FoundationKit<br/>(System Clock, Unified Logging, Thread Safety)"]
        LocalisationKit["LocalisationKit<br/>(Typed Strings, Pluralization, String Catalogs)"]
        DesignTokensKit["DesignTokensKit<br/>(BrandPalettes, ColorTheme, Typography, Metrics, SF Symbols)"]
        CommonNetworkingKit["CommonNetworkingKit<br/>(HTTPClient, URLSession, RequestBuilder, Interceptors)"]
        AppStubData["AppStubData<br/>(Synthetic Fixtures, Offline Catalogs, Test Scenarios)"]
    end

    subgraph UIServices ["Shared Presentation & Auth (SPMs)"]
        UIComponentsKit["UIComponentsKit<br/>(CatalogTile, SurfaceCard, StateMessage, Recipes)"]
        AuthKit["AuthKit & AuthKitUI<br/>(SessionManager, AppAuthGate, AccountToolbarItem)"]
        DeveloperProfileKit["DeveloperProfileKit<br/>(DeveloperProfileView, Runtime Overlays)"]
        SnapshotTestingKit["SnapshotTestingKit<br/>(Subpixel Comparison, Golden Baseline Engine)"]
    end

    subgraph HostApps ["Host Applications"]
        ShowBook["ShowBook<br/>(Book Discovery, Core Data Persistence, Open Library)"]
        MyTV["myTV<br/>(IPTV Browser, AVPlayer Lifecycle, Directory Cache)"]
        MotivationDaily["Motivation Daily<br/>(Card Feed, Quote Persistence, Image Export Studio)"]
    end

    subgraph QualityGates ["CI/CD Automation & Tooling"]
        ArchitectureGuard["check_architecture.py<br/>(Boundary Enforcement, Zero Token Leakage)"]
        SnapshotVerifier["verify-snapshot-baselines.py<br/>(Visual Regression Gate)"]
        GHActions["GitHub Actions CI<br/>(Fast Lane, Smoke Lane, Release Build Verification)"]
    end

    %% Dependencies between Shared SPMs
    DesignTokensKit --> UIComponentsKit
    LocalisationKit --> UIComponentsKit
    DesignTokensKit --> AuthKit
    UIComponentsKit --> AuthKit
    FoundationKit --> CommonNetworkingKit
    DesignTokensKit --> DeveloperProfileKit
    UIComponentsKit --> DeveloperProfileKit
    LocalisationKit --> DeveloperProfileKit

    %% Dependencies from Host Apps to Shared SPMs
    DesignTokensKit --> ShowBook
    UIComponentsKit --> ShowBook
    AuthKit --> ShowBook
    CommonNetworkingKit --> ShowBook
    DeveloperProfileKit --> ShowBook
    AppStubData --> ShowBook

    DesignTokensKit --> MyTV
    UIComponentsKit --> MyTV
    AuthKit --> MyTV
    CommonNetworkingKit --> MyTV
    DeveloperProfileKit --> MyTV
    AppStubData --> MyTV

    DesignTokensKit --> MotivationDaily
    UIComponentsKit --> MotivationDaily
    AuthKit --> MotivationDaily
    CommonNetworkingKit --> MotivationDaily
    DeveloperProfileKit --> MotivationDaily
    AppStubData --> MotivationDaily

    %% Testing & Verification Linkage
    SnapshotTestingKit -.-> ShowBook
    SnapshotTestingKit -.-> MyTV
    SnapshotTestingKit -.-> MotivationDaily

    ArchitectureGuard --> HostApps
    ArchitectureGuard --> CoreServices
    ArchitectureGuard --> UIServices
    SnapshotVerifier --> SnapshotTestingKit
    GHActions --> HostApps
    GHActions --> UIServices
    GHActions --> CoreServices
```

---

## 7. Canonical Notion Dashboards & Governance Links

- [iOS Portfolio — Engineering Tickets Dashboard](https://app.notion.com/p/c20d7f4b133b44499c8ac0b4d5f6249e?pvs=204)
- [iOS Portfolio — Master Document](https://app.notion.com/p/40ffa5f855b98192ad2ede66a5d36fe7)
- [Architecture Boundary Validator (`check_architecture.py`)](file:///Users/anuragchourasia/Desktop/Projects/UIComponentsKit/Scripts/check_architecture.py)
- [Release & Gate Policy Documentation (`Docs/MASTER.md`)](file:///Users/anuragchourasia/Desktop/Projects/Docs/MASTER.md)
