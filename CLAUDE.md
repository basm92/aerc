# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Course materials for the **Applied Economics Research Course (AERC): Historical Persistence & Geospatial Economics** at Utrecht University (taught by Bas Machielsen). The course covers geospatial econometrics applied to historical persistence questions.

## Repository Structure

- `slides/` — Lecture slides: lectures 1–3 and 6 are `.qmd` (Quarto beamer); lectures 4–5 are `.Rmd` (xaringan, not yet migrated)
- `notebooks/` — Quarto HTML notebooks for student practicals (geospatial analysis, RDD, synthetic control)
- `data/` — Geospatial datasets: GeoJSON, rasters (France/Germany, Netherlands/Roman Empire, schools)
- `documentation/` — Codebooks and course documentation
- `main.py` — Python utility (web scraping via LangChain)

## Build Commands

### Render the Quarto book (notebooks + index)
```bash
quarto render
```

### Render a single slide deck (beamer PDF)
```bash
quarto render slides/lecture1_introduction/introduction.qmd
```

### Render a single notebook
```bash
quarto render notebooks/compute_roads_distance_wijk.qmd
```

### Run Python scripts
```bash
uv run main.py
```

### Install Python dependencies
```bash
uv sync
```

## Quarto Book Layout

The project is a Quarto **book** (`_quarto.yml`, `type: book`). The book renders `.qmd` files in the root and `notebooks/` as HTML chapters. Slides in `slides/` are excluded from the book render (`render: - "!slides/*"`) and must be rendered separately. PDFs of rendered slides are linked directly from `_quarto.yml` as book chapters.

## Slide Format

- Lectures 1–3, 6, example: Quarto beamer (`.qmd`) with `format: beamer`, `aspectratio: 169`, code chunks using `#|` options
- Lectures 4–5: xaringan R Markdown (`.Rmd`) — use the `rmd-to-qmd` skill if migrating these to Quarto beamer

## Tech Stack

**R** is the primary language. Key packages:
- `sf` + `tidyverse` — geospatial data wrangling
- `fixest` — fixed effects / IV regression (`feols`)
- `modelsummary` — publication-style regression tables
- `rdrobust` — regression discontinuity estimation
- `spdep` — spatial weights and Moran's I (lecture 6)
- `cawd` — historical boundary data (Roman Empire 117 AD)
- `cbsodataR` — CBS (Statistics Netherlands) geographic data

**Python** is managed with `uv`. Dependencies: `langchain`, `langchain-community`, `bs4`, `pandas`.

## Data Sources

- `data/france_germany/france_germany_updated.geojson` — France/Germany border region (treatment: `tretmnt`, population density: `POP_DEN`, NUTS-2/3 regions)
- `data/netherlands/netherlands_roman_updated.geojson` — Netherlands municipalities with Roman Empire proximity
- `data/schools/` — Dutch school geocoded data + NOx raster (`nox_avg_22.tif`)
- `documentation/codebook_fr_gr/`, `documentation/codebook_netherlands_roman/` — variable codebooks
- Notebook-local GeoJSON copies in `notebooks/` mirror the canonical versions in `data/`

## Known Issues (from README)

- `notebooks/france_roads_persistence.qmd` — needs debugging
- `slides/lecture2_data_wrangling/data_wrangling.qmd` — needs inspection and debugging
