# ===============================
# ANDROID TEMEL KURALLAR
# ===============================

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
    *;
}

# ===============================
# GOOGLE PLAY SERVICES
# ===============================

# Billing
-keep class com.android.billingclient.api.** { *; }
-keep class com.oguz.spy.billing.** { *; }

# Auth & Games
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.games.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ===============================
# ANDROIDX & JETPACK
# ===============================

# Room
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keep @androidx.room.Dao class *

# DataStore
-keep class androidx.datastore.** { *; }

# Compose
-keep class androidx.compose.runtime.** { *; }
-keep class androidx.compose.material.icons.** { *; }
-keep class androidx.navigation.compose.** { *; }
-dontwarn androidx.compose.**

# ===============================
# KOTLIN & COROUTINES
# ===============================

-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keep class kotlinx.coroutines.** { *; }
-keepclassmembers class **$Companion { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# ===============================
# KOTLINX SERIALIZATION
# ===============================

-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# Serialization runtime
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}

-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Serializable sınıflar
-keep,includedescriptorclasses class com.oguz.spy.**$$serializer { *; }

-keepclassmembers class com.oguz.spy.** {
    *** Companion;
}

-keepclasseswithmembers class com.oguz.spy.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# SerialName annotation
-keepclassmembers class * {
    @kotlinx.serialization.SerialName <fields>;
}

# Serializable companion
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

-dontwarn kotlinx.serialization.**

# ===============================
# GSON (FALLBACK İÇİN)
# ===============================

-keep class com.google.gson.** { *; }
-keepattributes Signature

# ===============================
# UYGULAMA DATA CLASSES
# ===============================

-keep class com.oguz.spy.datamanagment.** { *; }
-keep class com.oguz.spy.ux.Category { *; }
-keep class com.oguz.spy.ux.Subcategory { *; }
-keep class com.oguz.spy.ux.GamePlayer { *; }
-keep class com.oguz.spy.data.** { *; }
-keep class com.oguz.spy.model.** { *; }
-keep class com.oguz.spy.models.** { *; }

# ViewModels & Repositories
-keep class com.oguz.spy.viewmodel.** { *; }
-keep class com.oguz.spy.repository.** { *; }

# MainActivity
-keep class com.oguz.spy.MainActivity { *; }

# ===============================
# RAW RESOURCES (ÖNEMLİ!)
# ===============================

-keepclassmembers class **.R$* {
    public static <fields>;
}

-keep class **.R$raw { *; }
-keep class com.oguz.spy.R$raw { *; }

# categories.json dosyasını özellikle koru
-keepclassmembers class **.R$raw {
    public static final int categories;
}

# ===============================
# OPTIMIZATIONS
# ===============================

-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# ===============================
# DEBUG LOGLAR (TEST İÇİN KAPALI)
# ===============================

# ⚠️ TEST BİTTİKTEN SONRA AÇABİLİRSİNİZ
# -assumenosideeffects class android.util.Log {
#     public static *** d(...);
#     public static *** v(...);
#     public static *** i(...);
# }

# ===============================
# UYARILAR
# ===============================

-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**