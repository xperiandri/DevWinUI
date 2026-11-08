---
description: 'Guidelines for the DevWinUI Gallery sample app'
language: XAML, C#
applyTo: 'dev/DevWinUI.Gallery/**'
---

# DevWinUI Gallery

The Gallery (`dev/DevWinUI.Gallery`, namespace `DevWinUIGallery`) shows every control of the libraries. It is a WinUI app for `x86`, `x64` and `ARM64` that targets `net10.0-windows10.0.26100.0` and is published with Native AOT, so the Native AOT rules of `winui.instructions.md` apply to it as well. It references `DevWinUI` and `DevWinUI.Shader` as projects.

## Adding a sample page

1. Add `NamePage.xaml` and `NamePage.xaml.cs` to `Views/Pages/<Category>/`. The categories are the folders there now: `Common`, `Composition`, `Features`, `LandingsPage`, `Settings` and `Win2d`. The class is `DevWinUIGallery.Views.NamePage`, and the code-behind uses `namespace DevWinUIGallery.Views;`.
2. Lay the page out like the existing ones: a `ScrollViewer` with a `StackPanel Margin="10" dev:PanelAttach.ChildrenTransitions="Default" Spacing="10"` that holds one `local:ControlExample` for each sample.
   * `HeaderText` names the sample.
   * `DocPage` is the path of the control page on the documentation site (`controls/motionwall`), which the Gallery opens in the browser.
   * `XamlSource` and `CSharpSource` are the paths of the snippet files relative to `ControlPagesSampleCode/`.
   * The controls that change the sample go into `<local:ControlExample.Pane>`.
   * The page declares `xmlns:dev="using:DevWinUI"` and `xmlns:local="using:DevWinUIGallery"`.
3. Put the snippets that the page shows into `ControlPagesSampleCode/<Category>/<Name>/NamePage_xaml.txt` and `NamePage_cs.txt`. The app includes them as content.
4. Register the page in `Assets/NavViewMenu/AppData.json`, in the group that suits it.
   * `UniqueId` is the full name of the page class (`DevWinUIGallery.Views.NamePage`). The file is an `AdditionalFiles` input of the navigation source generator of `DevWinUI.SourceGenerator`, which maps the `UniqueId` to the page type, so a wrong `UniqueId` breaks the navigation.
   * `IsNew` is `true` for a new control and `IsUpdated` is `true` for a changed one.
   * `ImagePath` is an icon of `Assets/Fluent` (`ms-appx:///Assets/Fluent/ProgressBar.png`).
   * `tools/AppData.Schema.json` is the schema of the file.
5. Rebuild, and remove the `ItemGroup` lines (`Removed`, `Included` and so on) that the IDE adds to `DevWinUI.Gallery.csproj`.
