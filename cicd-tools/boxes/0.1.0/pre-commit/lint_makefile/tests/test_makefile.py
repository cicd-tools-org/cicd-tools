"""Test Makefile class."""

import pathlib
from io import StringIO
from unittest import TestCase, mock

from ..makefile import Makefile

MockOpen = mock.MagicMock()


@mock.patch("builtins.open", MockOpen)
class TestMakefile(TestCase):
  """Test the Makefile class."""

  def setup_method(self) -> None:
    self.mock_makefile = pathlib.Path("mock.makefile")
    self.mock_file_handle = StringIO()
    MockOpen.reset_mock()
    MockOpen.return_value = self.mock_file_handle

  def test_initialize__attributes(self) -> None:
    instance = Makefile(self.mock_makefile)

    self.assertEqual(instance.makefile_path, self.mock_makefile)
    self.assertEqual(instance.index, -1)

  def test_initialize__lines(self) -> None:
    for line in range(0, 10):
      self.mock_file_handle.write(f"{line}\n")
    self.mock_file_handle.seek(0)

    instance = Makefile(self.mock_makefile)

    MockOpen.assert_called_once_with(
        self.mock_makefile,
        "r",
        encoding="utf-8",
    )

    self.assertListEqual(
        instance.lines,
        [f"{line}\n" for line in range(0, 10)],
    )

  def test_next__iter__returns_iterator(self) -> None:
    instance = Makefile(self.mock_makefile)

    assert iter(instance) == instance

  def test_next__returns_next_line(self) -> None:
    for line in range(0, 10):
      self.mock_file_handle.write(f"{line}\n")
    self.mock_file_handle.seek(0)

    instance = Makefile(self.mock_makefile)

    lines = list(instance)
    self.assertListEqual(lines, [f"{line}\n" for line in range(0, 10)])
    self.assertEqual(len(lines), 10)

  def test_next__skips_comments(self) -> None:
    for line in range(0, 10):
      self.mock_file_handle.write(f"# {line}\n")
      self.mock_file_handle.write(f"{line}\n")
    self.mock_file_handle.seek(0)

    instance = Makefile(self.mock_makefile)

    lines = list(instance)
    self.assertListEqual(lines, [f"{line}\n" for line in range(0, 10)])
    self.assertEqual(len(lines), 10)

  def test_next__does_not_skip_shebang(self) -> None:
    shebang = f"#!/usr/bin/make -f\n"
    self.mock_file_handle.write(shebang)
    for line in range(0, 10):
      self.mock_file_handle.write(f"{line}\n")
    self.mock_file_handle.seek(0)

    instance = Makefile(self.mock_makefile)

    lines = list(instance)
    self.assertListEqual(
        lines, [shebang] + [f"{line}\n" for line in range(0, 10)]
    )
    self.assertEqual(len(lines), 11)
