# Source the other files
source("global.R")
source("helpers.R")
source("ui.R")
source("server.R")

# Run the application
shiny::shinyApp(ui = ui, server = server)

