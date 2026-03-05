# Guide Dose - ProGuard Rules

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Google Play Core (Deferred Components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

