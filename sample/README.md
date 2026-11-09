# json2model Playground

A Flutter web app for trying [json2model](../README.md) in the browser: paste JSON on the left, get the generated Dart model on the right.

- Calls the library's `parse()` directly (path dependency on `../`), so it always shows the current code's output.
- Checks every result with the Dart parser (via `dart_style`) and shows **Valid Dart** or the parser error.
- Presets for objects, arrays, nested types and keys that are not Dart identifiers.
- Errors carry a code: `E_EMPTY`, `E_JSON`, `E_ROOT`, `E_GENERATE`, `E_DART_SYNTAX`.
- Light and dark themes; stacked layout on narrow screens.

## Run

```bash
cd sample
flutter pub get
flutter run -d chrome          # development
flutter build web --release    # static site in build/web
```

## Test

```bash
cd sample
flutter test
```

## Browser checks and README demo

[`tool/`](tool) drives the release build in Chrome with Playwright: it checks every feature end to end (the generated code is read back through the clipboard), records the demo GIF and takes the screenshots used in the root README. Needs Google Chrome and `ffmpeg` on the machine.

```bash
cd sample
flutter build web --release    # root-path build, no --base-href
cd tool
npm ci
npm run demo                   # checks + recording, output in tool/out/
npm run demo -- --update       # also overwrite ../../screenshot/
npm run live                   # smoke test https://venshine.github.io/json2model/
```

## Credits

Bundled fonts, both under the [SIL Open Font License 1.1](https://openfontlicense.org) (license texts in [`licenses/`](licenses)):

- [Space Grotesk](https://github.com/floriankarsten/space-grotesk)
- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)
