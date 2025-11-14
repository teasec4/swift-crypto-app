# CryptoAsyncAwait - Architecture Guide

## Project Structure

```
CryptoAsyncAwait/
├── App/                          # Application root
│   └── ContentView.swift         # Main navigation container
├── Features/                     # Feature modules
│   ├── Coin/                     # Coin listing feature
│   │   ├── Repository/           # Data layer
│   │   │   ├── CoinRepository.swift       # Main coin data + caching
│   │   │   └── GlobalRepository.swift     # Global market data + caching
│   │   ├── ViewModel/            # Business logic layer
│   │   │   ├── CoinsPageViewModel.swift   # Page state (modal control)
│   │   │   ├── CoinListViewModel.swift    # Coin list state
│   │   │   └── GlobalMarketViewModel.swift # Market data state
│   │   └── View/                 # Presentation layer
│   │       ├── CoinsPage.swift          # Main page
│   │       └── Components/              # Reusable views
│   │
│   └── Assets/                   # Asset management feature
│       ├── ViewModel/            # Business logic
│       │   ├── AssetsViewModel.swift     # Asset list state
│       │   └── AddAssetViewModel.swift   # Form state
│       └── View/                 # Presentation
│           ├── AssetsView.swift
│           ├── AddAssetModalView.swift
│           └── AddAssetFormView.swift
│
├── core/                         # Shared utilities
│   ├── Services/                 # API & data fetching
│   │   ├── CoinDataFetchingService.swift
│   │   ├── GlobalMarketDataFetchingService.swift
│   │   └── SimplePriceFetchingService.swift
│   ├── Models/                   # Data models
│   └── Validators/               # Business validation
│
└── ARCHITECTURE.md               # This file
```

## Architecture Layers

### Presentation Layer (View)
- **SwiftUI Views** (`@View`)
- Use `@EnvironmentObject` for dependency injection
- No business logic - only display and user input
- Direct binding to ViewModels

### Business Logic Layer (ViewModel)
- **Observable** (`@MainActor @ObservableObject`)
- Manage state (`@Published`)
- Handle user actions (tap, input)
- Coordinate between views and data layer
- Each VM is responsible for ONE feature

### Data Access Layer (Repository)
- **Protocol-based** design
- Handle API calls and caching
- Separate concerns: fetching vs caching
- Throw errors that get mapped to user-friendly messages

## Key Principles

### 1. **Single Responsibility**
- `CoinsPageViewModel` = only modal control
- `CoinListViewModel` = only coin list state
- `GlobalMarketViewModel` = only market data
- Each has ONE reason to change

### 2. **Dependency Injection via @EnvironmentObject**
Instead of nesting ViewModels:
```swift
// ❌ OLD (bad)
@StateObject private var parent = ParentVM(
    child1: ChildVM1(),
    child2: ChildVM2()
)

// ✅ NEW (good)
@StateObject private var parent = ParentVM()
@StateObject private var child1 = ChildVM1()
@StateObject private var child2 = ChildVM2()

CoinsPage()
    .environmentObject(parent)
    .environmentObject(child1)
    .environmentObject(child2)
```

### 3. **Caching Strategy**
Caching is built into each Repository:
- `CoinRepository`: TopCoins cache (30min) + Prices cache (1min)
- `GlobalRepository`: Market data cache (1min)
- No separate `CachedRepository` wrapper - simpler design

### 4. **Naming Conventions**
| Type | Pattern | Example |
|------|---------|---------|
| ViewModel | `[Feature]ViewModel` | `CoinsPageViewModel`, `AddAssetViewModel` |
| Repository | `[Entity]Repository` | `CoinRepository`, `GlobalRepository` |
| Service | `[Entity][Action]Service` | `CoinDataFetchingService` |
| View | `[Feature]View` | `CoinsPage`, `AddAssetModalView` |

## Data Flow Example

### Loading Coins List

```
1. User opens Coins tab
   ↓
2. CoinsPage appears
   ↓
3. CoinListView requests data: coinListViewModel.loadCoins()
   ↓
4. CoinListViewModel calls: repository.getCoins(page: 1, limit: 250)
   ↓
5. CoinRepository:
   - Checks cache (is it fresh?)
   - If fresh → return cached data
   - If stale → fetch from API via dataFetcher
   - Cache result + return
   ↓
6. CoinListViewModel updates @Published state
   ↓
7. CoinListView re-renders with new data
```

## Common Tasks

### Adding New Feature
1. Create `Features/[FeatureName]/` folder
2. Add `ViewModel/[Feature]ViewModel.swift`
3. Add `View/[Feature]View.swift`
4. Add `Repository/[Feature]Repository.swift` (if needed)
5. Inject in ContentView as `@StateObject`

### Adding API Call
1. Create service in `core/Services/[Entity]FetchingService.swift`
2. Inject in Repository
3. Handle errors with `ErrorMappingService`
4. Update ViewModel state with result

### Testing Data Flow
1. Print in ViewModel: `print("State: \(state)")`
2. Check if Repository is called: add breakpoint
3. Verify cache: check timestamps

## Performance Notes

- **No recreating ViewModels**: use `@StateObject` at top level
- **Async/await**: all network calls are async
- **Main thread safety**: `@MainActor` on all UI-related code
- **Debouncing**: price refresh has 60-sec minimum interval

## Future Improvements

- [ ] Add `Unit Tests` for ViewModels
- [ ] Add `Integration Tests` for Repositories
- [ ] Extract common patterns into protocols
- [ ] Add logging system (Combine + file writer)
- [ ] Implement offline mode (SQLite caching)
- [ ] Add error recovery UI
