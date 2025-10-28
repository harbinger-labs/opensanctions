# Agent Guidelines for OpenSanctions

## Build/Test Commands
- Run crawler: `zavod crawl datasets/<country>/<source>/<file>.yml`
- Run all tests: `cd zavod && pytest zavod/tests/`
- Run single test: `cd zavod && pytest zavod/tests/<test_file>.py::<test_function>`
- Type check: `cd zavod && mypy --strict --exclude zavod/tests zavod/`
- Lint: `cd zavod && ruff check zavod/`

## Code Style
- Import helpers: `from zavod import helpers as h` (never direct imports from zavod.helpers)
- All zavod code must be fully typed, unit tested, and thoroughly documented
- Use specific conditionals: `if var is None:` not `if var:`
- Fail explicitly on unexpected conditions - distrust all input data
- New crawlers must be typed Python; suggest adding types to existing crawlers
- Use ruff for formatting (via pre-commit), isort profile "black"
- Naming: snake_case for functions/variables, PascalCase for classes
- Error handling: crash or produce error on ambiguous data, never emit uncertain data
- Conservative dependencies: use lxml for HTML/XML, context.fetch_* for data retrieval
- File extensions: use .yml not .yaml for dataset definitions

## Pre-commit Hooks
- ruff-check with import sorting, ruff-format, mypy --strict, yamllint, trailing-whitespace check
