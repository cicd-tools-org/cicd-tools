# CICD-Tools

This is documentation for an installation that sets up [cookiecutter](https://github.com/cookiecutter/cookiecutter) template CI/CD, [poetry](https://python-poetry.org/) and [pre-commit](https://pre-commit.com/) for your project.

## Installation Into Cookiecutter Projects

For [cookiecutter](https://github.com/cookiecutter/cookiecutter) projects, CICD-Tools actually provides two "layers" of CI coverage:

1. _The template itself:_  Here CI tests that your project can actually render correctly, and ensures that quality controls pass for both the template and the projects it spawns.
2. _Spawned projects:_  Here CI is "templated" by [cookiecutter](https://github.com/cookiecutter/cookiecutter), so that each new project has its own CI, supported by CICD-Tools.

This repository contains a [cookiecutter template](../../{{cookiecutter.project_slug}}) which is used for testing purposes and as an example for you to follow during integration.

If you have an existing [cookiecutter](https://github.com/cookiecutter/cookiecutter) project that you'd like to add CICD-Tools to, the [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) script can automate a great deal of the process, but there will be manual changes required as well.  

Please read the documentation below to identify all the requirements.

## Adding CICD-Tools to an existing Cookiecutter Project

### Step 1. Ensure your `cookiecutter.json` file is CICD-Tools Compliant

CICD-Tools actually reads your [cookiecutter.json](../../cookiecutter.json) file, and uses it for CI configuration.

In order to use CICD-Tools with your project, your file should be compliant with [this](../../cicd-tools/boxes/0.1.0/schemas/cookiecutter.json) JSON Schema.

In practice this means adding additional fields to your [cookiecutter.json](../../cookiecutter.json) file, and ensuring that the main directory of your project falls under [{{cookiecutter.project_slug}}](../../{{cookiecutter.project_slug}}).

### Step 2. Ensure your Project Contains `pyproject.toml` Files

[Poetry](https://python-poetry.org/) keeps all it's configuration in this file, and if you are managing conventional commits with [commitizen](https://pypi.org/project/commitizen/) you can bundle its configuration as well.  This allows you to consolidate both Python package management and tool configuration in one file.

CICD-Tools requires two `pyproject.toml` files:

1. One for the [template](../../pyproject.toml) itself.
2. One for the [spawned projects](../../{{cookiecutter.project_slug}}/pyproject.toml) your template creates.

If you don't have an existing `pyproject.toml` it's fairly easy to setup:

```bash
$ poetry init -q --dev-dependency=commitizen --dev-dependency=pre-commit
```

Depending on which CICD-Tools integrations you end up using, you may find it useful to explore formatting your `pyproject.toml` file with [tomll](https://github.com/pelletier/go-toml) and including some more advanced [commitizen](https://pypi.org/project/commitizen/) configuration.  You can find examples of this in the [installer.sh](../../scripts/libraries/installer.sh) library file.

Alternatively, the [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) setup script will automate this process for you giving you sensible, usable defaults.

### Step 3. Add the CICD-Tools Bootstrap Layer

In order to integrate with CICD-Tools, a minimal amount of configuration is required.

#### Step 3a. Add the CICD-Tools Configuration Files

The template and the projects it spawns should contain a [.cicd-tools](../../.cicd-tools) folder at the root level.  This is where global configuration is kept for CICD-Tools, and it's also where [Toolboxes](../../cicd-tools/boxes) are installed ephemerally during CI/CD.

The `configuration` sub-folder needs to be populated with the [CICD-Tools configuration files](../../.cicd-tools/configuration) to facilitate and customize global CI tasks such as how Toolboxes are installed and how changelogs are generated.

It's recommended to symlink the inner [{{cookiecutter.project_slug}}/.cicd-tools](../../{{cookiecutter.project_slug}}/.cicd-tools) folder from the root template level [.cicd-tools](../../.cicd-tools) folder to avoid duplication.

The [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) script will perform this installation for you.

#### Step 3b. .gitignore Changes

Once you've added the above content, you should append a line to your [.gitignore](../../.gitignore) files:

```.gitignore
.cicd-tools/boxes/*
```

Add this content to both your template's [.gitignore](../../.gitignore) file and your [{{cookiecutter.project_slug}}/.gitignore](../../{{cookiecutter.project_slug}}/.gitignore) file.

The [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) script will create these files if they don't exist or add these lines if they do.

### Step 4. Add the Toolbox Fetching Action

In order to interface with the [Toolbox Packaging System](../../cicd-tools/boxes), you'll need to add the [action-00-toolbox](../../{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox/action.yml) [GitHub Action](https://github.com/features/actions) to both your template, and each spawned project. Using a symlink is recommended, rather than another copy of the file.

The [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) script will perform this installation for you.

### Step 5. Add Testing Scenarios

To test your template under certain conditions, CICD-Tools supports [cookiecutter scenarios](../../.github/scenarios).

Scenarios are copies of your [cookiecutter.json](../../cookiecutter.json) modified so that the defaults reflect different user input scenarios.  During CI execution these different JSON files can be used to template your project in different ways.

### Step 6. Pre-Commit Hooks

To make full use of CICD-Tools, you'll need to define some [pre-commit](https://pre-commit.com/) hooks.  These hooks are used both for local development and by the CI itself.

Take a look at these example files to get up and running quickly:

1. For your template, please see this example [.pre-commit-config.yaml](../../.pre-commit-config.yaml) file
2. For your spawned projects, please see this [{{cookiecutter.project_slug}}/.pre-commit-config.yaml](../../{{cookiecutter.project_slug}}/.pre-commit-config.yaml) file

If you have no [.pre-commit-config.yaml](../../.pre-commit-config.yaml) file for your template or spawned projects, the [install-cookiecutter.sh](../../scripts/install-cookiecutter.sh) script will create a basic one for you.

There is a [cookiecutter](https://github.com/cookiecutter/cookiecutter) has feature known as a `post generation hook` that allows you to perform automation on each new project your template spawns.  It's recommended to leverage this feature so that you can complete the installation of your [pre-commit](https://pre-commit.com/) hooks on each new project that is spawned.

- This repository contains an example [here](../../hooks/post_gen_project.sh).
- See the [cookiecutter documentation](https://cookiecutter.readthedocs.io/) for more details on how to implement a `post generation hook`.

Also keep in mind that each of the tools you add may have their own configuration requirements, and may need separate configurations for the template and spawned project layers.

### Step 7. Your Template Workflow

At this point you can begin assembling a workflow for your template.

This involves selecting [Job Files](../../.github/workflows) and patching them together in your own GitHub Workflow such as [this example](../../.github/workflows/workflow-cookiecutter-template.yml).

- Your project's workflow should remotely call the [CICD-Tools Job Files](../../.github/workflows) in the manner documented [here](https://docs.github.com/actions/using-workflows/reusing-workflows#calling-a-reusable-workflow).
- These remote [Job Files](../../.github/workflows) will in turn call [action-00-toolbox](../../.github/actions/action-00-toolbox/action.yml) to install remote toolboxes and use their scripting.

Each [Job File](../../.github/workflows) has its own specific requirements and API, so it's best to carefully examine each file before integrating it.

#### Step 7a. CI Scripts

At the [template layer](../../.github/scripts), your project should contain implementations of:
- [step-render-template.sh](../../.github/scripts/step-render-template.sh) to tell the CI how to render your project, and how to consume [scenarios](#step-5-add-testing-scenarios).
- [step-requirements-template.sh](../../.github/scripts/step-requirements-template.sh) to tell the CI how install the requirements to render your template (such as how to install cookiecutter).
- [step-setup-environment.sh](../../.github/scripts/step-setup-environment.sh) to setup environment variables the CI requires.
- Any other scripts required by the [Job Files](../../.github/workflows) you select.

It's important to make clear that your project will need files that satisfy the implementations of these scripts, and not just copies of the files themselves.

### Step 8. Your Spawned Projects Workflows

You can also begin assembling a workflow for the projects your template spawns- giving them CI/CD whenever they are pushed to a GitHub repository.

This involves selecting [Job Files](../../.github/workflows) and patching them together in your own GitHub Workflow such as [this example](../../{{cookiecutter.project_slug}}/.github/workflows/workflow-push.yml).

- Your project's workflow should remotely call the [CICD-Tools Job Files](../../.github/workflows) in the manner documented [here](https://docs.github.com/actions/using-workflows/reusing-workflows#calling-a-reusable-workflow).
- These remote [Job Files](../../.github/workflows) will in turn call the spawned project's [action-00-toolbox](../../{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox/action.yml) to install remote toolboxes and use their scripting.

Each [Job File](../../.github/workflows) has its own specific requirements and API, so it's best to carefully examine each file before integrating it.

#### Step 8a. CI Scripts

At the [project layer](../../{{cookiecutter.project_slug}}/.github/scripts), your project should contain an implementation of:
- [step-setup-environment.sh](../../{{cookiecutter.project_slug}}/.github/scripts/step-setup-environment.sh) to setup environment variables the CI requires.
- Any other scripts required by the [Job Files](../../.github/workflows) you select.

It's important to make clear that your project will need files that satisfy the implementations of these scripts, and not just copies of the files themselves.
