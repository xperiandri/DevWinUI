# Copilot Instructions

## Project details

* DevWinUI – WinUI 3 controls, styles, helpers, Win2D and Composition effects, shaders, a Roslyn source generator, the Gallery sample app and Visual Studio templates
* .NET 10 (Release builds of the libraries also target .NET 8 and .NET 9)
* C# 14 (`LangVersion` is `Latest`)
* WinUI 3 on the Windows App SDK, Windows 10 version 1809 (10.0.17763) and newer
* Native AOT compatible
* Nullability checks are not enabled project-wide

The upstream repository is `ghost1372/DevWinUI`. Read `docs/CONTRIBUTING.md` before you change the libraries.

If you receive a GitHub link, you must use GitHub MCP tools to retrieve its content and perform additional code search.

## Shell operations

Always prefer PowerShell for all shell operations. Always prefer installing PowerShell modules over installing CLI tools.

## MCP servers

The servers are configured in `.mcp.json`:

* `GitHub` – repositories, issues, pull requests and code search. Use it to read the source of the Windows App SDK, WinUI and Win2D.
* `Microsoft Learn` – official documentation of .NET, WinUI 3 and the Windows App SDK. Prefer it over guessing an API or a piece of XAML syntax.
* `MSBuild Log` – reads MSBuild binary logs (`dotnet build -bl`) to find why a build failed or got slow.
* `nuget` – use it instead of querying the NuGet API by hand when checking the latest versions of packages.

`MSBuild Log` and `nuget` run as local dotnet tools from `.config/dotnet-tools.json`. The build does not restore them: run `dotnet tool restore` from the repository root after cloning and whenever the manifest changes.

When adding or changing a server in `.mcp.json`, follow the `install-dotnet-mcp-tool` skill rules: keep `servers` (Visual Studio / VS Code / GitHub Copilot) and `mcpServers` (Claude Code) in sync and alphabetical by key, except for servers Visual Studio already bundles itself (e.g. NuGet, Microsoft Learn) – those only go in `mcpServers`.

## Language/platform instructions

Core coding rules are defined in:

* `.github/instructions/csharp.instructions.md`
* `.github/instructions/dotnet.instructions.md`
* `.github/instructions/winui.instructions.md`
* `.github/instructions/xaml.instructions.md`
* `.github/instructions/gallery.instructions.md`

## Skills

Local reusable skills are defined in `.github/skills`:

* `cavecrew`
* `caveman`
* `caveman-commit`
* `caveman-compress`
* `caveman-help`
* `caveman-review`
* `caveman-stats`
* `install-dotnet-mcp-tool`

When task matches a skill domain, load and follow that skill instructions first.

Claude Code finds the skills through the local `.claude/skills` link to `.github/skills`. The link is git-ignored: create it after cloning with `pwsh -NoProfile -File .claude/scripts/Link-ClaudeSkills.ps1`.

## Code Style and Standards

* All comments, documentation, README files, and markdown files must be written in English only.
* When rendering a table, always put a line break between `||` characters.
* Do not use an em dash (—) as a punctuation dash; use an en dash (–) instead.
* In markdown files, do not manually hard-wrap paragraph text onto multiple lines; write each paragraph as a single line.

## Coding instructions

* During implementation, if you need types or members defined in another project that is not referenced:
  1. Stop implementation.
  2. Respond with a summary of what is needed and where it is defined.
  3. Ask if you can add the reference before continuing.
* Never duplicate code unless you receive explicit confirmation that duplication is allowed.

## Acceptance criteria

* Builds without errors. Build the affected projects in Debug, with the command from `dotnet.instructions.md`. Do not run Release builds: they target three frameworks and write NuGet packages to `Output/`.
* The repository has no automated tests. Check a UI change in the Gallery app (`dev/DevWinUI.Gallery`), or, when you cannot run it, state what has to be checked by hand.
* If acceptance criteria are not met, collect and report all relevant build error details.

## Response format

* Respond terse like smart caveman. All technical substance stay. Only fluff die.

* Rules:
  1. Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
  2. Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
  3. Pattern: [thing] [action] [reason]. [next step].
  4. Not: "Sure! I'd be happy to help you with that."
  5. Yes: "Bug in auth middleware. Fix:"
  6. Switch level: /caveman lite|full|ultra|wenyan Stop: "stop caveman" or "normal mode"

* Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

* Boundaries: code/commits/PRs written normal.

* By default, use "full" level. Switch with `/caveman [level]`. Level persists until changed or session end.

## Solution structure

```text
/
├── dev
│   ├── DevWinUI – controls library: custom controls, styles, converters, Win2D and Composition controls (references DevWinUI.Base)
│   │   ├── Controls (Native, Ported, Win2DAndComposition)
│   │   ├── Themes (Styles, ItemTemplate, generated Generic.xaml)
│   │   ├── Converters, Common, CompositionProToolkit, LandingPages
│   │   └── build – NuGet package targets
│   ├── DevWinUI.Base – core library: attached properties, helpers, extensions, services, native methods; no XAML
│   ├── DevWinUI.ContextMenu – context menu library for WinUI, WPF and other hosts, with a binary-only host DLL
│   ├── DevWinUI.Shader – ComputeSharp shader controls (references DevWinUI.Base)
│   ├── DevWinUI.SourceGenerator – Roslyn source generators (netstandard2.0)
│   └── DevWinUI.Gallery – sample app (references DevWinUI and DevWinUI.Shader)
├── VSIX – Visual Studio project and item templates
├── docs – contribution guide, migration notes, policies, third-party notices
├── tools – shared assets, XAML Styler settings, AppData JSON schema
├── Output – generated build output and NuGet packages (git-ignored)
├── Directory.Build.props – central build configuration, versions and target frameworks
└── DevWinUI.slnx – solution
```
