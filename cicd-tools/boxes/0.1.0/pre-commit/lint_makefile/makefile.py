"""Makefile class."""

import pathlib
from typing import Iterator, List


class Makefile:
  """A GNU Makefile iterator."""

  def __init__(self, makefile_path: pathlib.Path) -> None:
    self.makefile_path = makefile_path
    self.index = -1
    self.lines: List[str] = []

    with open(self.makefile_path, "r", encoding="utf-8") as fh:
      for line in fh.readlines():
        self.lines.append(line)

  def __iter__(self) -> Iterator[str]:
    return self

  def __next__(self) -> str:
    if self.index + 1 < len(self.lines):
      self.index += 1
      next_line = self.lines[self.index]
      if not self.is_shebang(next_line) and self.is_comment(next_line):
        return self.__next__()
      return next_line
    raise StopIteration

  def is_comment(self, next_line: str) -> bool:
    return next_line.startswith("#")

  def is_shebang(self, next_line: str) -> bool:
    return self.index == 0 and next_line.startswith("#!")
