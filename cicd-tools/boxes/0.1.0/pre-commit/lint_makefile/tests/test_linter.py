"""Test the Linter class."""

import json
import pathlib
from io import StringIO
from unittest import mock
import pytest

from .. import linter, rules
from . import schemas

MockReadText = mock.Mock()


@mock.patch(linter.__name__ + ".pathlib.Path.read_text", MockReadText)
class TestLinter:
  """Test the Linter class."""

  def setup_method(self) -> None:
    self.mock_schema = pathlib.Path("mock_schema.yml")
    self.mock_file_handle = StringIO()
    MockReadText.reset_mock()
    __import__('sys').modules['unittest.util']._MAX_LENGTH = 999999999

  def test_initialize__attributes(self) -> None:
    MockReadText.return_value = json.dumps(schemas.one_simple_rule)

    instance = linter.Linter(self.mock_schema)

    assert instance.schema_path == self.mock_schema
    assert instance.index == 0
    assert instance.loop_index is None

  def test_initialize__rule_classes(self) -> None:
    MockReadText.return_value = json.dumps(schemas.one_simple_rule)

    instance = linter.Linter(self.mock_schema)

    assert instance.rule_classes == [
        rules.AssertBlankLine,
        rules.AssertEqual,
        rules.AssertRegex,
        rules.CreateSectionFromRegex,
        rules.UntilEOF,
    ]

  def test_initialize__rule_instances(self) -> None:
    MockReadText.return_value = json.dumps(schemas.two_simple_rules)

    instance = linter.Linter(self.mock_schema)

    test_rules = schemas.two_simple_rules["rules"]
    for index, rule_instance in enumerate(instance.rule_instances):
      assert rule_instance.name == test_rules[index]["name"]
      assert rule_instance.operation == test_rules[index]["operation"]

  def test_initialize__until_eof__loop_index(self) -> None:
    MockReadText.return_value = json.dumps(schemas.three_simple_rules)

    instance = linter.Linter(self.mock_schema)

    assert instance.rule_instances[2].operation == "until_eof"
    assert instance.loop_index == 3

  def test_initialize__invalid_operation__raises_exception(self) -> None:
    MockReadText.return_value = json.dumps(schemas.invalid_operation)
    invalid_operation = schemas.invalid_operation["rules"][0]

    with pytest.raises(linter.SchemaError) as exc:
      linter.Linter(self.mock_schema)

    assert exc.value.args[0] == (
          "rule #0 unknown operation\n"
          f"  SCHEMA FILE: {self.mock_schema}\n"
          f"  RULE DEFINITION:\n" + "\n".join(
              [
                  f"    {key}: {value}"
                  for key, value in invalid_operation.items()
              ]
          ) + "\n"
          "  CONTEXT: None\n"
      )

  def test_initialize__key_error__raises_exception(self) -> None:
    MockReadText.return_value = json.dumps(schemas.key_error)
    key_error = schemas.key_error["rules"][0]

    with pytest.raises(linter.SchemaError) as exc:
      linter.Linter(self.mock_schema)

    assert exc.value.args[0] == (
            "rule #0 unknown syntax\n"
            f"  SCHEMA FILE: {self.mock_schema}\n"
            f"  RULE DEFINITION:\n" + "\n".join(
                [
                    f"    {key}: {value}"
                    for key, value in key_error.items()
                ]
            ) + "\n"
            "  CONTEXT: 'operation'\n"
        )

  def test_initialize__type_error__raises_exception(self) -> None:
    MockReadText.return_value = json.dumps(schemas.type_error)
    type_error = schemas.type_error["rules"][0]
    del type_error["operation"]

    with pytest.raises(linter.SchemaError) as exc:
      linter.Linter(self.mock_schema)

    assert exc.value.args[0] == (
            "rule #0 unknown syntax\n"
            f"  SCHEMA FILE: {self.mock_schema}\n"
            f"  RULE DEFINITION:\n" + "\n".join(
                [
                    f"    {key}: {value}"
                    for key, value in type_error.items()
                ]
            ) + "\n"
            "  CONTEXT: __init__() got an unexpected keyword argument "
            "'wrong_field'\n"
        )

  def test_next__iter__returns_iterator(self) -> None:
    MockReadText.return_value = json.dumps(schemas.one_simple_rule)

    instance = linter.Linter(self.mock_schema)

    assert iter(instance) == instance

  def test_next__one_rule__returns_next_operation_(self) -> None:
    MockReadText.return_value = json.dumps(schemas.one_simple_rule)

    instance = linter.Linter(self.mock_schema)

    lines = list(instance)
    assert lines == instance.rule_instances
    assert len(lines) == 1

  def test_next__two_rules__returns_next_operation(self) -> None:
    MockReadText.return_value = json.dumps(schemas.two_simple_rules)

    instance = linter.Linter(self.mock_schema)

    lines = list(instance)
    assert lines == instance.rule_instances
    assert len(lines) == 2
