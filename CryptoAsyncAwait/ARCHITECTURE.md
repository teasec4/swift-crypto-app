# CryptoAsyncAwait - Project Architecture

## Directory Structure

```
CryptoAsyncAwait/
├── App/
│   ├── CryptoAsyncAwaitApp.swift        # App entry point with SwiftData setup
│   ├── RootView.swift                   # Root navigation logic
│   ├── ContentView.swift                # Main tab-based navigation view
│   └── Theme/                           # Theme & styling system
│       ├── AppTheme.swift               # Color palette + ThemeManager
│       ├── ThemeStyles.swift            # Button, text, and card styles
│       ├── ColorExtensions.swift        # Color constants and helpers
│       └── README.md                    # Theme usage documentation
│
├── core/                                # Core/Shared layer
│   ├── DI/
│   │   └── DependencyContainer.swift    # Dependency injection singleton
│   │
│   ├── Protocols/                       # Centralized protocol definitions
│   │   ├── NetworkProtocols.swift
│   │   ├── DataFetchingProtocols.swift
│   │   ├── RepositoryProtocols.swift
│   │   └── ServiceProtocols.swift
│   │
│   ├── Networking/                      # Network layer
│   │   ├── NetworkService.swift         # HTTP request handler (Alamofire)
│   │   ├── CoinAPI.swift                # CoinGecko API implementation
│   │   ├── NetworkLogger.swift          # Network debugging
│   │   └── SupabaseService.swift        # Supabase auth client
│   │
│   ├── Errors/                          # Error types
│   │   ├── NetworkError.swift
│   │   └── CoinError.swift
│   │
│   └── Extensions/                      # Utility extensions
│       ├── Double.swift
│       └── CoinError+Mapping.swift
│
├── Features/                            # Feature modules
│   │
│   ├── Auth/                            # Authentication feature
│   │   ├── Model/
│   │   │   └── UserEntity.swift         # SwiftData user model
│   │   ├── View/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   ├── ProfileView.swift
│   │   │   └── Widgets/
│   │   ├── ViewModel/
│   │   │   └── AuthViewModel.swift      # Auth state + persistence
│   │   └── Service/
│   │       └── UserPersistenceService.swift
│   │
│   ├── Markets/                         # Cryptocurrency markets
│   │   ├── Model/
│   │   │   ├── Coin.swift               # Coin data model
│   │   │   └── PricePoint.swift         # Chart data point
│   │   ├── View/
│   │   │   ├── MarketsPage.swift        # Main markets page
│   │   │   ├── MarketsListView.swift    # Unified: paginated list + search + add asset button
│   │   │   ├── MarketDetailView.swift   # Coin detail + chart
│   │   │   ├── CoinRowView.swift        # List item with add button
│   │   │   ├── CoinChartView.swift      # TradingView-like chart
│   │   │   └── HelperView/              # Loading states, errors, skeletons
│   │   ├── ViewModel/
│   │   │   ├── MarketsListViewModel.swift  # Pagination + search + coin loading
│   │   │   └── MarketDetailViewModel.swift # Chart data loading
│   │   ├── Repository/
│   │   │   ├── CoinRepository.swift     # Coin data + caching (30min TTL, 1min for prices)
│   │   │   └── ChartDataRepository.swift # Chart data + caching
│   │   └── Service/
│   │       └── CoinSearchService.swift  # Fuzzy search + category filtering
│   │
│   ├── Portfolio/                       # User's cryptocurrency portfolio
│   │   ├── Model/
│   │   │   └── UserAsset.swift          # SwiftData asset model (coin + amount + user)
│   │   ├── View/
│   │   │   ├── PortfolioView.swift      # Main portfolio page (edit/delete only)
│   │   │   ├── PortfolioAssetRowView.swift # List item for user assets
│   │   │   └── AddAssetFormView.swift   # Add/edit form (shared with Markets)
│   │   ├── ViewModel/
│   │   │   ├── PortfolioViewModel.swift # Asset management + price refresh
│   │   │   └── AddAssetViewModel.swift  # Form state machine (used in Markets + Portfolio)
│   │   └── Service/
│   │       └── AssetValidator.swift     # Amount + ownership validation
│   │
│   └── Navigation/                      # Navigation components
│       └── Components/
│           └── NavigationTabBar.swift   # Bottom tab bar
│
└── Assets.xcassets/
```

## Key Changes from Original Structure

### 1. **Renaming for Clarity**
- `Coins` → `Markets` (better reflects cryptocurrency market context)
- `Assets` → `Portfolio` (clearer user intent)
- `CoinsPage` → `MarketsPage`
- `CoinListView` → `MarketsListView`
- `CoinListViewModel` → `MarketsListViewModel`
- `CoinDetailView` → `MarketDetailView`
- `CoinDetailViewModel` → `MarketDetailViewModel`
- `AssetsViewModel` → `PortfolioViewModel`
- `AssetsView` → `PortfolioView`
- `UserAssetRowView` → `PortfolioAssetRowView`
- `CustomTabBar` → `NavigationTabBar` (moved to Features/Navigation/Components)

### 2. **Centralized Protocols**
Created `core/Protocols/` directory:
- **NetworkProtocols.swift** - `NetworkServiceProtocol`
- **DataFetchingProtocols.swift** - All data fetching interfaces
- **RepositoryProtocols.swift** - Repository contracts
- **ServiceProtocols.swift** - Service interfaces (error mapping, validation, search)

### 3. **Improved Organization**
- Moved `CustomTabBar` from `core/` to `Features/Navigation/Components/` (UI belongs in Features)
- Removed incomplete `ServiceLocator(inprogres).swift`
- Organized core utilities in clean layers

