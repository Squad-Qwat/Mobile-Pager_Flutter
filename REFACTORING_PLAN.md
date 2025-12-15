# 🔧 Mobile Pager - Comprehensive Refactoring Plan

**Created**: 2025-12-16
**Status**: DRAFT - Awaiting Approval
**Estimated Effort**: 3-5 Days (Team of 2-3 developers)

---

## 📋 Executive Summary

This document outlines a comprehensive refactoring plan for the Mobile Pager Flutter application to address **23 structural issues** identified in the codebase analysis, including **5 critical architectural violations**.

**Goals**:
1. ✅ Enforce Clean Architecture principles
2. ✅ Standardize folder and file naming conventions
3. ✅ Remove circular dependencies
4. ✅ Improve code maintainability and testability
5. ✅ Enable team collaboration with clear structure

**Impact**:
- 📁 ~40 files will be moved/renamed
- 🔄 ~15 import statements will be updated per affected file
- 🧪 Enable proper unit testing with separated layers
- 👥 Clear structure for team onboarding

---

## 🎯 Refactoring Phases

### Phase 1: Critical Architecture Fixes (Priority: CRITICAL)
**Estimated Time**: 1-2 days
**Dependencies**: None
**Breaking Changes**: Yes (imports will change)

### Phase 2: Folder Structure Standardization (Priority: HIGH)
**Estimated Time**: 1 day
**Dependencies**: Phase 1
**Breaking Changes**: Yes (file paths will change)

### Phase 3: File Naming Consistency (Priority: MEDIUM)
**Estimated Time**: 0.5 days
**Dependencies**: Phase 2
**Breaking Changes**: Yes (file names will change)

### Phase 4: Documentation & Testing Setup (Priority: MEDIUM)
**Estimated Time**: 0.5-1 day
**Dependencies**: Phase 1-3
**Breaking Changes**: No

---

## 🔴 Phase 1: Critical Architecture Fixes

### 1.1 Move Domain Models from Core to Features

**Problem**: `core/domains/` contains feature-specific models that violate Clean Architecture.

**Action**:
```
BEFORE:
lib/core/domains/
  ├── users.dart          (UserModel - 5KB)
  ├── orders.dart         (Orders model - 3KB)
  └── orders_history_dummy.dart

AFTER:
lib/features/authentication/domain/models/
  └── user_model.dart     (moved from core/domains/users.dart)

lib/features/pager/domain/models/
  └── order_model.dart    (moved from core/domains/orders.dart)

DELETED:
  - core/domains/users.dart
  - core/domains/orders.dart
  - core/domains/orders_history_dummy.dart (obsolete dummy data)
```

**Files to Update** (estimated 20+ files):
- All imports of `core/domains/users.dart` → `features/authentication/domain/models/user_model.dart`
- All imports of `core/domains/orders.dart` → `features/pager/domain/models/order_model.dart`

**Commands**:
```bash
# Find all files importing core/domains/users.dart
grep -r "import.*core/domains/users" lib/

# After moving, update all imports
# Use IDE refactoring: Rename/Move file → Update references
```

**Testing**:
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

---

### 1.2 Move AuthNotifier from Domain to Presentation

**Problem**: `auth_notifier.dart` is in domain layer, but StateNotifier belongs in presentation.

**Action**:
```
BEFORE:
lib/features/authentication/
  ├── domain/
  │   └── auth_notifier.dart        ❌ WRONG LAYER
  └── presentation/
      └── providers/
          └── auth_providers.dart

AFTER:
lib/features/authentication/
  ├── domain/
  │   ├── models/
  │   │   └── user_model.dart       (moved from core)
  │   └── repositories/
  │       └── i_auth_repository.dart
  └── presentation/
      ├── notifiers/
      │   ├── auth_notifier.dart     ✅ CORRECT LAYER (moved)
      │   └── auth_state.dart        ✅ State model
      └── providers/
          └── auth_providers.dart
```

**Files to Update**:
- `lib/features/authentication/presentation/providers/auth_providers.dart`
- All files importing auth_notifier

**Testing**: Ensure authentication flow still works.

---

### 1.3 Remove Core Service Dependencies on Features

**Problem**: `core/services/notification_service_provider.dart` imports from `features/notifications/presentation/`.

