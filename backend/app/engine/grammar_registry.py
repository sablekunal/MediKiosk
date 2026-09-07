from dataclasses import dataclass
from pathlib import Path


class GrammarValidationError(ValueError):
    """Raised when a bundled grammar is not a usable GBNF definition."""


@dataclass(frozen=True, slots=True)
class Grammar:
    name: str
    source: str


class GrammarRegistry:
    """Loads only bundled grammars and performs inexpensive, fail-fast validation."""

    def __init__(self, grammar_directory: Path | None = None) -> None:
        self.grammar_directory = grammar_directory or Path(__file__).parents[1] / "grammars"
        self._grammars: dict[str, Grammar] = {}

    def load_all(self) -> None:
        if not self.grammar_directory.is_dir():
            raise GrammarValidationError(f"Grammar directory does not exist: {self.grammar_directory}")
        for path in sorted(self.grammar_directory.glob("*.gbnf")):
            grammar = Grammar(path.stem, path.read_text(encoding="utf-8").strip())
            self._validate(grammar)
            self._grammars[grammar.name] = grammar
        if not self._grammars:
            raise GrammarValidationError("No GBNF grammar files were found")

    def get(self, name: str) -> Grammar:
        if not self._grammars:
            self.load_all()
        try:
            return self._grammars[name]
        except KeyError as error:
            raise GrammarValidationError(f"Unknown grammar: {name}") from error

    def names(self) -> tuple[str, ...]:
        if not self._grammars:
            self.load_all()
        return tuple(self._grammars)

    @staticmethod
    def _validate(grammar: Grammar) -> None:
        if not grammar.source or "root" not in grammar.source:
            raise GrammarValidationError(f"{grammar.name}: missing root production")
        if "::=" not in grammar.source:
            raise GrammarValidationError(f"{grammar.name}: missing production operator")
        if grammar.source.count('"') % 2:
            raise GrammarValidationError(f"{grammar.name}: unbalanced quoted terminal")
