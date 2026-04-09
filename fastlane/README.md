fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### tdd_ci

```sh
[bundle exec] fastlane tdd_ci
```

TDD 테스트 및 자동 배포

----


## iOS

### ios match_dev

```sh
[bundle exec] fastlane ios match_dev
```

Get development certificates and profiles

### ios match_store

```sh
[bundle exec] fastlane ios match_store
```

Get AppStore certificates and profiles

### ios match_dev_readonly

```sh
[bundle exec] fastlane ios match_dev_readonly
```

Get development certificates and profiles (readonly)

### ios match_store_readonly

```sh
[bundle exec] fastlane ios match_store_readonly
```

Get AppStore certificates and profiles (readonly)

### ios QA

```sh
[bundle exec] fastlane ios QA
```

Upload to TestFlight (Debug)

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit to App Store

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Submit already uploaded version for review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
