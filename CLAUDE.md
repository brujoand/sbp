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
- **Prompt latency outranks features and brevity.** The shell accepts no input
  until the prompt has rendered. See "Prompt latency" below.

## Prompt latency

`main.bash` waits for every segment with no timeout, so the slowest segment sets
the render time and a hung segment hangs the shell. On a Linux host a render
takes about 10 ms with one trivial segment and about 40 ms with the default
config. These rules cover the render path: `_sbp_set_prompt`, `src/main.bash`,
`configure::load_config`, segments and layouts.

1. **Nothing of unbounded latency runs in the foreground.** That covers network
   calls, credential CLIs and cloud tools. Read a cache, print it, and hand the
   refresh to `execute::execute_nohup_function`.
2. **Return early.** Put the cheapest test that can hide the segment first.
3. **A builtin beats a fork.** Each `$(...)` or external command costs about 1 ms
   on Linux, on every prompt.
4. **Measure render path changes** and report before and after. Runs differ by
   several ms, so compare repeated runs:

   ```bash
   export SBP_PATH=$PWD SBP_TMP=$(mktemp -d) COLUMNS=200
   time (for i in {1..20}; do bash src/main.bash 0 0 >/dev/null; done)
   ```

| Instead of | Use |
| --- | --- |
| `v=$(cat f)` | `read -r v <f` or `mapfile -t a <f` |
| `$(date +%s)` | `_sbp_get_current_time v` |
| `$(date +fmt)` | `printf -v v '%(fmt)T' -1` |
| `basename`, `dirname`, `sed s///` | `${p##*/}`, `${p%/*}`, `${v//a/b}` |
| `grep`, `awk`, `cut` on a value | `[[ $v =~ re ]]` with `BASH_REMATCH`, `IFS=: read -r` |
| `tr`, `wc -l` | `${v^^}`, `${v,,}`, `${#a[@]}` |
| `stat` for cache age | an epoch stored in a file, read with `read` |
| `which x` | `command -v x` |
| `v=$(internal_fn)` | a nameref out-parameter |

`timestamp` and `terraform` fork on every render: do not copy them. `aws`
is the model for a segment that reads the environment, and `wttr` for a cached
background refresh, apart from its `stat` call.

## Bash conventions

- **Bash 4.3 syntax only.** Not available: `${v@Q}` and the other `${v@...}`
  forms, `mapfile -d`. `EPOCHSECONDS` and `EPOCHREALTIME` need a fallback, which
  `_sbp_get_current_time` provides.
- **macOS is supported.** No GNU-only flags (`grep -P`, `stat -c`, `date +%N`).
- **Names:** `module::function`, with `segments::<name>` and `hooks::<name>`.
- **Return values through a nameref:** `local -n <function>_result=$1`. The
  function-specific name prevents a circular reference when the caller's variable
  has the same name. See `execute::get_script`.
- **`local` every variable** in a function, and use `[[ ]]` for tests.
- **`command rm`** (or `command <tool>`) in `sbp.bash` and tests, because the
  user's aliases apply in an interactive shell.

## Segment contract

- `src/segments/<name>.bash` defines `segments::<name>`. It is sourced on every
  render, inside a background subshell of `bash src/main.bash`. Shell variables
  do not persist between renders, and only exported variables are visible.
- **stdout is parsed:** line 1 is the length and line 2 the value. Write to it only
  through `print_themed_segment 'normal'|'highlight' <parts...>`. Printing nothing
  hides the segment.
- **stderr reaches the terminal,** `debug::log` included. Silence expected
  failures.
- **Width is `${#part}`,** so a double-width emoji misaligns the right side. Use
  narrow glyphs for default icons, and respect `SEGMENTS_MAX_LENGTH`.
- **Cache location:** `$SEGMENT_CACHE` is global to all shells. State that differs
  per shell or terminal belongs in `$SBP_TMP`.
- **Register a segment** in four places: default colors in `config/colors.conf`
  (`SEGMENTS_<NAME>_COLOR_PRIMARY`, `_SECONDARY`, and `_HIGHLIGHT` variants if it
  highlights), settings in `config/settings.conf` and its template, docs in
  `src/segments/README.md`, and tests in `test/segments/<name>.bats`.

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
bin/run_tests                    # sets SBP_PATH, runs `bats --recursive test/`
bats test/segments/git.bats      # single file
bats -f "<pattern>" test/        # single case
bin/ci_test_wrapper <bash-version>   # matrix test in Docker
bin/try_me                       # demo the prompt
pre-commit run --files <changed files>
```

## Gotchas

- **Bash 4.3+ is the floor, and CI proves it.** `pull_request_verify.yaml` runs
  the suite against bash `rc` (non-blocking), `5.3.20`, `4.4.23`, and `4.3.48` in
  Docker, and on macOS with Homebrew's bash. Avoid syntax that only exists in 4.4+
  or 5.x.
- `bats` is not installed in the agent environment and the agent has no root, so
  `apt-get install bats` needs the human. Without it `bin/run_tests` cannot run.
- `bin/install` appends `SBP_PATH` and a source line to `~/.bashrc`.
- The README's build badge still points at Travis; the real CI is GitHub Actions.
- shellcheck runs with `-e SC1091 -e SC2034 -e SC1090 -e SC2030 -e SC2031`;
  shfmt with `-i 2 -ci -s`.
