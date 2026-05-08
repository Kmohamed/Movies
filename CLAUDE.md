# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

iOS app (Swift 4.2, iOS 11.0+) that fetches and displays a list of movies in a `UITableView`. CocoaPods-managed; always open the **workspace**, not the project file.

## Commands

Dependencies must be installed before first build:

```bash
pod install
```

Build / run / test from the command line (always use `Movies.xcworkspace`, never `Movies.xcodeproj`):

```bash
# Build
xcodebuild -workspace Movies.xcworkspace -scheme Movies -sdk iphonesimulator build

# Run all unit + integration tests
xcodebuild test -workspace Movies.xcworkspace -scheme Movies \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Run a single test (or class) — use the -only-testing: form
xcodebuild test -workspace Movies.xcworkspace -scheme Movies \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:MoviesTests/MovieParserTests/testParsingArrayOfMovies
```

Test targets: `MoviesTests` (unit + integration, plain XCTest with hand-rolled mocks) and `MoviesUITests` (XCUITest, stubs HTTP via Swifter).

## Architecture

MVP, with the dependency chain wired by `MoviesListViewController.moviesPresenter()` ([Movies/View/MoviesListViewController.swift:26](Movies/View/MoviesListViewController.swift:26)):

```
View (MoviesListViewController)
  └── Presenter (MoviesListPresenter)        ← owns [Movie] state, exposes index-based getters
        └── Model (MoviesListModel)          ← orchestrates fetch + parse
              ├── Network                    ← URLSession GET wrapper
              └── MovieParser                ← JSONSerialization → [Movie]
```

Communication is one-way via weak `delegate` protocols at each seam (`MoviesListModelDelegate`, `MoviesListPresenterDelegate`). The Presenter is itself the Model's delegate — it stores the fetched movies and forwards a simplified `didFetchMovies(success:)` up to the View. The View hops to the main queue before calling `reloadData`; nothing below the View is main-thread aware.

### Network layer is the UI-test seam

[Movies/Network.swift](Movies/Network.swift) inspects `ProcessInfo.processInfo.environment` at request time:

- If `isUITest` is set → base URL comes from the `BASEURL` env var (used by `MoviesUITests` to point at `http://localhost:8080`).
- Otherwise → hardcoded `https://api.example.com`.

Unit/integration tests don't go through this branch — they inject a `NetworkLayerMock` subclass ([MoviesTests/Helper/NetworkLayerMock.swift](MoviesTests/Helper/NetworkLayerMock.swift)) that overrides `executeGETRequest` and synchronously calls back with canned data. Because the mock fires synchronously, integration tests can assert on presenter state immediately after `fetchMovies()` with no expectation/wait.

UI tests use Swifter ([HTTPDynamicStubs](MoviesUITests/HTTPStubs.swift)) to spin up an in-process HTTP server on port 8080, register canned JSON for `/Movies`, then launch the app with the env vars above. JSON fixtures live alongside the UI test files (e.g. [MoviesUITests/listOfMovies.json](MoviesUITests/listOfMovies.json)) and are loaded via `Bundle(for:)` lookup.

### Subclass-based mocking pattern

Mocks in this codebase are concrete subclasses of production types, not protocols:

- `NetworkLayerMock: Network` overrides `executeGETRequest`.
- `MoviesListModelMock: MoviesListModel` overrides `fetchMovies` to skip the network entirely.

For this to work, production methods that need to be mocked are declared `open` (see `MoviesListModel.fetchMovies`, `Network.executeGETRequest`). When adding new dependencies that tests will need to swap out, keep this convention — declare the class `open` and the overridable method `open func`, rather than introducing a protocol.

## Quirks worth knowing

- The JSON field name is `"ratting"` (misspelled), not `"rating"`. This is consistent across the parser, fixtures, and stub server. Don't "fix" one without fixing all of them — the parser, the test fixtures, and any backend stub must agree.
- `Movie` properties are stored on a Swift class (not a struct) and are mutable `var`s with `Optional<String>` types. The presenter exposes them via index-based getters (`movieName(index:)`, `movieRatting(index:)`) that return empty strings for `nil`.
- The app launches into `MoviesListViewController` from the storyboard with no programmatic root-VC setup in `AppDelegate`.
