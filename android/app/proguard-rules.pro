# Flutter motoru ve gömülü Java köprüleri için koruma
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# shared_preferences ve platform kanalları yansımayla erişilir
-keep class androidx.** { *; }
-keep class com.google.android.gms.** { *; }
