# README.md
## Project Overview

A software project consisting of **20** source files spanning .swift, .cpp, .txt, .h, .yaml, .md. Documentation generated locally from file metadata (no remote AI).


## Features

- Command-driven CLI architecture
- Automated documentation generation
- GitHub repository integration
- Local fallback mode (no API required)


## File Structure

- `windows/runner/win32_window.cpp` — 289 lines · 31 fn · 0 imports
- `windows/runner/utils.cpp` — 66 lines · 12 fn · 0 imports
- `windows/runner/flutter_window.cpp` — 72 lines · 12 fn · 0 imports
- `windows/runner/win32_window.h` — 103 lines · 5 fn · 0 imports
- `README.md` — 316 lines · 0 fn · 0 imports *(large)*
- `macos/Flutter/GeneratedPluginRegistrant.swift` — 21 lines · 1 fn · 7 imports
- `windows/CMakeLists.txt` — 109 lines · 1 fn · 0 imports
- `pubspec.yaml` — 98 lines · 0 fn · 0 imports
- `windows/runner/main.cpp` — 44 lines · 3 fn · 0 imports
- `linux/CMakeLists.txt` — 129 lines · 1 fn · 0 imports
- `ios/RunnerTests/RunnerTests.swift` — 13 lines · 1 fn · 3 imports
- `macos/RunnerTests/RunnerTests.swift` — 13 lines · 1 fn · 3 imports


# Architecture

Command-driven single-responsibility modules under `commands/`.
An entry-point CLI (`index.js`) delegates to commands.

### Top modules (by heuristic score)

- **windows/runner/win32_window.cpp** — complexity: 21, exports: 0
- **windows/runner/utils.cpp** — complexity: 9, exports: 0
- **windows/runner/flutter_window.cpp** — complexity: 7, exports: 0
- **windows/runner/win32_window.h** — complexity: 10, exports: 0
- **README.md** — complexity: 16, exports: 0
- **macos/Flutter/GeneratedPluginRegistrant.swift** — complexity: 0, exports: 0
- **windows/CMakeLists.txt** — complexity: 8, exports: 0
- **pubspec.yaml** — complexity: 10, exports: 0
- **windows/runner/main.cpp** — complexity: 4, exports: 0
- **linux/CMakeLists.txt** — complexity: 7, exports: 0
- **ios/RunnerTests/RunnerTests.swift** — complexity: 1, exports: 0
- **macos/RunnerTests/RunnerTests.swift** — complexity: 1, exports: 0


# Onboarding

1. Clone the repository: `git clone <repo-url>`
2. Install dependencies: `npm install`
3. (Optional) Link globally: `npm link`
4. Configure API key: `cdx config`
5. Generate docs: `cdx create README.md`


# Usage

```bash
cdx create README.md       # Generate full documentation
cdx create docs.md --all   # Include hidden files
cdx config                 # Set Gemini API key
cdx start                  # Interactive UI
```


# Security

- **No raw source code** is transmitted in local fallback mode.
- API keys stored in `~/.mycli-config.json` with `0o600` permissions.
- Sensitive files (`.env`, private keys, credentials) are excluded from AI payloads.
- GitHub tokens are redacted before any network call.
- Review and rotate credentials regularly.
