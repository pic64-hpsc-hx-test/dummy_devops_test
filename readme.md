# devops_dummy_project

A small C project used to validate HPSC CI infrastructure changes before they go to the real HPSC
repositories. Its first use is the **merge train** (HPSC-9198): its Jenkins jobs copy the
`p64h_sysc` / `p64h-sysc_regression` setup, so a train validated here can be applied to p64h-sysc as is.

## What is in it

| Path | What it stands in for in p64h-sysc |
|------|------------------------------------|
| `src/` (`dummy_app`, a calculator) | the firmware / tools sources |
| `gen_data/logs.yaml` → `src/generated/logs.[ch]` (`tools/gen_logs.py`) | the logs registry (`logs.yaml` → `p64h_sysc_logs.c/.h`), the main merge conflict source. Both generated files are committed. |
| `tests/unit/` | unit tests in the build job |
| `tests/regression/` | the regression job (`run_regression.sh`, JUnit output) |
| `Jenkinsfile` | `Jenkinsfile` (job `hpsc/devops_dummy_project`, like `hpsc/p64h_sysc`) |
| `Jenkinsfile_Regression` | `Jenkinsfile_SysC_Regression` (job `hpsc/devops_dummy_project_regression`) |
| `ci/Jenkinsfile_MergeTrain` | the merge train job for `main` (`hpsc/devops_dummy_project_merge_train-main`) |

## Build locally

    make all unit-tests            # build + unit tests
    make check-generated           # logs.yaml and src/generated/ agree
    REGRESSION_SECONDS=0 make regression
    python3 tools/gen_logs.py      # after editing gen_data/logs.yaml

## Adding a log message

Add a `- name:` block to `gen_data/logs.yaml`, run `tools/gen_logs.py`, and commit both generated
files. The build fails if they are out of date (`make check-generated`).

## Simulation knobs

To stage merge train scenarios without touching code:

| Knob | Where | Effect |
|------|-------|--------|
| `[sim-fail-build]` | any commit message of the PR | the build job fails |
| `[sim-fail-regression]` | any commit message of the PR | the regression fails (FAILURE) |
| `[sim-unstable-regression]` | any commit message of the PR | the regression is UNSTABLE (shows FAILED in Bitbucket, as in p64h-sysc) |
| `BUILD_SECONDS` | `ci/sim.env` | extra build time (default 30 s) |
| `REGRESSION_SECONDS` | `ci/sim.env` | extra regression time (default 60 s) |
| `FLAKY_PERCENT` | `ci/sim.env` | chance that the regression fails at random |

A real conflict: two PRs that each add an entry at the end of `gen_data/logs.yaml`.
A semantic break the file check cannot see: one PR renames `calc()`, another adds a call to it.

## How a PR gets merged (merge train)

1. Push, open the PR. The PR build runs (it is gated on one approval, as in p64h-sysc).
2. Get an approval, then **enable auto-merge**. That puts the PR in the train; the train does the merge.
3. The train rebuilds the PR merged with the current `main`, runs the regression on that build,
   and squash-merges it if `main` has not moved. A red result gets a PR comment and turns auto-merge off.

`main` requires the build key `merge-train`, which only the train posts, so a PR cannot be merged
around the train.

## Merge train test log

| Test | What it shows |
|------|---------------|
| MT-04 | first merge by the train: one squash commit on the tested main |
| MT-05 | three independent PRs merged one at a time, first come first served, each tested on the main that already has the PRs before it |
| MT-18 | the Merge Train page and the PR reports during a run; a slow regression (PR A) and its reset (PR C) |

MT-11: a push to the PR while the train builds it must not merge the old head.
Second commit, pushed while the train builds this PR.
