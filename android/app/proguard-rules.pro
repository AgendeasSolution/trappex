# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-keep class com.google.android.gms.internal.measurement.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keep class com.google.unity.** { *; }
-keep class com.unity3d.** { *; }
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

# Unity Ads
-keep class com.unity3d.ads.** { *; }
-keep class com.unity3d.player.** { *; }
-dontwarn com.unity3d.ads.**
-dontwarn com.unity3d.player.**

# ironSource
-keep class com.ironsource.** { *; }
-keep interface com.ironsource.** { *; }
-dontwarn com.ironsource.**
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# AppLovin (MAX)
-keep class com.applovin.** { *; }
-keep interface com.applovin.** { *; }
-dontwarn com.applovin.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Meta Audience Network (Facebook)
-keep class com.facebook.** { *; }
-keep interface com.facebook.** { *; }
-dontwarn com.facebook.**
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.facebook.ads.** { *; }
-keep class com.facebook.audiencenetwork.** { *; }

# Facebook SDK
-keep class com.facebook.android.** { *; }
-dontwarn com.facebook.android.**
-keepattributes Signature
-keepattributes *Annotation*

# Google Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Google Play Core (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep interface com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Keep custom model classes if you have any
-keep class com.fgtp.trappex.** { *; }

# Keep MainActivity
-keep class com.fgtp.trappex.MainActivity { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R class
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep View constructors
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

