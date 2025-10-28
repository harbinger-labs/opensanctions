# SHELL specifies the shell used by Make. Bash is used for its array and string manipulation capabilities.
SHELL := /bin/bash

# Check if 'docker-compose' is available, if not, use 'docker compose'.
COMPOSE_CMD := $(if $(shell which docker-compose 2>/dev/null),docker-compose,docker compose)

# Docker image for running zavod commands
DOCKER_IMAGE := ghcr.io/opensanctions/opensanctions:latest

# Database port configuration (changed from 5432 to 5444 to avoid port conflicts)
DB_PORT := 5444

.PHONY: build

all: run

workdir:
	mkdir -p data/

build:
	$(COMPOSE_CMD) build --pull

shell: build workdir
	$(COMPOSE_CMD) run --rm app bash

run: build workdir
	$(COMPOSE_CMD) run --rm app opensanctions run

stop:
	$(COMPOSE_CMD) down --remove-orphans

clean:
	rm -rf data/datasets build dist .mypy_cache .pytest_cache

# ============================================================================
# SANCTIONS DATA CRAWLING AND EXPORT
# ============================================================================
# These targets crawl sanctions data from US and EU sources and export to CSV
# All data is stored in the data/datasets/ directory
# ============================================================================

.PHONY: sanctions-all sanctions-crawl sanctions-export sanctions-us sanctions-eu
.PHONY: crawl-us-ofac crawl-eu-sanctions export-us-ofac export-eu-sanctions
.PHONY: sanctions-info sanctions-clean

# Main target: Crawl and export all sanctions data
sanctions-all: sanctions-crawl sanctions-export sanctions-info
	@echo ""
	@echo "======================================================================"
	@echo "✓ All sanctions data has been crawled and exported successfully!"
	@echo "======================================================================"

# Crawl all sanctions datasets
sanctions-crawl: crawl-us-ofac crawl-eu-sanctions
	@echo ""
	@echo "======================================================================"
	@echo "✓ All sanctions data crawled successfully"
	@echo "======================================================================"

# Export all sanctions datasets to CSV and other formats
sanctions-export: export-us-ofac export-eu-sanctions
	@echo ""
	@echo "======================================================================"
	@echo "✓ All sanctions data exported successfully"
	@echo "======================================================================"

