---
description: 'Guidelines for authoring controls and helpers in the DevWinUI libraries'
language: C#, XAML
applyTo: 'dev/DevWinUI/**/*.cs,dev/DevWinUI.Base/**/*.cs,dev/DevWinUI.Shader/**/*.cs,dev/DevWinUI.ContextMenu/**/*.cs'
---

# DevWinUI library conventions

`docs/CONTRIBUTING.md` is the contribution guide of the project. This file is its short form for agents; where the two disagree, the code that is in the repository now wins.

## Projects and layering

* `DevWinUI.Base` – the core library: attached properties, common code, extensions, helpers, native methods, services and managers. It has no XAML and no theme files, and it references no other project.
* `DevWinUI` – the controls library: custom controls, styles, brushes, converters, Win2D and Composition controls. It references `DevWinUI.Base`.
* `DevWinUI.Shader` – ComputeSharp based shader controls. It references `DevWinUI.Base`.
* `DevWinUI.ContextMenu` – the context menu library for WinUI, WPF and other hosts. It is built without WinUI (`UseWinUI` is off for it) and uses the binary-only `ContextMenuCustomHost.dll` because of licensing. Never edit or remove that file.
* `DevWinUI.SourceGenerator` – Roslyn generators that target `netstandard2.0`. They are not WinUI code and not AOT code. The Gallery takes the generator from NuGet (a `PackageReference`), not from this project, so a change here does not show in the Gallery until a package is published.

## Namespace

* All code of the libraries uses the single root namespace `DevWinUI`, whatever the depth of the folder: `namespace DevWinUI;`. Do not add sub-namespaces such as `DevWinUI.Controls` or `DevWinUI.Helpers`.
* In XAML declare `xmlns:local="using:DevWinUI"`.
* Shared `global using` directives of a project are in its `GlobalUsings.cs`; check it before adding a `using` to a file.

## Native AOT

* The libraries are Native AOT compatible (`IsAotCompatible`), and the README promises it. Mark every control and helper class `partial`.
* Do not use reflection, `dynamic`, runtime code generation or any other indirect access to a type. A new AOT or trimming warning is a regression.

## Controls

* Declare a control as `public [sealed] partial class Name : Control`, set `DefaultStyleKey = typeof(Name);` in the constructor, and declare each part of the template with `[TemplatePart]` and a `private const string ...PartName = "PART_...";`.
* Declare a dependency property by hand next to its CLR wrapper, with `nameof` for the name. A control with many properties keeps them in the `Name.Properties.cs` partial file. The repository does not use generated dependency properties.

  ```csharp
  public int Lanes
  {
      get { return (int)GetValue(LanesProperty); }
      set { SetValue(LanesProperty, value); }
  }

  public static readonly DependencyProperty LanesProperty =
      DependencyProperty.Register(nameof(Lanes), typeof(int), typeof(MotionWall), new PropertyMetadata(4, OnSettingsChanged));
  ```

* A control that has several files gets its own folder: `Name.cs`, `Name.Properties.cs`, `Enums/`, `Internals/`.
* Put a new control into one of the folders of `dev/DevWinUI/Controls`: `Native` for the controls written for this library, `Win2DAndComposition` for the controls that draw with Win2D or the Composition API, `Ported` for code ported from other open-source projects. `docs/CONTRIBUTING.md` still names the folders `Controls/` and `Others/`; they do not exist now.
* Keep the license header of a ported file as it is, and list the source and the license of new third-party code in `docs/ThirdPartyNotices.txt`. The XAML of a ported control stays next to its code in `Controls/Ported`, not in `Themes/Styles`.
* The style of a control is a separate XAML file; see `xaml.instructions.md`. A new control also needs a sample page in the Gallery; see `gallery.instructions.md`.

## Resources and threads

Recent fixes in this repository are mostly about leaks and per-frame cost, so check these on every change of a drawing or animated control:

* Win2D and Composition objects (`CanvasBitmap`, `CanvasRenderTarget`, brushes, effects, `CompositionObject`s) hold native memory. Dispose or release them when the control unloads or when the input that produced them changes.
* Remove every event handler, timer and subscription that the control adds on `Loaded` or in `OnApplyTemplate` when it unloads, and add them again on the next `Loaded`.
* Do not allocate in a draw or per-frame handler: keep brushes, formats, arrays and lists in fields and reuse them.
* Touch XAML objects only on the `DispatcherQueue` of the control.
