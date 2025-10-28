# 📁 Folder Structure Guide

**Version**: 1.0
**Last Updated**: 2025-12-16
**Target Architecture**: Clean Architecture with Feature-First Organization

---

## 🎯 Overview

This document defines the **standardized folder structure** for the Mobile Pager Flutter application. All team members MUST follow this structure when creating new features or modifying existing ones.

**Core Principles**:
1. **Feature-First**: Organize by feature, not by layer
2. **Clean Architecture**: Separate presentation, domain, and data layers
3. **Consistency**: Every feature follows the same pattern
4. **Scalability**: Easy to add new features without affecting others

---

## 📂 Root Structure

```
mobile_pager_flutter/
├── lib/
│   ├── core/                    # Shared utilities (no business logic)
│   ├── features/                # Feature modules
│   └── main.dart               # App entry point
├── test/                        # Mirror lib/ structure
├── docs/                        # Documentation
├── assets/                      # Static assets
└── pubspec.yaml                # Dependencies
```

---

## 🔷 Core Layer (`lib/core/`)

**Purpose**: Shared infrastructure and utilities used across ALL features.

**Rules**:
- ✅ Generic, reusable code only
- ✅ No business logic
- ✅ No feature imports
- ❌ NEVER import from `features/`

```
lib/core/
├── constants/                   # App-wide constants
│   ├── app_routes.dart         # Route names
│   ├── firebase_constants.dart # Firebase config
│   └── api_constants.dart      # API endpoints
│
├── presentation/
│   └── widgets/                # Generic reusable widgets
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   └── dropdown_button.dart
│       ├── input_fields/
│       │   ├── text_input_field.dart
│       │   └── search_input_field.dart
│       └── loading/
│           ├── skeleton_loader.dart
│           └── circular_loader.dart
│
├── services/                   # Infrastructure services
│   ├── fcm_service.dart       # Firebase Cloud Messaging setup
│   ├── connectivity_service.dart
│   └── crashlytics_service.dart
│
├── theme/                      # App theming
│   ├── app_color.dart
│   ├── app_padding.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
│
└── utils/                      # Utility functions
    ├── date_formatter.dart
    ├── validators.dart
    └── extensions/
        ├── string_extensions.dart
        └── datetime_extensions.dart
```

### Example: Generic Widget in Core

```dart
// ✅ GOOD: Generic widget with no feature dependencies
// lib/core/presentation/widgets/buttons/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Generic implementation
  }
}
```

```dart
// ❌ BAD: Widget importing from features
// lib/core/presentation/widgets/pager_ticket_card.dart
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';  // ❌ WRONG

// This should be in features/pager/presentation/widgets/ instead!
```

---

## 🔶 Features Layer (`lib/features/`)

**Purpose**: Self-contained feature modules with complete Clean Architecture layers.

**Structure**:
```
lib/features/
├── authentication/
├── pager/
├── notifications/
├── pager_history/
├── analytics/
├── merchant/
├── home/
├── profile/
└── about/
```

Each feature follows **the same pattern**:

```
lib/features/<feature_name>/
├── data/                       # Data Layer (optional for simple features)
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── <feature>_remote_datasource.dart
│   │   └── local/
│   │       └── <feature>_local_datasource.dart
│   ├── models/                 # Data Transfer Objects (DTOs)
│   │   └── <feature>_dto.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
│
├── domain/                     # Domain Layer (core business logic)
│   ├── models/                 # Business entities
│   │   └── <feature>_model.dart
│   ├── repositories/           # Repository interfaces
│   │   └── i_<feature>_repository.dart
│   ├── usecases/               # Business use cases (optional)
│   │   ├── get_<feature>.dart
│   │   └── create_<feature>.dart
│   └── services/               # Domain services (optional)
│       └── <feature>_service.dart
│
└── presentation/               # Presentation Layer (UI)
    ├── notifiers/              # State management
    │   ├── <feature>_notifier.dart
    │   └── <feature>_state.dart
    ├── pages/                  # Full-screen pages
    │   ├── <feature>_page.dart
    │   └── <feature>_detail_page.dart
    ├── providers/              # Riverpod providers
    │   └── <feature>_providers.dart
    └── widgets/                # Feature-specific widgets
        ├── <feature>_card.dart
        └── <feature>_list_item.dart
```

