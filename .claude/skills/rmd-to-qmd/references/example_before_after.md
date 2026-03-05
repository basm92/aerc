# Complete Before/After Conversion Example

## Source: xaringan .Rmd

```rmd
---
title: "Historical Persistence"
subtitle: "Applied Economics Research Course"
author: "Bas Machielsen"
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

```{r setup, include=F}
library(tidyverse); library(pacman); library(modelsummary)
knitr::opts_chunk$set(warning=F, message=F, fig.retina = 3)
```

class: inverse, center, middle

# Data & Methodology

---

# Data

- On your data slide, you explain the data sources you have used

---

# Methodology

- Explain your empirical method

$$Y_{ij} = \alpha + \beta_1 X_{ij} + \epsilon_{ij}$$

---

# Results

```{r, echo=F, fig.width=6, fig.height=4, fig.align='center'}
plot(mtcars$mpg, mtcars$cyl)
```

---

# Regression Results

```{r, echo=FALSE}
model1 <- lm(mpg ~ cyl, data=mtcars)
model2 <- lm(mpg ~ qsec, data=mtcars)

modelsummary(
  list(model1, model2),
  stars=TRUE,
  gof_map = c("r.squared", "nobs")
)
```

---

class: inverse, center, middle

# Conclusion

---

# Conclusion

- Summary of findings here
```

---

## Target: Quarto beamer .qmd

```qmd
---
title: Historical Persistence
subtitle: Applied Economics Research Course
author: Bas Machielsen
format: beamer
aspectratio: 169
---

```{r setup}
#| include: false
library(tidyverse); library(pacman); library(modelsummary); library(tinytable)
knitr::opts_chunk$set(warning=FALSE, message=FALSE, fig.retina=3)
```

# Data & Methodology

## Data

- On your data slide, you explain the data sources you have used

## Methodology

- Explain your empirical method

$$Y_{ij} = \alpha + \beta_1 X_{ij} + \epsilon_{ij}$$

## Results

```{r}
#| echo: false
#| fig-width: 6
#| fig-height: 4
#| fig-align: 'center'
plot(mtcars$mpg, mtcars$cyl)
```

## Regression Results

```{r}
#| echo: false
model1 <- lm(mpg ~ cyl, data=mtcars)
model2 <- lm(mpg ~ qsec, data=mtcars)

modelsummary(
  list(model1, model2),
  stars=TRUE,
  gof_map = c("r.squared", "nobs")
) |> theme_latex(
    resize_width = 0.3,
    resize_direction = 'both'
)
```

# Conclusion

## Conclusion

- Summary of findings here
```

---

## Key Changes Annotated

1. **YAML**: Removed `institute`, `date`, entire `output:` block. Added `format: beamer`, `aspectratio: 169`. Stripped quotes from string values.

2. **Section break**: `class: inverse, center, middle` + `# Data & Methodology` + `---` → just `# Data & Methodology`.

3. **Slide headers**: `# Data`, `# Methodology`, `# Results`, `# Regression Results`, `# Conclusion` → `## Data`, etc. (promoted to h2).

4. **`---` separators**: All removed.

5. **Setup chunk**: `include=F` → `#| include: false`. Added `library(tinytable)`. Removed `knitr::opts_chunk$set()`.

6. **Figure chunk**: Inline options `echo=F, fig.width=6, fig.height=4, fig.align='center'` → separate `#|` lines with hyphenated names and YAML booleans.

7. **modelsummary**: Added `|> theme_latex(resize_width=0.5, resize_direction='both')` (2 models → 0.5).

8. **Bullet spacing**: Blank lines between consecutive bullet points removed.
