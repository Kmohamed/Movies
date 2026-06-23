---
flow: movies_list_fetch
module: Movies
entry_point: MoviesListPresenter.fetchMovies

participating_symbols:
  - MoviesListPresenter.fetchMovies
  - MoviesListPresenter.didFetchMovies
  - MoviesListPresenter.moviesCount
  - MoviesListPresenter.movieName
  - MoviesListPresenter.movieRatting
  - MoviesListModel.fetchMovies
  - MovieParser.parseMovies

outer_boundary:
  - Network.executeGETRequest
---

# Flow: Movies List Fetch & Display

## Summary

The Movies app is a single-screen iOS app that fetches a list of movies over
HTTP and shows them in a `UITableView` (title + rating per row). It is wired
together with MVP (Model–View–Presenter): the **View** owns a **Presenter**,
the Presenter owns a **Model**, and the Model talks to a **Network** layer and
a **Parser**. Communication flows back up through one-way `weak delegate`
protocols at each seam.

This flow describes the core feature end to end: a caller asks the Presenter to
fetch movies, the request travels down to the Network boundary, the response is
parsed into `[Movie]`, the parsed list is stored on the Presenter, and a
success/failure signal is forwarded up to the View, which reloads the table.
The Network layer is the only outer boundary — everything else is owned by the
flow and is the thing under test. In production the Network layer loads a
bundled `movies` data asset; in unit/integration tests it is swapped for a
synchronous mock (`NetworkLayerMock`) so presenter state can be asserted
immediately after `fetchMovies()` returns.

## Components

| Component | Type | Responsibility |
|---|---|---|
| `MoviesListViewController` | View | Hosts the `UITableView`, builds the dependency chain in `moviesPresenter()`, triggers the fetch in `viewDidLoad`, reloads the table on the main thread when the fetch completes. |
| `MoviesListPresenter` | Presenter | Owns the `[Movie]` state. Exposes index-based getters (`moviesCount`, `movieName(index:)`, `movieRatting(index:)`). Is itself the Model's delegate — stores the fetched movies and forwards a simplified `didFetchMovies(success:)` up to the View. |
| `MoviesListModel` | Model | Orchestrates fetch + parse. Calls `Network.executeGETRequest`, hands the returned `Data` to `MovieParser`, then calls its delegate with `(success, movies)`. |
| `Network` | Boundary | `URLSession` GET wrapper. In UI-test mode reads `BASEURL` from the environment; otherwise loads the bundled `movies` `NSDataAsset` off a background queue. Declared `open` so tests subclass it. |
| `MovieParser` | Helper | `JSONSerialization` → `[Movie]`. Maps each JSON object's `name` and `ratting` (note the spelling) fields onto a `Movie`. |
| `Movie` | Model object | Plain class with two mutable optionals: `name: String?`, `rating: String?`. |

## Architecture

```
View (MoviesListViewController)
  └── Presenter (MoviesListPresenter)      ← owns [Movie] state, index-based getters
        └── Model (MoviesListModel)        ← orchestrates fetch + parse
              ├── Network                  ← URLSession GET wrapper  (OUTER BOUNDARY — mocked)
              └── MovieParser              ← JSONSerialization → [Movie]
```

Each downward arrow is a direct ownership reference; each result travels back up
through a `weak delegate`: `MoviesListModelDelegate` (Model → Presenter) and
`MoviesListPresenterDelegate` (Presenter → View).

## Inputs

- **Trigger**: `MoviesListPresenter.fetchMovies()` (called by the View in
  `viewDidLoad`, or directly by a test).
- **Network response**: raw `Data?` returned by `Network.executeGETRequest`. In
  tests this is canned JSON; the only field names that matter are `"name"` and
  `"ratting"` (both `String`).
- **Read inputs**: `index: Int` passed to `movieName(index:)` and
  `movieRatting(index:)` after a fetch completes.

## Expected Behavior

### Happy path

1. `MoviesListPresenter.fetchMovies()` delegates straight to
   `MoviesListModel.fetchMovies()`.
2. `MoviesListModel.fetchMovies()` calls
   `Network.executeGETRequest(api: "/Movies", completionBlock:)`.
3. On a non-nil `Data`, the Model builds a `MovieParser` and calls
   `parseMovies(data:)`, getting back `[Movie]`.
4. The Model calls `delegate.didFetchMovies(success: true, movies:)` with the
   parsed list (or `success: false, movies: []` when `Data` is nil).
5. `MoviesListPresenter.didFetchMovies(success:movies:)` stores the array into
   `self.movies` and forwards `didFetchMovies(success:)` to the View.
