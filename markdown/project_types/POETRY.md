# CICD-Tools

## API Documentation for Poetry Projects

[Poetry](https://python-poetry.org/) is a Python package manager, and provides an excellent way to put [pre-commit](https://pre-commit.com/) under version control.  [pre-commit](https://pre-commit.com/) itself is written in Python, but can be used by Non-Python projects (i.e. Javascript, or golang).  

There are language specific alternatives such as [husky](https://github.com/typicode/husky) for Javascript that may make a better choice for your specific project.  However, you may find that [pre-commit](https://pre-commit.com/) is a viable option.  So, adding a [pyproject.toml](../../pyproject.toml) file may make sense- even for Non-Python projects.

If you have an existing project that you'd like to add CICD-Tools to, the [install-poetry.sh](../../scripts/install-poetry.sh) script can automate a great deal of the process, but there will be manual changes required as well.

Please read the documentation below to identify all the requirements.

## Adding CICD-Tools to an existing Poetry Project

### Step 1. Ensure your Project Contains a `pyproject.toml` File

[Poetry](https://python-poetry.org/) keeps all it's configuration in this file, and if you are managing conventional commits with [commitizen](https://pypi.org/project/commitizen/) you can bundle its configuration as well.  This allows you to consolidate both Python package management and tool configuration in one file.

If you don't have an existing `pyproject.toml` it's fairly easy to setup:

```bash
$ poetry init -q --dev-dependency=commitizen --dev-dependency=pre-commit
```

Depending on which CICD-Tools integrations you end up using, you may find it useful to explore formatting your `pyproject.toml` file with [tomll](https://github.com/pelletier/go-toml) and including some more advanced [commitizen](https://pypi.org/project/commitizen/) configuration.  You can find examples of this in the [installer.sh](../../scripts/libraries/installer.sh) library file.

Alternatively, the [install-poetry.sh](../../scripts/install-poetry.sh) setup script will automate this process for you giving you sensible, usable defaults.

### Step 2. Add the CICD-Tools Bootstrap Layer

In order to integrate with CICD-Tools, a minimal amount of scripting is required.

#### Step 2a. The Scripting

Your project should contain the [.cicd-tools](../../.cicd-tools) folder at the root level.  This takes care of the scripting requirement and allows [Toolboxes](../../cicd-tools/boxes) to be used.

The [install-poetry.sh](../../scripts/install-poetry.sh) script will perform this installation for you.

#### Step 2b. `.gitignore` Changes

Once you've copied the above content, you should also add a couple of lines to your [.gitignore](../../.gitignore) file:

```.gitignore
.cicd-tools/boxes/*
!.cicd-tools/boxes/bootstrap
```

The [install-poetry.sh](../../scripts/install-poetry.sh) script will create this file if it doesn't exist or add these lines if it does.

### Step 3. Add the Toolbox Fetching Action

In order to interface with the [Toolbox Packaging System](../../cicd-tools/boxes), you'll need to add the [action-00-toolbox](../../{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox/action.yml) [GitHub Action](https://github.com/features/actions) to your project.

The [install-poetry.sh](../../scripts/install-poetry.sh) script will perform this installation for you.

### Step 4. Pre-Commit Hooks

To make full use of CICD-Tools, you'll need to define some [pre-commit](https://pre-commit.com/) hooks.  These hooks are used both for local development, and by the CI itself.

Take a look at this example [.pre-commit-config.yaml](../../{{cookiecutter.project_slug}}/.pre-commit-config.yaml) file to get up and running quickly.

If you have no [.pre-commit-config.yaml](../../{{cookiecutter.project_slug}}/.pre-commit-config.yaml) for your project the [install-poetry.sh](../../scripts/install-poetry.sh) script will create a basic one for you.

Also keep in mind that each of the tools that you add may have their own configuration requirements.

### Step 5. Your Project's Workflows

You can also begin assembling a workflow for your project, giving it CI/CD whenever it's pushed to a GitHub repository.

This involves selecting [Job Files](../../.github/workflows) and patching them together in your own GitHub Workflow such as [this example](../../{{cookiecutter.project_slug}}/.github/workflows/workflow-push.yml).

- Your project's workflow should remotely call the [CICD-Tools Job Files](../../.github/workflows) in the manner documented [here](https://docs.github.com/actions/using-workflows/reusing-workflows#calling-a-reusable-workflow).
- These remote [Job Files](../../.github/workflows) will in turn call your project's [action-00-toolbox](../../{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox/action.yml) to install remote toolboxes and use their scripting.

Each [Job File](../../.github/workflows) has its own specific requirements and API, so it's best to carefully examine each file before integrating it.

#### Step 5a. CI Scripts

Your project should contain an implementation of:
- [step-setup-environment.sh](../../{{cookiecutter.project_slug}}/.github/scripts/step-setup-environment.sh) to setup environment variables the CI requires.
- Any other scripts required by the [Job Files](../../.github/workflows) you select.

It's important to make clear that your project will need files that satisfy the implementations of these scripts, and not just copies of the files themselves.
