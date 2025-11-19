plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.fgtp.trappex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fgtp.trappex"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.facebook.android:facebook-android-sdk:[8,9)")
    
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    
    // Add the dependencies for Firebase products you want to use
    implementation("com.google.firebase:firebase-analytics")
    
    // Add the dependencies for any other desired Firebase products
    // https://firebase.google.com/docs/android/setup#available-libraries
    
    // Google Mobile Ads (Flutter plugin already brings GMA runtime)
    implementation("com.google.android.gms:play-services-ads:23.0.0")
    
    // Unity Ads - Latest version
    implementation("com.unity3d.ads:unity-ads:4.16.3")
    implementation("com.google.ads.mediation:unity:4.16.3.0")
    
    // ironSource - Comment out if version not available, or update to latest compatible version
    // Note: If build fails, try removing these lines temporarily or update to a working version
    implementation("com.ironsource.sdk:mediationsdk:8.1.0")
    implementation("com.google.ads.mediation:ironsource:8.1.0.0")
    
    // AppLovin (MAX) - Latest version
    implementation("com.applovin:applovin-sdk:13.5.0")
    implementation("com.google.ads.mediation:applovin:13.5.0.0")
    
    // Meta Audience Network (Facebook) - Latest version
    implementation("com.facebook.android:audience-network-sdk:6.21.0")
    implementation("com.google.ads.mediation:facebook:6.21.0.0")
}
