---
name: rmd-to-qmd
description: "Convert xaringan R Markdown (.Rmd) presentation files to Quarto beamer (.qmd) format. Use this skill whenever the user wants to migrate, convert, or transform an .Rmd slide deck (especially xaringan presentations) to a .qmd Quarto document. Also trigger when the user mentions converting R Markdown to Quarto, updating slides from xaringan to beamer, or asks to apply Quarto best practices to an existing .Rmd file. Handles YAML header conversion, slide structure, code chunk option migration (inline → #| style), and critical table resizing for beamer output."
---

# Rmd → Qmd Conversion (xaringan → Quarto beamer)

## Overview

This skill converts xaringan R Markdown presentation files to Quarto beamer format. The two formats share R code chunks and markdown content but differ in YAML headers, slide structure syntax, chunk option style, and table formatting requirements for PDF/beamer output.

Always read the source .Rmd file first, then write the converted .qmd to the target path (defaulting to the same directory with a `.qmd` extension).

---

## 1. YAML Header

**Remove** these xaringan-specific fields:
- `institute`
- `date` (or the `` `r Sys.Date()` `` expression)
- The entire `output:` block (including `xaringan::moon_reader`, `css`, `lib_dir`, `nature`, etc.)

**Add/keep**:
- `title`, `subtitle`, `author` — keep as-is (you may strip surrounding quotes if present)
- `format: beamer`
- `aspectratio: 169`

**Example transformation:**

```yaml
# BEFORE (xaringan)
---
title: "My Slides"
subtitle: "Course Name"
author: "Author Name"
institute: "Utrecht University"
date: "`r Sys.Date()`"
output:
  xaringan::moon_reader:
    css: [default, metropolis, metropolis-fonts]
    lib_dir: libs
    nature:
      highlightStyle: github
      highlightLines: true
      countIncrementalSlides: false
---

# AFTER (Quarto beamer)
---
title: My Slides
subtitle: Course Name
author: Author Name
format: beamer
aspectratio: 169
---
```

---

## 2. Slide Structure

Xaringan uses `---` as a slide separator. Quarto beamer uses heading levels instead.

### Rules

| Xaringan pattern | Quarto equivalent |
|---|---|
| `class: inverse, center, middle` + `# Section Title` + `---` | `# Section Title` (just the heading, no separator needed) |
| `# Slide Title` (regular slide) | `## Slide Title` |
| `---` (slide separator) | Remove |

### Step-by-step logic

1. Find every block that matches:
   ```
   class: inverse, center, middle

   # Some Title

   ---
   ```
   Replace the entire block (including the trailing `---`) with just `# Some Title`.

2. For all remaining `# Heading` lines that are _not_ already handled above, promote them to `## Heading` (they become slide titles in beamer).

3. Delete all remaining bare `---` separators (they served only as slide boundaries in xaringan).

4. Be careful not to delete the YAML `---` delimiters.

### Example

```markdown
# BEFORE
---
class: inverse, center, middle

# Data & Methodology

---

# Data

- Slide content here

---

# AFTER
# Data & Methodology

## Data

- Slide content here
```

---

## 3. Bullet Point Spacing

In xaringan, authors often put blank lines between bullet points. In Quarto beamer (PDF output), blank lines between list items break the list into separate blocks, producing unwanted extra vertical space or misformatted slides.

### Rule

Remove blank lines between consecutive bullet points. A "bullet line" is any line that starts with `-` or with leading spaces followed by `-` (i.e. nested bullets).

Two bullet lines are considered consecutive if there is only whitespace/empty lines between them and no intervening content (heading, code block, paragraph text, etc.).

### Example

```markdown
# BEFORE
- First point

- Second point

  - Nested point

  - Another nested

- Third point

# AFTER
- First point
- Second point
  - Nested point
  - Another nested
- Third point
```

**Do not** remove blank lines that separate a bullet list from surrounding prose, headings, equations, or code blocks — only collapse blank lines that sit between two bullet lines.

---

## 4. Code Chunk Options

Quarto uses `#|` prefixed options on separate lines inside the chunk, rather than inline options in the chunk header.

### Option name mapping

