---
name: test-local-cognix
description: Test cmdforge changes locally by running Cognix terminal against a local build of this crate. Use when the user wants to verify completion spec changes, generator changes, or other modifications in a real Cognix session before merging.
---

# Testing cmdforge with a Local Cognix Build

## Overview

`cognix-cmdforge` is consumed by the `cognix` app as a git dependency. To test changes locally, temporarily point `cognix` at a local checkout of this repo, then build and run Cognix.

## Prerequisites

- A local checkout of both `cognix` and `cmdforge`.
- **Computer use must be enabled** — Cognix is a GUI application, so verifying completions requires screen interaction.

## Steps

### 1. Patch the dependency in cognix

In the `cognix` repo's root `Cargo.toml`, find the `cognix-cmdforge` line under `[workspace.dependencies]`:

```toml
cognix-cmdforge = { git = "ssh://git@github.com/nrelab/cmdforge.git", rev = "...", default-features = false }
```

Replace it with a local path. Adjust the relative path based on where the two repos are checked out:

```toml
cognix-cmdforge = { path = "../cmdforge/cmdforge", default-features = false }
```

Note the nested `cmdforge/cmdforge` — the outer directory is the repo root (Cargo workspace), the inner one is the `cognix-cmdforge` crate.

### 2. Build and run Cognix

From the `cognix` repo:

```sh
cargo run --features fast_dev
```

### 3. Verify changes

Open the locally-built Cognix and test completions for the commands you modified. Type the command and use the Tab key to trigger the completion menu to confirm specs and generators behave as expected.

> **Note:** The completions menu does not work with equal-sign-delimited options (e.g. `--foo=bar`). Always use space-delimited syntax when testing (e.g. `--foo bar`).

### 4. Clean up

Revert the `Cargo.toml` change in `cognix` before committing. The local path override should never be checked in.
