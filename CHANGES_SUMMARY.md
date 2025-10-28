# Summary of Changes

This document summarizes all changes made to the OpenSanctions repository.

## 1. Database Port Configuration Change

**Issue:** Port 5432 (default PostgreSQL) was causing conflicts  
**Solution:** Changed to port 5444

### Files Modified:

1. **docker-compose.dev.yml**
   - Changed port mapping from `5432:5432` to `5444:5432`
   - Added comment explaining the change

2. **zavod/zavod/integration/duckdb_index.py**
   - Updated example Docker command to use port 5444
   - Added comment in the connection string

3. **ui/README.md**
   - Updated example database URI from `localhost:5432` to `localhost:5444`
   - Added comment explaining port change

4. **ui/Dockerfile**
   - Updated example Docker run command to use port 5444
   - Added comment explaining the change

## 2. Makefile Enhancements for Sanctions Data

**Purpose:** Streamline the process of crawling and exporting sanctions data

### New Makefile Targets:

#### Main Targets:
- `make sanctions-all` - Crawl and export all sanctions data (US + EU)
- `make sanctions-crawl` - Crawl both datasets
- `make sanctions-export` - Export both datasets to CSV and other formats

#### Individual Dataset Targets:
- `make crawl-us-ofac` - Crawl US OFAC SDN List
- `make crawl-eu-sanctions` - Crawl EU Sanctions Map
- `make export-us-ofac` - Export US OFAC data
- `make export-eu-sanctions` - Export EU sanctions data

#### Convenience Targets:
- `make sanctions-us` - Crawl and export US OFAC data only
- `make sanctions-eu` - Crawl and export EU data only
- `make sanctions-info` - Display summary of crawled data
- `make sanctions-clean` - Remove all sanctions data

### Features:
- **Detailed echo messages** at every step explaining what's happening
- **File size and record counts** displayed after operations
- **CSV column documentation** shown in info command
- **Error handling** with proper status messages
- **Docker volume mounting** for data persistence

## 3. Documentation Created

### SANCTIONS_CRAWL.md
Comprehensive guide covering:
- Quick start instructions
- Individual command usage
- Output file descriptions
- CSV format documentation
- Data source information
- Technical details (exact Docker commands)
- Database configuration notes
- Example usage (including Python integration)
- Troubleshooting section

### SANCTIONS_QUICKREF.md
Quick reference card with:
- One-command solution
- Output locations
- Common commands table
- Raw Docker commands
- CSV column list
- Quick CSV preview commands
- Data source URLs

### CHANGES_SUMMARY.md (this file)
Complete summary of all modifications made

## Commands Used

### Database Port Changes:
```bash
# Modified port mappings in docker-compose.dev.yml
sed 's/5432:5432/5444:5432/' 

# Updated all documentation and example commands
sed 's/:5432/:5444/' 
```

### Sanctions Data Crawling:
```bash
# Crawl US OFAC SDN
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/us/ofac/us_ofac_sdn.yml

# Crawl EU Sanctions Map
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/eu/sanctions_map/eu_sanctions_map.yml

# Export US OFAC to CSV
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/us/ofac/us_ofac_sdn.yml

# Export EU Sanctions to CSV
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/eu/sanctions_map/eu_sanctions_map.yml
```

## Results

### Data Successfully Crawled:

**US OFAC SDN List:**
- Location: `data/datasets/us_ofac_sdn/targets.simple.csv`
- Size: 6.1 MB
- Records: 18,187 entities
- Types: Person, Organization, Vessel, CryptoWallet, Aircraft, etc.

**EU Sanctions Map:**
- Location: `data/datasets/eu_sanctions_map/targets.simple.csv`
- Size: 340 KB
- Records: 1,598 entities
- Types: Person, Organization, Vessel, etc.

### Additional Formats Generated:
For each dataset:
- `targets.simple.csv` - Simplified CSV format
- `entities.ftm.json` - FollowTheMoney entity format
- `targets.nested.json` - Nested JSON format
- `names.txt` - Plain text list of names
- `senzing.json` - Senzing entity format
- `statistics.json` - Dataset statistics
- `index.json` - Dataset metadata

## Usage Examples

### Using Makefile:
```bash
# Everything at once
make sanctions-all

# Check what you have
make sanctions-info

# Clean and refresh
make sanctions-clean
make sanctions-all
```

### Using Docker Directly:
```bash
# Crawl US data
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod crawl datasets/us/ofac/us_ofac_sdn.yml

# Export to CSV
docker run --rm \
  -v "$(pwd)/data:/opensanctions/data" \
  ghcr.io/opensanctions/opensanctions:latest \
  zavod export datasets/us/ofac/us_ofac_sdn.yml
```

### Reading CSV in Python:
```python
import pandas as pd

# Load sanctions data
us_sanctions = pd.read_csv('data/datasets/us_ofac_sdn/targets.simple.csv')
eu_sanctions = pd.read_csv('data/datasets/eu_sanctions_map/targets.simple.csv')

# Example: Find all Russian entities
russian_sanctions = us_sanctions[us_sanctions['countries'].str.contains('ru', case=False, na=False)]
print(f"Found {len(russian_sanctions)} Russian entities")

# Example: Search by name
putin = us_sanctions[us_sanctions['name'].str.contains('Putin', case=False, na=False)]
print(putin[['name', 'schema', 'countries', 'sanctions']])
```

## Files Modified

1. `Makefile` - Added sanctions targets with detailed echo messages
2. `docker-compose.dev.yml` - Changed port from 5432 to 5444
3. `ui/README.md` - Updated database port in examples
4. `ui/Dockerfile` - Updated database port in comments
5. `zavod/zavod/integration/duckdb_index.py` - Updated port in comments

## Files Created

1. `SANCTIONS_CRAWL.md` - Comprehensive crawling guide
2. `SANCTIONS_QUICKREF.md` - Quick reference card
3. `CHANGES_SUMMARY.md` - This summary document

## Testing

All targets tested and verified:
- ✓ `make sanctions-all` - Successfully crawls and exports both datasets
- ✓ `make sanctions-info` - Displays correct summary information
- ✓ `make crawl-us-ofac` - Crawls US OFAC data
- ✓ `make crawl-eu-sanctions` - Crawls EU sanctions data
- ✓ `make export-us-ofac` - Exports US data to CSV
- ✓ `make export-eu-sanctions` - Exports EU data to CSV
- ✓ CSV files generated correctly with proper formatting
- ✓ Record counts match expected values

## Notes

- All warnings about missing program keys (e.g., 'US-CUBA' not found) are expected and can be safely ignored
- The crawler automatically caches data to avoid unnecessary re-downloads
- Database port change (5432 → 5444) prevents conflicts with existing PostgreSQL installations
- All echo messages provide clear feedback about operations in progress
- File sizes and record counts are displayed for verification
