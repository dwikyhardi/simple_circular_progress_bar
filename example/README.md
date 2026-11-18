# Simple circular progress bar example

Uses the extracted `material_ui` library. Requires Flutter >=3.47.0 and
Dart >=3.13.0; the repository pins FVM Flutter 3.50.0.

From this directory:

```sh
fvm flutter pub get
fvm flutter run
```

The home screen opens two demos:

- Progress bar examples: colors/gradients, angles, stroke widths, merge mode,
  animation duration, and text or custom center widgets.
- Value notifier example: submit a numeric value to animate the progress bar.

Run `fvm flutter analyze` and `fvm flutter test` to check the example and its
navigation/notifier interactions. These widget tests do not verify device builds.
