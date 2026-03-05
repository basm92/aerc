library(tidyverse)
library(scpi)

# the treatment for smoking laws adoption in 4 states (fictitious) at different times
data("smoking")
smoking <- smoking |>
  mutate(treatment = if_else((state == "Iowa" & year > 1976) | 
                               (state == "Arkansas" & year > 1980) |
                               (state == "Alabama" & year > 1977) |
                               (state == "California" & year > 1975), 1, 0))

# you need a data.frame with data.frame, id var, outcome var, treatment var, time var, list of donors
# and effect=time is the most commonly used
df <- scdataMulti(smoking, id.var = "state", outcome.var = "cigsale",
              treatment.var = "treatment", time.var = "year", constant = TRUE,
              donors.est = list(c("North Dakota", "New Hampshire", "Oklahoma", "Tennessee")),
              features = list(c("cigsale", "retprice")),
              cov.adj = list(c("constant", "trend")),
              effect = "time")

# Estimate across-time treatment effects with positive weights from the donor pool
res <- scest(df, w.constr = list("name" = "simplex"))
scplotMulti(res)

# Estimate bootstrapped confidence intervals
respi <- scpi(df, w.constr = list("name" = "simplex"), cores = 4, sims = 50, e.method = "gaussian")
scplotMulti(respi, type="series")
