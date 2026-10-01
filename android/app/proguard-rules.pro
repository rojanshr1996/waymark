# ==============================================================================
# WAYMARK - PRODUCTION R8 / PROGUARD RULES
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. General Flutter Engine & Platform Rules
# ------------------------------------------------------------------------------
# Keep Flutter embedding and plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Generated Plugin Registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }

# Preserve annotations and line numbers for crash reporting / stack traces
-keepattributes *Annotation*,EnclosingMethod,InnerClasses,Signature,Exceptions
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep annotations used by Flutter & AndroidX
-keep @interface androidx.annotation.Keep
-keep @androidx.annotation.Keep class * { *; }
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <init>(...);
}

# ------------------------------------------------------------------------------
# 2. Kotlin Runtime & Coroutines
# ------------------------------------------------------------------------------
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**
-keepclassmembers class * extends java.lang.Enum {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ------------------------------------------------------------------------------
# 3. Java 8+ Core Library Desugaring
# ------------------------------------------------------------------------------
-dontwarn java.time.**
-dontwarn java.util.function.**
-dontwarn java.util.stream.**
-dontwarn java.lang.invoke.**
-dontwarn com.android.tools.r8.**

# ------------------------------------------------------------------------------
# 4. Flutter Local Notifications
# ------------------------------------------------------------------------------
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Keep notification broadcast receivers and services
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }

# ------------------------------------------------------------------------------
# 5. Firebase Core & Firebase Cloud Messaging (FCM)
# ------------------------------------------------------------------------------
-keep class io.flutter.plugins.firebase.core.** { *; }
-dontwarn io.flutter.plugins.firebase.core.**
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-dontwarn io.flutter.plugins.firebase.messaging.**

# Google Play Services & Firebase internals
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.datatransport.** { *; }
-dontwarn com.google.android.datatransport.**

# Keep background messaging service and receivers
-keep public class * extends com.google.firebase.messaging.FirebaseMessagingService { *; }

# ------------------------------------------------------------------------------
# 6. SQLite3 Native Libs & Drift Database
# ------------------------------------------------------------------------------
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }
-dontwarn eu.simonbinder.sqlite3_flutter_libs.**

# JNI method preservation for native SQLite libraries
-keepclasseswithmembernames class * {
    native <methods>;
}

# ------------------------------------------------------------------------------
# 7. Image Compression, Picker & Media
# ------------------------------------------------------------------------------
-keep class com.fluttercandies.flutter_image_compress.** { *; }
-dontwarn com.fluttercandies.flutter_image_compress.**
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**
-keep class com.spencerccf.gal.** { *; }
-dontwarn com.spencerccf.gal.**

# ------------------------------------------------------------------------------
# 8. Geolocator & Permission Handler
# ------------------------------------------------------------------------------
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ------------------------------------------------------------------------------
# 9. Share Plus, URL Launcher, Shared Preferences & Path Provider
# ------------------------------------------------------------------------------
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-dontwarn dev.fluttercommunity.plus.packageinfo.**

# ------------------------------------------------------------------------------
# 10. Networking (Dio, OkHttp)
# ------------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
