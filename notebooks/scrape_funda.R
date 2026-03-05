# Set up Selenium server
library(RSelenium); library(rvest); library(tidyverse)

# Import function to extract the data
get_information_on_one_page <- function(huizen_one_page) {
  adres <- map(huizen_one_page, ~ {
    .x |>
      html_elements('h2') |>
      html_text2()
  })
  
  adres2 <- map(huizen_one_page, ~ {
    .x |> 
      html_elements('div[data-test-id="postal-code-city"]') |>
      html_text2()
  })
  
  price <- map(huizen_one_page, ~ {
    .x |>
      html_elements('p[data-test-id="price-sale"]') |>
      html_text2()
  })
  
  characteristics <- map(huizen_one_page, ~{
    .x |>
      html_elements('p[data-test-id="price-sale"] + ul') |>
      html_text2()
  })
  
  out <- tibble(adres, adres2, price, characteristics) |> 
    unnest(everything())
  
  return(out)
}

# Set up Selenium
rD <- rsDriver(browser = "chrome", port=4573L, chromever = "127.0.6533.88", extraCapabilities = list(
  chromeOptions = list(
    args = c(
      '--disable-blink-features=AutomationControlled', 
      '--disable-infobars',
      '--disable-dev-shm-usage',
      '--no-sandbox',
      '--disable-gpu',
      '--window-size=1920,1080',
      '--start-maximized',
      '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    )
  )
))

remDr <- rD$client

# Open a browser session and set-up the stuff
remDr$navigate("https://www.funda.nl")
el <- remDr$findElement(using='css selector', "button#didomi-notice-agree-button")
el$clickElement()
el <- remDr$findElement(using='css selector', 'div.relative div.relative svg')
el$clickElement()

# From now on, scrape all pages
condition <- TRUE
data <- list()
while(condition){
  html_code <- remDr$getPageSource() |>
  purrr::pluck(1)
  
  # Get huizen on one page
  huizen_one_page <- html_code |>
    read_html() |>
    html_elements('div.flex.justify-between div.min-w-0')
  
  data_one_page <- get_information_on_one_page(huizen_one_page)
  data <- c(data, data_one_page)
  
  # Update the condition and switch to the next page
  next_button <- remDr$findElement(using='xpath', "//span[contains(text(), 'Volgende')]")
  next_button$clickElement()
  # Stop when the button before Volgende is equal to the page on the url:
  last_button <- html_code |>
    read_html() |>
    html_elements(xpath="//ul[contains(@class, 'pagination') and contains(@class, 'pagination-mobile')]//li[last()-1]") |>
    html_text()
  
  page_current_url <- remDr$getCurrentUrl() |>
    pluck(1) |>
    str_extract("\\d+(?=[^\\d]*$)")
  
  condition <- if_else(last_button == page_current_url, FALSE, TRUE)
  # Sleep
  Sys.sleep(rnorm(n=1, mean=2, sd=0.5))
}

adressen <- data[seq(1, 2668, by = 4)] |> reduce(c)
adressen_2 <- data[seq(2, 2668, by = 4)] |> reduce(c)
prices <- data[seq(3, 2668, by = 4)] |> reduce(c)
info <- data[seq(4, 2668, by = 4)] |> reduce(c)

houses <- tibble(adressen=adressen, adressen_2=adressen_2, prices=prices, info = info)
houses <- houses |>
  mutate(type = str_count(info, "\n")) |>
  mutate(
    footage_interior = str_extract(info, "(.+)m²"),
    footage_exterior = if_else(type == 3, str_extract(info, "\n(.+)m²"), str_extract(info, "(.+)m²")),
    bedrooms = str_extract(info, "\n\\d+\n"),
    energy_label = str_extract(info, "\n(.+)$")) |>
  mutate(across(c(footage_interior, footage_exterior, bedrooms, energy_label), ~ str_remove_all(.x, "\n")),
         across(c(prices, footage_interior, footage_exterior, bedrooms), ~ parse_number(.x)),
         postcode_4 = str_extract(adressen_2, "\\d{4}"),
         prices_per_sq_m = 1000*prices/footage_interior)

houses |> write_csv2("houses_funda.csv")
library(fixest)
test <- feols(prices*1000 ~ footage_interior + footage_exterior + as.factor(energy_label) | postcode_4,
      data=houses |> filter(prices > 100))

houses |>
  filter(prices > 100) |>
  mutate(residual_prices = resid(test, na.rm=F)) |>
  ggplot(aes(x=bedrooms, y = residual_prices)) + geom_point(size=0.002) + geom_smooth()
