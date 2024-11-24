# hive_wasm_case

A small repo to test and verify a potential WASM issue.

Reported here in `hive_ce`: https://github.com/IO-Design-Team/hive_ce/issues/46
And here in `flutter`:  

## Type conversion issues in WASM builds

When saving key-value pair to a Hive box in a Flutter WASM web build, the of types `int`, `int?` and `double?` are not type converted correctly when retrieving values from the Hive box, that uses WEB IndexedDB for the locally persisted data.

When building the same code using native Dart VM build as target or more relevant, when building with JavaScript as target, the type conversions all work as expected.

This issue covers the two other WASM issues mentioned [here #159375](https://github.com/flutter/flutter/issues/159375) that were discussed with @kevmoo in a video meeting Nov 18, 2024. A reproduction sample and issue in the Flutter repo was requested by Kevin during the meeting.

## Issue sample code

The reproduction sample is provided in a separate repository here: https://github.com/rydmike/hive_wasm_case

The sample uses the `hive_ce` package that on web builds persists **key-value** pairs in the WEB browser IndexedDB. The `hive_ce` package is a community fork of the original `hive` package, that has been modified to work with **Flutter Web WASM** builds, by using `package:web` instead of `html` library.

The package works as expected when building for Web JS target with no `--wasm` option, but when building with `--wasm` option, the here presented type conversion issues are present.

As the `hive_ce` package is used, the issue has also been reported to package maintainer here https://github.com/IO-Design-Team/hive_ce/issues/46.

While it is possible that the issue is in the package, it is worth stating that `hive_ce` works as expected on native VM and Web JS builds, and for the WASM build it uses the same `package:web` primitives as the Flutter Web JS build, that works correctly and as expected.


## Expected results

Expect retrieving `int`, `int?` and `double?` values to work, when values of known saved types are loaded and converted back their original types.

Build and run the sample code using WEB target in Chrome browser.
Open up developer tools, show the console. 

Hit the **(Increase values and save to DB)** button to add some key-value pairs to the IndexedDB for local storage.

![1-wasm-issue](https://github.com/user-attachments/assets/74a740d5-709b-40ee-ac97-5f5c93dec2db)

We can verify that the values have been persisted as expected in comparing console log debug prints and values persisted in browser **IndexedDB**.

![2-wasm issue](https://github.com/user-attachments/assets/ab88f89f-f29c-40e4-8e0d-7d92626a8213)

Next hit refresh page on the browser, an empty start page is shown, then hit the **(Load values from DB)** button, to load values from the IndexedDB.

Same values as before are loaded and printed to the console **without any errors**.

![3-wasm-issue](https://github.com/user-attachments/assets/ca435eb4-3352-466a-a199-6426b60adc0e)

This works the same way on all **native VM platform** builds and **WEB JS** builds and on ALL Flutter channels. We **expect** the **same** results in a **WEB WASM** build.

## Actual results

Let's repeat this process again, but this time we build for web target with `--wasm` option.

The sample app header will change confirming that the build is for web target with WASM-GC being used, the app will also run with a red theme, indicating this will have some issues.

Again open up developer tools, show the console.

Hit the **(Increase values and save to DB)** button to add some key-value pairs to the IndexedDB for local storage.

![4-wasm-issue](https://github.com/user-attachments/assets/2336d0a4-bbe6-4462-8c99-668a9739cc3b)

We can again verify that the values have been persisted as expected by checking the console.

![5-wasm-issue](https://github.com/user-attachments/assets/0ee71101-c64d-48db-98ea-e733349c1428)

### Issue 1) double? type conversion issue

Next clear the console and then hit **(Load values from DB)** button.

![6-wasm-issue](https://github.com/user-attachments/assets/b765f775-1182-4737-8cb4-5d85eaad2188)

We can see that the saved value that had type nullable double `double?`, threw an **exception** error when trying to convert it back to double.

In this sample code, an attempt was made to try handle the error before it is thrown, by checking for the conditions that seem to trigger it and work around it:

```dart
      // We should catch the 2nd issue here, but we do not see it in this
      // if branch, we should see the debugPrint, but we do not see it.
      // We get a caught error in the catch block instead.
      } else if (App.isRunningWithWasm && storedValue != null &&
                 isNullableDoubleT && defaultValue == null) {
        debugPrint(
          '   WASM Error : Expected double? but thinks T is int, '
          'returning as double: $storedValue',
        );
        final double loaded = storedValue as double;
        return loaded as T;
      } 
```

However, the attempts to do so did not work as expected, and the error was thrown and caught in the catch block instead.

```console
Store LOAD ERROR ********
  Error message ...... : Type 'int' is not a subtype of type 'double?' in type cast
  Store key .......... : D: doubleNullable
  Store value ........ : 0.1
  defaultValue ....... : null
```

If we add a stacktrace to the error message, can get some additional information:

```console
  Stacktrace ......... :     
     at module0._TypeError._throwAsCheckError (http://localhost:55415/main.dart.wasm:wasm-function[921]:0x244e22)
     at module0._asSubtype (http://localhost:55415/main.dart.wasm:wasm-function[975]:0x245c0d)
     at module0.StorageServiceHive.load inner (http://localhost:55415/main.dart.wasm:wasm-function[15615]:0x36e600)
     at module0.StorageServiceHive.load (http://localhost:55415/main.dart.wasm:wasm-function[15607]:0x36e1d0)
     at module0._MyHomePageState._loadCounters inner (http://localhost:55415/main.dart.wasm:wasm-function[15602]:0x36e03b)
     at module0._awaitHelper closure at org-dartlang-sdk:///dart-sdk/lib/_internal/wasm/lib/async_patch.dart:95:5 (http://localhost:55415/main.dart.wasm:wasm-function[19862]:0x3c6172)
     at module0.closure wrapper at org-dartlang-sdk:///dart-sdk/lib/_internal/wasm/lib/async_patch.dart:95:5 trampoline (http://localhost:55415/main.dart.wasm:wasm-function[19867]:0x3c6213)
     at module0._RootZone.runUnary (http://localhost:55415/main.dart.wasm:wasm-function[1561]:0x24e333)
```

Next comes an interesting twist.

### Issue 2) int type conversion issue, when loading values from fresh start.

Next hit refresh page on the browser, empty start page is shown, and hit **(Load values from DB)** button again.

![7-wasm-issue](https://github.com/user-attachments/assets/e577c3cc-1553-448b-ac50-d95ee2cc78b3)

This time we get **more errors**! 

In the sample reproduction code there is a special condition to catch this issue without throwing an error:

```dart
      // Add workaround for hive WASM returning double instead of int, when
      // values saved to IndexedDb were int.
      // In this reproduction sample we see this FAIL triggered ONLY when
      // loading the values from the DB without having written anything to it
      // first. We can reproduce this issue by running the sample as WASM build
      // hitting Increase button a few times, then hot restart the app or 
      // reload the browser and hit Load Values. We then hit this issue.
      // Without this special if case handling, we would get an error thrown.
      // This path is never entered on native VM or JS builds.
      } else
      if (App.isRunningWithWasm &&
          storedValue != null &&
          (storedValue is double) &&
          (defaultValue is int || defaultValue is int?)) {
        final T loaded = storedValue.round() as T;
        debugPrint(
          '  ** WASM Error : Expected int but got double, '
          'returning as int: $loaded',
        );
        return loaded;
      }
```

We can see that in this case when the values are loaded from the **IndexedDB**, the `int` values are not type converted correctly, because they are for some reason returned as **"1.0"** instead of **"1"**, as they were before re-loading the web app and starting it again.

We can again check that values are actually persisted in the **IndexedDB** and that the values are correct, they are **"1"** and not **"1.0"** as returned when loading the values from the **IndexedDB** when starting the app without having saved anything to it first.

![8-wasm-issue](https://github.com/user-attachments/assets/3c5866a1-d61c-4057-bcb1-43961f61d867)

If we hit **(Increase values and save to DB)** button again and update the `int` values to **2**, and hit **(Load values from DB)** again, we can see that the values are now loaded as **"2"** as they should be, and not **"2.0"**.

![9-wasm-issue](https://github.com/user-attachments/assets/df492aa5-04ab-4468-9cf9-d7fcb7109a0b)

Again if we restart the app with a page refresh (or Flutter hot restart), the `int` values are again returned as **"2.0"** and not **"2"**. 

![10-wasm-issue](https://github.com/user-attachments/assets/05ff42fb-070e-4b79-8a08-de34083f1cac)

It is worth noticing that **issue 1)** is present all the time, but the second **issue 2)** with `int` being returned as `double` is only present when loading values from the **IndexedDB**, without having written anything to it first after starting the app, it seem like if you write something to it after opening the DB, the read values will be returned with the correct `int` type.

### Flutter version

Used Flutter version: Channel master
**Channel master, 3.27.0-1.0.pre.621**

It reproduces on beta and stable 3.24.5 too.

<details>
  <summary>Flutter doctor</summary>

```
flutter doctor -v
[✓] Flutter (Channel master, 3.27.0-1.0.pre.621, on macOS 15.1.1 24B91 darwin-arm64, locale en-US)
    • Flutter version 3.27.0-1.0.pre.621 on channel master at /Users/rydmike/fvm/versions/master
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision da188452a6 (55 minutes ago), 2024-11-23 19:55:24 +0100
    • Engine revision b382d17a27
    • Dart version 3.7.0 (build 3.7.0-183.0.dev)
    • DevTools version 2.41.0-dev.2

[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at /Users/rydmike/Library/Android/sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: /Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java
      This is the JDK bundled with the latest Android Studio installation on this machine.
      To manually set the JDK path, use: `flutter config --jdk-dir="path/to/jdk"`.
    • Java version OpenJDK Runtime Environment (build 17.0.9+0-17.0.9b1087.7-11185874)
    • All Android licenses accepted.

[!] Xcode - develop for iOS and macOS (Xcode 16.1)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 16B40

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Android Studio (version 2023.2)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin can be installed from:
    • Dart plugin can be installed from:
    • Java version OpenJDK Runtime Environment (build 17.0.9+0-17.0.9b1087.7-11185874)

[✓] IntelliJ IDEA Community Edition (version 2024.2.4)
    • IntelliJ at /Applications/IntelliJ IDEA CE.app
    • Flutter plugin version 82.1.3
    • Dart plugin version 242.22855.32

[✓] VS Code (version 1.95.3)
    • VS Code at /Applications/Visual Studio Code.app/Contents
    • Flutter extension version 3.100.0

[✓] Connected device (4 available)
    • MrPinkPro (mobile)              • 74120d6ef6769c3a2e53d61051da0147d0279996 • ios            • iOS 17.7.2 21H221
    • macOS (desktop)                 • macos                                    • darwin-arm64   • macOS 15.1.1 24B91 darwin-arm64
    • Mac Designed for iPad (desktop) • mac-designed-for-ipad                    • darwin         • macOS 15.1.1 24B91 darwin-arm64
    • Chrome (web)                    • chrome                                   • web-javascript • Google Chrome 131.0.6778.86

[✓] Network resources
    • All expected network resources are available.

```

</details>