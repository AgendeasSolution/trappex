plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
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
        applicationId = "com.fgtp.trappex"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.facebook.android:facebook-android-sdk:[8,9)")
    
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    
    implementation("com.google.firebase:firebase-analytics")
    
    // Google Mobile Ads
    implementation("com.google.android.gms:play-services-ads:23.0.0")
    
    // Unity Ads
    implementation("com.unity3d.ads:unity-ads:4.16.3")
    implementation("com.google.ads.mediation:unity:4.16.3.0")
    
    // ironSource
    implementation("com.ironsource.sdk:mediationsdk:8.4.0")
    implementation("com.google.ads.mediation:ironsource:8.4.0.0")
    
    // AppLovin (MAX)
    implementation("com.applovin:applovin-sdk:13.5.0")
    implementation("com.google.ads.mediation:applovin:13.5.0.0")
    
    // Meta Audience Network (Facebook)
    implementation("com.facebook.android:audience-network-sdk:6.21.0")
    implementation("com.google.ads.mediation:facebook:6.21.0.0")
}
