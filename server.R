server <- function(input, output, session) {
  # Reactive data
  earthquake_data <- eventReactive(input$refresh, {
    req(input$days, input$min_magnitude)
    fetch_earthquake_data(input$days, input$min_magnitude)
  }, ignoreNULL = FALSE)
  
  # Value boxes
  output$total_quakes <- renderValueBox({
    data <- earthquake_data()
    valueBox(
      value = if (nrow(data) == 0) "No data" else nrow(data),
      subtitle = "Total Earthquakes",
      color = "blue",
      icon = icon("globe")
    )
  })
  
  output$avg_magnitude <- renderValueBox({
    data <- earthquake_data()
    valueBox(
      value = if (nrow(data) == 0) "No data" else round(mean(data$magnitude, na.rm = TRUE), 2),
      subtitle = "Average Magnitude",
      color = "aqua",
      icon = icon("chart-line")
    )
  })
  
  output$max_magnitude <- renderValueBox({
    data <- earthquake_data()
    valueBox(
      value = if (nrow(data) == 0) "No data" else round(max(data$magnitude, na.rm = TRUE), 2),
      subtitle = "Strongest Quake",
      color = "red",
      icon = icon("exclamation-triangle")
    )
  })
  
  # Info boxes
  output$recent_count_24 <- renderInfoBox({
    data <- earthquake_data()
    count_24h <- if (nrow(data) == 0) 0 else sum(difftime(Sys.time(), data$time, units = "hours") <= 24)
    
    infoBox(
      title = "Recent Activity (24h)",
      value = tags$span(class = "wave-box", count_24h),  # Apply wave effect
      subtitle = "Last 24 hours",
      color = "yellow",
      icon = icon("wave-square"),  # Use a wave icon
      width = 4
    )
  })
  
  output$recent_count_48 <- renderInfoBox({
    data <- earthquake_data()
    infoBox(
      title = "Recent Activity_48",
      value = if (nrow(data) == 0) "No data" else sum(difftime(Sys.time(), data$time, units = "hours") <= 48),
      subtitle = "Last 48 hours",
      color = "yellow",
      icon = icon("clock")
    )
  })
  
  output$avg_depth <- renderInfoBox({
    data <- earthquake_data()
    infoBox(
      title = "Average Depth",
      value = if (nrow(data) == 0) "No data" else round(mean(data$depth, na.rm = TRUE), 1),
      subtitle = "kilometers",
      color = "green",
      icon = icon("arrow-down")
    )
  })
  
  # Map output
  output$map <- renderLeaflet({
    data <- earthquake_data()
    req(nrow(data) > 0)
    
    pal <- colorNumeric(palette = "YlOrRd", domain = data$magnitude)
    
    leaflet(data) %>% 
      addTiles() %>% 
      addCircleMarkers(
        ~longitude, ~latitude, 
        radius = ~magnitude * 1,
        color = ~pal(magnitude),
        fillOpacity = 0.8,
        popup = ~paste(
          "<strong>Magnitude:</strong>", magnitude, "<br>",
          "<strong>Location:</strong>", place, "<br>",
          "<strong>Time:</strong>", format(time, "%Y-%m-%d %H:%M:%S"), "<br>",
          "<strong>Depth:</strong>", depth, "km"
        )
      ) %>%
      addLegend(
        position = "topright",
        pal = pal,
        values = ~magnitude,
        title = "Magnitude",
        opacity = 0.8
      )
  })
  
  
  output$magnitude_hist <- renderPlotly({
    data <- earthquake_data()
    req(nrow(data) > 0)
    plot_ly(data, x = ~magnitude, type = "histogram", nbinsx = 20)
  })
  # Plots
  output$magnitude_hist <- renderPlotly({
    data <- earthquake_data()
    req(nrow(data) > 0)
    
    plot_ly(
      data,
      x = ~magnitude,
      type = "histogram",
      nbinsx = 20,
      name = "Magnitude Distribution"
    ) %>%
      layout(
        xaxis = list(title = "Magnitude"),
        yaxis = list(title = "Count"),
        showlegend = FALSE
      )
  })
  
  
  
  output$time_series <- renderPlotly({
    data <- earthquake_data()
    req(nrow(data) > 0)
    
    plot_ly(
      data,
      x = ~time,
      y = ~magnitude,
      type = "scatter",
      mode = "markers",
      marker = list(
        size = ~magnitude * 3,
        color = ~magnitude,
        colorscale = "YlOrRd"
      )
    ) %>%
      layout(
        xaxis = list(title = "Time"),
        yaxis = list(title = "Magnitude"),
        showlegend = FALSE
      )
  })
  
  output$scatter_3d <- renderPlotly({
    data <- earthquake_data()
    req(nrow(data) > 0)
    
    plot_ly(
      data,
      x = ~longitude,
      y = ~latitude,
      z = ~magnitude,
      type = "scatter3d",
      mode = "markers",
      marker = list(
        size = 5,
        color = ~magnitude,
        colorscale = "YlOrRd",
        opacity = 0.8
      )
    ) %>%
      layout(
        scene = list(
          xaxis = list(title = "Longitude"),
          yaxis = list(title = "Latitude"),
          zaxis = list(title = "Magnitude"),
          aspectmode = "manual",
          aspectratio = list(x = 1, y = 1, z = 1)
        )
      )
  })
  
  # Data table
  output$quake_table <- renderDT({
    data <- earthquake_data()
    req(nrow(data) > 0)
    datatable(data, options = list(pageLength = 20))
  })
  
  # News table
  output$news_table <- renderTable({
    head(fetch_earthquake_news(),20)
  }, sanitize.text.function = function(x) x)
}
