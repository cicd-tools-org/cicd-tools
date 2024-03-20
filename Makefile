#!/usr/bin/make -f

.PHONY: help clean fmt lint security spelling clean-fit format-shell format-toml lint-markdown lint-shell lint-workflows lint-yaml security-leaks spelling-add spelling-markdown spelling-sync

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  clean-git         to run git clean"
	@echo "  format-shell      to format shell scripts"
	@echo "  format-toml       to format TOML files"
	@echo "  lint-markdown     to lint Markdown files"
	@echo "  lint-shell        to lint shell scripts"
	@echo "  lint-workflows    to lint GitHub workflows"
	@echo "  lint-yaml         to lint YAML files"
	@echo "  security-leaks    to check for credential leaks"
	@echo "  spelling-add      to add a regex to the ignore patterns"
	@echo "  spelling-markdown to spellcheck markdown files"
	@echo "  spelling-sync     to synchronize vale packages"

clean: clean-git
fmt: format-shell format-toml
lint: lint-markdown lint-shell lint-workflows lint-yaml
security: security-leaks
spelling: spelling-markdown

clean-git:
	@echo "Cleaning git content ..."
	@git clean -fd
	@echo "Done."

format-shell:
	@echo "Checking shell scripts ..."
	@poetry run bash -c "pre-commit run format-shell --all-files --verbose"
	@echo "Done."

format-toml:
	@echo "Checking TOML files ..."
	@poetry run bash -c "pre-commit run format-toml --all-files --verbose"
	@echo "Done."

lint-markdown:
	@echo "Checking Markdown files ..."
	@poetry run bash -c "pre-commit run lint-markdown --all-files --verbose"
	@echo "Done."

lint-shell:
	@echo "Checking shell scripts ..."
	@poetry run bash -c "pre-commit run lint-shell --all-files --verbose"
	@echo "Done."

lint-workflows:
	@echo "Checking workflows ..."
	@poetry run bash -c "pre-commit run lint-github-workflow --all-files --verbose"
	@poetry run bash -c "pre-commit run lint-github-workflow-header --all-files --verbose"
	@echo "Done."

lint-yaml:
	@echo "Checking YAML files ..."
	@poetry run bash -c "pre-commit run yamllint --all-files --verbose"
	@echo "Done."

spelling-add:
	@echo "Adding word ..."
	@echo "${MAKE_ARGS}" >> ".vale/Vocab/${PROJECT_NAME}/accept.txt"
	@sort -u -o ".vale/Vocab/${PROJECT_NAME}/accept.txt" ".vale/Vocab/${PROJECT_NAME}/accept.txt"

security-leaks:
	@echo "Checking security ..."
	@poetry run bash -c "pre-commit run security-credentials --all-files --verbose"
	@echo "Done."

spelling-markdown:
	@echo "Checking spelling ..."
	@poetry run bash -c "pre-commit run spelling-markdown --all-files --verbose"
	@echo "Done."

spelling-sync:
	@echo "Synchronizing vale ..."
	@poetry run bash -c "pre-commit run --hook-stage manual spelling-vale-sync --all-files --verbose"
