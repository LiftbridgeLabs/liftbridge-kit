# liftbridge-kit

Shared Swift packages for Liftbridge Labs apps (README.md says what's here and
how an app adds it). Public repo: never commit secrets, server addresses,
tokens, test data, or app plans, and don't name an app that isn't in the store.

## Who changes what (Jason, 2026-10-29)

- This repo's chat owns the packages: new seasons, new or renamed themes, fixes,
  new shared libraries. App chats pull a release into their app and wire it up
  themselves; they don't edit this repo. If an app needs a change here, it asks
  for it here.
- A theme `id` never changes once released (it's saved on devices). Rename the
  `name` instead.

## Releasing

1. Change the code, add tests, `swift test`. After any theme or color change,
   `swift run KotlinCatalog` regenerates the Android colors, then
   `cd android && ./gradlew :liftbridge-themes:testDebugUnitTest` (JAVA_HOME is
   Android Studio's: `/Applications/Android Studio.app/Contents/jbr/Contents/Home`).
   Bump `VERSION` (the Android library's version) with each tag.
2. CodeRabbit once per batch, before the push (workspace review flow).
3. Add the version to CHANGELOG.md: minor for new themes, seasons, renames and
   fixes; major only for a change apps must adapt to, with what to change.
4. Commit (Rule #1: no AI attribution), push to `main`, then tag the release
   with a plain version (`git tag 1.1.0 && git push origin 1.1.0`, no "v").
   Apps resolve by tag, so an untagged change never reaches them.
5. Run `swift run Gallery` so Jason's theme gallery (gallery.html) shows the
   release.
6. Tell Jason which apps should update to pick it up.

## Seasons

A seasonal group lists its window in `Catalog.swift`. It shows only in season,
marked "New", so release a new season well ahead of its start date: apps need
time to ship a build with it.
