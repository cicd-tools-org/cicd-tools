# CICD-Tools

## Technical Overview

CICD-Tools provides four consumable resources that together form the basis for a complete CI solution:

1. Customized [pre-commit hooks](https://github.com/cicd-tools-org/pre-commit) for end-user projects.
2. A custom [Docker container](../.cicd-tools/container/Dockerfile) which supplies the required binary tools for the pre-commit hooks.
3. Remotely consumable [GitHub "Jobs"](../.github/workflows) that are actively maintained.
4. A custom [packaging system](https://github.com/cicd-tools-org/manifest/blob/main/manifest.json.asc) that securely delivers upgradable [Toolboxes](../cicd-tools/boxes) full of scripts for the workflows.

End-user projects consume these components to create their own custom CI solution, all while shifting the maintenance of the CI itself to CICD-Tools.

## 1. Pre-Commit Hooks

The [pre-commit hooks](https://github.com/cicd-tools-org/pre-commit) are designed to be consumed by end-user projects directly: integration requires creating a [.pre-commit-config.yaml](../.pre-commit-config.yaml) file.

These hooks form the basic building blocks of your codebase's quality controls and are used in two ways:
1. To perform standard pre-commit checks when committing code locally to end-user projects.
2. As a way of keeping the CI and the local dev experience congruent, the pre-commit hooks that run at various stages are also run by the CI.  (See the [pre-commit documentation](https://pre-commit.com/#config-stages) for more detail on `stages`.)

However, this leads to a problem where the tools used to perform these quality controls now need to be available…

## 2. Docker Containers

The [CICD-Tools container](https://ghcr.io/cicd-tools-org/cicd-tools) provides vetted binaries that are [integrated](https://github.com/cicd-tools-org/pre-commit/blob/main/.pre-commit-hooks.yaml) with the pre-commit hooks.

This allows a [single container definition](../.cicd-tools/container/Dockerfile) to [securely](../.cicd-tools/container/Dockerfile.sha256) provide most third party software. Where necessary, other trusted containers are leveraged to create a complete solution. Together these containers provide a way of leveraging third party tools without polluting your codebase with extra dependencies.

Finally, the containers ensure the same tools are used to check the codebase locally, and in the CI.  

This should help in the elimination of `environment drift` (where the codebase or test tooling performs differently in local, test, or production environments).

## 3. GitHub "Jobs"

There is a large collection of remotely consumable [GitHub Jobs](../.github/workflows) that provide various CI/CD services.  These [Jobs](../.github/workflows) are [reusable GitHub workflows](https://docs.github.com/actions/using-workflows/reusing-workflows) that are actively maintained as part of the CICD-Tools project.

- It's important to stop for a moment and note that ONLY the files named "job" are intended to be consumed by end-user projects.  
- The "workflow" files are used to provide CI/CD to CICD-Tools itself.

### The Job Naming Convention

Each [Job](../.github/workflows) is named in accordance with this convention:

- job-`step`-`project type`-`function`

The `step` is an integer between 0 and 100 which tries to give you an idea of how far along the software release process it should be used:
- Low digit steps are generally used early on as setup steps, leading the way to high digit steps that facilitate release or deployment.
- Low digit steps may also be low complexity [Jobs](../.github/workflows) that can be used at any stage in the CI process.

The `project type` describes the type of project this workflow supports:
- `generic` [Jobs](../.github/workflows) could be used by any sort of end-user project.
- `container` [Jobs](../.github/workflows) are designed specifically for workflows that are generating or testing containers.
- `cookecutter` [Jobs](../.github/workflows) are designed to be consumed by [cookiecutter](https://github.com/cookiecutter/cookiecutter) template projects.
- `mac_maker` [Jobs](../.github/workflows) are designed to be used with the [mac_maker](https://github.com/osx-provisioner/mac_maker) binary tool.
- `poetry` [Jobs](../.github/workflows) make use of the Python library [poetry](https://python-poetry.org/) and as such require the presence of a [pyproject.toml](../pyproject.toml) file.  However, the projects themselves may not necessarily be Python projects.

The `function` indicates the specific deliverable or service the Job provides.

### Using CICD-Tools "Jobs"

End-user projects contain workflows that in turn call the [CICD-Tools Jobs](../.github/workflows), in a manner similar to [this example](../{{cookiecutter.project_slug}}/.github/workflows/workflow-push.yml).

- This requires a local definition of [.github/actions/action-00-toolbox](../{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox/action.yml) to facilitate fetching the dependencies these [Jobs](../.github/workflows) rely on.
- Most of the [Jobs](../.github/workflows) require an end-user implementation of the [.github/scripts/step-setup-environment.sh](../{{cookiecutter.project_slug}}/.github/scripts/step-setup-environment.sh) script.  Other [Jobs](../.github/workflows) may require additional scripts to customize other behaviours: [examples](../{{cookiecutter.project_slug}}/.github/scripts) are present in this repository.
- Many [Jobs](../.github/workflows) have additional requirements, such as the presence of [pre-commit hooks](https://github.com/cicd-tools-org/cicd-tools) or additional configuration files.

It's important to look at the [Job files](../.github/workflows) themselves before incorporating them into your project- the [Job files](../.github/workflows) define a clear API and state their scripting requirements.

## 4. The Packaging System

The [CICD-Tools Jobs](../.github/workflows) in turn consume [Toolboxes](../cicd-tools/boxes):
- These [Toolboxes](../cicd-tools/boxes) are nothing more than [tarballs](https://en.wikipedia.org/wiki/Tar_(computing)) of scripts and custom [GitHub Actions](../cicd-tools/boxes/0.1.0/ci/github/actions).
- Adding the [action-00-toolbox](../.github/actions/action-00-toolbox/action.yml) GitHub Action to your project's [.github/actions](.github/actions) integrates your project with this packaging system.
- The [Jobs](../.github/workflows) read the [Toolbox Manifest](https://github.com/cicd-tools-org/manifest/blob/main/manifest.json.asc) and select the [Toolbox version](../cicd-tools/boxes) they require.

### The Advantages of Decoupling

The Packaging System allows the API of each [Job](../.github/workflows) to be decoupled from its actual implementation:
- This allows multiple [Jobs](../.github/workflows) to reuse the same [Toolbox](../cicd-tools/boxes) components.
- This also allows the [Toolboxes](../cicd-tools/boxes) to be developed independently of the [Jobs](../.github/workflows).
- Finally, it's possible to customize your project's [action-00-toolbox](../.github/actions/action-00-toolbox/action.yml) GitHub Action to use your own manifest.  In this way you can create your own Toolbox tarballs and customize the CI even further- while adhering to the same API.
