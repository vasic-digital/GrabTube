# Add project specific ProGuard rules here.

# Keep data classes for serialization
-keepclassmembers class com.grabtube.android.data.remote.dto.** {
    <fields>;
}

# Keep Room entities
-keep class com.grabtube.android.data.local.entity.** { *; }

# Keep Retrofit interfaces
-keep interface com.grabtube.android.data.remote.api.** { *; }

# Socket.IO
-keep class io.socket.** { *; }
-keep class org.json.** { *; }

# Kotlin Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class com.grabtube.android.**$$serializer { *; }
-keepclassmembers class com.grabtube.android.** {
    *** Companion;
}
-keepclasseswithmembers class com.grabtube.android.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Retrofit
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*
