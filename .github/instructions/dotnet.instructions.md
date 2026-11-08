---
description: 'Guidelines for building the .NET libraries of DevWinUI'
language: C#
applyTo: '**/*.cs,**/*.csx'
---

# .NET Development

The repository does not use central package management and has no `Directory.Packages.props`. The versions of the shared dependencies are MSBuild properties in `Directory.Build.props` (`WASDKWinUIVersion`, `Win2dVersion`, `CsWin32Version`, `ComputeSharpVersion`, `XAMLToolsVersion`), and a project file refers to them as `Version="$(Win2dVersion)"`. To change such a version, change the property. A package that only one project uses is pinned in that project file.

## Libraries we use

If you need any source code you can find it in the following repositories:

* [Windows App SDK](https://github.com/microsoft/WindowsAppSDK)
* [WinUI 3](https://github.com/microsoft/microsoft-ui-xaml)
* [Win2D](https://github.com/microsoft/Win2D)
* [CsWin32](https://github.com/microsoft/CsWin32)
* [ComputeSharp](https://github.com/Sergio0694/ComputeSharp)

Use GitHub MCP tools for code search, and the `Microsoft Learn` server for the documentation of .NET and Windows APIs.

## General Instructions

* Make only high confidence suggestions when reviewing code changes.
* Write code with good maintainability practices, including comments on why certain design decisions were made.
* Handle edge cases and write clear exception handling.
* For libraries or external dependencies, mention their usage and purpose in comments.
* Write clear and concise comments for each function.
* Avoid repeated expensive/member-chain calls; cache intermediate values locally.

## Building

* Build and check in Debug. A Debug build targets only `net10.0-windows10.0.19041.0` (`DevWinUI.Shader` and the Gallery use `net10.0-windows10.0.28000.0`). A Release build targets .NET 8, 9 and 10 and packs the NuGet packages into `Output/` (`GeneratePackageOnBuild`), so do not run it unless the task is about packaging.
* Always pass `-c Debug` (or `-c Release`) to `dotnet build`, and `-p:Configuration=Debug` to `dotnet restore`: `Directory.Build.props` picks the target frameworks by `Configuration`, and without it the project has no target framework (NETSDK1241 or NETSDK1013).
* `OutputPath` of the libraries is `$(SolutionDir)Output\`. A project that is built alone has an empty `SolutionDir`, and its output lands in an `Output` folder inside the project folder, which git does not ignore. So pass the repository root yourself when you build a project from the command line, and run the command from the repository root:

  ```powershell
  dotnet build dev/DevWinUI/DevWinUI.csproj -c Debug "-p:SolutionDir=$PWD\"
  ```

* The Gallery declares only the platforms `x86`, `x64` and `ARM64`: build it with `-p:Platform=x64`, or from Visual Studio.
* The Gallery needs the Windows SDK 10.0.28000 itself, not only the NuGet projection (`C:\Program Files (x86)\Windows Kits\10\Platforms\UAP\10.0.28000.0\Platform.xml`). Without it the build stops with `Could not read the Windows SDK's Platform.xml`, and the XAML compiler then adds misleading errors such as `WMC0001 Unknown type 'SampleCodePresenter'` and `WMC9999`. Install the SDK instead of changing the XAML; the library projects do not need it.
* The .NET SDK does not know Windows SDK 10.0.28000 yet (dotnet/sdk#55834) and rejects it with NETSDK1140. The group with `UseWindowsSDKPreview` and `WindowsSdkPackageVersion` in `Directory.Build.props` is the workaround for the Gallery and the Debug build of `DevWinUI.Shader`: keep it until the SDK accepts 10.0.28000. The GitHub `windows-latest` image has no Windows SDK 10.0.28000, so the Gallery cannot be built there.
* After you switch between Debug and Release, close Visual Studio and run `Clean-obj-bin.bat`.
* The versions of the libraries (`LibraryMajorVersion`, `DevWinUI_*_MinorVersion`, `DevWinUI_*_PatchVersion`, `IsPreviewBuild`, `PreviewLabel`) are in `Directory.Build.props`. Do not change them unless the task is a version bump.
* Do not commit the `ItemGroup` lines (`Removed`, `Included` and so on) that the IDE adds to a `.csproj` file.

## Documentation comments

* Ensure that XML doc comments are created for any public APIs. When applicable, include `<example>` and `<code>` documentation in the comments. Always use `<see cref="ReferencedType"/>` tags for references to other types or members. Always use tags like `<see langword="null"/>` for references to a single reserved language keyword; a multi-word syntax shape (`await foreach`, `yield return`) or a construct from a different language than the one being documented isn't a `langword` target – keep it as `<c>`.
* On an explicit interface implementation, write `/// <inheritdoc />` alone instead of restating the interface member's documentation, unless this implementation has behavior worth calling out beyond what the interface already documents – write a normal `<summary>`/`<remarks>` there instead.
* Split multi-paragraph documentation into `<para>` elements, in `<summary>` and in `<remarks>` alike. A long comment can keep in `<summary>` what the member is or does and move the details to `<remarks>`. Never rely on bare line breaks, as the documentation renderers collapse them.
* Write enumerations as structured XML list markup – `<list type="bullet">` (or `type="number"`) with `<item><description>…</description></item>` – never as manually broken lines or Markdown-style `-`/`*` bullets.
* If the body of a member throws an exception itself (a `throw` statement or expression, a check of an argument or of the state), add an XML comment about it to the member: an `<exception cref="ExceptionType">` that says when the exception is thrown, one for each exception type. This includes an exception that the body lets out from a call that documents it, for example the `FormatException` of `Int32.Parse`.
* The same applies to XAML-facing documentation: `DependencyProperty` and attached property declarations, behaviors and custom controls.

## Global usings

* `ImplicitUsings` is on for every project. The `DevWinUI`, `DevWinUI.Base`, `DevWinUI.ContextMenu` and Gallery projects keep their shared `global using` directives in a `GlobalUsings.cs`: add a namespace that many files of such a project need there, and not to each file or as an MSBuild `<Using>` item.
