import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// =============================================================================
// RELEASE SIGNING — finding SEC-21 / R7-01 (was CRITICAL)
// =============================================================================
//
// WHAT WAS WRONG. `buildTypes.release` pointed its signingConfig at the DEBUG
// signing config by name, behind a `// TODO`. Two consequences:
// Google Play rejects a debug-signed artifact outright, and — worse — a
// sideloaded APK signed with the PUBLICLY KNOWN Android debug key can be
// re-signed by anyone and accepted by Android as an in-place update, delivering
// a trojaned merchant console that inherits the bearer token already on the
// device.
//
// WHAT THIS DOES NOW. The release signing config is read from
// `android/key.properties`, which is untracked (`.gitignore:51`,
// `android/.gitignore:12`). When that file is missing or incomplete there is NO
// FALLBACK: the release signing config is simply not created, and any task
// graph containing a release packaging task fails with the message below.
//
// A FAILING RELEASE BUILD IS THE CORRECT OUTCOME HERE. Silently signing with
// the debug key is the defect; refusing to build is the fix. Debug and profile
// builds are unaffected, so day-to-day development and `flutter run` keep
// working without a keystore.
//
// WHAT THE OWNER MUST SUPPLY — see android/RELEASE_SIGNING.md for the full
// procedure. Nothing below it may ever be committed.
// =============================================================================

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

val requiredKeystoreKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")

val missingKeystoreKeys: List<String> =
    if (keystorePropertiesFile.exists()) {
        requiredKeystoreKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
    } else {
        requiredKeystoreKeys
    }

val keystoreFile: java.io.File? =
    keystoreProperties.getProperty("storeFile")
        ?.takeIf { it.isNotBlank() }
        ?.let { path ->
            val candidate = file(path)
            if (candidate.isAbsolute) candidate else rootProject.file(path)
        }

val hasReleaseSigning: Boolean =
    keystorePropertiesFile.exists() &&
        missingKeystoreKeys.isEmpty() &&
        keystoreFile != null &&
        keystoreFile.exists()

/** Why the release signing config could not be assembled, in the owner's terms. */
val releaseSigningProblem: String =
    when {
        hasReleaseSigning -> ""
        !keystorePropertiesFile.exists() ->
            "android/key.properties does not exist."
        missingKeystoreKeys.isNotEmpty() ->
            "android/key.properties is missing or has blank values for: " +
                missingKeystoreKeys.joinToString(", ") + "."
        keystoreFile == null ->
            "android/key.properties has no usable storeFile value."
        else ->
            "the keystore named by storeFile does not exist at " +
                "${keystoreFile?.absolutePath}."
    }

android {
    namespace = "com.syriastore.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.syriastore.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // Created ONLY when a complete key.properties and a real keystore are
        // both present. Never created from the debug keystore.
        if (hasReleaseSigning) {
            create("release") {
                storeFile = keystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // SEC-21 / R7-01: the release buildType no longer references the
            // debug signing config, and must never reference it again. If the
            // release signing config does not exist, the release buildType is
            // left with no signing config at all and the guard below aborts
            // the build.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }

            // Code shrinking is EXPLICITLY SKIPPED, not forgotten. Flutter
            // compiles Dart to AOT machine code, so R8 only touches the thin
            // Kotlin shim: the benefit is APK size, not security, while R8
            // without correct keep-rules is a known source of release-only
            // crashes in Firebase and other reflection-using plugins.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// =============================================================================
// FAIL LOUDLY — never ship an unsigned or debug-signed release artifact
// =============================================================================
//
// Checked against the resolved task graph rather than at configuration time, so
// that `assembleDebug`, `flutter run`, `flutter test` and IDE sync all keep
// working on a machine that has no keystore. Only a release packaging task
// trips it.
gradle.taskGraph.whenReady {
    if (hasReleaseSigning) return@whenReady

    val releaseTaskNames =
        allTasks
            .filter { it.project.path == project.path }
            .map { it.name }
            .filter { name ->
                name.contains("Release") &&
                    (
                        name.startsWith("assemble") ||
                            name.startsWith("bundle") ||
                            name.startsWith("package") ||
                            name.startsWith("install")
                        )
            }

    if (releaseTaskNames.isEmpty()) return@whenReady

    throw GradleException(
        """

        ================================================================
         RELEASE BUILD ABORTED — no release signing key (SEC-21 / R7-01)
        ================================================================

        Requested release task(s): ${releaseTaskNames.joinToString(", ")}

        Reason: $releaseSigningProblem

        This build used to fall back to the Android DEBUG keystore. That
        fallback has been removed on purpose: a debug-signed APK is
        rejected by Google Play, and because the debug key is public,
        anyone can re-sign such an APK and have Android accept it as an
        in-place update of the merchant console — inheriting the bearer
        token already stored on the device.

        TO FIX THIS (owner action — a release keystore must never be
        committed to git):

          1. Create a keystore, once, and keep the only copies in the
             password manager and an offline backup:

               keytool -genkey -v \
                 -keystore /secure/path/storesyria-release.jks \
                 -storetype JKS -keyalg RSA -keysize 2048 \
                 -validity 10000 -alias storesyria

          2. Create android/key.properties (already gitignored) with:

               storeFile=/secure/path/storesyria-release.jks
               storePassword=<the store password>
               keyAlias=storesyria
               keyPassword=<the key password>

             android/key.properties.example is a template. Do not put the
             real values in the example file and do not commit them.

          3. Re-run the build.

        Full procedure, CI notes and the tester-uninstall warning:
        android/RELEASE_SIGNING.md

        ================================================================
        """.trimIndent()
    )
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
