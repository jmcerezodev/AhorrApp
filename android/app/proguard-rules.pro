-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.vision.text.devanagari.**

# Google ML Kit — mantener clases de modelos y anotaciones
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# Isar — mantener clases de colecciones y el motor nativo
-keep class io.isar.** { *; }
-keep @io.isar.annotations.Collection class * { *; }
-keepclassmembers class * {
    @io.isar.annotations.* *;
}