**Action**:
```
BEFORE:
lib/core/services/
  ├── notification_service.dart          ❌ Business logic in core
  └── notification_service_provider.dart ❌ Imports presentation

AFTER:
lib/features/notifications/domain/usecases/
  ├── send_new_customer_notification.dart
  ├── send_order_ready_notification.dart
  ├── send_order_calling_notification.dart
  ├── send_order_expiring_soon_notification.dart
  ├── send_order_expired_notification.dart
  └── send_order_finished_notification.dart

lib/features/notifications/presentation/providers/
  └── notification_usecases_provider.dart

DELETED:
  - core/services/notification_service.dart
  - core/services/notification_service_provider.dart
```

**Rationale**: Notification sending is feature-specific business logic, not core infrastructure.

**Migration Strategy**:
1. Create use case classes in `features/notifications/domain/usecases/`
2. Move business logic from `NotificationService` to use cases
3. Update all callers to use new use cases
4. Delete core notification services

---

### 1.4 Extract pager_ticket_card from Core

**Problem**: Core widget `pager_ticket_card.dart` imports feature-specific providers.

**Action**:
```
BEFORE:
lib/core/presentation/widget/
  └── pager_ticket_card.dart    ❌ Imports features/pager/

AFTER:
lib/features/pager/presentation/widgets/
  └── pager_ticket_card.dart    ✅ Feature-specific widget

OR (if truly reusable):
lib/core/presentation/widgets/
  └── generic_ticket_card.dart  ✅ Generic widget (no feature imports)
      - Accept data as parameters
      - No provider dependencies
```

**Recommendation**: Move to `features/pager/presentation/widgets/` since it's pager-specific.

---

### 1.5 Fix FCM Token Manager Location

**Problem**: `fcm_token_manager.dart` in core imports feature repository.

**Action**:
```
BEFORE:
lib/core/services/
  └── fcm_token_manager.dart    ❌ Depends on INotificationRepository

AFTER:
lib/features/notifications/domain/services/
  └── fcm_token_manager.dart    ✅ Feature-specific service
```

---

## 🟡 Phase 2: Folder Structure Standardization

### 2.1 Standardize Presentation Folder Structure

**Decision**: Use `presentation/pages/` (plural) for ALL features.

**Action**:
```
BEFORE (inconsistent):
authentication/presentation/page/         ❌ singular
merchant/presentation/pages/              ✅ plural
active_pagers/presentation/               ❌ no subfolder
home/presentation/                        ❌ no subfolder

AFTER (standardized):
ALL features use: presentation/pages/     ✅ consistent
```

**Files to Move**:
```
authentication/presentation/page/authentication_page.dart
  → authentication/presentation/pages/authentication_page.dart

active_pagers/presentation/active_pagers_page.dart
  → active_pagers/presentation/pages/active_pagers_page.dart

home/presentation/home_page.dart
  → home/presentation/pages/home_page.dart

(... repeat for all features)
```

**Result**: Consistent `features/*/presentation/pages/` structure across all features.

---

### 2.2 Add Missing Data Layers

**Problem**: 9 features missing data layer.

**Action**: Create data layer for each feature that needs it.

#### Example: `active_pagers` Feature

```
BEFORE:
lib/features/active_pagers/
  └── presentation/
      └── active_pagers_page.dart

AFTER:
lib/features/active_pagers/
  ├── data/
  │   └── repositories/
  │       └── active_pagers_repository_impl.dart
  ├── domain/
  │   ├── models/
  │   │   └── active_pager_model.dart
  │   └── repositories/
  │       └── i_active_pagers_repository.dart
  └── presentation/
      ├── pages/
      │   └── active_pagers_page.dart
      ├── providers/
      │   └── active_pagers_providers.dart
      └── notifiers/ (if needed)
```

**Apply to**:
- `active_pagers`
- `detail_history`
- `pager_qr_view`
- `pager_scan`
- `profile` (if needs data fetching)
- `about` (simple page, may not need full layers)

**Note**: `pager_history` already has domain, just needs data layer.

---

### 2.3 Create pager_history Data Layer

