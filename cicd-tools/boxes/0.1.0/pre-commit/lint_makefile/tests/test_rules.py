"""Test RuleBase sybclasses."""

import pathlib
from io import StringIO
from unittest import TestCase, mock

from .. import rules


class TestAssertEqual:
  """Test the AssertEqual class."""

  def setup_method(self) -> None:
    self.mock_makefile = pathlib.Path("mock.makefile")

  def test_initialize__attributes(self) -> None:
    pass
