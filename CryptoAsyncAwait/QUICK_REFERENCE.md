# 🚀 Quick Reference - v2.0 API

## Самые нужные методы и изменения

### 1️⃣ Cache Invalidation

```swift
// Очистить кэш перед force refresh
coinListViewModel.invalidateCaches()

// Или конкретные кэши
if let repo = repository as? CoinRepository {
    repo.invalidatePricesCache()
    repo.invalidateAllCoinsCache()
    repo.invalidateTopCoinsCache()
}
```

### 2️⃣ Force Refresh Assets (с error handling)

```swift
// OLD (v1.0)
await assetsViewModel.forceRefreshAssetPrices(context: context)

// NEW (v2.0) - пробрасывает ошибки
do {
    try await assetsViewModel.forceRefreshAssetPrices(context: context)
} catch {
    // Handle error
    showError(error.localizedDescription)
}
```

### 3️⃣ Pull-to-Refresh в CoinsPage

```swift
.refreshable {
    coinListViewModel.invalidateCaches()  // ← Important!
    await coinListViewModel.loadCoins()
}
```

### 4️⃣ Pull-to-Refresh в AssetsView

```swift
.refreshable {
    do {
        try await assetsViewModel.forceRefreshAssetPrices(context: context)
    } catch {
        refreshError = error.localizedDescription
        showRefreshError = true
    }
}
```

### 5️⃣ Cache Behavior

```swift
// Загрузка монет - автоматически кэширует
let coins = try await repository.getCoins(page: 1, limit: 50)
// ↓
// Второй раз - из кэша (30 минут)
let cachedCoins = try await repository.getCoins(page: 1, limit: 50)
// ↓
// При ошибке сети - fallback на кэш
// ❌ Network Error → ✅ Returns cached data
```

### 6️⃣ Retry Behavior

```swift
// Автоматический retry при ошибке сети
await coinListViewModel.loadCoins()
// ↓
// При ошибке:
// Попытка 1 → fail → wait 0.5s
// Попытка 2 → fail → wait 1.0s
// Попытка 3 → fail → wait 1.5s
// Показать ошибку пользователю
```

### 7️⃣ Console Logs to Look For

```
✅ Успешно: ✅, 💾, 🔄
❌ Ошибка: ❌, ⚠️, ⏳
```

**Примеры:**
```
💾 Using cached coins for page 1
🔄 Retrying coin load (attempt 1/3)...
✅ Asset prices updated and saved
⚠️ Network error, using cached coins
❌ Failed to load coins after 3 attempts
```

---

## 🔧 Common Scenarios

### Scenario 1: Pull-to-Refresh (Coins)
```swift
coinListViewModel.invalidateCaches()
await coinListViewModel.loadCoins()
// Результат: свежие данные из API
```

### Scenario 2: Pull-to-Refresh (Assets)
```swift
do {
    try await assetsViewModel.forceRefreshAssetPrices(context: context)
} catch {
    // Show error to user
}
```

### Scenario 3: Offline Mode
```swift
// User has no internet
let coins = try await repository.getCoins(page: 1, limit: 50)
// Result: Cached data (if available) or Error (if no cache)
```

### Scenario 4: Weak Network
```swift
// User on slow connection
await coinListViewModel.loadCoins()
// Retries 3 times with backoff:
// 0.5s → 1.0s → 1.5s
// Then either success or error
```

---

## ⚠️ Breaking Changes

### Only 1 breaking change:

```swift
// BEFORE (v1.0)
func forceRefreshAssetPrices(context: ModelContext) async

// AFTER (v2.0)
func forceRefreshAssetPrices(context: ModelContext) async throws
// ↑ Now throws - you MUST handle errors
```

**Fix:**
```swift
// Add do-catch
do {
    try await assetsViewModel.forceRefreshAssetPrices(context: context)
} catch {
    // Handle
}
```

---

## 📊 Performance

| Operation | Before | After |
|-----------|--------|-------|
| Repeat load | ~1-2s | Instant 💾 |
| Offline | ❌ Error | ✅ Cache |
| Slow network | ❌ Fails | ✅ Retries |
| Add asset | 2.0s | ~1.0s |

---

## 🎯 Key Constants

```swift
// CoinRepository
topCoinsCacheDuration = 1800    // 30 min
allCoinsCacheDuration = 1800    // 30 min
pricesCacheDuration = 60        // 1 min

// AssetsViewModel
priceRefreshMinInterval = 60    // Debounce 60s

// CoinListViewModel
maxRetries = 3                  // 3 attempts
backoffDelays = [0.5, 1.0, 1.5] // seconds
```

---

## 🧪 How to Test

### Test Cache
```
1. Load coins (with internet)
2. Turn off internet
3. Return to coins view
4. Should see cached data ✅
```

### Test Retry
```
1. Use Network Link Conditioner
2. Set to "Very Bad Network"
3. Try to load coins
4. Watch console for retry logs 🔄
5. Should succeed after retries ✅
```

### Test Error Handling
```
1. Turn off internet
2. Pull to refresh Assets
3. Should see error alert ⚠️
4. Tap "Retry"
5. Should try again ✅
```

---

## 📝 Tips & Tricks

### 💡 Tip 1: Force Fresh Data
```swift
// Always get new data from API
coinListViewModel.invalidateCaches()
await coinListViewModel.loadCoins()
```

### 💡 Tip 2: Check Cache Status
```
// Look for "💾" in console = using cache
// Look for "⚠️" in console = fallback to cache
// Look for "🔄" in console = retrying
```

### 💡 Tip 3: Disable Retry (for testing)
```swift
// In CoinListViewModel
// private let maxRetries = 0  // Disable retries temporarily
```

### 💡 Tip 4: Clear All Caches
```swift
// Nuclear option - clear everything
coinListViewModel.invalidateCaches()
// Or manually in repository
repository.invalidatePricesCache()
repository.invalidateTopCoinsCache()
repository.invalidateAllCoinsCache()
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Not using cache" | Check cache duration constants |
| "Retry not working" | Check network connectivity |
| "Error not showing" | Check do-catch blocks |
| "Old data showing" | Call `invalidateCaches()` |
| "Slow performance" | Check cache duration (30 min is default) |

---

## 📚 Full Documentation

For detailed info:
- **IMPROVEMENTS.md** - All 15 improvements explained
- **MIGRATION.md** - How to update your code
- **RELEASE_NOTES_v2.0.md** - User-facing features
- **CHANGES_SUMMARY.md** - All code changes

---

## ✅ Checklist for Code Review

- [ ] Using `invalidateCaches()` before pull-to-refresh
- [ ] Handling errors with try-catch for `forceRefreshAssetPrices()`
- [ ] Not manually managing retry (built-in now)
- [ ] Cache durations make sense for your use case
- [ ] Error alerts shown to user
- [ ] Console logs helpful for debugging

---

## 🚀 That's it!

You're ready to use v2.0!

Key takeaways:
1. ✅ Cache works automatically
2. ✅ Retry happens automatically
3. ✅ Errors are shown to users
4. ⚠️ Remember `invalidateCaches()` for fresh data
5. ⚠️ Handle throws in `forceRefreshAssetPrices()`

Happy coding! 🎉
