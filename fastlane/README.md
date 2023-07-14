fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

Submit a new Beta Build to Google Play Beta

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Deploy a new version to the Google Play

----


## iOS

### ios changelogs

```sh
[bundle exec] fastlane ios changelogs
```

Prints path and changelog

### ios build

```sh
[bundle exec] fastlane ios build
```

Build iOS app for distribution

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Deploy iOS version to app store (manual release)

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Deploy iOS version to app store (automatic release)

----


## macos

### macos changelogs

```sh
[bundle exec] fastlane macos changelogs
```

Prints path and changelog

### macos build

```sh
[bundle exec] fastlane macos build
```

Build iOS app for distribution

### macos beta

```sh
[bundle exec] fastlane macos beta
```

Deploy MacOS version to app store (manual release)

### macos deploy

```sh
[bundle exec] fastlane macos deploy
```

Deploy MacOS version to app store (automatic release)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
