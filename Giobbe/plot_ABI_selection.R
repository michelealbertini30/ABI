library(formattable)
library(htmltools)
library(webshot)
library(readr)

# Load data
data <- read.table("ABI_table.csv", sep = ";", header = TRUE)

# Colored headers for ABI1, ABI2, ABI3
colnames(data) <- c(
  as.character(tags$span(style="font-weight:bold;", "Test")),
  as.character(tags$span(style="color: limegreen; font-weight:bold;", "ABI1")),
  as.character(tags$span(style="color: orange; font-weight:bold;", "ABI2")),
  as.character(tags$span(style="color: steelblue; font-weight:bold;", "ABI3"))
)

# Bold all entries in Test column (first column)
ft <- formattable(data, list(
  area(col = 1) ~ formatter("span", style = ~ style(font.weight = "bold"))
))
