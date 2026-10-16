# zigdoc: view documentation for Zig standard library symbols. `just --list`
# shows the recipes. AGENTS.md holds the working conventions.

[private]
default:
    @just --list

[doc("Unit tests. `zig build test` also checks formatting")]
[group("test")]
test:
    zig build test --summary all

[doc("Build the Nix package in the sandbox with no network, and run it. A stale build.zig.zon.nix fails here")]
[group("test")]
package:
    nix build .#zigdoc --print-build-logs
    PATH="$(dirname "$(command -v zig)"):$PATH" ./result/bin/zigdoc std.ArrayList > /dev/null

[doc("Regenerate build.zig.zon.nix, the package's Zig dependencies, after a dependency bump")]
[group("build")]
zon2nix:
    zon2nix --nix=build.zig.zon.nix build.zig.zon

[doc("Lint Zig, Nix, Markdown, the workflows, and this justfile: ziglint, zig fmt, nix fmt, oxfmt, actionlint, zizmor, and just --fmt")]
[group("lint")]
lint:
    ziglint
    zig fmt --check src build.zig build_readme.zig
    nix fmt -- --ci
    oxfmt --check README.md AGENTS.md .github scripts
    actionlint
    zizmor .
    just --fmt --check

[doc("Format everything lint checks")]
[group("lint")]
fmt:
    zig fmt src build.zig build_readme.zig
    nix fmt
    oxfmt README.md AGENTS.md .github scripts
    just --fmt

[doc("Build one release target into the prefix DIR, so the program lands in DIR/bin. The shared release workflow bundles it: the archive name and layout are the org's, not this repo's")]
[group("release")]
release-build TARGET DIR:
    zig build -Doptimize=ReleaseFast -Dtarget={{ TARGET }} --prefix {{ DIR }}

[doc("Tag a release and push the tag, which starts the release workflow. Checks first: a clean tree on main, level with origin")]
[group("release")]
release VERSION:
    #!/usr/bin/env bash
    set -euo pipefail
    test -z "$(git status --porcelain)" || { echo "the tree is not clean" >&2; exit 1; }
    test "$(git branch --show-current)" = main || { echo "not on main" >&2; exit 1; }
    git fetch --quiet origin main
    test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" || { echo "main is not level with origin" >&2; exit 1; }
    git tag -s "v{{ VERSION }}" -m "v{{ VERSION }}"
    git push origin "v{{ VERSION }}"

[doc("Everything CI runs")]
[group("ci")]
ci: test package lint
