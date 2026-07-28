# Preserve Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Preserve Security Bridge & Security Classes
-keep class com.dijlah.inteshar.security.** { *; }