6. The View hops to the main queue and calls `tableView.reloadData()`.
7. The table data source reads back through the Presenter:
   `moviesCount()` → row count; `movieName(index:)` / `movieRatting(index:)`
   → cell text.

### Ordering invariants

- `Network.executeGETRequest` is called before `MovieParser.parseMovies`
  (you can't parse a response you haven't received).
- `MovieParser.parseMovies` is called before
  `MoviesListPresenter.didFetchMovies` (the stored array is the parsed form).
- `self.movies` is replaced wholesale on every completion — a later fetch
  overwrites an earlier one; there is no merge or append.
- After a successful fetch of N movies, `moviesCount()` returns exactly N.

### State invariants (what the walk should check)

- `moviesCount()` is always `>= 0` and equals the length of the most recently
  stored array.
- For any `index` in `0 ..< moviesCount()`, `movieName(index:)` and
  `movieRatting(index:)` return a `String` (empty string when the underlying
  optional is `nil`) and never crash.
- Before any successful fetch, `moviesCount() == 0`.

### Error modes

- **Nil response**: if `Network.executeGETRequest` calls back with `nil`,
  the Model reports `didFetchMovies(success: false, movies: [])`; the Presenter
  stores an empty array. No throw.
- **Non-array / malformed JSON**: `MovieParser.parseMovies` catches the error
  (or fails the `[[String:String]]` cast) and returns `[]`. No throw; the fetch
  still reports `success: true` because `Data` was non-nil.
- **Missing fields**: a JSON object without `"name"` / `"ratting"` yields a
  `Movie` with `nil` properties; the getters surface `""`.

### Boundaries touched

- Network: yes — `Network.executeGETRequest` (the outer boundary; mocked in
  tests).
- Disk: no direct file I/O in this flow (production reads a bundled asset
  inside the Network layer, which is mocked away).
- Time: no.
- Async dispatch: production is async (background queue / `URLSession`); the
  test mock fires the completion **synchronously**, so integration tests can
  assert presenter state immediately after `fetchMovies()` with no wait.
- Threading: nothing below the View is main-thread aware; only the View hops to
  the main queue before `reloadData()`.

## Example Invocations

### Example 1: Successful fetch of two movies
- Input: mocked `Network` calls back with
  `[{"name":"Inception","ratting":"8.8"},{"name":"Tenet","ratting":"7.4"}]`.
- Expected effects:
  - `MovieParser.parseMovies` returns 2 `Movie`s.
  - `MoviesListPresenter.didFetchMovies(success: true, movies:)` stores both.
  - `moviesCount() == 2`; `movieName(index: 0) == "Inception"`;
    `movieRatting(index: 1) == "7.4"`.

### Example 2: Empty / nil response
- Input: mocked `Network` calls back with `nil`.
- Expected effects:
  - Model reports `didFetchMovies(success: false, movies: [])`.
  - `moviesCount() == 0`; no crash, no throw.

### Example 3: Out-of-range read (risk area)
- Input: after any fetch, call `movieName(index: moviesCount())`.
- Expected (buggy) effect: `self.movies[index]` is an **unguarded** array
  subscript, so an out-of-range index traps and crashes the process. See
  Risk Areas below — this is exactly the kind of integration bug a seeded walk
  should surface.

## Risk Areas / Known Quirks

- ⚠ **Unguarded index getters.** `movieName(index:)` and `movieRatting(index:)`
  do `self.movies[index]` with no bounds check. Any caller that passes an index
  `>= moviesCount()` (or negative) crashes. The table view happens to ask only
  for valid rows, so this never trips in normal UI use — but it is a latent
  crash for any other caller.
- ⚠ **Misspelled JSON field.** The rating field is `"ratting"`, not `"rating"`,
  and this spelling is intentionally consistent across the parser, the test
  fixtures, and the UI-test stub server. Do not "fix" one side without the
  others.
- **Whole-list replacement.** Each completion replaces `self.movies` entirely;
  there is no incremental update or de-duplication.
- **Success decoupled from content.** `success: true` only means the response
  `Data` was non-nil — malformed JSON still reports success with an empty list.
- **Strict cast in the parser.** `parseMovies` casts to `[[String:String]]`;
  any non-string JSON value (e.g. a numeric rating) makes the whole cast fail
  and returns `[]`.

---

<!--
This document is both a human-readable spec and a SmartTest flow doc. The YAML
frontmatter is the contract consumed by the `explore` pipeline (miner, catalog
planner, walk). Module under test: the `Movies/` source tree. Outer boundary
(`Network.executeGETRequest`) is the only dependency mocked during exploration.
-->
