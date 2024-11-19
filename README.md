# DRAFT - hive_wasm_case

A small repo to test and verify a potential hive WASM issue.

## Type conversion issues in WASM builds

When saving key-value to a hive box in a Flutter WASM web build, the of types 
`int`, `int?` and `double?` are not type converted correctly when retrieving 
values from the hive box, that uses WEB IndexedDB for the locally persisted 
data.

When building the same code using native Dart VM build or targetting 
JavaScript, the type conversions works as expected.


## Issue sample code

The reproduction sample code is provided in a separate repository here https://github.com/rydmike/hive_wasm_case


## Expected results

Expect retrieving `int`, `int?` and `double?` value to work, when the known values type is used to convert the value to its original type.

Build and run the sample code using WEB target in Chrome browser.
Open up developer tools, show the console. 

Hit the FAB (+) button twice to add some key-value pairs to the hive box
that uses IndexedDB for local storage.

<ADD Image of console with saves>

Clear the console and hit (Load Value from DB)

The values load correctly and are printed to the console.

<ADD Image of console with loaded values>

We can also verify the same values are stored in the IndexedDB using DevTools.


Next hit refresh page on the browser, empty start page is shown, and hit load values from DB again.

Same values as before are loaded and printed to the console without any errors.

## Actual results

Let's repeat this process again, but this time we build for web target with --wasm option.

The app header will change confirming that the build is for web target with WASM-GC being used.

Open up developer tools, show the console.

Again, hit the FAB (+) button twice to add some key-value pairs to the hive box
that uses IndexedDB for local storage.

<ADD Image of console with saves>

Clear the console and hit (Load Values from DB)

We can see that saved value that had type nullable double, threw an error when trying to convert it back to double.

We can check the values in the IndexedDB using DevTools, and see that the values are stored correctly.

<ADD Image of IndexedDB values>

Next hit refresh page on the browser, empty start page is shown, and hit load values from DB again.

<ADD Image of console with loaded values>

This time we get mor errors. In the sample repro code there is a special condition to catch without threoing an error, we can see that in this case when the values are loaded from the IndexedDB, the int values are not type converted correctly and are returned as "2.0" instead of "2", as they were before re-loading the web app and starting it again.

If we hit (+) again and update the value to 3, and hit (Load Values from DB) again, we can see that the value is now "3" as it should be. Again if we restart the app with a page refresh (or Flutter hot restart), the int values are again returned "3.0" and not "3". 


## Used Flutter version

Channel master, ...

<details>
  <summary>Flutter doctor</summary>

```
flutter doctor -v


```

</details>