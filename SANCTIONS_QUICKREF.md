# Sanctions Data - Quick Reference

## One-Command Solution

```bash
make sanctions-all
```

This single command will:
- ✓ Crawl US OFAC SDN sanctions list (~18,000 entities)
- ✓ Crawl EU Sanctions Map (~1,600 entities)
- ✓ Export both to CSV and other formats
- ✓ Display detailed summary

## Output Locations

```
data/datasets/us_ofac_sdn/targets.simple.csv       (6.1 MB)
data/datasets/eu_sanctions_map/targets.simple.csv  (340 KB)
```

## Common Commands

| Command | Description |
|---------|-------------|
| `make sanctions-all` | Crawl and export everything |
| `make sanctions-info` | Show summary of data |
| `make sanctions-us` | Only US OFAC data |
| `make sanctions-eu` | Only EU data |
| `make sanctions-clean` | Delete all sanctions data |

## Docker Commands (if not using Makefile)

### Crawl US OFAC
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/us/ofac/us_ofac_sdn.yml
```

### Export US OFAC
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/us/ofac/us_ofac_sdn.yml
```

### Crawl EU Sanctions
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/eu/sanctions_map/eu_sanctions_map.yml
```

### Export EU Sanctions
```bash
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/eu/sanctions_map/eu_sanctions_map.yml
```

## CSV Columns

The CSV files contain these columns (all comma-separated where multiple values):

- **id** - Unique identifier
- **schema** - Entity type (Person, Organization, Vessel, CryptoWallet, etc.)
- **name** - Primary name
- **aliases** - Alternative names
- **birth_date** - Date of birth
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

## Quick CSV Preview

```bash
# View first 10 lines of US OFAC data
head -10 data/datasets/us_ofac_sdn/targets.simple.csv

# Search for a specific name
grep -i "name_to_search" data/datasets/us_ofac_sdn/targets.simple.csv

# Count entities by type
cut -d',' -f2 data/datasets/us_ofac_sdn/targets.simple.csv | sort | uniq -c
```

## Data Sources

**US OFAC:** https://www.treasury.gov/resource-center/sanctions/Pages/default.aspx
**EU Sanctions:** https://www.sanctionsmap.eu/

## Port Configuration Note

PostgreSQL database port changed from **5432** to **5444** to avoid conflicts.

## More Information

See `SANCTIONS_CRAWL.md` for detailed documentation.
