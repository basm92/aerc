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
rD <- rsDriver(browser = "chrome", port=4569L, chromever = "114.0.5735.90", extraCapabilities = list(
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
  
  huizen_one_page <- html_code |>
    read_html() |>
    html_elements('div.flex.justify-between div.min-w-0')
  
  data_one_page <- get_information_on_one_page(huizen_one_page)
  data <- c(data, data_one_page)
  
  # Update the condition and switch to the next page
  
  Sys.sleep(rnorm(2, sd=1))
  
}