### 4. **Removed Files**
- `core/Networking/CoinAPIProtocol.swift` (consolidated into core/Protocols)
- `core/ServiceLocator(inprogres).swift` (incomplete, removed)
- Duplicate protocol definitions

## Architecture Layers

### 1. **Presentation Layer** (Features/*)
- Views (SwiftUI)
- ViewModels (@MainActor, @Published properties)
- Tab-based navigation

### 2. **Repository Layer** (Features/*/Repository)
- Data caching with TTL
- Handles both local and remote data
- Error mapping

### 3. **Service Layer** (Features/*/Service, core/Networking)
- Business logic isolation
- NetworkService (HTTP via Alamofire)
- CoinAPI (CoinGecko implementation)
- Error mapping, validation, search

### 4. **Model Layer** (Features/*/Model)
- Codable data structures
- SwiftData entities (@Model)

### 5. **Core/Infrastructure** (core/)
- Dependency injection
- Protocol definitions
- Network layer
- Error types
- Extensions

## Data Flow Example: Fetching Markets

```
MarketsListView
    ↓
MarketsListViewModel.loadCoins()
    ↓
CoinRepository.getCoins(page:limit:)
    ↓
CoinAPI.fetchCoins() [implements CoinDataFetchingService]
    ↓
NetworkService.request<[Coin]>() [implements NetworkServiceProtocol]
    ↓
Alamofire Session
    ↓
CoinGecko API
    ↓
[Caching: 30min TTL] ← CoinRepository
    ↓
@Published var state: ScreenState
    ↓
MarketsListView updates UI
```

## Caching Strategy

- **Markets List**: 30 minutes
- **Top Coins**: 30 minutes
- **Simple Prices**: 1 minute
- **Fallback**: Returns cached data on network error
- **Invalidation**: Manual cache clearing methods available

## Key Design Patterns

1. **MVVM** - Views observe ViewModels via @Published
2. **Repository Pattern** - Data abstraction with caching
3. **Dependency Injection** - DependencyContainer singleton
4. **Protocol-Oriented** - Heavy use of protocols for flexibility
5. **Async/Await** - Modern concurrency handling
6. **Error Mapping** - Centralized error transformation

## Testing Considerations

- Protocols enable easy mocking
- Services can be replaced via DependencyContainer
- ViewModels accept injected dependencies
- Network layer abstraction allows test doubles

## Recent Refactoring (V2.0) - Complete Cleanup

### Files Deleted:
- `Features/Markets/ViewModel/GlobalMarketViewModel.swift`
- `Features/Markets/View/GlobalMarketHeaderView.swift`
- `Features/Markets/View/HelperView/Skeleton/GlobalMarketSkeletonView.swift`
- `Features/Markets/Repository/GlobalRepository.swift`
- `Features/Markets/Model/GlobalMarketData.swift`
- `Features/Markets/ViewModel/MarketsPageViewModel.swift`
- `Features/Portfolio/View/AddAssetModalView.swift`

### Architecture Changes:
1. **Removed Global Market Feature** - Global market cap header completely removed
2. **Unified Markets Page** - Single MarketsListView with:
   - Paginated coin list (50 coins per page)
   - Integrated search with fuzzy matching
   - Category filtering (All, Top 10, DeFi, AI)
   - Inline "+" button on each coin to add to portfolio
3. **Single API Call** - Coins loaded once via `getCoins()` and `getTopCoins()` for search
4. **Portfolio Focused** - Portfolio tab now only for managing existing assets:
   - View portfolio value
   - Edit asset amounts
   - Delete assets
5. **Clean Protocols** - All protocols centralized in `core/Protocols/`

### Benefits:
- ✅ Single network request for coins (was 2 before)
- ✅ Better UX - search and add on same page
- ✅ Fewer ViewModels (removed 2)
- ✅ No unused modal screens
- ✅ Reduced memory footprint
- ✅ Cleaner codebase (no duplicate protocol definitions)

## Theme System (V2.1)

### Overview
Centralized theme management with support for light and dark modes. All colors and styles are organized in `App/Theme/`.

### Key Files
- **AppTheme.swift** - `ThemeManager` singleton, `AppColors` palette
- **ThemeStyles.swift** - Reusable button and card modifiers
- **ColorExtensions.swift** - Color constants

### Color Palette
- **Primary**: #0078FF (blue) with dark variant
- **Accents**: Green (#56C226), Red (#FF5555), Orange (#FF9600)
- **Light Mode**: Light background + light text
- **Dark Mode**: Dark background + light text

### Usage Pattern
```swift
struct MyView: View {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack {
                Text("Title").appTitle(themeManager)
                Button("Action") {}
                    .buttonStyle(PrimaryButtonStyle(theme: themeManager))
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}
```

### ProfileView Redesign
- Large avatar with gradient background
- Key stats cards (Member Since, Status)
- Settings section with Dark Mode toggle
- Improved visual hierarchy and spacing
- Dynamic colors that adapt to selected theme

### Theme Persistence
- User preference saved in `UserDefaults` key: `"isDarkMode"`
- Persists across app launches
- Can be toggled from ProfileView

## Future Improvements

- [ ] Modularize into SPM packages
- [ ] Add unit tests for repositories
- [ ] Implement error recovery flows
- [ ] Add offline-first capability
- [ ] Performance monitoring
- [ ] Advanced filtering in Markets page
- [ ] Apply theme system to all views (Markets, Portfolio, Auth)
- [ ] Add more theme presets (e.g., High Contrast)
