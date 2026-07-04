# Where2Go Plan B UI First Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert Where2Go V0.1 from a tech-minimal interface into a Boutique Concierge + Apple Journal style app, while adding the new "运动" trip category.

**Architecture:** Keep the existing SwiftUI + SwiftData structure. Centralize visual changes in `DesignTokens` and category metadata, then update the existing screens/components to consume those tokens without introducing new dependencies.

**Tech Stack:** SwiftUI, SwiftData, XCTest, Xcode 26.6, iOS Simulator 26.5.

## Global Constraints

- Homepage title remains `下一程`.
- Summary card title is `行程 Briefing`.
- Add category `运动`, not `运行`.
- Date expression: today shows `今天`, tomorrow shows `明天`, farther dates show concrete month/day/weekday.
- Summary copy should include a concise private-assistant style suggestion.
- Reservation status should render as a subtle capsule.
- Trip form category selection should use low-saturation icon chips instead of a plain system picker.
- Light and dark mode must both use the new premium warm concierge palette.
- No new third-party package dependency.

---

### Task 1: Behavior Tests For Category And Briefing

**Files:**
- Modify: `Where2GoTests/TripQueryServiceTests.swift`
- Modify: `Where2Go/Models/TripCategory.swift`
- Modify: `Where2Go/Services/TripQueryService.swift`

**Interfaces:**
- Produces: `TripCategory.sport`
- Produces: `TripQueryService.relativeDayText(for:now:calendar:) -> String`
- Updates: `TripQueryService.summary(for:trips:now:calendar:) -> String`

- [ ] Add tests that assert the sport category title/icon and the smarter date labels.
- [ ] Run tests and verify they fail before implementation.
- [ ] Implement category and summary logic.
- [ ] Run tests and verify they pass.

### Task 2: Design Tokens And Category Palette

**Files:**
- Modify: `Where2Go/DesignSystem/DesignTokens.swift`
- Modify: `Where2Go/Models/TripCategory.swift`

**Interfaces:**
- Produces: warm light/dark semantic color tokens.
- Produces: low-saturation category tint colors.

- [ ] Replace blue/system background tokens with warm concierge semantic tokens.
- [ ] Add reusable helpers for card stroke, soft shadow, icon background, and capsule background.
- [ ] Keep all colors token-driven.

### Task 3: Core Cards And Homepage

**Files:**
- Modify: `Where2Go/Views/NextTrip/NextTripView.swift`
- Modify: `Where2Go/Views/Components/TripRowView.swift`
- Modify: `Where2Go/Views/Components/EmptyStateView.swift`

**Interfaces:**
- Consumes: new `DesignTokens`.
- Consumes: `TripQueryService.summary`.

- [ ] Keep page title as `下一程`.
- [ ] Rename the summary label to `行程 Briefing`.
- [ ] Render trip rows as refined warm cards.
- [ ] Render `已预约` as a subtle capsule.
- [ ] Update empty-state copy and styling without implying the next trip is today.

### Task 4: Form Category Selector

**Files:**
- Modify: `Where2Go/Views/TripForm/TripFormView.swift`

**Interfaces:**
- Consumes: `TripCategory.allCases`.
- Produces: chip/grid category selection bound to `selectedCategory`.

- [ ] Replace plain category picker with low-saturation icon chips.
- [ ] Ensure touch targets are at least 44pt high.
- [ ] Preserve existing save/edit behavior.

### Task 5: Supporting Screens And Dark Mode

**Files:**
- Modify: `Where2Go/Views/Calendar/MonthCalendarView.swift`
- Modify: `Where2Go/Views/Timeline/TimelineView.swift`
- Modify: `Where2Go/Views/Settings/SettingsView.swift`
- Modify: `Where2Go/Views/TripForm/TripDetailView.swift`

**Interfaces:**
- Consumes: new tokens and category colors.

- [ ] Align backgrounds, selected states, section surfaces, and detail chips with the new visual system.
- [ ] Keep native navigation and form semantics.
- [ ] Confirm both light and dark mode compile and render.

### Task 6: Verification

**Files:**
- No source edits expected.

- [ ] Run `xcodebuild test` on iPhone 17 / iOS 26.5.
- [ ] Run `xcodebuild build`.
- [ ] Install and launch the app in Simulator.
- [ ] Capture a screenshot and visually inspect the first screen.
