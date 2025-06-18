# Craigslist Rental Scraper (R + RSelenium)

This R script uses **RSelenium** and **rvest** to scrape rental listings from Craigslist for a selected city (e.g. Vancouver or Toronto). The scraper navigates multiple pages, extracts data such as title, price, number of bedrooms, and listing link, and saves the results to a CSV file.

---

## Features

- Automates browser with RSelenium (headless or interactive)
- Extracts:
  - Listing title
  - Price
  - Number of bedrooms
  - Listing URL
  - Scrape date
- Iterates through all pages in search results
- Appends results to a CSV log

---

## Requirements

Install the following R packages:

```r
install.packages(c("RSelenium", "rvest", "dplyr"))
```

Also required:

- Firefox browser
- [geckodriver](https://github.com/mozilla/geckodriver/releases) (must be in your system PATH)
- Java installed and accessible to R

---

## File Structure

```
.
├── craigslist_scraper.R   # Main scraping script
├── vancouver_craigslist_rentals.csv  # Output data (auto-generated)
└── README.md
```

---

## 🔧 Setup Instructions

1. **Set your working directory**
   Edit this line in the script to point to your local directory:
   ```r
   wd <- "/Users/YOURNAME/Documents/R"
   ```

2. **Start script**
   Run the entire `craigslist_scraper.R` file. It will:
   - Launch Firefox via RSelenium
   - Navigate to the Craigslist apartment listings
   - Loop through all result pages
   - Write results to a CSV file

---

## 🌐 Changing the Target City

Modify the `base_url` in the script to any Craigslist city/region:
```r
base_url <- "https://vancouver.craigslist.org/search/vancouver-bc/apa"
```

Other examples:
- Toronto: `https://toronto.craigslist.org/search/toronto-on/apa`
- Montreal: `https://montreal.craigslist.org/search/apa`

---

## ⚠️ Known Issues

- Craigslist listings are dynamically rendered; slower connections may require longer `Sys.sleep()` delays.
- The "next" button selector (`button.cl-next-page`) may change if Craigslist updates their front end — inspect and adjust if needed.
- Ensure no other process is using port `4545` when RSelenium starts.

---

## 📄 License

Use freely, but please respect Craigslist’s [terms of use](https://www.craigslist.org/about/terms.of.use).

---


