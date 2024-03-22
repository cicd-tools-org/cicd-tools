"""Module entrypoint."""

import argparse
import pathlib

try:
  from controller import Controller
except (ImportError, ModuleNotFoundError):
  from .controller import Controller


def cli() -> None:
  """Parse the command line arguments."""

  parser = argparse.ArgumentParser(
      prog="lint_makefile",
      description="CICD-Tools makefile linter.",
  )
  required = parser.add_argument_group("required arguments")
  required.add_argument(
      "-f",
      "--filename",
      help="the makefile to lint",
      required=True,
      type=pathlib.Path,
  )
  args = parser.parse_args()

  ctrl = Controller(args.filename)
  ctrl.start()


if __name__ == "__main__":
  cli()
