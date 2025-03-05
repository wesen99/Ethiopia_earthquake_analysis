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
library(DT)
library(curl)
library(fresh)

# Enable automatic theming
thematic_shiny()

plot_colour <- "#8965CD"

# Helper functions
source("helpers.R")