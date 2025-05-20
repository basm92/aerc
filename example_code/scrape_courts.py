from io import StringIO
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup
import pandas as pd
import time

def scrape_table(page):
    # Get the HTML of the table
    table_html = page.inner_html('div#divresult')
    
    # Parse with BeautifulSoup
    table = pd.read_html(StringIO(table_html))
    
    # Convert to pandas DataFrame
    if table:
        return table[0]
    return None

p = sync_playwright().start()
# Launch browser (headless=False to see what's happening)
browser = p.chromium.launch(headless=False)
page = browser.new_page()

# Navigate to the website
page.goto("https://reyestr.court.gov.ua/")

# Open court selection menu
page.click('a#CourtRegion.multiSelect')

# Press down arrow 10 times to arrive at Kievska oblast
for _ in range(10):
    page.keyboard.press('ArrowDown')
    time.sleep(0.2)  # slight delay between presses
    
# Click to select
page.click('label.hover')

# Click search button
page.click('input[value="Пошук"]')

# Wait for results to load
page.wait_for_selector('table#tableresult')
# Scrape the table
out = scrape_table(page)

while True:    
    # Check if there are more pages
    try:
        next_button = page.get_by_text(">", exact=True).first
        if not next_button.is_visible():
            print("No more pages found")
            break
    except Exception as e:
        print(f"Error finding next button: {e}")
        break
    
    # Click the button and wait for the next page to load
    next_button.click()
    # Wait for the new results to load
    page.wait_for_selector('table#tableresult')
    # Scrape the table
    df = scrape_table(page)
    if df is not None:
        out = pd.concat([out, df], ignore_index=True)
    else:
        print("No more data found")
        break
    if "dis" in next_button.get_attribute("class"):
        print("Next button is disabled - last page reached.")
        break

out.drop_duplicates().to_csv('court_data.csv', index=False)
browser.close()