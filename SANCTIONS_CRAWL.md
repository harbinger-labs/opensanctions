# Sanctions Data Crawling Guide

This guide explains how to crawl and export US and EU sanctions data using the Makefile targets.

## Quick Start

Crawl and export all sanctions data:
```bash
make sanctions-all
```

This will:
1. Crawl US OFAC SDN sanctions list
2. Crawl EU Sanctions Map
3. Export both datasets to CSV and other formats
4. Display summary information

## Individual Commands

### Crawl Data

Crawl both US and EU sanctions:
```bash
make sanctions-crawl
```

Crawl only US OFAC SDN:
```bash
make crawl-us-ofac
```

Crawl only EU Sanctions:
```bash
make crawl-eu-sanctions
```

### Export Data

Export both datasets:
```bash
make sanctions-export
```

Export only US OFAC:
```bash
make export-us-ofac
```

Export only EU Sanctions:
```bash
make export-eu-sanctions
```

### Convenience Commands

Process US data only (crawl + export):
```bash
make sanctions-us
```

Process EU data only (crawl + export):
```bash
make sanctions-eu
```

### Information and Cleanup

View summary of crawled data:
```bash
make sanctions-info
```

Clean sanctions data:
```bash
make sanctions-clean
```

## Output Files

All data is stored in `data/datasets/`:

### US OFAC SDN List
**Location:** `data/datasets/us_ofac_sdn/`

**Files:**
- `targets.simple.csv` - Simplified CSV format (~6 MB, ~18,000 entities)
- `entities.ftm.json` - FollowTheMoney entity format
- `targets.nested.json` - Nested JSON format
- `names.txt` - Plain text list of names
- `senzing.json` - Senzing entity format
- `statistics.json` - Dataset statistics
- `index.json` - Dataset metadata

### EU Sanctions Map
**Location:** `data/datasets/eu_sanctions_map/`

**Files:**
- `targets.simple.csv` - Simplified CSV format (~340 KB, ~1,600 entities)
- `entities.ftm.json` - FollowTheMoney entity format
- `targets.nested.json` - Nested JSON format
- `names.txt` - Plain text list of names
- `senzing.json` - Senzing entity format
- `statistics.json` - Dataset statistics
- `index.json` - Dataset metadata

## CSV Format

The `targets.simple.csv` files contain the following columns:

| Column | Description |
|--------|-------------|
| `id` | Unique entity identifier |
| `schema` | Entity type (Person, Organization, Vessel, CryptoWallet, etc.) |
| `name` | Primary name of the entity |
| `aliases` | Alternative names (comma-separated) |
| `birth_date` | Date of birth (for persons) |
| `countries` | Associated countries (comma-separated) |
| `addresses` | Known addresses (comma-separated) |
| `identifiers` | IDs, passport numbers, registration numbers (comma-separated) |
| `sanctions` | Sanction dates (comma-separated) |
| `phones` | Phone numbers (comma-separated) |
| `emails` | Email addresses (comma-separated) |
| `program_ids` | Sanction program identifiers |
| `dataset` | Source dataset name |
| `first_seen` | First appearance in dataset |
| `last_seen` | Last appearance in dataset |
| `last_change` | Last modification date |

## Data Sources

### US OFAC SDN List
- **Publisher:** US Department of the Treasury - Office of Foreign Assets Control (OFAC)
- **Description:** Primary US sanctions list including individuals, companies, and entities designated under various sanctions programs
- **URL:** https://www.treasury.gov/resource-center/sanctions/Pages/default.aspx
- **Update Frequency:** Daily

### EU Sanctions Map
- **Publisher:** Council of the European Union
- **Description:** EU sanctions including asset freezes, travel bans, and designated vessels under various EU restrictive measures
- **URL:** https://www.sanctionsmap.eu/
- **Update Frequency:** Daily

## Technical Details

### Docker Commands Used

The Makefile uses Docker to run the `zavod` ETL framework:

**Crawl US OFAC:**
```bash
docker run --rm \
  -v "$(PWD)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/us/ofac/us_ofac_sdn.yml
```

**Crawl EU Sanctions:**
```bash
docker run --rm \
  -v "$(PWD)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/eu/sanctions_map/eu_sanctions_map.yml
```

**Export to CSV and other formats:**
```bash
docker run --rm \
  -v "$(PWD)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/us/ofac/us_ofac_sdn.yml
```

### Database Configuration

The PostgreSQL database port has been changed from `5432` to `5444` to avoid port conflicts. This is configured in:
- `docker-compose.dev.yml`
- `ui/README.md`
- `ui/Dockerfile`
- `zavod/zavod/integration/duckdb_index.py`

## Example Usage

1. **First-time setup:**
   ```bash
   # Crawl and export all sanctions data
   make sanctions-all
   ```

2. **Update existing data:**
   ```bash
   # Clean old data first
   make sanctions-clean
   
   # Re-crawl and export
   make sanctions-all
   ```

3. **Work with specific datasets:**
   ```bash
   # Only US sanctions
   make sanctions-us
   
   # Check the output
   head -10 data/datasets/us_ofac_sdn/targets.simple.csv
   ```

4. **Integration example (Python):**
   ```python
   import pandas as pd
   
   # Load US OFAC sanctions
   us_sanctions = pd.read_csv('data/datasets/us_ofac_sdn/targets.simple.csv')
   
   # Load EU sanctions
   eu_sanctions = pd.read_csv('data/datasets/eu_sanctions_map/targets.simple.csv')
   
   # Search for a name
   matches = us_sanctions[us_sanctions['name'].str.contains('Putin', case=False)]
   print(matches[['name', 'schema', 'countries']])
   ```

## Troubleshooting

**Issue:** Docker image not found
```bash
# Pull the latest image
docker pull ghcr.io/opensanctions/opensanctions:latest
```

**Issue:** Permission denied on data directory
```bash
# Ensure the data directory exists and is writable
mkdir -p data/datasets
chmod -R u+w data/
```

**Issue:** Port conflict with database
- The database port has been changed to 5444 to avoid conflicts
- If you still have issues, check `docker-compose.dev.yml`

**Issue:** Out of disk space
```bash
# Check data size
du -sh data/datasets/

# Clean old data
make sanctions-clean
```

## Notes

- Crawling can take several minutes depending on your internet connection
- The US OFAC dataset is significantly larger (~6 MB CSV) than the EU dataset (~340 KB)
- Data is cached in the `data/datasets/` directory between runs
- Use `make sanctions-clean` to force a fresh crawl
- All warnings about missing program keys (e.g., 'US-CUBA' not found) are expected and can be ignored
