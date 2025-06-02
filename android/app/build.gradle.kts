plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.shoe_store_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"   // hardcode NDK versi yang dibutuhkan

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8    // ganti ke 1_8
        targetCompatibility = JavaVersion.VERSION_1_8    // ganti ke 1_8
        isCoreLibraryDesugaringEnabled = true             // aktifkan core library desugaring
    }

    kotlinOptions {
        jvmTarget = "1.8"                                // sesuaikan ke 1.8
    }

    defaultConfig {
        applicationId = "com.example.shoe_store_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")  // wajib ditambahkan
}

flutter {
    source = "../.."
}
