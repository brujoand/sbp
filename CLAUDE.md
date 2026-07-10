# sbp

Simple Bash Prompt — a powerline-style shell prompt in pure bash (4.3+).
Installed alongside `sbc` by the `dotfiles` repo.

## Hard rules

- **Never push to `main`/`master`.** Feature branch + PR, always. Open the PR,
  report the URL, stop — **only the human merges.**
- **Conventional Commits** (`feat:`, `fix:`, `chore:`, …). Never hand-bump a version.
- **`pre-commit` is the gate.** Run `pre-commit run --files <changed>` before
  declaring a change done, and report the result.
- Plan every non-trivial task. If the plan fails, restart planning.

## Workflow

Default branch is `master`. There is no mise here — `pre-commit` expects
`shellcheck`, `shfmt`, and `bats` as system binaries. CI is
`pull_request_verify.yaml`: an sh-checker lint job plus a test matrix.

## Architecture

`sbp.bash` is the entrypoint. Under `src/`:

- `main.bash`, `configure.bash`, `execute.bash`, `decorate.bash`, `debug.bash`
- `interact.bash` / `interact_themed.bash` — the `sbp` subcommands
  (`sbp edit config`, `sbp reload`, `sbp status`, `sbp list`)
- `segments/` — one file per prompt segment; `layouts/`, `colors/`, `hooks/`

`config/` holds `settings.conf` and `colors.conf` plus their templates. Tests in
`test/` mirror the source layout (`test/segments/`, `test/hooks/`).

## Commands

```bash
bin/run_tests                    # sets SBP_PATH, runs `bats test/`
bats test/segments/git.bats      # single file
bats -f "<pattern>" test/        # single case
bin/ci_test_wrapper <bash-version>   # matrix test in Docker
bin/try_me                       # demo the prompt
pre-commit run --files <changed files>
```

## Gotchas

- **Bash 4.3+ is the floor, and CI proves it.** `pull_request_verify.yaml` runs
  the suite against bash `rc`, `5.0.17`, `4.4.23`, and `4.3.48` in Docker. Avoid
  syntax that only exists in 4.4+ or 5.x.
- `bats` is not installed in the agent environment (`apt-get install bats`, as CI
  does). Without it `bin/run_tests` cannot run.
- `bin/install` appends `SBP_PATH` and a source line to `~/.bashrc`.
- The README's build badge still points at Travis; the real CI is GitHub Actions.
- shellcheck runs with `-e SC1091 -e SC2034 -e SC1090 -e SC2030 -e SC2031`;
  shfmt with `-i 2 -ci -s`.