---

## 📘 Feature Structure Examples

### Example 1: Full Feature (authentication)

```
lib/features/authentication/
├── data/
│   ├── datasources/
│   │   └── remote/
│   │       └── auth_remote_datasource.dart     # Firebase Auth calls
│   └── repositories/
│       └── auth_repository_impl.dart           # Implements IAuthRepository
│
├── domain/
│   ├── models/
│   │   └── user_model.dart                     # User entity
│   ├── repositories/
│   │   └── i_auth_repository.dart              # Repository interface
│   └── usecases/                               # (optional)
│       ├── sign_in_with_google.dart
│       ├── sign_out.dart
│       └── get_current_user.dart
│
└── presentation/
    ├── notifiers/
    │   ├── auth_notifier.dart                  # StateNotifier<AuthState>
    │   └── auth_state.dart                     # AuthState sealed class
    ├── pages/
    │   └── authentication_page.dart            # Login screen
    ├── providers/
    │   └── auth_providers.dart                 # authNotifierProvider, etc.
    └── widgets/
        ├── google_sign_in_button.dart
        └── auth_error_message.dart
```

**File: `user_model.dart`**
```dart
// lib/features/authentication/domain/models/user_model.dart
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String role;
  final bool isGuest;

  UserModel({...});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {...}
  Map<String, dynamic> toMap() {...}

  // Getters
  bool get isMerchant => role == 'merchant';
  bool get isCustomer => role == 'customer';
  bool get isGuestUser => role == 'guest' && isGuest;
}
```

**File: `i_auth_repository.dart`**
```dart
// lib/features/authentication/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Stream<UserModel?> watchAuthState();
  Future<UserModel?> getCurrentUser();
}
```

**File: `auth_repository_impl.dart`**
```dart
// lib/features/authentication/data/repositories/auth_repository_impl.dart
import '../../domain/models/user_model.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signInWithGoogle() async {
    // Implementation
  }

  @override
  Future<void> signOut() async {
    // Implementation
  }

  // ... other methods
}
```

**File: `auth_notifier.dart`**
```dart
// lib/features/authentication/presentation/notifiers/auth_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _watchAuthState();
  }

  void _watchAuthState() {
    _authRepository.watchAuthState().listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState.unauthenticated();
  }
}
```

**File: `auth_state.dart`**
```dart
// lib/features/authentication/presentation/notifiers/auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

**File: `auth_providers.dart`**
```dart
// lib/features/authentication/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/auth_state.dart';

// Repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Convenience provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});
```

---

### Example 2: Simple Feature (about)

For simple features that don't need full Clean Architecture:

```
lib/features/about/
└── presentation/
    └── pages/
        └── about_page.dart
```

**When to use simple structure**:
- Static pages (no data fetching)
- Pure UI components
- Settings pages with local state only

**When to use full structure**:
- Features that fetch data
- Features with business logic
- Features that need testing
- Features that will scale

---

### Example 3: Feature with Use Cases (notifications)

```
lib/features/notifications/
├── data/
│   └── repositories/
│       └── notification_repository_impl.dart
│
├── domain/
│   ├── models/
│   │   └── notification_model.dart
│   ├── repositories/
│   │   └── i_notification_repository.dart
│   ├── services/
│   │   └── fcm_token_manager.dart              # Domain service
│   └── usecases/                               # Business logic
│       ├── send_new_customer_notification.dart
│       ├── send_order_ready_notification.dart
│       ├── send_order_calling_notification.dart
│       ├── send_order_expiring_soon_notification.dart
│       ├── send_order_expired_notification.dart
│       └── send_order_finished_notification.dart
│
└── presentation/
    ├── pages/
    │   └── notification_history_page.dart
    └── providers/
        ├── notification_providers.dart
        └── notification_usecases_provider.dart
```

**Use Case Example**:
```dart
// lib/features/notifications/domain/usecases/send_order_ready_notification.dart
class SendOrderReadyNotification {
  final INotificationRepository _notificationRepository;

