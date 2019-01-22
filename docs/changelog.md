## Changelog

This changelog is tracking all the changes that will affect the behavior of this library.

### Upcoming version

- TBA

### 0.6.0

- Added support for vibration/sounds ([related pull request](https://github.com/wultra/swift-lime-auth/pull/50))
- Added pin/password strength test feature ([related pull request](https://github.com/wultra/swift-lime-auth/pull/60))
- Added default strings for alert displayed when passphrase is not good enough:
  ```
  "limeauth.auth.passStrength.defaultWarningPin"        = "Warning";
  "limeauth.auth.passStrengthDifferentPin"              = "Change passcode";
  "limeauth.auth.passStrength.defaultWarningPassword"   = "Warning";
  "limeauth.auth.passStrengthDifferentPassword"         = "Change password";
  "limeauth.auth.passStrength.defaultDifferentPin"      = "Change passcode";
  "limeauth.auth.passStrengthIgnorePin"                 = "Use anyway";
  "limeauth.auth.passStrength.defaultDifferentPassword" = "Change password";
  "limeauth.auth.passStrengthIgnorePassword"            = "Use anyway";
  "limeauth.auth.passStrength.defaultIgnorePin"         = "Use anyway";
  "limeauth.auth.passStrength.defaultIgnorePassword"    = "Use anyway";
  "limeauth.auth.passStrength.defaultWeakPin"           = "This PIN looks weak. Are you sure you want to use it?";
  "limeauth.auth.passStrength.defaultWeakPassword"      = "This password is weak. Are you sure you want to use it?";
  ```
- Added `limeauth.err.touchIdFail` and `limeauth.err.faceIdFail` strings to distinguish between "wrong pin" and "biometry not recognized" error. Equal properties were also added to `Authentication.UIData.CommonErrors`