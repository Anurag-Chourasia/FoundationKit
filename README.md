# FoundationKit

Shared foundational primitives for the portfolio apps.

## Purpose

- Logging abstractions and a default console logger
- Build environment and app configuration types
- Feature flag storage
- Deterministic date and number formatting factories
- Small concurrency abstractions for clock and main-queue dispatching
- Lightweight string utilities

## Dependency Rules

- `FoundationKit` has no package dependencies
- Higher-level packages may depend on `FoundationKit`
- `FoundationKit` must not import app-specific code

## Public API

- `AppLogger`, `ConsoleLogger`, `LogLevel`
- `BuildEnvironment`, `AppConfiguration`, `FeatureFlags`
- `DateFormatting`, `NumberFormatting`, `DateFormatterFactory`, `NumberFormatterFactory`
- `AppClock`, `SystemClock`
- `MainQueueDispatching`, `MainQueueDispatcher`
- `StringFormatting`

## Test Notes

- Formatting tests use fixed locale, calendar, and time zone
- Configuration tests verify flag resolution and environment propagation
- Logger tests assert no-crash behavior for the default logger