**Action**:
```
BEFORE:
lib/features/pager_history/
  ├── domain/
  │   ├── extendedDummy.dart
  │   ├── history.dart
  │   └── models/
  │       └── customer_stats_model.dart
  └── presentation/
      └── (pages, widgets, providers)

AFTER:
lib/features/pager_history/
  ├── data/
  │   └── repositories/
  │       └── pager_history_repository_impl.dart
  ├── domain/
  │   ├── models/
  │   │   ├── history_model.dart (renamed from history.dart)
  │   │   └── customer_stats_model.dart
  │   └── repositories/
  │       └── i_pager_history_repository.dart
  └── presentation/
      └── (same)

DELETED:
  - extendedDummy.dart (obsolete)
```

**Responsibility**: Currently using `pager_repository` for customer stats. Create dedicated `pager_history_repository` if needed.

---

## 🟢 Phase 3: File Naming Consistency

### 3.1 Fix File Name Typos

**Action**:
```
BEFORE:
lib/core/presentation/widget/inputfileds/text_inputfiled.dart

AFTER:
lib/core/presentation/widgets/input_fields/text_input_field.dart
  - Fixed folder: inputfileds → input_fields
  - Fixed file: text_inputfiled → text_input_field
  - Standardized: widget → widgets (plural)
```

### 3.2 Rename Domain Files to Use Model Suffix

**Action**:
```
BEFORE:
pager_history/domain/history.dart          (just entity name)

AFTER:
pager_history/domain/models/history_model.dart  (with suffix + in models/)
```

### 3.3 Fix camelCase File Names

**Action**:
```
BEFORE:
pager_history/domain/extendedDummy.dart    ❌ camelCase

AFTER:
(DELETE - obsolete dummy data)
```

---

## 🔵 Phase 4: Documentation & Testing Setup

### 4.1 Create Architecture Documentation

**File**: `docs/ARCHITECTURE.md`