# Crawl US OFAC SDN (Specially Designated Nationals) List
crawl-us-ofac:
	@echo ""
	@echo "======================================================================"
	@echo "Crawling US OFAC SDN Sanctions List"
	@echo "======================================================================"
	@echo "Dataset: US OFAC Specially Designated Nationals (SDN) List"
	@echo "Source: US Department of the Treasury - Office of Foreign Assets Control"
	@echo "Description: Primary US sanctions list including individuals, companies,"
	@echo "             and entities designated under various sanctions programs"
	@echo "Output: data/datasets/us_ofac_sdn/"
	@echo "======================================================================"
	@echo ""
	docker run --rm \
		-v "$(PWD)/data:/opensanctions/data" \
		$(DOCKER_IMAGE) \
		zavod crawl datasets/us/ofac/us_ofac_sdn.yml
	@echo ""
	@echo "✓ US OFAC SDN data crawled successfully"
	@echo "  Location: data/datasets/us_ofac_sdn/"
	@ls -lh data/datasets/us_ofac_sdn/*.pack 2>/dev/null || true

# Crawl EU Sanctions Map
crawl-eu-sanctions:
	@echo ""
	@echo "======================================================================"
	@echo "Crawling EU Sanctions Map"
	@echo "======================================================================"
	@echo "Dataset: EU Sanctions Map"
	@echo "Source: Council of the European Union"
	@echo "Description: EU sanctions including asset freezes, travel bans, and"
	@echo "             designated vessels under various EU restrictive measures"
	@echo "Output: data/datasets/eu_sanctions_map/"
	@echo "======================================================================"
	@echo ""
	docker run --rm \
		-v "$(PWD)/data:/opensanctions/data" \
		$(DOCKER_IMAGE) \
		zavod crawl datasets/eu/sanctions_map/eu_sanctions_map.yml
	@echo ""
	@echo "✓ EU Sanctions Map data crawled successfully"
	@echo "  Location: data/datasets/eu_sanctions_map/"
	@ls -lh data/datasets/eu_sanctions_map/*.pack 2>/dev/null || true

# Export US OFAC data to CSV and other formats
export-us-ofac:
	@echo ""
	@echo "======================================================================"
	@echo "Exporting US OFAC SDN Data"
	@echo "======================================================================"
	@echo "Exporting to multiple formats:"
	@echo "  - targets.simple.csv    : Simplified CSV format"
	@echo "  - entities.ftm.json     : FollowTheMoney entity format"
	@echo "  - targets.nested.json   : Nested JSON format"
	@echo "  - names.txt             : Plain text list of names"
	@echo "  - senzing.json          : Senzing entity format"
	@echo "======================================================================"
	@echo ""
	docker run --rm \
		-v "$(PWD)/data:/opensanctions/data" \
		$(DOCKER_IMAGE) \
		zavod export datasets/us/ofac/us_ofac_sdn.yml
	@echo ""
	@echo "✓ US OFAC SDN data exported successfully"
	@echo ""
	@echo "CSV Output:"
	@ls -lh data/datasets/us_ofac_sdn/targets.simple.csv 2>/dev/null || true
	@echo ""
	@echo "Record count:"
	@wc -l data/datasets/us_ofac_sdn/targets.simple.csv 2>/dev/null | awk '{print "  " $$1 - 1 " entities (excluding header)"}'

# Export EU Sanctions data to CSV and other formats
export-eu-sanctions:
	@echo ""
	@echo "======================================================================"
	@echo "Exporting EU Sanctions Map Data"
	@echo "======================================================================"
	@echo "Exporting to multiple formats:"
	@echo "  - targets.simple.csv    : Simplified CSV format"
	@echo "  - entities.ftm.json     : FollowTheMoney entity format"
	@echo "  - targets.nested.json   : Nested JSON format"
	@echo "  - names.txt             : Plain text list of names"
	@echo "  - senzing.json          : Senzing entity format"
	@echo "======================================================================"
	@echo ""
	docker run --rm \
		-v "$(PWD)/data:/opensanctions/data" \
		$(DOCKER_IMAGE) \
		zavod export datasets/eu/sanctions_map/eu_sanctions_map.yml
	@echo ""
	@echo "✓ EU Sanctions Map data exported successfully"
	@echo ""
	@echo "CSV Output:"
	@ls -lh data/datasets/eu_sanctions_map/targets.simple.csv 2>/dev/null || true
	@echo ""
	@echo "Record count:"
	@wc -l data/datasets/eu_sanctions_map/targets.simple.csv 2>/dev/null | awk '{print "  " $$1 - 1 " entities (excluding header)"}'

# Display information about crawled sanctions data
sanctions-info:
	@echo ""
	@echo "======================================================================"
	@echo "SANCTIONS DATA SUMMARY"
	@echo "======================================================================"
	@echo ""
	@echo "US OFAC SDN List:"
	@echo "  CSV File: data/datasets/us_ofac_sdn/targets.simple.csv"
	@ls -lh data/datasets/us_ofac_sdn/targets.simple.csv 2>/dev/null | awk '{print "  Size: " $$5}' || echo "  Status: Not yet exported"
	@wc -l data/datasets/us_ofac_sdn/targets.simple.csv 2>/dev/null | awk '{print "  Records: " $$1 - 1 " entities"}' || true
	@echo ""
	@echo "EU Sanctions Map:"
	@echo "  CSV File: data/datasets/eu_sanctions_map/targets.simple.csv"
	@ls -lh data/datasets/eu_sanctions_map/targets.simple.csv 2>/dev/null | awk '{print "  Size: " $$5}' || echo "  Status: Not yet exported"
	@wc -l data/datasets/eu_sanctions_map/targets.simple.csv 2>/dev/null | awk '{print "  Records: " $$1 - 1 " entities"}' || true
	@echo ""
	@echo "All Files Location: data/datasets/"
	@echo ""
	@echo "CSV Columns:"
	@echo "  - id: Unique entity identifier"
	@echo "  - schema: Entity type (Person, Organization, Vessel, etc.)"
	@echo "  - name: Primary name"
	@echo "  - aliases: Alternative names (comma-separated)"
	@echo "  - birth_date: Date of birth (for persons)"
	@echo "  - countries: Associated countries (comma-separated)"
	@echo "  - addresses: Known addresses (comma-separated)"
	@echo "  - identifiers: IDs, passport numbers, etc. (comma-separated)"
	@echo "  - sanctions: Sanction dates (comma-separated)"
	@echo "  - phones: Phone numbers (comma-separated)"
	@echo "  - emails: Email addresses (comma-separated)"
	@echo "  - program_ids: Sanction program identifiers"
	@echo "  - dataset: Source dataset name"
	@echo "  - first_seen: First appearance in dataset"
	@echo "  - last_seen: Last appearance in dataset"
	@echo "  - last_change: Last modification date"
	@echo ""
	@echo "======================================================================"

# Clean only sanctions data (preserves other data)
sanctions-clean:
	@echo ""
	@echo "======================================================================"
	@echo "Cleaning sanctions data..."
	@echo "======================================================================"
	@echo "Removing:"
	@echo "  - data/datasets/us_ofac_sdn/"
	@echo "  - data/datasets/eu_sanctions_map/"
	@echo "======================================================================"
	@echo ""
	rm -rf data/datasets/us_ofac_sdn/
	rm -rf data/datasets/eu_sanctions_map/
	@echo "✓ Sanctions data cleaned"

# Quick aliases for convenience
sanctions-us: crawl-us-ofac export-us-ofac
	@echo ""
	@echo "✓ US OFAC sanctions data ready"
	@ls -lh data/datasets/us_ofac_sdn/targets.simple.csv

sanctions-eu: crawl-eu-sanctions export-eu-sanctions
	@echo ""
	@echo "✓ EU sanctions data ready"
	@ls -lh data/datasets/eu_sanctions_map/targets.simple.csv