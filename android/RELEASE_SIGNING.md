# Android release signing — owner action required

Finding **SEC-21 / R7-01**. Until the steps below are done, `flutter build apk
--release` and `flutter build appbundle` **will fail on purpose**. Debug and
profile builds are unaffected.

## Why the build fails instead of falling back

`android/app/build.gradle.kts` used to sign release builds with the Android
**debug** keystore. That is not shippable:

- Google Play rejects a debug-signed artifact outright.
- The debug key is **public and identical on every machine**. Anyone can
  re-sign a sideloaded Store Syria APK with it, and Android will accept the
  result as an in-place **update** of the installed merchant console — which
  then inherits the bearer token already stored on the device.

The fallback has been removed with no replacement. A build that fails loudly is
the correct outcome; a build that silently signs with the debug key is the
defect.

## What the owner must supply

Four values, in `android/key.properties`. That file is gitignored
(`.gitignore:51`, `android/.gitignore:12`) and **must never be committed**, and
neither must the keystore itself.

### 1. Generate the upload keystore — once, ever

```
keytool -genkey -v \
  -keystore /secure/path/storesyria-release.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias storesyria
```

`-validity 10000` (about 27 years) is Google's recommendation: an expired
signing key cannot publish an update.

### 2. Store the only copies safely

The keystore file and both passwords belong in the company password manager
**and** an offline backup. **If this keystore is lost, the app can never be
updated under the same package name again** unless Play App Signing is enabled
and Google holds the app signing key — see step 5.

### 3. Create `android/key.properties`

Copy `android/key.properties.example` and fill it in:

```
storeFile=/secure/path/storesyria-release.jks
storePassword=<store password>
keyAlias=storesyria
keyPassword=<key password>
```

`storeFile` may be absolute (recommended) or relative to `android/`.

### 4. Verify the artifact is not debug-signed

```
flutter build apk --release
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

The certificate subject must **not** be `CN=Android Debug, O=Android, C=US`.
This is the acceptance check for SEC-21 and the one assertion that cannot be
made from source alone.

### 5. Recommended: enable Play App Signing

Upload the key as an *upload key* and let Google hold the app signing key. That
converts "we lost the keystore" from unrecoverable into a support ticket.

## CI

Do not commit `key.properties`. In CI, write it at build time from secrets and
materialise the keystore from a base64-encoded secret into a path outside the
workspace. The guard in `build.gradle.kts` will abort the job if either is
missing, so a misconfigured pipeline fails instead of publishing an unsigned or
debug-signed artifact.

## Release note that must reach the testers

**Once the release key changes, every debug-signed build already installed on a
tester's device must be UNINSTALLED before the properly signed build will
install.** Android refuses an update whose signature differs from the installed
one. This is a one-time cost at the changeover and it affects testers only, not
merchants, because no properly signed build has ever shipped.

## iOS

Not covered by SEC-21 and not changed in this pass. iOS release signing is
handled by Xcode automatic signing plus the Apple Developer account; it has no
equivalent debug-key fallback.
