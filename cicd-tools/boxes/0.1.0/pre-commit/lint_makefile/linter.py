"""Linter class."""

import re
from typing import Any, List, Match


class Linter:
  """Generic linter tools."""

  def assert_equal(
      self,
      expected: Any,
      received: Any,
      description: str,
  ) -> None:
    """Assert that two strings are equal."""

    if expected != received:
      raise ValueError(
          f"ERROR: {description}\n"
          f"  EXPECTED: '{self.visible_whitespace(expected)}'\n"
          f"  RECEIVED: '{self.visible_whitespace(received)}'\n"
      )

  def assert_in(
      self,
      member: Any,
      container: List[Any],
      container_name: str,
  ) -> None:
    """Assert a container has a specific member."""

    if member not in container:
      raise ValueError(
          "ERROR: unexpectedly missing\n"
          f"  MEMBER: '{self.visible_whitespace(member)}'\n"
          f"  CONTAINER: '{container_name}'\n"
      )

  def assert_not_in(
      self,
      member: Any,
      container: List[Any],
      container_name: str,
  ) -> None:
    """Assert a container does NOT have a specific member."""

    if member in container:
      raise ValueError(
          "ERROR: unexpectedly present\n"
          f"  MEMBER: '{self.visible_whitespace(member)}'\n"
          f"  CONTAINER: '{container_name}'\n"
      )

  def assert_regex(
      self,
      regex: str,
      data: str,
      description: str,
  ) -> Match[str]:
    """Assert a regex matches the given data."""

    match = re.match(regex, data, re.DOTALL)

    if not match:
      raise ValueError(
          f"ERROR: {description}\n"
          f"  REGEX: '{regex}'\n"
          f"  DATA: '{self.visible_whitespace(data)}'\n"
      )

    return match

  @staticmethod
  def visible_whitespace(value: Any) -> str:
    """Make a string's whitespace visible."""

    string = (
        str(value).replace("\n", "\\n").replace("\r",
                                                "\\r").replace("\t", "\\t")
    )

    return string
