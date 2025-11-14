# Диагностика: Ассеты не сохраняются

## Сценарий: Добавил ассет → Перезагрузил → Ассета нет

Это означает, что ассет не сохраняется в SwiftData. Проверим логику.

## Логи которые должны быть

### 1. При запуске приложения

```
🚀 RootView appeared - restoring user from database
🔍 getOrCreateLocalUser: user@email.com
📥 Found existing user in database: user@email.com
   Assets count: 0
👤 User changed: user@email.com
📲 Loading assets for: user@email.com
📥 loadAssets for: user@email.com
   Fetching from user.assets relationship...
   Found 0 assets in relationship
✅ Loaded 0 assets via relationship for: user@email.com
📱 AssetsView appeared, user: user@email.com
```

### 2. При добавлении ассета

```
💾 addAsset called for user@email.com: Bitcoin x1.0
   User ID: 550e8400-e29b-41d4-a716-446655440000
   Current assets count before: 0
   Created new asset: (uuid)
➕ Added Bitcoin: 1.0 units to user@email.com
   Total assets now: 1
✅ Context saved successfully
   Assets in DB: 1
```

### 3. При перезагрузке

```
🚀 RootView appeared - restoring user from database
🔍 getOrCreateLocalUser: user@email.com
📥 Found existing user in database: user@email.com
   Assets count: 1  ← ✅ ВАЖНО! Должно быть 1
👤 User changed: user@email.com
📲 Loading assets for: user@email.com
📥 loadAssets for: user@email.com
   Fetching from user.assets relationship...
   Found 1 assets in relationship  ← ✅ Ассет загружен!
✅ Loaded 1 assets via relationship for: user@email.com
```

## Что проверить если ассет исчезает

### Проблема 1: Context.save() не вызывается

**Место:**
```swift
// AddAssetFormView.swift линия 84
await viewModel.submit(context: context)
```

Убедись что:
1. ✅ `context` передан правильно
2. ✅ `context.save()` вызывается в `addAsset()`
3. ✅ Нет exception при `save()`

**Проверка:**
Ищи в логах строку `✅ Context saved successfully`

---

### Проблема 2: User не сохранен в БД

Если логи показывают:
```
📥 Found existing user in database: user@email.com
   Assets count: 0  ← ПРОБЛЕМА!
```

Это значит:
- ✅ Юзер найден в БД
- ❌ Но ассеты не привязаны к нему

**Причина:** В `addAsset()` добавляем ассет в `user.assets`, но `user` может быть local copy, не из БД.

**Решение:**
Убедись что в `ContentView.onAppear()`:
```swift
assetsViewModel.currentUser = authVM.user
```

Этот юзер должен быть ТОТ ЖЕ объект, что вернулась из `getOrCreateLocalUser()`.

---

### Проблема 3: Relationship не установлена

Проверь модель `UserAsset`:

```swift
@Model
final class UserAsset {
    ...
    var user: UserEntity?  // ✅ Должно быть не null!
}
```

И `UserEntity`:

```swift
@Model
final class UserEntity: Equatable {
    ...
    @Relationship(deleteRule: .cascade, inverse: \UserAsset.user)
    var assets: [UserAsset] = []  // ✅ Обратная связь!
}
```

**Проверка:**
В логе `addAsset()` должно быть:
```
   User ID: 550e8400-...  ← ID существует!
   Current assets count before: 0
```

Если видишь `No current user set`, то `assetsViewModel.currentUser` не установлен.

---

### Проблема 4: ModelContainer не инициализирован

**Где:** `CryptoAsyncAwaitApp.swift`

```swift
.modelContainer(for: [
    UserEntity.self,
    UserAsset.self
])
```

✅ Оба типа должны быть зарегистрированы!

---

## Полный checklist

- [ ] Логи показывают `✅ Context saved successfully` при добавлении
- [ ] После перезагрузки "Assets count:" показывает > 0
- [ ] В `AssetsView` видится текст "Loaded X assets"
- [ ] `currentUser` в `AssetsView.onAppear` не null
- [ ] `UserEntity.email` помечен как `@Attribute(.unique)`
- [ ] `UserAsset.user` не null при создании
- [ ] `user.assets.append(newAsset)` вызывается перед `context.save()`

## Как читать логи

Добавь в `Console` фильтр:
```
category: "Assets" OR category: "Auth"
```

**Порядок логов говорит о проблеме:**

1. Если логи не идут по порядку выше — есть проблема с flow
2. Если `addAsset` не вызывается — проверь `AddAssetFormView`
3. Если `save()` не вызывается — ассет только в памяти
4. Если `loadAssets` не видит ассет — он не в БД

## Быстрая проверка

Удали приложение с девайса и начни с чистого листа:

```
1. Запусти приложение
2. Зарегистрируйся новым юзером
3. Добавь ассет
4. Закрой приложение (полностью, свайпом)
5. Открой заново
6. Проверь есть ли ассет
```

Если ассет исчезает на шаге 6, то проблема в том, что он не сохранялся в БД.