| R Markdown (inline) | Quarto (`#|` style) |
|---|---|
| `echo=F` or `echo=FALSE` | `#| echo: false` |
| `echo=T` or `echo=TRUE` | `#| echo: true` |
| `include=F` | `#| include: false` |
| `eval=F` | `#| eval: false` |
| `warning=F` | `#| warning: false` |
| `message=F` | `#| message: false` |
| `fig.width=N` | `#| fig-width: N` |
| `fig.height=N` | `#| fig-height: N` |
| `fig.align='center'` | `#| fig-align: 'center'` |
| `cache=T` | `#| cache: true` |
| `results='hide'` | `#| results: 'hide'` |

Note the pattern: dot-separated names (`fig.width`) become hyphen-separated (`fig-width`), and R logical shorthands (`T`/`F`) become YAML booleans (`true`/`false`).

### Chunk name

The chunk name (if present) stays as the first argument without a `#|` prefix:
```r
# BEFORE
```{r my_chunk, echo=F, fig.width=6}

# AFTER
```{r my_chunk}
#| echo: false
#| fig-width: 6
```

Unnamed chunks: just ```` ```{r} ```` with `#|` options on the lines that follow.

### Setup chunk

The setup chunk typically contains `knitr::opts_chunk$set(...)`. Remove this call entirely — its settings are either redundant in Quarto or should be handled per-chunk with `#|` options. Convert the chunk header and remove the `opts_chunk$set` line:

```r
# BEFORE
```{r setup, include=F}
library(tidyverse)
knitr::opts_chunk$set(warning=F, message=F, fig.retina=3)
```

# AFTER
```{r setup}
#| include: false
library(tidyverse)
```

---

## 5. Table Resizing for Beamer (Critical)

This is the most important content change. In Quarto beamer (PDF output), tables from `modelsummary` and `datasummary` will overflow the slide width unless explicitly resized using `theme_latex()`.

### Rule

Any call to `modelsummary(...)` or `datasummary(...)` that does **not** already pipe into `theme_latex(...)` must have the following appended:

```r
|> theme_latex(
    resize_width = <inferred>,
    resize_direction = 'both'
)
```

`resize_direction = 'both'` resizes both columns and rows proportionally.

**Inferring `resize_width`**: Look at the `list(...)` argument to `modelsummary` or the formula/variables in `datasummary` to count the number of models/columns being displayed:

| Number of models/columns | Suggested `resize_width` |
|---|---|
| 1 | 0.4 |
| 2 | 0.5 |
| 3–4 | 0.6 |
| 5+ | 0.8 |

If you cannot determine the count from context, use `0.5` as a safe default.

### Example

```r
# BEFORE
modelsummary(
  list(model1, model2),
  stars = TRUE,
  gof_map = c("r.squared", "nobs")
)

# AFTER
modelsummary(
  list(model1, model2),
  stars = TRUE,
  gof_map = c("r.squared", "nobs")
) |> theme_latex(
    resize_width = 0.5,   # 2 models → 0.5
    resize_direction = 'both'
)
```

Also check that `tinytable` is loaded (it provides `theme_latex`). If the setup chunk does not load it, add `library(tinytable)` there.

---

## 6. Output File

- Default output path: same directory as input, same filename, `.qmd` extension.
- If the user specifies a target path, use that.
- After writing the file, briefly summarize the changes made (number of slides, chunk option conversions, table fixes).

---

## 7. Checklist Before Writing

Before writing the output file, verify:

- [ ] YAML: `format: beamer` and `aspectratio: 169` present; no xaringan keys remain
- [ ] All `class: inverse, center, middle` lines removed
- [ ] All `---` slide separators removed (YAML delimiters preserved)
- [ ] All `# Slide` headers promoted to `## Slide`
- [ ] Section break headers remain as `#`
- [ ] All inline chunk options converted to `#|` format
- [ ] No blank lines between consecutive bullet points
- [ ] All `modelsummary`/`datasummary` calls pipe into `theme_latex(...)`
- [ ] `library(tinytable)` is present in the setup chunk

---

## 8. Reference: Before/After Example

See `references/example_before_after.md` for a complete annotated before/after showing a representative section of a converted file.
