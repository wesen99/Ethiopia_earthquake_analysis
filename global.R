# Load required libraries
library(shiny)
library(bs4Dash)
library(thematic)
library(waiter)
library(mapdeck)
library(shinydashboard)
library(dplyr)
library(leaflet)
library(plotly)
library(lubridate)
library(jsonlite)
library(httr)
library(xml2)
library(readr)
library(DT)
library(curl)
library(fresh)

# Enable automatic theming
#thematic_shiny()

plot_colour <- "#8965CD"

theme <- create_theme(
  bs4dash_color(
    lime = "#52A1A5",
    olive = "#4A9094",
    purple = "#8965CD"
  ),
  bs4dash_status(
    primary = "#E1EDED",
    info = "#E4E4E4"
  )
)


# Helper functions
source("helpers.R")