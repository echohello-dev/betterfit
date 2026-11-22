# TestFlight beta builds

Use the reviewed main branch and Xcode's automatic signing for
`dev.echohello.BetterFit`. This workflow is separate from package releases and
does not change their versioning. Confirm the app record, version and next unused
build number in App Store Connect before archiving. Local format validation does
not establish that a build number is unused.

## Select the backend

Choose the beta's backend explicitly. Guest builds store training data locally
and ignore cloud credentials, including development launch environment variables.
Cloud builds read public configuration from the installed app's Info.plist, so
they work outside Xcode. They do not inherit development environment overrides.

For a cloud build, create a private local JSON file with exactly `SUPABASE_URL`
and `SUPABASE_ANON_KEY`. Use a public HTTPS endpoint and the project's publishable
key or anon-role JWT. The public client configuration will be readable from the
installed app; enforce access through backend authentication and Row Level
Security. Never include service-role keys, secret keys, signing keys or `.env`
files in the app. Do not commit the JSON file or print its values.

The local development `.env` and scheme injection are not a TestFlight backend.
The archive preflight rejects local HTTP/private endpoints, privileged keys,
extra JSON fields and configuration supplied to guest builds. It validates key
type locally; verify the intended production project and backend permissions
separately before distributing a cloud beta.

## Archive a Release build

Supply an unused output directory outside the checkout. The following example
version and build are format examples; choose the actual values in App Store
Connect. Apple build numbers use one to three integers with maximum lengths of
four, two and two digits respectively.

```bash
mise run ios:archive -- --backend guest --version 1.7.0 --build 2611.22.1 \
  --team YOURTEAMID --output /tmp/betterfit-beta
```

For cloud mode, use `--backend supabase --public-config /private/path/public.json`.
Add `--prepare-only` to validate inputs and produce build/export configuration
without contacting Apple or building. No command in this preparation step uploads
the app or changes tester access.

The command runs `mise run ios:gen`, archives the iOS device Release scheme with
automatic provisioning, and checks the resulting app identity, version/build,
backend values and app privacy manifest. It rejects source PNGs with alpha or
transparency and verifies the archived 1024px AppIcon rendition is opaque.
It writes a redacted archive log and
local configuration/export options beside `BetterFit.xcarchive`. Keep those
working files private and outside version control. The generated Info.plist binds
the version fields to Xcode's version build settings.

Use an Apple Developer account configured in Xcode Settings > Accounts, with
permission for this app and team. Automatic signing may acquire distribution
certificates and profiles during export. A successful development-signed archive
alone does not prove distribution or App Store Connect access. An Apple agreement
update must be reviewed by the account holder; the tool does not accept agreements.

## Export, validate and upload

The iOS PNG icons use the existing artwork from
`design-system/assets/app-icon-1024.png`. That reference is byte-identical to the
original marketing icon, including its rounded transparent corners. The opaque
exports extend its existing `#FFD500` background to the full image. Samples at
the four side centres and an interior background point all had RGB `255,213,0`.
The mark and every previously opaque pixel are preserved exactly; the design
reference is unchanged. This is a packaging export, not a palette update.

The reproducible native export verifies encoded RGB pixels before writing:

```bash
swift scripts/opaque_app_icons.swift \
  Apps/iOS/BetterFitApp/Assets.xcassets/AppIcon.appiconset FFD500
```

The background argument belongs to that existing source; establish it again if
the source artwork changes. iOS applies the app-icon mask to the full-bleed image.

```bash
xcodebuild -exportArchive \
  -archivePath /tmp/betterfit-beta/BetterFit.xcarchive \
  -exportPath /tmp/betterfit-beta/export \
  -exportOptionsPlist /tmp/betterfit-beta/ExportOptions.plist \
  -allowProvisioningUpdates
```

The generated export options use `app-store-connect`, automatic signing, local
export and TestFlight internal testing only. They preserve the chosen build
number. Inspect the export result and signing entitlements, verify the final
version/build and backend, and launch a Release simulator build without demo/test
arguments. Verify normal guest persistence or production authentication as
appropriate. HealthKit usage strings and the required UserDefaults API reason
are included in the app; the privacy manifest is not a substitute for accurate
App Store Connect privacy and export-compliance answers.

Use Xcode Organizer's validation/upload flow for an authorised, reviewed beta.
After upload, monitor App Store Connect processing and any export-compliance
questions until the build is available for the intended existing internal group.
Do not treat upload success as processing or testability success. Record the app
ID, version/build, processing status and TestFlight link. Uploading a beta does
not authorise a public App Store release, public TestFlight links, tester invites
or notifications.

Apple documents [automatic distribution signing](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases),
[build-number format](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleversion)
and [required-reason privacy declarations](https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest).
