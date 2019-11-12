## Changelog

This changelog is tracking all the changes that will affect the behavior of this library.

### Upcoming version

- better error handling during activation process
  - `ActivationUIDataProvider` now requires implementation of `localizeError` method
- using PowerAuth  SDK v `1.2+`
- support for iOS 13 modal presentation
- added `cancel()` to `LimeAuthAuthenticationUI`
- UI fixes

### 0.7.2

- Better activation & recovery code validation
- Fixed broken spinner in recovery screen
- Added configuration for how long activation will wait before "cancel activation" button is displayed.
- Fixed layout issues in recovery code screen.
- Turned off autocorrection in password text fields
- New strings:
  ```
  "limeauth.act.enterCode.notValidTitle"      = "Invalid activation code";
  "limeauth.act.enterCode.notValidText"       = "This activation code is not valid. Make sure that you entered it right.";
  "limeauth.act.enterCode.notValidButton"     = "OK";
  
  "limeauth.act.enterRecovery.notValidCodeTitle" = "Invalid activation code";
  "limeauth.act.enterRecovery.notValidCodeText"  = "This activation code is not valid. Make sure that you entered it right.";
  "limeauth.act.enterRecovery.notValidPukTitle"  = "Invalid PUK";
  "limeauth.act.enterRecovery.notValidPukText"   = "This PUK is not valid. Make sure that you entered it right.";
  "limeauth.act.enterRecovery.notValidButton"    = "OK";
  ```

### 0.7.1

- Fixed broken background in recovery code scene

### 0.7.0

- updated to `swift 5`
- added new recovery activation feature ([related pull request](https://github.com/wultra/swift-lime-auth/pull/86))
- new strings:   
  ```
  // Activation :: Begin Recovery Scene
  "limeauth.act.beginRec.title"                  = "Prepare your Activation Recovery";
  "limeauth.act.beginRec.description"            = "During your last activation, you were asked to write down the Activation Recovery data that consist of Activation Code and PUK. Please, prepare this data.";
  "limeauth.act.beginRec.continue"               = "Continue";
  
  // Activation :: Enter Code Recovery Scene
  "limeauth.act.enterRecovery.title"             = "Recovery Activation";
  "limeauth.act.enterRecovery.codeDesc"          = "Please retype the Activation Code.";
  "limeauth.act.enterRecovery.pukDesc"           = "Please retype the PUK.";
  "limeauth.act.enterRecovery.confirm"           = "Continue";
  
  // MARK: - Recovery Code Screen
  
  // during activation
  
  "limeauth.recovery.act.title"           = "Activation Recovery data";
  "limeauth.recovery.act.description"     = "Please write your recovery Activation Code and PUK down and store it in a secure place.";
  "limeauth.recovery.act.codeheader"      = "ACTIVATION CODE";
  "limeauth.recovery.act.pukHeader"       = "PUK";
  "limeauth.recovery.act.warning"         = "If you'll lose your recovery data, you won't be able to reactivate again on a new device. In such a case, you will need to visit us at one of our branches.";
  "limeauth.recovery.act.continue"        = "Continue";
  "limeauth.recovery.act.continueSeconds" = "Continue (%@)";
  
  // during reactivation
  
  "limeauth.recovery.react.title"            = "New Activation Recovery data";
  "limeauth.recovery.react.description"      = "Please write your new recovery Activation Code and PUK down and store it in a secure place. The code and PUK you just used won't work anymore.";
  "limeauth.recovery.react.codeheader"       = "NEW ACTIVATION CODE";
  "limeauth.recovery.react.pukHeader"        = "NEW PUK";
  "limeauth.recovery.react.warning"          = "If you'll lose your new recovery data, you won't be able to reactivate again on a new device. In such a case, you will need to visit us at one of our branches.";
  "limeauth.recovery.react.continue"         = "Continue";
  "limeauth.recovery.react.continueSeconds"  = "Continue (%@)";
  
  // on single page
  
  "limeauth.recovery.view.title"           = "Activation Recovery data";
  "limeauth.recovery.view.description"     = "Please write your recovery Activation Code and PUK down and store it in a secure place.";
  "limeauth.recovery.view.codeheader"      = "ACTIVATION CODE";
  "limeauth.recovery.view.pukHeader"       = "PUK";
  "limeauth.recovery.view.warning"         = "If you'll lose your recovery data, you won't be able to reactivate again on a new device. In such a case, you will need to visit us at one of our branches.";
  "limeauth.recovery.view.continue"        = "OK";
  "limeauth.recovery.view.continueSeconds" = "OK (%@)";
  
  // warning alert
  
  "limeauth.recovery.screenshot.title"   = "Screenshot detected";
  "limeauth.recovery.screenshot.message" = "Taking screenshots of the Activation Recovery data is a potential risk. We strongly recommend deleting such a screenshot as soon as possible.";
  "limeauth.recovery.screenshot.button"  = "I understand";
  "limeauth.op.recovery.activity"             = "Retrieving recovery data...";   
  ```
  

### 0.6.1

-  Forcing fonts on passcode dots ([related pull request](https://github.com/wultra/swift-lime-auth/pull/79))

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