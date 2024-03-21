"""Test the Linter class."""

from unittest import TestCase

try:
  from linter import Linter
except ImportError:
  from ..linter import Linter


class TestLinter(TestCase):
  """Test the Linter class."""

  def test_assert_equal__equal__raises_no_exception(self) -> None:
    linter = Linter()

    linter.assert_equal(
        "test 1",
        "test 1",
        "test values should match",
    )

  def test_assert_equal__unequal__raises_exception(self) -> None:
    linter = Linter()

    with self.assertRaises(ValueError) as exc:
      linter.assert_equal(
          "test 1",
          "test 1\r\t\n",
          "test values should match",
      )

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: test values should match\n"
            "  EXPECTED: 'test 1'\n"
            "  RECEIVED: 'test 1\\r\\t\\n'\n"
        )
    )

  def test_assert_in__present__raises_no_exception(self) -> None:
    linter = Linter()

    linter.assert_in(1, [1, 2, 3], "list_of_numbers")

  def test_assert_in__missing__raises_exception(self) -> None:
    linter = Linter()

    with self.assertRaises(ValueError) as exc:
      linter.assert_in("a", [1, 2, 3], "list_of_numbers")

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: unexpectedly missing\n"
            "  MEMBER: 'a'\n"
            "  CONTAINER: 'list_of_numbers'\n"
        )
    )

  def test_assert_not_in__missing__raises_no_exception(self) -> None:
    linter = Linter()

    linter.assert_not_in("a", [1, 2, 3], "list_of_numbers")

  def test_assert_not_in__present__raises_exception(self) -> None:
    linter = Linter()

    with self.assertRaises(ValueError) as exc:
      linter.assert_not_in(1, [1, 2, 3], "list_of_numbers")

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: unexpectedly present\n"
            "  MEMBER: '1'\n"
            "  CONTAINER: 'list_of_numbers'\n"
        )
    )

  def test_assert_regex__equal__raises_no_exception(self) -> None:
    linter = Linter()

    result = linter.assert_regex(
        r'(test) [0-9\s]+',
        "test 1 2 3",
        "regex should match",
    )

    assert result.group(1) == "test"

  def test_assert_regex__unequal__raises_exception(self) -> None:
    linter = Linter()

    with self.assertRaises(ValueError) as exc:
      linter.assert_regex(
          r'(test) [0-9\s]+',
          "test a b c\n",
          "regex should match",
      )

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: regex should match\n"
            "  REGEX: '(test) [0-9\\s]+'\n"
            "  DATA: 'test a b c\\n'\n"
        )
    )

  def test_visible_whitespace__replaces_whitespace(self) -> None:
    linter = Linter()

    self.assertEqual(linter.visible_whitespace("1\n"), "1\\n")
    self.assertEqual(linter.visible_whitespace("1\r"), "1\\r")
    self.assertEqual(linter.visible_whitespace("1\t"), "1\\t")