  SendOrderReadyNotification(this._notificationRepository);

  Future<void> call({
    required String customerId,
    required String pagerNumber,
    required String pagerLabel,
  }) async {
    final notification = NotificationModel(
      userId: customerId,
      type: NotificationType.orderReady,
      title: 'Pesanan Siap!',
      body: 'Pager #$pagerNumber ($pagerLabel) sudah siap diambil',
      createdAt: DateTime.now(),
    );

    await _notificationRepository.createNotification(notification);
  }
}
```

**Provider**:
```dart
// lib/features/notifications/presentation/providers/notification_usecases_provider.dart
final sendOrderReadyNotificationProvider = Provider<SendOrderReadyNotification>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return SendOrderReadyNotification(repository);
});
```

**Usage in UI**:
```dart
// In some widget
final sendNotification = ref.read(sendOrderReadyNotificationProvider);
await sendNotification(
  customerId: 'user123',
  pagerNumber: '42',
  pagerLabel: 'Loket A',
);
```

---

## 🔀 Import Rules

### ✅ Allowed Imports

**Presentation Layer** can import:
```dart
// Domain layer (interfaces and models)
import '../../domain/models/user_model.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/sign_in_with_google.dart';

// Other presentation files
import '../notifiers/auth_notifier.dart';
import '../widgets/google_sign_in_button.dart';

// Core utilities
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/presentation/widgets/buttons/primary_button.dart';
```

**Data Layer** can import:
```dart
// Domain layer (interfaces and models only)
import '../../domain/models/user_model.dart';
import '../../domain/repositories/i_auth_repository.dart';

// External packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
```

**Domain Layer** can import:
```dart
// ONLY other domain files and pure Dart packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Only for Timestamp, etc.

// Other domain files
import '../models/user_model.dart';
import '../repositories/i_auth_repository.dart';
```

### ❌ Forbidden Imports

**Domain Layer CANNOT import**:
```dart
❌ import '../../data/repositories/auth_repository_impl.dart';  // No data layer!
❌ import '../../presentation/notifiers/auth_notifier.dart';   // No presentation!
❌ import 'package:flutter/material.dart';                     // No Flutter!
```

**Presentation Layer CANNOT import**:
```dart
❌ import '../../data/repositories/auth_repository_impl.dart';  // Use interface!
```

**Core CANNOT import**:
```dart
❌ import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';  // No features!
```

---

## 📝 Naming Conventions

### File Names
- **Models**: `<entity>_model.dart` (e.g., `user_model.dart`, `pager_model.dart`)
- **Repositories**:
  - Interface: `i_<feature>_repository.dart`
  - Implementation: `<feature>_repository_impl.dart`
- **Pages**: `<feature>_page.dart` (e.g., `authentication_page.dart`)
- **Widgets**: `<widget_name>.dart` (e.g., `google_sign_in_button.dart`)
- **Notifiers**: `<feature>_notifier.dart`
- **States**: `<feature>_state.dart`
- **Providers**: `<feature>_providers.dart`
- **Use Cases**: `<action>_<entity>.dart` (e.g., `get_user.dart`, `sign_in_with_google.dart`)

### Folder Names
- Always **lowercase with underscores**: `pager_history`, `active_pagers`
- Always **plural** for collections: `pages/`, `widgets/`, `models/`, `providers/`
- Always **singular** for single purpose: `data/`, `domain/`, `presentation/`

### Class Names
- **Models**: `<Entity>Model` (e.g., `UserModel`, `PagerModel`)
- **Repositories**:
  - Interface: `I<Feature>Repository`
  - Implementation: `<Feature>RepositoryImpl`
- **Notifiers**: `<Feature>Notifier`
- **States**: `<Feature>State`
- **Widgets**: `<Widget>` (e.g., `GoogleSignInButton`, `PagerTicketCard`)
- **Pages**: `<Feature>Page`
- **Use Cases**: `<Action><Entity>` (e.g., `GetUser`, `SignInWithGoogle`)

---

## 🧪 Test Structure

Mirror the `lib/` structure in `test/`:

```
test/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── user_model_test.dart
│   │   │   └── usecases/
│   │   │       └── sign_in_with_google_test.dart
│   │   └── presentation/
│   │       └── notifiers/
│   │           └── auth_notifier_test.dart
│   │
│   └── pager/
│       └── (same structure)
│
└── core/
    └── utils/
        └── validators_test.dart
