---
layout: default
title: Continuous Integration Testing
nav_order: 4
---

# Continuous Integration Testing (CI)

### Definition
Continuous Integration (CI) is a method for automating the integration of code changes made by multiple contributors to a single software project. It is a primary DevOps best practice that allows developers to frequently merge code changes into a central repository where builds and tests are executed. Automated tools are used to confirm the new code is bug-free before integration.

[Wiki - Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration){:target="_blank"}


### Command Line Tool
GdUnit3 provides a command line tool that allows you to automate your testing workflow, including CI.

For more details please show at [Command Line Tool](/gdUnit3/advanced_testing/cmd)

### Howto run Unit Tests with GitLab CI
You have to create a new workflow file on GitLab and named it *\.gitlab-ci\.yml*. Please visit [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/yaml/gitlab_ci_yaml.html){:target="_blank"} for more detaild instructions

Thanks to [mzoeller](https://github.com/mzoeller){:target="_blank"} to providing this example workflow.

{% raw %}
```yaml
image: barichello/godot-ci:3.4.4

cache:
  key: import-assets
  paths:
    - .import/

stages:
  - export
  - tests
  - deploy

variables:
  EXPORT_NAME: $CI_PROJECT_NAME
  GIT_SUBMODULE_STRATEGY: recursive

linux:
  stage: export
  script:
    - mkdir -v -p build/linux
    - godot -v --export "Linux/X11" build/linux/$EXPORT_NAME.x86_64
  artifacts:
    name: $EXPORT_NAME-$CI_JOB_NAME
    paths:
      - build/linux

gdunit3:
  stage: tests
  dependencies:
    - linux
  script:
    - export GODOT_BIN=/usr/local/bin/godot
    - ./runtest.sh -a ./test || if [ $? -eq 101 ]; then echo "warnings"; elif [ $? -eq 0 ]; then echo "success"; else exit 1; fi
  artifacts:
    when: always
    reports:
      junit: ./reports/report_1/results.xml
```
{% endraw %}

### Howto run Unit Tests with GitHub Action
You have to create a new workflow file on GitHub **\.github/workflows/** and named it **unit_tests\.yml**.<br>
Please visit [GitHub Workflows Page](https://docs.github.com/en/actions/using-workflows){:target="_blank"} for more detaild instructions.

The example shows how to run unit tests via a GitHub workflow:

{% raw %}
```yaml
name: unit-tests
run-name: ${{ github.head_ref || github.ref_name }}-unit-tests

on:
  workflow_call:
    inputs:
      os:
        required: false
        type: string
        default: 'ubuntu-22.04'
      godot-version:
        required: true
        type: string
      
  workflow_dispatch:
    inputs:
      os:
        required: false
        type: string
        default: 'ubuntu-22.04'
      godot-version:
        required: true
        type: string

concurrency:
  group: unit-tests-${{ github.head_ref || github.ref_name }}-${{ inputs.godot-version }}
  cancel-in-progress: true

jobs:

  unit-test:
    name: "Unit Tests"
    runs-on: ${{ inputs.os }}
    timeout-minutes: 15

    steps:
      - name: "Checkout GdUnit Repository"
        uses: actions/checkout@v3
        with:
          lfs: true
          submodules: 'recursive'

      - name: "Install Godot ${{ inputs.godot-version }}"
        uses: ./.github/actions/godot-install
        with:
          godot-version: ${{ inputs.godot-version }}
          godot-mono: false
          godot-status-version: 'stable'
          godot-bin-name: 'x11.64'
          godot-cache-path: '~/godot-linux'

      - name: "Update Project"
        if: ${{ !cancelled() }}
        timeout-minutes: 1
        continue-on-error: true # we still ignore the timeout, the script is not quit and we run into a timeout
        shell: bash
        run: |
          xvfb-run --auto-servernum ~/godot-linux/godot -e --path . -s res://addons/gdUnit3/src/core/scan_project.gd --audio-driver Dummy --no-window

      - name: "Run Unit Tests"
        if: ${{ !cancelled() }}
        timeout-minutes: 8
        uses: ./.github/actions/unit-test
        with:
          godot-bin: '~/godot-linux/godot'
          test-includes: "res://addons/gdUnit3/test/"

      - name: "Set Report Name"
        if: ${{ always() }}
        shell: bash
        run: echo "REPORT_NAME=${{ inputs.os }}-${{ inputs.godot-version }}" >> "$GITHUB_ENV"

      - name: "Publish Unit Test Reports"
        if: ${{ !cancelled() }}
        uses: ./.github/actions/publish-test-report
        with:
          report-name: ${{ env.REPORT_NAME }}

      - name: "Upload Unit Test Reports"
        if: ${{ !cancelled() }}
        uses: ./.github/actions/upload-test-report
        with:
          report-name: ${{ env.REPORT_NAME }}

```
{% endraw %}

This **unit-test** workflow is used by **ci-pr.yml** to run on every pull request to verify no tests are broken.

{% raw %}
```yaml
name: ci-pr
run-name: ${{ github.head_ref || github.ref_name }}-ci-pr

on:
  pull_request:
    paths-ignore:
      - '**.yml'
      - '**.jpg'
      - '**.png'
      - '**.md'
  workflow_dispatch:


concurrency:
  group: ci-pr-${{ github.event.number }}
  cancel-in-progress: true


jobs:
  unit-tests:
    strategy:
      fail-fast: false
      max-parallel: 10
      matrix:
        godot-version: [3.4.1, 3.4.2, 3.4.4, 3.4.5, 3.5, 3.5.1, 3.5.2]

    name: "CI on Godot 🐧 v${{ matrix.godot-version }}"
    uses: ./.github/workflows/unit-tests.yml
    with: 
      godot-version: ${{ matrix.godot-version }}
```
{% endraw %}
The full set of used actions can be found [here](https://github.com/MikeSchulze/gdUnit3/tree/master/.github){:target="_blank"}
