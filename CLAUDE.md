# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Course materials for the **Applied Economics Research Course (AERC): Historical Persistence & Geospatial Economics** at Utrecht University (taught by Bas Machielsen). The course covers geospatial econometrics applied to historical persistence questions.

## Repository Structure

- `slides/` — R Markdown lecture slides (5 lectures + example presentation)
- `syllabus/` — Course syllabus (R Markdown → PDF via LaTeX)
- `example_code/` — R scripts for student practicals (geospatial analysis, RDD, scraping)
- `data/` — Geospatial datasets: shapefiles, GeoJSON, rasters (France/Germany, Netherlands/Roman Empire, schools)
- `grading_2025.md`, `grades_2025_summary.md` — Per-student grading feedback
- `python_scrape_politicians.py`, `main.py` — Python utilities (web scraping via LangChain)

## Tech Stack

**R** is the primary language. Key packages used across slides and example code:
- `sf` + `tidyverse` — geospatial data wrangling
- `fixest` — fixed effects / IV regression (`feols`)
- `modelsummary` — regression tables
- `rdrobust` — regression discontinuity estimation
- `ggplot2` / `kableExtra` / `tinytable` — visualization and tables
- `quarto` — slide rendering

**Python** is managed with `uv` (see `pyproject.toml`). Dependencies: `langchain`, `langchain-community`, `bs4`, `pandas`.

## Common Commands

### Run Python scripts
```bash
uv run python_scrape_politicians.py
```

### Install Python dependencies
```bash
uv sync
```

## Data Sources

- `data/france_germany/` — France/Germany border region shapefiles (treatment variable: `tretmnt`, population density `POP_DEN`, NUTS-2/3 regions)
- `data/netherlands/` — Netherlands municipalities with Roman Empire proximity data
- `data/schools/` — Dutch school geocoded data
- `data/codebook_*/` — Codebooks for the above datasets
- GeoJSON snapshots: `example_code/france_germany_updated.geojson`, `example_code/netherlands_roman_updated.geojson`

## Econometric Patterns

The codebase consistently uses:
- `fixest::feols()` for OLS/IV with fixed effects
- `modelsummary::modelsummary()` for publication-style tables
- `sf::st_read()` for loading shapefiles/GeoJSON
- Regression Discontinuity via `rdrobust` — see `example_code/rdrobust_to_table.R`
