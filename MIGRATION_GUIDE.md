# 🔄 Phase 1 Refactoring - Migration Guide (VSCode)

**Status**: Ready for Manual Execution
**Estimated Time**: 30-60 minutes
**Tool**: VSCode with Find & Replace

---

## 📋 Overview

This guide helps you complete **Phase 1 Critical Architecture Fixes** using VSCode's powerful find-replace features. Already done by Claude:

✅ Created `lib/features/authentication/domain/models/user_model.dart`

**You need to complete**:
1. Delete old `core/domains/` files
2. Update all imports using VSCode Find & Replace
3. Move `AuthNotifier` to correct location
4. Verify compilation

---

## 🚀 Step-by-Step Instructions

### Step 1: Delete Old Core Domain Files

**Action**: Delete these files (they're now moved to features):

```
lib/core/domains/users.dart              ❌ DELETE (moved to authentication)
lib/core/domains/orders.dart             ❌ DELETE (will handle separately)
lib/core/domains/orders_history_dummy.dart   ❌ DELETE (obsolete)
```

**VSCode**:
1. Open Explorer (Ctrl+Shift+E)
2. Navigate to `lib/core/domains/`
3. Right-click `users.dart` → Delete
4. Right-click `orders_history_dummy.dart` → Delete
5. Keep `orders.dart` for now (Phase 1.2)

---

### Step 2: Update ALL Imports for UserModel

**Goal**: Replace all imports from `core/domains/users.dart` to new location.

#### Option A: VSCode Find & Replace (Recommended)

**Steps**:
1. Press `Ctrl+Shift+H` (Find in Files)
2. **Find**: `import 'package:mobile_pager_flutter/features/authentication/domain/models/user_model.dart';`
3. **Replace**: `import 'package:mobile_pager_flutter/features/authentication/domain/models/user_model.dart';`
4. Click "Replace All" (Ctrl+Alt+Enter)

**Expected Files to Update** (~20 files):
- `lib/features/authentication/data/repositories/auth_repository_impl.dart`
- `lib/features/authentication/domain/auth_notifier.dart`
- `lib/features/authentication/domain/repositories/i_auth_repository.dart`
- `lib/features/authentication/presentation/providers/auth_providers.dart`
- `lib/features/pager/data/repositories/pager_repository_impl.dart`
- `lib/features/home/presentation/home_page.dart`
- `lib/features/profile/presentation/profile_page.dart`
- `lib/features/merchant/presentation/pages/merchant_settings_page.dart`
- And 12+ more files...

#### Option B: Manual Update (If Find & Replace Fails)

If VSCode doesn't find all files, update manually:

```bash
# Find all files that import users.dart
grep -r "import.*core/domains/users" lib/
```

Then update each file one by one.

---

### Step 3: Move AuthNotifier to Presentation Layer

**Problem**: `AuthNotifier` is currently in domain layer (wrong!).

**Current Location**:
```
lib/features/authentication/domain/auth_notifier.dart   ❌ WRONG LAYER
```

**Target Location**:
```
lib/features/authentication/presentation/notifiers/auth_notifier.dart   ✅ CORRECT
```

**Steps**:

#### 3.1 Create Notifiers Folder
1. Right-click `lib/features/authentication/presentation/`
2. New Folder → `notifiers`

#### 3.2 Move auth_notifier.dart
1. Open `lib/features/authentication/domain/auth_notifier.dart`
2. Select All (Ctrl+A) → Copy (Ctrl+C)
3. Create `lib/features/authentication/presentation/notifiers/auth_notifier.dart`
4. Paste content
5. Update imports in the file:
   ```dart
   // Change relative imports from:
   import '../repositories/i_auth_repository.dart';

   // To:
   import '../../../domain/repositories/i_auth_repository.dart';
   import '../../../domain/models/user_model.dart';
   ```

#### 3.3 Update Imports to auth_notifier.dart

**Find & Replace**:
- **Find**: `import 'package:mobile_pager_flutter/features/authentication/domain/auth_notifier.dart';`
- **Replace**: `import 'package:mobile_pager_flutter/features/authentication/presentation/notifiers/auth_notifier.dart';`

**Files to Update**:
- `lib/features/authentication/presentation/providers/auth_providers.dart`
- Possibly a few more...

#### 3.4 Delete Old File
Delete: `lib/features/authentication/domain/auth_notifier.dart`

---

### Step 4: Fix Import Issues (if any)

After Steps 1-3, you might see some red squiggly lines. Common fixes:

#### Issue 1: Can't find UserModel
**Solution**: Make sure import is:
```dart
import 'package:mobile_pager_flutter/features/authentication/domain/models/user_model.dart';
```

#### Issue 2: Relative imports broken
**Solution**: Check relative path depth:
```dart
// From presentation/notifiers/ to domain/models/
import '../../../domain/models/user_model.dart';

// From presentation/notifiers/ to domain/repositories/
import '../../../domain/repositories/i_auth_repository.dart';
```

---

### Step 5: Verify Compilation

**Run**:
```bash
flutter clean
flutter pub get
flutter analyze
```

**Expected**:
- ✅ 0 errors
- ✅ 0 warnings (or minimal)
- ⚠️ If errors, check Step 4 fixes

---

## 📊 Checklist

Use this to track progress:

### Files to Delete
- [ ] `lib/core/domains/users.dart`
- [ ] `lib/core/domains/orders_history_dummy.dart`

### Find & Replace Operations
- [ ] Replace import `core/domains/users.dart` → `features/authentication/domain/models/user_model.dart`
- [ ] Replace import `domain/auth_notifier.dart` → `presentation/notifiers/auth_notifier.dart`

### File Moves
- [ ] Create `features/authentication/presentation/notifiers/` folder
- [ ] Move `auth_notifier.dart` from domain to presentation/notifiers
- [ ] Fix relative imports in moved file
- [ ] Delete old `domain/auth_notifier.dart`

### Verification
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` → 0 errors
- [ ] Run `flutter test` (optional)

---

## 🔍 How to Find Files That Need Update

### Method 1: VSCode Search
```
Ctrl+Shift+F
Search: core/domains/users
Results will show all files importing from old location
```

### Method 2: Grep (if available)
```bash
# Find all imports of users.dart
grep -r "import.*core/domains/users" lib/

# Find all imports of auth_notifier
grep -r "import.*auth_notifier" lib/
```

### Method 3: Flutter Analyze
```bash
# Run analyze to see errors
flutter analyze

# Errors will point to files with broken imports
```

---

## ⚠️ Common Errors & Solutions

### Error 1: "Target of URI doesn't exist"
```
Error: Target of URI doesn't exist: 'package:mobile_pager_flutter/core/domains/users.dart'
```

**Solution**: You missed updating an import. Use Find & Replace again or check the file manually.

### Error 2: "Undefined class 'UserModel'"
```
Error: Undefined class 'UserModel'
```

**Solution**: Import statement is missing or incorrect. Add:
```dart
import 'package:mobile_pager_flutter/features/authentication/domain/models/user_model.dart';
```

### Error 3: "Relative import doesn't exist"
```
Error: '../repositories/i_auth_repository.dart' doesn't exist
```

**Solution**: After moving auth_notifier, relative paths changed. Update to:
```dart
import '../../../domain/repositories/i_auth_repository.dart';
```

---

## 📝 Expected Import Changes Summary

| Old Import | New Import | Files Affected |
|-----------|-----------|----------------|
| `core/domains/users.dart` | `features/authentication/domain/models/user_model.dart` | ~20 files |
| `domain/auth_notifier.dart` | `presentation/notifiers/auth_notifier.dart` | ~3 files |

---

## 🎯 After Completion

Once all steps done:

1. **Commit** changes:
   ```bash
   git add .
   git commit -m "refactor(phase1): move UserModel to authentication feature and AuthNotifier to presentation layer"
   ```

2. **Verify** app still runs:
   ```bash
   flutter run
   ```

3. **Optional**: Continue to Phase 2 (folder standardization) or stop here.

---

## 🚨 If Stuck

**Problem**: Too many errors after find-replace?

**Solution**: Revert and go slower:
```bash
git checkout -- .
git clean -fd
```

Then do ONE find-replace at a time, verify, commit, repeat.

---

## 📞 Questions?

- Check `REFACTORING_PLAN.md` for detailed explanations
- Check `docs/FOLDER_STRUCTURE.md` for architecture guide
- Run `flutter analyze` to find remaining issues

---

**Estimated Time**: 30-60 minutes
**Difficulty**: Medium
**Breaking Changes**: Yes (all imports change)
**Reversible**: Yes (via git revert)

Good luck! 🚀
