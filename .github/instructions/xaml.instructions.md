---
description: 'Guidelines for writing XAML in DevWinUI'
language: XAML
applyTo: '**/*.xaml'
---

# XAML

## Formatting

* Format every new or changed XAML file with [XAML Styler](https://marketplace.visualstudio.com/items?itemName=TeamXavalon.XAMLStyler2022) and the settings in `tools/settings.xamlstyler` (it formats on save). The styler orders the attributes and decides the line breaks, so do not hand-format against its output.
* Indent XAML with 4 spaces.

## Library styles (`dev/DevWinUI/Themes/Styles/**`)

* A style file is a `ResourceDictionary` and nothing else: no `x:Class`, no code-behind. `XAMLTools.MSBuild` combines `Themes/Styles/**/*.xaml` and `Controls/Ported/**/*.xaml` into `Themes/Generic.xaml` during the build of `DevWinUI`.
* Never edit `Themes/Generic.xaml` by hand and never put an implicit style straight into it. Build the `DevWinUI` project, then commit the regenerated file together with the style that changed it.
* A build can regenerate `Themes/Generic.xaml` with the combined files in another order (for example `X_themeresources.xaml` before `X.xaml`), so `git status` shows the file as modified after any build. When `git diff` shows only moved blocks and no change of a style, restore the file with `git checkout -- dev/DevWinUI/Themes/Generic.xaml` instead of committing the noise.
* The style of a control is in `Themes/Styles/Controls/`, in a file named after the control (`MotionWall.xaml`). `Themes/Styles/CommonStyles/` holds the restyled stock controls (`Button.xaml`, `ComboBox.xaml`, ...) and the shared resources.
* Declare a style twice: a keyed default style and an implicit style based on it. The constructor of the control sets `DefaultStyleKey`.

  ```xml
  <Style x:Key="DefaultMotionWallStyle" TargetType="local:MotionWall">
      <!-- Setters and the control template -->
  </Style>

  <Style BasedOn="{StaticResource DefaultMotionWallStyle}" TargetType="local:MotionWall" />
  ```

* Put the colors and brushes of a control into `ResourceDictionary.ThemeDictionaries` with the entries `Default`, `Light` and `HighContrast`, and start each key with the name of the control (`MotionWallTileBackground`). Alias the system resources with `StaticResource` and use the keys with `ThemeResource` in the setters so that the control follows a theme change. The `HighContrast` entry uses the `SystemColor...` resources.
* Declare `xmlns:local="using:DevWinUI"` and use the `local:` prefix for the types of the library.
