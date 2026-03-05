library(rvest); library(tidyverse); library(chromote)

scrape_table <- function(session){
  ses$session$DOM$getOuterHTML(nodeId = 113) |>
    pluck(1) |>
    read_html() |>
    html_elements('table#tableresult') |>
    html_table() |>
    pluck(1)
}
# Read website
ses <- read_html_live("https://reyestr.court.gov.ua/")

# Open browser session to see what you are doing
ses$view()

# Open court selection Menu
ses$click(css='a#CourtRegion.multiSelect')

# Press down arrow 10 times to arrive at Kievska oblast
for(i in 1:10){ses$press(css='a#CourtRegion.multiSelect', key_code='ArrowDown')}
# Click button to select
ses$click(css='label.hover')

page <- ses$clone()
page$click(css='input[value="Пошук"]')
# Press search
ses$click(css='input[value="Пошук"]')
# Scrape table on page x, then switch to page x+1 and repeat, this until end
scrape_table(ses)
ses$html_elements(xpath='div')

ses
