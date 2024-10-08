# CICD-Tools

Managed, Centralized CI/CD Components.  A platform in a repository.

| Builds: [main](https://github.com/cicd-tools-org/cicd-tools/tree/main)                                                                                                                                                                                         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml)                 |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml)                             |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gettext-multiarch.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gettext-multiarch.yml)     |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gpg-multiarch.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gpg-multiarch.yml)             |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-utilities-multiarch.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-utilities-multiarch.yml) |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml)                 |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml)                                         |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml)                                       |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml)                   |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml/badge.svg?branch=main)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml)                               |

| Builds: [dev](https://github.com/cicd-tools-org/cicd-tools/tree/dev)                                                                                                                                                                                          |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-ansible-role-molecule.yml)                 |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-compose-command.yml)                             |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gettext-multiarch.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gettext-multiarch.yml)     |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gpg-multiarch.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-gpg-multiarch.yml)             |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-utilities-multiarch.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-container-utilities-multiarch.yml) |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-cookiecutter-template.yml)                 |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-mac_maker.yml)                                         |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-meta_tests.yml)                                       |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-npm-node_application.yml)                   |
| [![workflow-link](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml/badge.svg?branch=dev)](https://github.com/cicd-tools-org/cicd-tools/actions/workflows/workflow-poetry-command.yml)                               |

## About

This repository manages a group of tools used to add out-of-the-box CI/CD pipeline functionality to Git based projects.

### Supported CI Platforms

At the current time only [GitHub Actions](https://docs.github.com/en/actions) are supported, but the future may bring more integrations.

### Technical Overview

CICD-Tools provides four consumables to end-user projects that together form the basis of a managed CI solution:

1. Customized [pre-commit hooks](https://github.com/cicd-tools-org/pre-commit) for end-user projects.
2. A custom [Docker container](.cicd-tools/containers/utilities/Dockerfile) which supplies the required binary tools for the pre-commit hooks.
3. Remotely consumable [GitHub "Jobs"](.github/workflows) that are actively maintained.
4. A custom [packaging system](https://github.com/cicd-tools-org/manifest/blob/main/manifest.json.asc) that securely delivers upgradable [Toolboxes](cicd-tools/boxes) full of scripts for the workflows.

For more details on these components, please read the complete [Technical Overview](./markdown/OVERVIEW.md).

### Supported Project Installations

CICD-Tools supports the following types of installs:

1. Cookiecutter Template Installs
   - Please see the [cookiecutter installation guide](markdown/project_types/COOKIECUTTER.md) for details on:
     - installing CICD-Tools into cookiecutter templates
     - setting up CI/CD for templates and spawned projects
     - setting up pre-commit for templates and spawned projects
2. Standard Project Installs (Projects may use Python, Shell or other languages.)
   - Please see the [standard installation guide](markdown/project_types/STANDARD.md) for details on:
     - installing CICD-Tools into existing projects
     - setting up CI/CD for existing projects
     - setting up pre-commit for existing projects
3. Lightweight Project Installs (Projects may use Python, Shell or other languages.)
   - Please see the [light installation guide](markdown/project_types/LIGHT.md) for details on:
     - installing CICD-Tools into existing projects
     - setting up pre-commit for existing projects

## License

[MPL-2](LICENSE)
