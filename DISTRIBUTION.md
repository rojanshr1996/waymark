# WayMark — Distribution & CI/CD Guide

This guide documents the automated build and distribution pipeline for **WayMark** across iOS and Android platforms using [Fastlane](https://fastlane.tools/) and [Firebase App Distribution](https://firebase.google.com/products/app-distribution).

---

## 1. Flavors & Environments Overview

WayMark supports four distinct environments/flavors across both platforms:

| Environment | iOS Scheme | iOS Bundle ID | Android Flavor | Android Package Name | Tester Group | Target Audience |
|---|---|---|---|---|---|---|
| **Dev** | `dev` | `com.waymark.app.dev` | `dev` | `com.waymark.app.dev` | `dev-testers` | Active developers & internal testers |
| **QA** | `qa` | `com.waymark.app.qa` | `qa` | `com.waymark.app.qa` | `qa-testers` | QA team, regression & feature testing |
| **UAT** | `uat` | `com.waymark.app.uat` | `uat` | `com.waymark.app.uat` | `uat-testers` | Stakeholders & beta user acceptance |
| **Production** | `production` | `com.waymark.app` | `production` | `com.waymark.app` | `prod-testers` | Final release candidates & staging |

---

## 2. Prerequisites

Before running the distribution scripts or Fastlane lanes, ensure your local or CI machine has the following installed:

1. **Ruby 3.x & Bundler**
   ```bash
   ruby --version
   gem install bundler
   ```
2. **Fastlane 2.x**
   Installed via Bundler (`bundle install` from the project root) or:
   ```bash
   gem install fastlane
   ```
3. **Firebase CLI**
   Used for authentication and token generation:
   ```bash
   curl -sL https://firebase.tools | bash
   # or via npm:
   npm install -g firebase-tools
   ```
4. **Google Cloud CLI (`gcloud`)** *(optional for GCP services)*
   ```bash
   gcloud --version
   ```
5. **Platform SDKs**
   - **Flutter SDK**: Ensure `flutter doctor` passes cleanly.
   - **Xcode**: Required for iOS builds (macOS only, command line tools installed).
   - **Android SDK & JDK 17+**: Required for Android Gradle builds.

---

## 3. Environment Variables

Fastlane requires credentials and Firebase App IDs passed via environment variables. Configure these in your CI secrets, shell profile (`~/.zshrc`), or export them before running lanes:

| Variable Name | Description | Required | Example |
|---|---|---|---|
| `FIREBASE_TOKEN` | Firebase CLI CI authentication token | Yes | `1//04xxx...` |
| `FIREBASE_APP_ID_IOS_DEV` | Firebase App ID for iOS Dev | If distributing iOS Dev | `1:123456789:ios:abcdef1` |
| `FIREBASE_APP_ID_IOS_QA` | Firebase App ID for iOS QA | If distributing iOS QA | `1:123456789:ios:abcdef2` |
| `FIREBASE_APP_ID_IOS_UAT` | Firebase App ID for iOS UAT | If distributing iOS UAT | `1:123456789:ios:abcdef3` |
| `FIREBASE_APP_ID_IOS_PROD` | Firebase App ID for iOS Production | If distributing iOS Prod | `1:123456789:ios:abcdef4` |
| `FIREBASE_APP_ID_ANDROID_DEV` | Firebase App ID for Android Dev | If distributing Android Dev | `1:123456789:android:abcdef1` |
| `FIREBASE_APP_ID_ANDROID_QA` | Firebase App ID for Android QA | If distributing Android QA | `1:123456789:android:abcdef2` |
| `FIREBASE_APP_ID_ANDROID_UAT` | Firebase App ID for Android UAT | If distributing Android UAT | `1:123456789:android:abcdef3` |
| `FIREBASE_APP_ID_ANDROID_PROD` | Firebase App ID for Android Production | If distributing Android Prod | `1:123456789:android:abcdef4` |
| `SET_BUILD_NUMBER` | Set to `true` to auto-increment iOS build number | Optional | `true` |

### Export Example
```bash
export FIREBASE_TOKEN="your_firebase_ci_token"
export FIREBASE_APP_ID_IOS_DEV="1:XXXXXXXX:ios:YYYYYYYY"
export FIREBASE_APP_ID_ANDROID_DEV="1:XXXXXXXX:android:ZZZZZZZZ"
```

---

## 4. Setup Instructions

1. **Install Dependencies**
   From the project root (`/Users/rojanshrestha/Documents/rojan/personalProjects/waymark/`), install Fastlane and all plugins specified in `Gemfile` and `fastlane/Pluginfile`:
   ```bash
   bundle install
   ```

2. **Verify Fastlane Installation**
   ```bash
   bundle exec fastlane --version
   ```

---

## 5. Running Distribution

### 5.1 Interactive Shell Script (Recommended)

WayMark provides a guided CLI script:
```bash
./distribute.sh
```

**Workflow:**
1. Select target environment (1: Dev, 2: QA, 3: UAT, 4: Production).
2. Select target platform (1: iOS, 2: Android, 3: Both).
3. Enter optional release notes (defaults to today's date & environment label).
4. Review summary and confirm (`y/N`).
5. Executes the respective Fastlane lanes sequentially.

### 5.2 Manual Fastlane Commands

You can execute specific platform lanes directly using `bundle exec fastlane`:

#### iOS Lanes
```bash
cd ios
# Dev
bundle exec fastlane distribute_dev notes:"Dev test build"
# QA
bundle exec fastlane distribute_qa notes:"QA regression build"
# UAT
bundle exec fastlane distribute_uat notes:"UAT release candidate"
# Production
bundle exec fastlane distribute_prod notes:"Production ad-hoc build"
```

#### Android Lanes
```bash
cd android
# Dev
bundle exec fastlane distribute_dev notes:"Dev test build"
# QA
bundle exec fastlane distribute_qa notes:"QA regression build"
# UAT
bundle exec fastlane distribute_uat notes:"UAT release candidate"
# Production
bundle exec fastlane distribute_prod notes:"Production ad-hoc build"
```

---

## 6. iOS Code Signing Setup (`match`)

For seamless, reproducible code signing across developer machines and CI environments, use [Fastlane Match](https://docs.fastlane.tools/actions/match/):

1. **Initialize Match Repository**
   Create a private Git repository for storing encrypted certificates and provisioning profiles.
   ```bash
   cd ios
   bundle exec fastlane match init
   ```
   Follow prompts to enter your Git storage repo URL.

2. **Generate Ad-Hoc Profiles for All Flavors**
   ```bash
   bundle exec fastlane match adhoc -a com.waymark.app.dev
   bundle exec fastlane match adhoc -a com.waymark.app.qa
   bundle exec fastlane match adhoc -a com.waymark.app.uat
   bundle exec fastlane match adhoc -a com.waymark.app
   ```

3. **Configure `ios/fastlane/Appfile`**
   Fill in your Apple Developer Team ID and App Store Connect credentials:
   ```ruby
   app_identifier("com.waymark.app")
   apple_id("developer@example.com")
   itc_team_id("123456789")
   team_id("XXXXXXXXXX")
   ```

4. **Enable Match in `ios/fastlane/Fastfile`**
   Uncomment the `match` call in each lane inside `ios/fastlane/Fastfile`:
   ```ruby
   match(type: "adhoc", app_identifier: "com.waymark.app.dev")
   ```

---

## 7. Android Keystore Setup

To sign release builds for Android, configure `key.properties`:

1. **Generate Release Keystore** *(if not already created)*:
   ```bash
   keytool -genkey -v -keystore ~/waymark-release.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias waymark
   ```

2. **Create `android/key.properties`**:
   Create `/Users/rojanshrestha/Documents/rojan/personalProjects/waymark/android/key.properties` (ensure this file is gitignored):
   ```properties
   storePassword=yourStorePassword
   keyPassword=yourKeyPassword
   keyAlias=waymark
   storeFile=/path/to/waymark-release.jks
   ```

3. **Link to `android/app/build.gradle.kts`**:
   Load `key.properties` in your Gradle build script and assign `signingConfigs.getByName("release")` to the `release` build type.

---

## 8. Firebase App Distribution Setup

1. **Obtain Firebase CLI Token**
   Run the following on a machine with a web browser:
   ```bash
   firebase login:ci
   ```
   This will authenticate your Google account and print a token. Save this as `FIREBASE_TOKEN`.

2. **Retrieve Firebase App IDs**
   - Open the [Firebase Console](https://console.firebase.google.com/).
   - Go to **Project Settings** > **General**.
   - Under **Your apps**, find the respective iOS and Android apps for each flavor.
   - Copy the **App ID** (format: `1:1234567890:ios:abcdef12345` or `1:1234567890:android:abcdef12345`).
   - Populate the corresponding `FIREBASE_APP_ID_*` environment variables.

3. **Configure Tester Groups**
   In the Firebase Console, go to **Release & Monitor** > **App Distribution** > **Testers & Groups**:
   - Create `dev-testers` group and invite internal developers.
   - Create `qa-testers` group and invite QA engineers.
   - Create `uat-testers` group and invite beta testers/stakeholders.
   - Create `prod-testers` group for staging distribution.
