# CICD-Tools

Managed, Centralized CI/CD Components.  A platform in a repository.

<!-- vale off -->
## Master Branch Builds
<!-- vale on -->
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-multiarch.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-multiarch.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml/badge.svg?branch=master)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml)

#### Dev Branch
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-multiarch.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-multiarch.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml)
- [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml)

## About

This repository manages a group of tools used to add out-of-the-box CI/CD pipeline functionality to Git based projects.

### Supported CI Platforms

At the current time only [GitHub Actions](https://docs.github.com/en/actions) are supported, but the future may bring more integrations.

### Technical Overview

CICD-Tools provides four consumables to end-user projects that together form the basis of a managed CI solution:

1. Customized [pre-commit hooks](https://github.com/cicd-tools-org/pre-commit) for end-user projects.
2. A custom [Docker container](.cicd-tools/container/Dockerfile) which supplies the required binary tools for the pre-commit hooks.
3. Remotely consumable [GitHub "Jobs"](.github/workflows) that are actively maintained.
4. A custom [packaging system](https://github.com/cicd-tools-org/manifest/blob/master/manifest.json.asc) that securely delivers upgradable [Toolboxes](cicd-tools/boxes) full of scripts for the workflows.

For more details on these components, please read the complete [Technical Overview](./markdown/OVERVIEW.md).

### Supported Project Types

CICD-Tools supports the following types of projects:

1. [cookiecutter](https://github.com/cookiecutter/cookiecutter) templates.
   - Please see the [implementation documentation](markdown/project_types/COOKIECUTTER.md).
2. [poetry](https://python-poetry.org/) based projects, that may use Python, Shell or other languages.
   - Please see the [implementation documentation](markdown/project_types/POETRY.md).

## License

[MPL-2](LICENSE)
