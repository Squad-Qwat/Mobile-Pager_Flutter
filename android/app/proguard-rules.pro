# Flutter & Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mobile Scanner / MLKit / CameraX
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn androidx.camera.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Google Play Core (for deferred components - not used but referenced by Flutter)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
