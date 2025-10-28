# OpenSanctions

OpenSanctions aggregates and provides a comprehensive open-source database of sanctions data, politically exposed persons, and related entities. This project contains crawlers that import source data, such as sanctions lists and other KYC/AML screening data, into FollowTheMoney entities with an emphasis on data cleaning.

**Key functionalities:**
- **Parsing** of raw source data
- **Cleaning** and standardization of data structures
- **Deduplication** to maintain data integrity
- **Exporting** data into a variety of output formats

We build on top of the [Follow the Money](https://www.followthemoney.tech) framework, a JSON-focused anti-corruption data model, as the schema for all our crawlers.

## Quick Links
* [OpenSanctions Website](https://www.opensanctions.org/)
* [Datasets](https://www.opensanctions.org/datasets/)
* [zavod Documentation](https://zavod.opensanctions.org/)
* [API Documentation](https://api.opensanctions.org/)
* [Contributing](https://www.opensanctions.org/docs/opensource/contributing/)
* [FAQs](https://www.opensanctions.org/faq/)
* [Security Policy](https://www.opensanctions.org/docs/security/)

---

## Quick Start: Sanctions Data Crawling

### One Command to Get Started

```bash
make sanctions-all
```

This single command will crawl US OFAC and EU sanctions data, export to CSV, and show you a summary.

**Output:**
```
data/datasets/us_ofac_sdn/targets.simple.csv       → 18,187 entities (6.1 MB)
data/datasets/eu_sanctions_map/targets.simple.csv  → 1,598 entities (340 KB)
```

### Available Sanctions Commands

| Command | What It Does |
|---------|--------------|
| `make sanctions-all` | Complete workflow: crawl + export + summary |
| `make sanctions-info` | Show detailed summary of existing data |
| `make sanctions-us` | Process only US OFAC data |
| `make sanctions-eu` | Process only EU sanctions data |
| `make sanctions-clean` | Delete all sanctions data |

### Quick Python Example

```python
import pandas as pd

# Load the data
us = pd.read_csv('data/datasets/us_ofac_sdn/targets.simple.csv')
eu = pd.read_csv('data/datasets/eu_sanctions_map/targets.simple.csv')

# Search for a name
matches = us[us['name'].str.contains('Search Term', case=False)]
print(matches[['name', 'schema', 'countries']])
```

---

## Development Setup

### Repository Layout

* **`zavod/`** - ETL framework for crawlers, including:
  - `zavod.meta` - Metadata definitions
  - `zavod.entity.Entity` - Entity structure
  - `zavod.context.Context` - Crawler context
  - [Entity structure documentation](https://followthemoney.tech/explorer/schemata/)
  - [Data cleaning functions (rigour)](https://rigour.followthemoney.tech/)

* **`datasets/`** - Crawlers defined with `.yml` files (e.g., `datasets/us/ofac/us_ofac_sdn.yml`)
  - Each crawler has a code file (often `crawler.py`)
  - Output: `data/datasets/<dataset_name>/`

* **`ui/`** - NextJS user interface for reviewing and verifying crawler information

* **`docs/`** - Documentation and best practices

### Environment Setup

1. **Database Initialization** (optional, for caching):

```bash
docker compose up -d db
```

Note: PostgreSQL port is **5444** (not the default 5432) to avoid conflicts.

2. **Project Building**:

```bash
make build
# Or directly:
docker-compose build --pull
```

### Running a Crawler

```bash
# Using Docker Compose
docker compose run --rm app zavod crawl datasets/de/abgeordnetenwatch/de_abgeordnetenwatch.yml

# Or specify any dataset file
docker compose run --rm app zavod crawl datasets/<country>/<source>/<file>.yml
```

---

## Development Guidelines for Agents

### Build/Test Commands

- **Run crawler:** `zavod crawl datasets/<country>/<source>/<file>.yml`
- **Run all tests:** `cd zavod && pytest zavod/tests/`
- **Run single test:** `cd zavod && pytest zavod/tests/<test_file>.py::<test_function>`
- **Type check:** `cd zavod && mypy --strict --exclude zavod/tests zavod/`
- **Lint:** `cd zavod && ruff check zavod/`

### Code Style Guidelines

**Import Conventions:**
```python
from zavod import Context
from zavod import helpers as h  # ALWAYS use this pattern
```
Never use direct imports from `zavod.helpers`.

**Type Requirements:**
- All zavod code must be fully typed, unit tested, and thoroughly documented
- All new crawlers should be written using typed Python
- Run `mypy --strict` after each change to zavod

**Code Patterns:**
```python
# ✓ GOOD: Specific conditionals
if var is None:
    handle_none()

# ✗ BAD: Vague conditionals
if var:
    do_something()
```

**Error Handling:**
- Fail explicitly on unexpected conditions
- Distrust all input data, especially from source files
- Crash or produce error on ambiguous data
- Never emit uncertain data
- Use lookups to override specific values for ambiguous data

**Formatting:**
- Use ruff for formatting (via pre-commit)
- isort profile: "black"
- Naming: `snake_case` for functions/variables, `PascalCase` for classes
- File extensions: use `.yml` not `.yaml` for dataset definitions

**Dependencies:**
- Be extremely conservative in adding new dependencies
- Use `lxml` for parsing HTML/XML
- Use `context.fetch_*` functions to retrieve online data
- See `zavod/pyproject.toml` for approved libraries

**Pre-commit Hooks:**
- ruff-check with import sorting
- ruff-format
- mypy --strict
- yamllint
- trailing-whitespace check

### Crawler Development

**When a crawler runs:**
1. Fetches data using `context.fetch_resource` (cached between runs)
2. Parses and cleans the data
3. Emits entities in FollowTheMoney format
4. Writes output to `data/datasets/<dataset_name>/`
5. Creates `issues.log` with line-based JSON of warnings/errors

**Key principles:**
- When encountering uncertainty, crash or produce an error instead of emitting ambiguous data
- Use lookups to clarify individual ambiguous cases
- Write test code in `zavod/zavod/tests`

---

## CSV Output Format

Sanctions CSV files contain these columns:

- **id** - Unique entity identifier
- **schema** - Entity type (Person, Organization, Vessel, etc.)
- **name** - Primary name
- **aliases** - Alternative names (comma-separated)
- **birth_date** - Date of birth (for persons)
- **countries** - Associated countries (comma-separated)
- **addresses** - Known addresses (comma-separated)
- **identifiers** - IDs, passport numbers, registration numbers (comma-separated)
- **sanctions** - Sanction dates (comma-separated)
- **phones** - Phone numbers (comma-separated)
- **emails** - Email addresses (comma-separated)
- **program_ids** - Sanction program identifiers
- **dataset** - Source dataset name
- **first_seen** - First appearance in dataset
- **last_seen** - Last appearance in dataset
- **last_change** - Last modification date

---

## Data Sources

### US OFAC SDN List
- **Publisher:** U.S. Department of the Treasury - Office of Foreign Assets Control
- **URL:** https://www.treasury.gov/resource-center/sanctions/Pages/default.aspx
- **Update Frequency:** Daily

### EU Sanctions Map
- **Publisher:** Council of the European Union
- **URL:** https://www.sanctionsmap.eu/
- **Update Frequency:** Daily

---

## Advanced Usage

### Docker Commands (Raw)

**Crawl US OFAC:**
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/us/ofac/us_ofac_sdn.yml
```

**Export US OFAC:**
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/us/ofac/us_ofac_sdn.yml
```

### Output Formats

For each dataset, the following formats are generated:
- `targets.simple.csv` - Simplified CSV format
- `entities.ftm.json` - FollowTheMoney entity format
- `targets.nested.json` - Nested JSON format
- `names.txt` - Plain text list of names
- `senzing.json` - Senzing entity format
- `statistics.json` - Dataset statistics
- `index.json` - Dataset metadata

---

## Associated Repositories

- [opensanctions/nomenklatura](https://github.com/opensanctions/nomenklatura) - Framework for storing data statements with full data lineage and entity data integration
- [opensanctions/yente](https://github.com/opensanctions/yente) - API for entity matching and searching

---

## Licensing

**Code:** MIT License

**Content and Data:** [CC 4.0 Attribution-NonCommercial](https://www.opensanctions.org/licensing/)

For responsible disclosure of security issues, please visit https://www.opensanctions.org/docs/security/

---

## Troubleshooting

**Issue: Docker image not found**
```bash
docker pull ghcr.io/opensanctions/opensanctions:latest
```

**Issue: Permission denied on data directory**
```bash
mkdir -p data/datasets
chmod -R u+w data/
```

**Issue: Port conflict with database**
- Database port changed to **5444** to avoid conflicts
- Check `docker-compose.dev.yml` if issues persist

**Issue: Out of disk space**
```bash
du -sh data/datasets/
make sanctions-clean
```

---

## Notes

- Crawling can take several minutes depending on internet connection
- Data is cached in `data/datasets/` between runs
- Use `make sanctions-clean` to force a fresh crawl
- Warnings about missing program keys are expected and can be ignored
- The venv running crawlers should have `zavod` configured
