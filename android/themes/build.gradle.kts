// LiftbridgeThemes for Android: the same themes as the Swift package, for
// Jetpack Compose. Apps include it as
// com.liftbridgelabs:liftbridge-themes (see the repo README).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    `maven-publish`
}

group = "com.liftbridgelabs"
// The same version as the Swift package's tag.
version = rootProject.file("../VERSION").readText().trim()

android {
    namespace = "com.liftbridgelabs.themes"
    compileSdk = 36
    defaultConfig {
        minSdk = 26
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    publishing {
        singleVariant("release") { withSourcesJar() }
    }
    testOptions {
        // ThemeStore's tests use Compose state, which needs no Android framework.
        unitTests.isReturnDefaultValues = true
    }
}

kotlin {
    compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) }
}

dependencies {
    implementation(platform(libs.androidx.compose.bom))
    api(libs.androidx.compose.ui)
    api(libs.androidx.compose.foundation)
    testImplementation(libs.junit)
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "com.liftbridgelabs"
            artifactId = "liftbridge-themes"
            afterEvaluate { from(components["release"]) }
        }
    }
}
