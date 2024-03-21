"""Makefile class."""

import pathlib
from typing import Dict, List

try:
  from linter import Linter
except ImportError:
  from .linter import Linter


class Makefile:
  """A GNU Makefile."""

  def __init__(self, filename: pathlib.Path) -> None:
    self.aliases: Dict[str, str] = {}
    self.commands: List[str] = []
    self.filename = filename
    self.helps: List[str] = []
    self.index = 0
    self.lines: List[str] = []
    self.linter = Linter()
    self.phonies: List[str] = []

    with open(self.filename, "r", encoding="utf-8") as fh:
      shebang = False
      for line in fh.readlines():
        if not line.startswith("#") or not shebang:
          shebang = True
          self.lines.append(line)

  def lint(self) -> None:
    """Lint the makefile."""
    self._check_shebang()
    self._check_phonies()
    self._check_helps()
    self._check_aliases()
    self._check_commands()

    for entry in self.phonies:
      self.linter.assert_in(
          entry, self.helps + list(self.aliases.keys()) + ["help"],
          "all phonies in help and aliases"
      )
      self.linter.assert_in(
          entry, self.commands + list(self.aliases.keys()) + ["help"],
          "all phonies in commands and aliases"
      )

    for entry in self.helps:
      self.linter.assert_in(
          entry,
          self.phonies,
          "all help entries in phonies",
      )
      self.linter.assert_in(
          entry,
          self.commands,
          "all help entries in commands",
      )

    for entry in self.commands:
      self.linter.assert_in(
          entry,
          self.phonies,
          "all commands in phonies",
      )
      self.linter.assert_in(
          entry,
          self.helps,
          "all commands in help entries",
      )

    for entry in self.aliases:
      self.linter.assert_in(
          entry,
          self.phonies,
          "all aliases in phonies",
      )
      self.linter.assert_not_in(
          entry,
          self.helps,
          "all aliases in help",
      )
      self.linter.assert_not_in(
          entry,
          self.commands,
          "all aliases in commands",
      )

  def _check_shebang(self) -> None:
    self.linter.assert_equal(
        "#!/usr/bin/make -f\n",
        self.lines[self.index],
        "shebang",
    )
    self.index += 1
    self.linter.assert_equal(
        "\n",
        self.lines[self.index],
        "blank line after shebang",
    )
    self.index += 1

  def _check_phonies(self) -> None:
    found_phonies = self.linter.assert_regex(
        r'^.PHONY: ([a-z-\s]+)\n',
        self.lines[self.index],
        "phonies",
    )
    self.index += 1
    self.phonies = found_phonies.group(1).split(" ")

  def _check_helps(self) -> None:
    found_helps: List[str] = []
    help_section = self.next_section("help")
    self.linter.assert_equal(
        "help:\n",
        help_section[0],
        "help section start",
    )
    self.linter.assert_equal(
        "\t@echo \"Please use 'make <target>' where <target> is one of:\"\n",
        help_section[1],
        "help section title",
    )
    for line in help_section[2:]:
      match = self.linter.assert_regex(
          r'\t@echo "  ([a-z-]+)\s+.+\n', line, "help section entry"
      )
      found_helps.append(match.group(1))
    self.helps = found_helps

  def _check_aliases(self) -> None:
    found_aliases: Dict[str, List[str]] = {}
    aliases_section = self.next_section("aliases")
    for line in aliases_section:
      match = self.linter.assert_regex(
          r'^([a-z]+): ([a-z-\s]+)\n', line, "alias definition"
      )
      group_name = match.group(1)
      group_members = match.group(2).split(" ")
      if group_name in found_aliases:
        raise ValueError(f"Duplicate alias entry: '{group_name}'.")
      if len(group_members) != len(set(group_members)):
        raise ValueError(
            f"Duplicate alias member in alias entry: '{group_name}'."
        )
      found_aliases[match.group(1)] = group_members
    self.aliases = found_aliases

  def _check_commands(self) -> None:
    found_commands: List[str] = []
    while self.index < len(self.lines):
      command_section = self.next_section(
          f"command-{len(found_commands)}",
          eof=True,
      )
      command_header = self.linter.assert_regex(
          r'^([a-z-]+):\n', command_section[0], "command section start"
      )
      for line in command_section[1:]:
        self.linter.assert_regex(r'^\t@.*\n', line, "command section content")
      found_commands.append(command_header.group(1))
    self.commands = found_commands

  def next_section(self, section_name: str, eof: bool = False) -> List[str]:
    """Read the next Makefile paragraph, looking for a linebreak."""
    section: List[str] = []
    found_start = False

    for index in range(self.index, len(self.lines)):
      if self.lines[index] == "\n":
        if found_start:
          break
        self.index += 1
        found_start = True
        continue
      self.index += 1
      section.append(self.lines[index])
    else:
      if not eof:
        raise ValueError(f"Could not find end of '{section_name}' section.")

    return section
