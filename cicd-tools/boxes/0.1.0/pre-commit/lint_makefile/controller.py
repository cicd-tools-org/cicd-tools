"""Controller class."""

import pathlib
from typing import Dict, List

try:
  from linter import Linter
  from makefile import Makefile
except ImportError:
  from .linter import Linter
  from .makefile import Makefile


class Controller:
  """Orchestrates the makefile validation process."""

  def __init__(self, makefile_path: pathlib.Path) -> None:
    self.linter = Linter(pathlib.Path(__file__).parent / "schema.yml")
    self.makefile = Makefile(pathlib.Path(makefile_path))
    self.results: Dict[str, List[str]] = {}

  def start(self) -> None:
    """Start the makefile validation process."""

    for operation in self.linter:

      try:
        operation.apply(self.makefile)
      except StopIteration:
        break

      if not operation.result or not operation.save:
        continue

      if operation.split:
        for match in operation.result:
          for group in match.groups():
            split_result = group.split(operation.split)
            self._save(operation.save, split_result)
      else:
        for match in operation.result:
          self._save(operation.save, list(match.groups()))

    print(self.results)

  def _save(self, save_key: str, result: List[str]) -> None:
    self.results[save_key] = self.results.get(save_key, []) + result