**Content**:
```markdown
# Architecture Guide

## Clean Architecture Layers

### 1. Presentation Layer
- **Location**: `features/*/presentation/`
- **Contents**:
  - `pages/` - UI screens
  - `widgets/` - Reusable components
  - `providers/` - Riverpod providers
  - `notifiers/` - State management (StateNotifier)
- **Rules**:
  - Can import from domain layer
  - CANNOT import from data layer
  - Use repository interfaces, not implementations

### 2. Domain Layer
- **Location**: `features/*/domain/`
- **Contents**:
  - `models/` - Business entities
  - `repositories/` - Repository interfaces (abstractions)
  - `usecases/` - Business logic (optional)
- **Rules**:
  - Pure Dart (no Flutter dependencies)
  - CANNOT import from presentation or data
  - Only abstractions, no implementations

### 3. Data Layer
- **Location**: `features/*/data/`
- **Contents**:
  - `repositories/` - Repository implementations
  - `datasources/` - API clients, Firebase, etc.
  - `models/` - Data transfer objects (DTOs)
- **Rules**:
  - Implements domain repository interfaces
  - Can import from domain
  - CANNOT import from presentation

### 4. Core Layer
- **Location**: `lib/core/`
- **Contents**:
  - `constants/` - App-wide constants
  - `theme/` - Theme configuration
  - `utils/` - Utility functions
  - `services/` - Infrastructure services (FCM, etc.)
  - `presentation/widgets/` - Generic reusable widgets
- **Rules**:
  - MUST be truly generic
  - CANNOT import from features
  - No business logic
```

---

### 4.2 Create Folder Structure Guide

**File**: `docs/FOLDER_STRUCTURE.md`

**Content**: (See detailed structure below)

---

### 4.3 Setup Unit Testing Structure

**Action**: Create test folders mirroring lib/ structure.

```
test/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── user_model_test.dart
│   │   └── presentation/
│   │       └── notifiers/
│   │           └── auth_notifier_test.dart
│   └── pager/
│       └── (same structure)
└── core/
    └── utils/
        └── (utility tests)
```

**Template Test**:
```dart
// test/features/authentication/data/repositories/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('should sign in with Google', () async {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

---

## 📊 Refactoring Checklist

### Phase 1: Critical Architecture Fixes
- [ ] 1.1 Move UserModel from core/domains to features/authentication/domain/models
- [ ] 1.2 Move OrderModel from core/domains to features/pager/domain/models
- [ ] 1.3 Delete core/domains/orders_history_dummy.dart
- [ ] 1.4 Move AuthNotifier to presentation/notifiers
- [ ] 1.5 Move AuthState to presentation/notifiers
- [ ] 1.6 Extract notification_service to features/notifications/domain/usecases
- [ ] 1.7 Delete core/services/notification_service.dart
- [ ] 1.8 Delete core/services/notification_service_provider.dart
- [ ] 1.9 Move pager_ticket_card to features/pager/presentation/widgets
- [ ] 1.10 Move fcm_token_manager to features/notifications/domain/services
- [ ] 1.11 Update all imports (20+ files)
- [ ] 1.12 Run `flutter analyze` and fix errors
- [ ] 1.13 Run `flutter test` and ensure all pass

### Phase 2: Folder Structure Standardization
- [ ] 2.1 Rename authentication/presentation/page → pages
- [ ] 2.2 Create pages/ subfolder for all features without it
- [ ] 2.3 Move page files into pages/ subfolder
- [ ] 2.4 Create data layer for active_pagers
- [ ] 2.5 Create data layer for detail_history
- [ ] 2.6 Create data layer for pager_qr_view
- [ ] 2.7 Create data layer for pager_scan
- [ ] 2.8 Create data layer for pager_history
- [ ] 2.9 Create domain models folder for all features
- [ ] 2.10 Update all imports
- [ ] 2.11 Run `flutter analyze`

### Phase 3: File Naming Consistency
- [ ] 3.1 Rename inputfileds → input_fields
- [ ] 3.2 Rename text_inputfiled.dart → text_input_field.dart
- [ ] 3.3 Rename widget → widgets (in core/presentation)
- [ ] 3.4 Rename history.dart → history_model.dart
- [ ] 3.5 Delete extendedDummy.dart
- [ ] 3.6 Update all imports
- [ ] 3.7 Run `flutter analyze`

### Phase 4: Documentation & Testing
- [ ] 4.1 Create docs/ARCHITECTURE.md
- [ ] 4.2 Create docs/FOLDER_STRUCTURE.md
- [ ] 4.3 Create docs/CONTRIBUTING.md
- [ ] 4.4 Create test/ folder structure
- [ ] 4.5 Write sample unit tests
- [ ] 4.6 Create README_TEAM.md for team onboarding
- [ ] 4.7 Run final `flutter analyze`
- [ ] 4.8 Run final `flutter test`
- [ ] 4.9 Update ai_discussion.md with refactoring summary

---

## 🎯 Final Folder Structure (Target)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_routes.dart
│   │   └── firebase_constants.dart
│   ├── presentation/
│   │   └── widgets/               (generic only, no feature imports)
│   │       ├── buttons/
│   │       │   ├── primary_button.dart
│   │       │   └── dropdown_button.dart
│   │       └── input_fields/
│   │           └── text_input_field.dart
│   ├── services/
│   │   └── fcm_service.dart       (infrastructure only)
│   ├── theme/
│   │   ├── app_color.dart
│   │   └── app_padding.dart
│   └── utils/
│       └── (utility functions)
│
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart        (moved from core)
│   │   │   └── repositories/
│   │   │       └── i_auth_repository.dart
│   │   └── presentation/
│   │       ├── notifiers/
│   │       │   ├── auth_notifier.dart     (moved from domain)
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── authentication_page.dart
│   │       └── providers/
│   │           └── auth_providers.dart
│   │
│   ├── pager/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── pager_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── pager_model.dart
│   │   │   │   └── order_model.dart       (moved from core)
│   │   │   └── repositories/
│   │   │       └── i_pager_repository.dart
│   │   └── presentation/
│   │       ├── notifiers/
│   │       │   ├── pager_notifier.dart
│   │       │   └── pager_state.dart
│   │       ├── pages/
│   │       │   └── (pages)
│   │       ├── providers/
│   │       │   └── pager_providers.dart
│   │       └── widgets/
│   │           └── pager_ticket_card.dart (moved from core)
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── i_notification_repository.dart
│   │   │   ├── services/
│   │   │   │   └── fcm_token_manager.dart (moved from core)
│   │   │   └── usecases/
│   │   │       ├── send_new_customer_notification.dart
│   │   │       ├── send_order_ready_notification.dart
│   │   │       ├── send_order_calling_notification.dart
│   │   │       ├── send_order_expiring_soon_notification.dart
│   │   │       ├── send_order_expired_notification.dart
│   │   │       └── send_order_finished_notification.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── notification_history_page.dart
│   │       └── providers/
│   │           ├── notification_providers.dart
│   │           └── notification_usecases_provider.dart
│   │
│   ├── pager_history/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── pager_history_repository_impl.dart  (NEW)
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── history_model.dart
│   │   │   │   └── customer_stats_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── i_pager_history_repository.dart    (NEW)
│   │   │   └── services/
│   │   │       └── history_filter_service.dart  (moved from presentation)
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── pager_history_page.dart
│   │       │   └── customer_detail_page.dart
│   │       ├── providers/
│   │       │   └── customer_stats_providers.dart
│   │       └── widgets/
│   │           ├── customer_list_view.dart
│   │           └── filter_widget.dart
│   │
│   ├── active_pagers/
│   │   ├── data/                          (NEW)
│   │   │   └── repositories/
│   │   │       └── active_pagers_repository_impl.dart
│   │   ├── domain/                        (NEW)
│   │   │   ├── models/
│   │   │   │   └── active_pager_model.dart
│   │   │   └── repositories/
│   │   │       └── i_active_pagers_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── active_pagers_page.dart
│   │       └── providers/
│   │           └── active_pagers_providers.dart
│   │
│   ├── detail_history/
│   │   ├── data/                          (NEW if needed)
│   │   ├── domain/                        (NEW if needed)
│   │   └── presentation/
│   │       └── pages/
│   │           └── detail_history_page.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart
│   │
│   ├── profile/
│   │   └── presentation/
│   │       └── pages/
│   │           └── profile_page.dart
│   │
│   ├── about/
│   │   └── presentation/
│   │       └── pages/
│   │           └── about_page.dart
│   │
│   └── (other features follow same pattern)
│
└── main.dart
```

---

## ⚠️ Breaking Changes Warning

**All team members MUST**:
1. Pull latest changes before starting work
2. Run `flutter clean && flutter pub get` after refactoring
3. Update all local branches
4. Review import path changes in your code

**Git Strategy**:
```bash
# Create refactoring branch
git checkout -b refactor/clean-architecture

# Complete Phase 1
git commit -m "refactor(phase1): move domain models from core to features"

# Complete Phase 2
git commit -m "refactor(phase2): standardize folder structure"

# Complete Phase 3
git commit -m "refactor(phase3): fix file naming consistency"

# Complete Phase 4
git commit -m "docs: add architecture and testing documentation"

# Merge to main
git checkout main
git merge refactor/clean-architecture
```

---

## 📚 Additional Documentation to Create

1. **docs/ARCHITECTURE.md** - Clean Architecture guide
2. **docs/FOLDER_STRUCTURE.md** - Detailed folder structure
3. **docs/CONTRIBUTING.md** - Team contribution guidelines
4. **docs/TESTING.md** - Testing strategy and examples
5. **README_TEAM.md** - Team onboarding guide

---

## 🚀 Benefits After Refactoring

1. **Clear Separation of Concerns**
   - Each layer has single responsibility
   - Easy to locate files
   - Reduced coupling

2. **Improved Testability**
   - Can mock repositories easily
   - Pure domain logic testing
   - Isolated unit tests

3. **Better Team Collaboration**
   - Consistent structure
   - Clear conventions
   - Easy onboarding

4. **Scalability**
   - Easy to add new features
   - Modular architecture
   - Independent development

5. **Maintainability**
   - Less cognitive load
   - Easier debugging
   - Predictable structure

---

## ✅ Success Criteria

- [ ] All 23 structural issues resolved
- [ ] `flutter analyze` shows 0 errors
- [ ] `flutter test` passes all tests
- [ ] Architecture documentation complete
- [ ] Team can navigate codebase easily
- [ ] New features follow consistent pattern

---

## 📞 Support & Questions

For questions during refactoring:
1. Check this document first
2. Refer to `docs/ARCHITECTURE.md`
3. Ask team lead
4. Create GitHub issue with `refactoring` label

---

**Last Updated**: 2025-12-16
**Document Version**: 1.0
**Status**: Ready for Team Review
