# Sanctions Data Crawling - Quick Start

## One Command to Rule Them All

```bash
make sanctions-all
```

This will crawl US OFAC and EU sanctions data, export to CSV, and show you a summary.

## What You Get

Two CSV files with comprehensive sanctions data:

```
data/datasets/us_ofac_sdn/targets.simple.csv       → 18,187 entities (6.1 MB)
data/datasets/eu_sanctions_map/targets.simple.csv  → 1,598 entities (340 KB)
```

## Available Commands

| Command | What It Does |
|---------|--------------|
| `make sanctions-all` | Complete workflow: crawl + export + summary |
| `make sanctions-info` | Show detailed summary of existing data |
| `make sanctions-us` | Process only US OFAC data |
| `make sanctions-eu` | Process only EU sanctions data |
| `make sanctions-clean` | Delete all sanctions data |

## CSV Format

Each CSV has these columns:
- **id** - Unique identifier
- **schema** - Type (Person, Organization, Vessel, etc.)
- **name** - Primary name
- **aliases** - Alternative names
- **birth_date** - Date of birth (if applicable)
- **countries** - Associated countries
- **addresses** - Known addresses
- **identifiers** - IDs, passports, registration numbers
- **sanctions** - Sanction dates
- **phones** - Phone numbers
- **emails** - Email addresses
- **program_ids** - Sanction program IDs
- **dataset** - Source dataset
- **first_seen** - First appearance
- **last_seen** - Last appearance  
- **last_change** - Last modification

## Quick Python Example

```python
import pandas as pd

# Load the data
us = pd.read_csv('data/datasets/us_ofac_sdn/targets.simple.csv')
eu = pd.read_csv('data/datasets/eu_sanctions_map/targets.simple.csv')

# Search for a name
matches = us[us['name'].str.contains('Search Term', case=False)]
print(matches[['name', 'schema', 'countries']])
```

## Data Sources

- **US OFAC SDN:** Office of Foreign Assets Control, U.S. Department of the Treasury
- **EU Sanctions Map:** Council of the European Union

Both sources are updated daily.

## More Information

- **Quick Reference:** See `SANCTIONS_QUICKREF.md`
- **Full Documentation:** See `SANCTIONS_CRAWL.md`
- **Changes Made:** See `CHANGES_SUMMARY.md`

## Note on Database Port

The PostgreSQL port has been changed from 5432 to 5444 to avoid conflicts with existing installations.

---

**Ready to start?** Just run: `make sanctions-all`
