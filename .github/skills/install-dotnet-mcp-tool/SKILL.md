---
name: install-dotnet-mcp-tool
description: >
  Install an MCP server that's distributed as a .NET tool NuGet package (e.g. binlog-mcp, NuGet.Mcp.Server) as a project-local dotnet tool, wired into `.mcp.json`. Use when asked to add/install a .NET-based MCP server to this repo, or when `dotnet tool run <cmd>` fails with "Run dotnet tool restore" right after a successful restore.
---

# Install a .NET MCP tool

1. `dotnet tool install --local <PackageId>` – adds it to `.config/dotnet-tools.json`. The command echoes the real invocable command name (e.g. `nuget-mcp-server`, not the package id) – use that, don't guess it.
2. Add an entry to both `.mcp.json` sections (`servers` for VS Code Copilot, `mcpServers` for Claude Code), **alphabetical by key** in each – except when Visual Studio already bundles that MCP server itself (e.g. NuGet, Microsoft Learn), in which case only add it to `mcpServers`:
   ```json
   "<name>": { "type": "stdio", "command": "dotnet", "args": ["tool", "run", "<command>"] }
   ```
   Add any args the server needs (e.g. `--source <url> --yes`) after the command name.
3. Verify by feeding it a real MCP handshake over stdin:
   ```
   echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"probe","version":"1.0"}}}' | dotnet tool run <command>
   ```
   Expect a JSON-RPC `result` back – not silence, not a crash. A server shuts down at the end of its input, and it can do that before it answers: if a one-shot pipe prints nothing, send the line from a process that keeps stdin open until the response arrives (`System.Diagnostics.Process` with `RedirectStandardInput`).
4. Restart the Claude Code session (or run `claude mcp list`) to pick up the `.mcp.json` change – it isn't hot-reloaded.
5. Agents discover servers from `.mcp.json` on their own. Only if the server needs a routing hint its tool descriptions don't convey (when to prefer it over another tool), add a one-line bullet to the "MCP servers" section of `.github/copilot-instructions.md`.

The build of this repository does not restore local dotnet tools. Run `dotnet tool restore` from the repository root after cloning and whenever `.config/dotnet-tools.json` changes, before an MCP host starts the tool.

## Known pitfall

`dotnet tool run <cmd>` (and the `dotnet <cmd>` shorthand) can fail with `Run "dotnet tool restore" to make the "<cmd>" command available` even right after a successful restore, whenever `NUGET_PACKAGES` points anywhere other than the default `%USERPROFILE%\.nuget\packages` – `dotnet tool restore` always bakes that *default* path into `%USERPROFILE%\.dotnet\toolResolverCache`, ignoring the env var. Open, unfixed SDK bug: [dotnet/sdk#11432](https://github.com/dotnet/sdk/issues/11432).
