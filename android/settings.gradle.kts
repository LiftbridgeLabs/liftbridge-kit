pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "liftbridge-kit-android"
// The project is named as apps ask for it (com.liftbridgelabs:liftbridge-themes),
// so an app that includes this build gets it substituted automatically.
include(":liftbridge-themes")
project(":liftbridge-themes").projectDir = file("themes")
