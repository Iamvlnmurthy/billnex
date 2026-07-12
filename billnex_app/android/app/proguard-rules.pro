# BillNex R8/ProGuard keep-rules.
# Enable in build.gradle.kts (release): isMinifyEnabled = true, isShrinkResources = true,
# proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
# Then verify a release build installs + prints on a real device.

# Flutter engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# printing / pdf (uses reflection + platform channels)
-keep class net.nfet.** { *; }
-keep class com.dexterous.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep annotations / signatures used by plugins
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
