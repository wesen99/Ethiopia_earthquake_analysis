ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "Ethiopian Earthquake Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Statistical Analysis", tabName = "stats", icon = icon("chart-bar")),
      menuItem("Data Table", tabName = "data", icon = icon("table")),
      menuItem("News", tabName = "news", icon = icon("newspaper")),
      sliderInput("days", "Days to analyze:", 30, min = 1, max = 365),
      sliderInput("min_magnitude", "Minimum magnitude:", 4, min = 4, max = 10, step = 0.5),
      actionButton("refresh", "Refresh Data", class = "btn-primary")
    )
  ),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        @keyframes waveMotion {
          0% { transform: translateY(0); }
          25% { transform: translateY(-5px); }
          50% { transform: translateY(0); }
          75% { transform: translateY(5px); }
          100% { transform: translateY(0); }
        }
        .wave-box {
          display: inline-block;
          animation: waveMotion 1.5s infinite ease-in-out;
        }
      "))
    ),
    tabItems(
      tabItem(
        tabName = "overview",
        fluidRow(
          valueBoxOutput("total_quakes", width = 4),
          valueBoxOutput("avg_magnitude", width = 4),
          valueBoxOutput("max_magnitude", width = 4)
        ),
        fluidRow(
          infoBoxOutput("recent_count_24", width = 4),
          infoBoxOutput("recent_count_48", width = 4),
          infoBoxOutput("avg_depth", width = 4)
        ),
        fluidRow(
          box(
            title = "Earthquake Locations",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            leafletOutput("map", height = 650)
          )
        )
      ),
      tabItem(
        tabName = "stats",
        fluidRow(
          box(
            title = "Magnitude Distribution",
            width = 6,
            solidHeader = TRUE,
            status = "info",
            plotlyOutput("magnitude_hist", height = 400)
          ),
          box(
            title = "3D Scatter Plot of Earthquakes",
            width = 6,
            solidHeader = TRUE,
            status = "primary",
            plotlyOutput("scatter_3d", height = 400)
          ),
          box(
            title = "Earthquakes Over Time",
            width = 6,
            solidHeader = TRUE,
            status = "warning",
            plotlyOutput("time_series", height = 400)
          )
        )
      ),
      tabItem(
        tabName = "data",
        box(
          title = "Detailed Earthquake Data",
          width = 12,
          solidHeader = TRUE,
          status = "primary",
          DTOutput("quake_table")
        )
      ),
      tabItem(
        tabName = "news",
        box(
          title = HTML('<a href="https://news.google.com/search?q=ethiopian+earthquake" target="_blank" style="color: white; text-decoration: none;">Latest Earthquake News 🔗</a>'),
          status = "danger",
          solidHeader = TRUE,
          width = 12,
          div(
            style = "background-color: #f8d7da; padding: 10px; border-radius: 5px;",
            strong("⚠️ Important: "), "Latest updates on Ethiopian earthquakes from news sources."
          ),
          tableOutput("news_table")
        )
      )
    )
  )
)