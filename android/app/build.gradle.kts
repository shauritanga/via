plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.curtis.via"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.curtis.via"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable multidex for large apps
        multiDexEnabled = true
        
        // Test configuration
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        create("release") {
            // For production, these should be loaded from environment variables
            // or a secure keystore file
            keyAlias = System.getenv("KEY_ALIAS") ?: "via-release"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "via-release-password"
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "via-release.keystore")
            storePassword = System.getenv("STORE_PASSWORD") ?: "via-release-password"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
            
            // Enable crash reporting in release builds
            buildConfigField("boolean", "ENABLE_CRASH_REPORTING", "true")
            buildConfigField("boolean", "ENABLE_ANALYTICS", "true")
        }
        
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            
            // Disable crash reporting in debug builds
            buildConfigField("boolean", "ENABLE_CRASH_REPORTING", "false")
            buildConfigField("boolean", "ENABLE_ANALYTICS", "false")
        }
    }

    // Enable R8 optimization
    buildFeatures {
        buildConfig = true
    }

    // Bundle configuration for Play Store
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add multidex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Add security library for production
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    
    // Add biometric authentication support
    implementation("androidx.biometric:biometric:1.1.0")
    
    // Add work manager for background tasks
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    
    // Add room for local database
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    
    // Add lifecycle components
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
    
    // Add coroutines support
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    
    // Add network security config
    implementation("androidx.security:security-network-security:1.0.0")
}
