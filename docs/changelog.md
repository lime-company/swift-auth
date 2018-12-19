## Changelog

This changelog is tracking all the changes that will affect the behavior of this library.

### Upcoming version
- Added strings for alert displayed when passphrase is not good enough:
  ```
  "limeauth.auth.passStrengthWarning"            = "Warning";
  "limeauth.auth.passStrengthDifferentPin"       = "Change passcode";
  "limeauth.auth.passStrengthDifferentPassword"  = "Change password";
  "limeauth.auth.passStrengthIgnorePin"          = "Use anyway";
  "limeauth.auth.passStrengthIgnorePassword"     = "Use anyway";
  ```
- Added `limeauth.err.touchIdFail` and `limeauth.err.faceIdFail` strings to distinguish between "wrong pin" and "biometry not recognized" error. Equal properties were also added to `Authentication.UIData.CommonErrors`