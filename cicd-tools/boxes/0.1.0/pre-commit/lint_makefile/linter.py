"""Linter class."""

import pathlib
from typing import Any, Dict, Iterator, List, Optional, Tuple, Type

import yaml

try:
  import rules
except ImportError:
  from . import rules


class SchemaError(ValueError):
  """Raised when the linter cannot read a rule from the schema."""

  def __init__(
      self,
      description: str,
      schema: pathlib.Path,
      rule: Dict[str, Any],
      context: Optional[Exception],
  ) -> None:
    message = (
        description + "\n"
        f"  SCHEMA FILE: {schema}\n"
        "  RULE DEFINITION:\n"
    )
    for key, value in rule.items():
      message += f"    {key}: {rules.RuleBase.visible_whitespace(value)}\n"
    message += f"  CONTEXT: {str(context)}\n"
    super().__init__(message)


class Linter:
  """A linter operations iterator."""

  rule_classes: List[Type[rules.RuleBase]] = [
      rules.AssertBlankLine,
      rules.AssertEqual,
      rules.AssertRegex,
      rules.CreateSectionFromRegex,
      rules.UntilEOF,
  ]

  rule_instances: List[rules.RuleBase]

  def __init__(self, schema_path: pathlib.Path) -> None:
    """Initialize the Linter class."""

    self.schema_path = schema_path
    self.schema = yaml.safe_load(
        pathlib.Path(schema_path).read_text(encoding="utf-8")
    )
    self.version: Tuple[int, ...] = tuple(
        map(int, (self.schema["version"].split(".")))
    )
    self.index = 0
    self.loop_index: Optional[int] = None
    self.rule_instances = []

    for index, rule in enumerate(self.schema["rules"]):
      try:
        linter_operation = rule["operation"]
        if linter_operation == "until_eof":
          self.loop_index = index + 1
        for operation_class in self.rule_classes:
          if operation_class.operation == linter_operation:
            del rule["operation"]
            self.rule_instances.append(operation_class(**rule))
            break
        else:
          raise SchemaError(
              description=f"rule #{index} unknown operation",
              schema=self.schema_path,
              rule=rule,
              context=None,
          )
      except (AttributeError, TypeError, KeyError) as exc:
        # pylint: disable=raise-missing-from
        raise SchemaError(
            description=f"rule #{index} unknown syntax",
            schema=self.schema_path,
            rule=rule,
            context=exc,
        )

  def __iter__(self) -> Iterator[rules.RuleBase]:
    return self

  def __next__(self) -> rules.RuleBase:
    if self.index < len(self.rule_instances):
      self.index += 1
      return self.rule_instances[self.index - 1]
    if self.loop_index:
      self.index = self.loop_index
      return self.__next__()
    raise StopIteration
