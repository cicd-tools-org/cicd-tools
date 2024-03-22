"""Linter rules for the Makefile linter."""

import abc
import re
from typing import Any, List, Match, Optional, Union

try:
  from makefile import Makefile
except ImportError:
  from .makefile import Makefile


class MakefileError(ValueError):
  """Raised when a Makefile validation rule fails."""

  def __init__(
      self,
      rule: "RuleBase",
      expected: str,
      makefile: Makefile,
      hint: str,
  ) -> None:
    super().__init__(
        f"MAKEFILE ERROR: {rule.__class__.__name__}\n"
        f"  MAKEFILE: {makefile.makefile_path.resolve()}\n"
        f"  RULE: '{rule.name}'\n"
        f"  EXPECTED: '{rule.visible_whitespace(expected)}'\n"
        "  MAKEFILE LINE: "
        f"'{rule.visible_whitespace(makefile.lines[makefile.index])}'\n"
        f"  MAKEFILE LINE NUMBER: {makefile.index + 1}\n"
        f"  HINT: {hint}\n"
    )


class RuleBase(abc.ABC):
  """Validation rule Base Class"""

  lint: str
  result: Union[None, List[Match]]

  def __init__(
      self,
      name: str,
      save: Optional[str] = None,
      split: Optional[str] = None,
  ) -> None:
    self.name = name
    self.split = split
    self.save = save
    self.result = None

  @abc.abstractmethod
  def apply(self, makefile: Makefile) -> None:
    """Base method for applying a rule."""

  @staticmethod
  def visible_whitespace(value: Any) -> str:
    """Make a string's whitespace visible."""

    string = str(value). \
        replace("\n", "\\n"). \
        replace("\r", "\\r"). \
        replace("\t", "\\t")

    return string


class AssertEqual(RuleBase):
  """Assert that the line matches an expected static value."""

  lint = "assert_equal"

  def __init__(
      self,
      name: str,
      expected: str,
      save: Optional[str] = None,
      split: Optional[str] = None,
  ) -> None:
    self.expected = expected
    super().__init__(name, save, split)

  def apply(self, makefile: Makefile) -> None:
    """Assert that the line matches an expected static value."""

    data = next(makefile)

    if self.expected != data:
      raise MakefileError(
          rule=self,
          expected=self.expected,
          makefile=makefile,
          hint="this line must match the expected value",
      )


class AssertBlankLine(RuleBase):
  """Assert that the line is blank."""

  lint = "assert_blank"

  def apply(self, makefile: Makefile) -> None:
    """Assert that the line is blank."""

    data = next(makefile)

    if "\n" != data:
      raise MakefileError(
          rule=self,
          expected="\\n",
          makefile=makefile,
          hint="sections must be separated by blank lines",
      )


class AssertRegex(RuleBase):
  """Assert that the line matches a regular expression."""

  lint = "assert_regex"

  def __init__(
      self,
      name: str,
      regex: str,
      save: Optional[str] = None,
      split: Optional[str] = None,
  ) -> None:
    self.regex = re.compile(regex, re.DOTALL)
    super().__init__(name, save, split)

  def apply(self, makefile: Makefile) -> None:
    """Assert that the line matches a regular expression."""

    data = next(makefile)
    match = re.match(self.regex, data)

    if not match:
      raise MakefileError(
          rule=self,
          expected=self.regex.pattern,
          makefile=makefile,
          hint="this line must match the regex",
      )

    self.result = [match]


class CreateSectionFromRegex(RuleBase):
  """Assert that a sequence of lines matches a regular expression."""

  lint = "create_section_from_regex"

  def __init__(
      self,
      name: str,
      regex: str,
      save: Optional[str] = None,
      split: Optional[str] = None,
  ) -> None:
    self.regex = re.compile(regex, re.DOTALL)
    super().__init__(name, save, split)

  def apply(self, makefile: Makefile) -> None:
    """Assert that two strings are equal."""

    for data in makefile:

      if data == "\n":
        break

      match = re.match(self.regex, data)

      if not match:
        raise MakefileError(
            rule=self,
            expected=self.regex.pattern,
            makefile=makefile,
            hint="sections must be separated and contain lines "
            "that match this regex",
        )

      if not self.result:
        self.result = []

      self.result.append(match)


class UntilEOF(RuleBase):
  """Inform the linter to start repeating rules."""

  lint = "until_eof"

  def __init__(
      self,
      name: str,
  ) -> None:
    super().__init__(name, None, None)

  def apply(self, makefile: Makefile) -> None:
    """Inform the linter to start repeating rules."""