```

**Test File Example**:
```dart
// test/features/authentication/data/repositories/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_pager_flutter/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/models/user_model.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;

    setUp(() {
      repository = AuthRepositoryImpl();
    });

    test('should sign in with Google successfully', () async {
      // Arrange

      // Act
      final result = await repository.signInWithGoogle();

      // Assert
      expect(result, isA<UserModel>());
    });
  });
}
```

---

## 🚨 Common Mistakes to Avoid

### ❌ Mistake 1: Mixing Layers
```dart
// ❌ BAD: Notifier in domain layer
lib/features/authentication/domain/auth_notifier.dart

// ✅ GOOD: Notifier in presentation layer
lib/features/authentication/presentation/notifiers/auth_notifier.dart
```

### ❌ Mistake 2: Core Importing Features
```dart
// ❌ BAD: Core widget importing feature
// lib/core/presentation/widgets/pager_ticket_card.dart
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

// ✅ GOOD: Move to feature or make generic
// lib/features/pager/presentation/widgets/pager_ticket_card.dart
```

### ❌ Mistake 3: Presentation Importing Data Implementations
```dart
// ❌ BAD: Importing concrete implementation
import '../../data/repositories/auth_repository_impl.dart';
final repo = AuthRepositoryImpl();

// ✅ GOOD: Use provider with interface
final repo = ref.watch(authRepositoryProvider);  // Returns IAuthRepository
```

### ❌ Mistake 4: Inconsistent Folder Names
```dart
❌ authentication/presentation/page/       (singular)
❌ merchant/presentation/pages/            (plural)

✅ All use: presentation/pages/            (consistent plural)
```

### ❌ Mistake 5: Domain Models in Core
```dart
❌ lib/core/domains/users.dart
❌ lib/core/domains/orders.dart

✅ lib/features/authentication/domain/models/user_model.dart
✅ lib/features/pager/domain/models/order_model.dart
```

---

## ✅ Checklist for New Features

When creating a new feature, follow this checklist:

### Step 1: Create Folder Structure
```bash
lib/features/my_feature/
├── data/
│   └── repositories/
│       └── my_feature_repository_impl.dart
├── domain/
│   ├── models/
│   │   └── my_feature_model.dart
│   └── repositories/
│       └── i_my_feature_repository.dart
└── presentation/
    ├── notifiers/
    │   ├── my_feature_notifier.dart
    │   └── my_feature_state.dart
    ├── pages/
    │   └── my_feature_page.dart
    ├── providers/
    │   └── my_feature_providers.dart
    └── widgets/
        └── (optional widgets)
```

### Step 2: Create Domain Layer (Bottom-Up)
- [ ] Create model in `domain/models/`
- [ ] Create repository interface in `domain/repositories/`
- [ ] (Optional) Create use cases in `domain/usecases/`

### Step 3: Create Data Layer
- [ ] Create repository implementation in `data/repositories/`
- [ ] Implement interface methods
- [ ] Add Firebase/API calls

### Step 4: Create Presentation Layer
- [ ] Create state class in `presentation/notifiers/`
- [ ] Create notifier in `presentation/notifiers/`
- [ ] Create providers in `presentation/providers/`
- [ ] Create page in `presentation/pages/`
- [ ] (Optional) Create widgets in `presentation/widgets/`

### Step 5: Wire Up
- [ ] Add route in `core/constants/app_routes.dart`
- [ ] Add route in `main.dart`
- [ ] Test navigation

### Step 6: Test
- [ ] Create test files mirroring structure
- [ ] Write unit tests for domain layer
- [ ] Write unit tests for data layer
- [ ] Write widget tests for presentation

---

## 📚 References

- [Flutter Clean Architecture Guide](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Feature-First Project Structure](https://codewithandrea.com/articles/flutter-project-structure/)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Last Updated**: 2025-12-16
**Maintained By**: Mobile Development Team
**Questions?**: Create an issue with `documentation` label
