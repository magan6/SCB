
# Installera och ladda in paket
install.packages(c("pxweb", "tidyr", "aws.s3", "readr", "ggplot2"))
library(pxweb)
library(tidyr)
library(aws.s3)
library(readr)
library(ggplot2)

options(scipen = 999)


# Hämta data från PXweb (https://www.statistikdatabasen.scb.se/pxweb/sv/ssd/START__BE__BE0101__BE0101A/FolkmangdDistrikt/table/tableViewLayout1/)
data <- as.data.frame(pxweb_get("https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/FolkmangdDistrikt",
          '{
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:ELandskap",
        "values": [
          "101",
          "102",
          "103",
          "104",
          "105",
          "106",
          "107",
          "108",
          "109",
          "110",
          "211",
          "212",
          "213",
          "214",
          "215",
          "217",
          "316",
          "318",
          "319",
          "320",
          "321",
          "322",
          "323",
          "324",
          "325",
          "999"
        ]
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": ["000000VK"]
      }
    },
    {
      "code": "Tid",
      "selection": {
        "filter": "item",
        "values": ["2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"]
      }
    }
  ],
  "response": {
    "format": "json"
  }
}'))

# Diagram
data %>% 
  dplyr::filter(region %in% c("Närke")) %>%
  ggplot(aes(x = år, y = Antal, group = region, color = region)) +
  geom_line()


# Spara ner tabellen
# Pivotera tabellen till wider med år som kolumner, regioner som rader och antal som värde
data_wide <- data %>% 
  pivot_wider(names_from = år, values_from = Antal) %>% 
  as.data.frame()


# Spara data till SSP Cloud (MinIO)
BUCKET_OUT = "scbmrid"
FILE_KEY_OUT_S3 = "demo/befolkning_2015_2024.csv"

aws.s3::s3write_using(
  data_wide,
  FUN = readr::write_csv,
  object = FILE_KEY_OUT_S3,
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)
