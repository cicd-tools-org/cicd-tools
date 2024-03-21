"""Test the Makefile class."""

import pathlib
from io import StringIO
from unittest import TestCase, mock

try:
  from linter import Linter
  from makefile import Makefile
except ImportError:
  from ..linter import Linter
  from ..makefile import Makefile

MockOpen = mock.MagicMock()


class TestMakefile(TestCase):
  """Test the Makefile class."""

  mock_makefile = pathlib.Path("/path/to/Makefile")

  def setUp(self) -> None:
    self.file_mock = StringIO()
    MockOpen.return_value = self.file_mock

  @mock.patch('builtins.open', MockOpen)
  def test_intialize__attributes(self) -> None:
    makefile = Makefile(self.mock_makefile)

    self.assertDictEqual(makefile.aliases, {})
    self.assertListEqual(makefile.commands, [])
    self.assertEqual(makefile.filename, self.mock_makefile)
    self.assertEqual(makefile.index, 0)
    self.assertListEqual(makefile.lines, [])
    self.assertIsInstance(makefile.linter, Linter)
    self.assertListEqual(makefile.phonies, [])

  @mock.patch('builtins.open', MockOpen)
  def test_intialize__lines(self) -> None:
    self.file_mock.write(
        "#!/usr/bin/make -f\n"
        "# commented line1"
        "    # commented line2"
    )
    self.file_mock.seek(0)

    makefile = Makefile(self.mock_makefile)

    self.assertEqual(makefile.lines, ['#!/usr/bin/make -f\n'])

  def test_lint__invalid_makefile__malformed_shebang(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_1.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: shebang\n"
            "  EXPECTED: '#!/usr/bin/make -f\\n'\n"
            "  RECEIVED: '#!/usr/bin/malformed -f\\n'\n"
        )
    )

  def test_lint__invalid_makefile__malformed_phonies(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_2.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    exception_lines = exc.exception.args[0].split("\n")
    self.assertEqual(
        exception_lines[0],
        "ERROR: phonies",
    )
    self.assertEqual(
        exception_lines[1],
        "  REGEX: '^.PHONY: ([a-z-\\s]+)\\n'",
    )

  def test_lint__invalid_makefile__malformed_help_1(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_3.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: help section title\n"
            "  EXPECTED: '\\t@echo \"Please use 'make <target>' where "
            "<target> is one of:\"\\n'\n"
            "  RECEIVED: '\\t@echo \"Please use `make <target>' where "
            "<target> is one of:\"\\n'\n"
        )
    )

  def test_lint__invalid_makefile__malformed_help_2(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_4.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0],
        "Could not find end of 'help' section.",
    )

  def test_lint__invalid_makefile__malformed_aliases_1(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_5.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: alias definition\n"
            "  REGEX: '^([a-z]+): ([a-z-\\s]+)\\n'\n"
            "  DATA: 'clean: CLEAN-GIT\\n'\n"
        )
    )

  def test_lint__invalid_makefile__malformed_aliases_2(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_6.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0],
        "Duplicate alias entry: 'clean'.",
    )

  def test_lint__invalid_makefile__malformed_aliases_3(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_7.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0],
        "Duplicate alias member in alias entry: 'clean'.",
    )

  def test_lint__invalid_makefile__malformed_aliases_4(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_8.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0],
        "Could not find end of 'aliases' section.",
    )

  def test_lint__invalid_makefile__malformed_command_1(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_9.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: command section start\n"
            "  REGEX: '^([a-z-]+):\\n'\n"
            "  DATA: 'CLEAN-GIT:\\n'\n"
        )
    )

  def test_lint__invalid_makefile__malformed_command_2(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_10.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: command section content\n"
            "  REGEX: '^\\t@.*\\n'\n"
            "  DATA: '\\tgit clean -fd\\n'\n"
        )
    )

  def test_lint__invalid_makefile__malformed_command_3(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "invalid_makefile_11.txt"
    )

    with self.assertRaises(ValueError) as exc:
      makefile.lint()

    self.assertEqual(
        exc.exception.args[0], (
            "ERROR: command section content\n"
            "  REGEX: '^\\t@.*\\n'\n"
            "  DATA: 'format-shell:\\n'\n"
        )
    )

  def test_lint__valid_makefile__parses_correctly(self) -> None:
    makefile = Makefile(
        pathlib.Path(__file__).parent / "fixtures" / "valid_makefile.txt"
    )

    makefile.lint()
