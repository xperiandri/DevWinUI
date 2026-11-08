---
description: 'Guidelines for writing C# in DevWinUI'
language: C#
applyTo: '**/*.cs,**/*.csx'
---

# C# Development

## C# Instructions

* Always use the latest version C#, currently C# 14 features (`LangVersion` is `Latest` in `Directory.Build.props`).
* Follow the style of the surrounding code and `.editorconfig`: the libraries have long-established conventions, and a new file must look like its neighbors.

## General Instructions

* Make only high confidence suggestions when reviewing code changes.
* Write code with good maintainability practices, including comments on why certain design decisions were made.
* Handle edge cases and write clear exception handling.
* For libraries or external dependencies, mention their usage and purpose in comments.

## Naming Conventions

* Follow PascalCase for type names, method names, constants, and public members.
* Use `_camelCase` for private fields (`_canvas`) and camelCase for local variables and parameters.
* Prefix interface names with "I" (e.g., IUserService).

## Formatting

* Apply code-formatting style defined in `.editorconfig`.
* Use file-scoped namespace declarations (`.editorconfig` reports a block-scoped namespace as a warning) and single-line using directives.
* Insert a newline before the opening curly brace of any code block (e.g., after `if`, `for`, `while`, `foreach`, `using`, `try`, etc.).
* Ensure that the final return statement of a method is on its own line.
* Use pattern matching and switch expressions wherever possible.
* Use `nameof` instead of string literals when referring to member names.
* Ensure that XML doc comments are created for any public APIs. When applicable, include `<example>` and `<code>` documentation in the comments. The details of the documentation rules are in `dotnet.instructions.md`.

## Nullable Reference Types

* Nullable reference types are not enabled project-wide (warning CS8632 is suppressed in `Directory.Build.props`), so a `?` on a reference type is documentation only and the compiler does not check it. Annotate public API the way the surrounding code does, and do not switch nullability on for a whole project.
* Nothing enforces non-nullability, so check for `null` at the public entry points and in the code that works with a template part, where a missing value would crash.
* Always use `is null` or `is not null` instead of `== null` or `!= null`.
