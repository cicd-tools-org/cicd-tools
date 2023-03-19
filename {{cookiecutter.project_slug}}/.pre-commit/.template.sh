#!/bin/bash

# Support extracting default values from a 'cookiecutter.json' file.

# IMAGE:  The Docker image and tag to use, or a 'cookiecutter.json' key.

# pre-commit script.

main() {

  if [[ -f "cookiecutter.json" ]]; then
    IMAGE="$(jq -erM ".${IMAGE}" cookiecutter.json)"
    echo "DEBUG: using 'cookiecutter.json' version '${IMAGE}'"
  fi

}

main "$@"
