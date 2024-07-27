"""Python example script."""

import gettext
import os


def main() -> None:

  translations = gettext.translation(
    "base",
    os.path.join(os.path.dirname(__file__), "locales"),
    fallback=True,
  )

  _ = translations.gettext

  print(_("Translation example string 1."))
  print(_("Translation example string 2."))


if __name__ == "__main__":
  main()
