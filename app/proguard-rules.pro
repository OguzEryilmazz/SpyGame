# Add project specific ProGuard rules here.

# ===============================
# ANDROID TEMEL KURALLAR
# ===============================

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep classes with main methods
-keepclasseswithmembers public class * {
    public static void main(java.lang.String[]);
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable
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

# ===============================
# GOOGLE PLAY BILLING
# ===============================

# Google Play Billing - ÇOK ÖNEMLİ!
-keep class com.android.billingclient.api.** { *; }
-keepclassmembers class com.android.billingclient.api.** { *; }

# Billing Manager - Kendi sınıflarını koru
-keep class com.oguz.spy.billing.** { *; }
-keepclassmembers class com.oguz.spy.billing.** { *; }

# ===============================
# GOOGLE PLAY SERVICES
# ===============================

# Play Services Auth
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.games.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ===============================
# ANDROIDX & JETPACK COMPOSE
# ===============================

# Room Database
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keep @androidx.room.Dao class *

# DataStore
-keep class androidx.datastore.** { *; }

# Compose
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Navigation Compose
-keep class androidx.navigation.compose.** { *; }

# ===============================
# KOTLIN & COROUTINES
# ===============================

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# Kotlin Metadata
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$Companion { *; }

# ===============================
# GSON (JSON İŞLEME)
# ===============================

# Gson
-keep class com.google.gson.** { *; }

# Gson model sınıfları (eğer JSON parse ediyorsan)
-keep class com.oguz.spy.data.** { *; }
-keep class com.oguz.spy.model.** { *; }

# ===============================
# KENDİ UYGULAMANIN KURALLARI
# ===============================

# Ana uygulama sınıfları
-keep class com.oguz.spy.MainActivity { *; }

# ViewModel'lar
-keep class com.oguz.spy.viewmodel.** { *; }

# Repository sınıfları
-keep class com.oguz.spy.repository.** { *; }

# Data sınıfları
-keep class com.oguz.spy.data.** { *; }

# ===============================
# ENUM SINIFLAR
# ===============================

# Enum sınıfları koru
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ===============================
# DEBUG VE LOGLAR
# ===============================

# Release'de Log.d, Log.v kaldır (performans için)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ===============================
# UYARILAR KAPAT
# ===============================

# Gereksiz uyarıları kapat
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# ===============================
# REFLECTION KORUMA
# ===============================

# Reflection kullanan sınıflar varsa
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ===============================
# OPTIMIZE ETME
# ===============================

# Agresif optimizasyon
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification