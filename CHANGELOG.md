# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This changelog starts its history at version 3.2.0. Earlier history is available through the git tags up to 3.1.0.

## [Unreleased]

Nothing yet.

## [3.2.0] 2026-09-16

### Added

* Swift Testing unit test target covering the pin view logic layer (text position, range, and selection math, plus per state appearance config resolution).
* GitHub Actions CI workflow that builds and tests on a macOS runner via xcodebuild against an iOS Simulator.
* DocC documentation catalog and doc comments for the public API.

### Changed

* Corrected the README Swift version badge (it showed Swift 5.1 or 5.9, but the package requires Swift 6.0) and documented the Xcode 16 requirement.
* Raised the package to Swift tools 6.0, which sets the minimum Xcode to 16 for consumers.
