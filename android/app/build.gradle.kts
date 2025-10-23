plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // == THAY ĐỔI 1: THÊM DÒNG NÀY ==
    // Add the Google services Gradle plugin
//    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.short_video_fe"
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
        applicationId = "com.example.short_video_fe"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // == THAY ĐỔI 2: THÊM DÒNG NÀY ==
        // Thêm dòng này để hỗ trợ các API Firebase cũ hơn
        multiDexEnabled = true
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

// == THAY ĐỔI 3: THÊM TOÀN BỘ KHỐI NÀY VÀO CUỐI TỆP ==
dependencies {
    // Import the Firebase BoM (Bill of Materials)
    // Nó sẽ tự động quản lý phiên bản của các thư viện Firebase khác
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))

    // Thư viện Firebase Analytics (nên có)
    implementation("com.google.firebase:firebase-analytics")

    // == Thêm các thư viện Firebase bạn cần cho MVP ==
    implementation("com.google.firebase:firebase-auth")      // Cho Đăng nhập / Đăng ký
    implementation("com.google.firebase:firebase-firestore") // Cho Cơ sở dữ liệu (lưu bài viết, user)
    implementation("com.google.firebase:firebase-storage")   // Cho Lưu trữ (lưu ảnh bài viết)
}

