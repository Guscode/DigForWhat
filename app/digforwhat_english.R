install.packages("pacman")
library(pacman) # To load and install packages


p_load(shiny, # R shiny functions
       leaflet, # Mapping
       sf, # Spatial operations with shapefiles and dataframes 
       dplyr, # General data operations
       shinydashboard, # To create dashboards in Shiny
       shinybusy, # Include spinners for waiting screen
       waiter, # Waiting screen function
       ggplot2, #plot functions
       ggthemes, #plot themes
       RColorBrewer #plot colors
       )

# List with unique findings labels 
labs_list <- read.csv("../data/preprocessed/labs_list.csv")

# Function for linebreaks 
linebreaks <- function(n){HTML(strrep(br(), n))}

# Dataframe containing fun facts
fun_facts <- data.frame(sentence = c("Did you know that religious buildings are often located higher than other types of settlements?", 
                                    "Did you know that old coins in Denmark are often found near the sea? Perhaps because harbours were used for trading."))
# Specifying details of waiting screen
waiting_screen <- tagList(
  spin_ball(),
  linebreaks(9),
  h3(sample(fun_facts$sentence, 1), style = "color:#FF8866;font-weight: 100;font-family: 'Helvetica Neue', Helvetica;font-size: 27px;"),
)


# Starting with the start page (here called DigForWhat) with two panes 
ui <- navbarPage("DigForWhat", id="nav",
           # Creating a panel where we can include the map
           tabPanel("Explore",
                    # Fluid page layout
                    fluidPage(
                    # Does not seem to influence the page layout
                    div(class="outer",
                    
                    tags$head(
                      # Include customized CSS 
                      includeCSS("styles.css"),
                      includeScript("gomap.js")
                    ),
                    
                  # Shiny versions prior to 0.11 should use class = "modal" instead.
                      
                      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                      # Content of the page
                  
                  # Insert the waiter function to show waiting screen with fun facts
                  use_waiter(), 
                  
                  # Fluid row layout
                  fluidRow(
                        # Column with map
                        column(9,leafletOutput("map")), 
                        # Column with text and buffer input possibilities
                        column(3, style='padding-left:0px; padding-right:50px; padding-top:5px; padding-bottom:5px',          
                               h3("Explore ancient findings"),
                                           textOutput("BufferIntro"),
                                           linebreaks(1),
                                           numericInput("buf_dist", "Choose number of kilometres to search within:", 3),
                                           linebreaks(1),
                                           wellPanel(textOutput("AddDescription"),
                                           selectInput("descrip", "If you have a comment or wish to add a new description, please do so below.", choices=c("Choose type...", sort(labs_list$labs_list))),
                                           textInput("text", label="Add description here:", value=""),
                                           actionButton("button", icon("paper-plane")), #fas fa-check-circle
                                           textOutput("thanks")))
                      )

           ))),
           # Creating a panel where we can create analysis of location of findings
           tabPanel("Analysis",
                    # Fill page layout so map fills entire screen
                    fillPage(
                    div(class="outer",
                                            
                        tags$head(
                          # Include customized CSS 
                          includeCSS("styles.css"),
                          # includeScript("gomap.js")
                        ),
                        tags$style(type = "text/css"), #  "#map {height: calc(100vh - 80px) !important;}
                        # fillRow and fillCol layout
                        # Map content
                        fillRow(leafletOutput("map_municipal", height = "100%"),
                        # Analysis content
                        fillCol(flex = NA, style='padding-left:20px; padding-right:50px; padding-top:5px; padding-bottom:5px',
                                h2("Municipality Analysis"),
                                textOutput("AnalysisIntro"),
                                plotOutput("over_rep_plot", height = 180),
                                plotOutput("count", height = 180),
                                plotOutput("top_elev", height = 180)
                                 ))
                          
                          )
                        )
                    )
            
           )
           


server <- function(input, output){
  # Explore section
  
  # Waiting screen
  waiter_show(html = waiting_screen, color = "#34495E")
  
  # Text in explore section
  output$BufferIntro <- renderText({"Welcome to the platform where you can explore ancient findings in Denmark. Here, you can investigate the findings in your area by zooming in and clicking on your location on the map. Afterwards, you can click the 'Analysis'-tab in the top to see which findings make your municipality special!"})
  output$AddDescription <- renderText({"Is the description missing?"})
  # Load data
  data <- sf::st_read("../data/anlaeg_all_4326.shp")

  # Preprocess
  data2 <- data[!(!is.na(data$anlaegsbet) & data$anlaegsbet==""), ] #remove NAs
  data2$id <- seq_len(nrow(data2)) #create ID
  data2$geometry <- st_transform(data$geometry, "+proj=utm +zone=42N +datum=WGS84 +units=km") #transform to WGS84 crs
  
  # Add extra info to data
  data2$color_category <- read.csv("../data/preprocessed/color_category.csv")$color_category
  data2$colors <- read.csv("../data/preprocessed/color_category.csv")$colors
  data2 <- left_join(data2, read.csv("../data/preprocessed/anlaeg_description.csv"), by = "anlaegsbet")
  
  #create list of latitudes as string in order to avoid map_click problems
  data$lat <- gsub("c\\(", "", as.character(data$geometry))
  data$lat <- gsub(",.*", "", as.character(data$lat))
  data$lat <- round(as.numeric(data$lat),7)
  
  # Center on click
  variables = reactiveValues(lat = FALSE, lng = FALSE)
  
  # Create map  
  output$map <- renderLeaflet({
    this_lat <- 56.2
    this_lng <- 11
    zm = 7
    
    # Show initial map of DK if the map has not been clicked
    if(is.null(input$map_click)){
      this_map <- leaflet() %>% clearPopups() %>% 
        addTiles() %>%
        setView(lng = this_lng, lat = this_lat, zoom=zm)
    }else{ this_map <- map_reactive() }
    this_map
    })
    # Removing the waiting screen with fun facts
    waiter_hide()
  
  # Creating reactive event
  map_reactive <- eventReactive(input$map_click, { 

    if(round(as.numeric(unlist(input$map_click[2])),7) %in% data$lat == FALSE){ #If point is clicked, specify lon, lat
      variables$lng <- as.numeric(unlist(input$map_click[2]))
      variables$lat <- as.numeric(unlist(input$map_click[1]))
    }
      #specify lon, lat and zoom
      this_lng <- as.numeric(unlist(input$map_center$lng)) 
      this_lat <- as.numeric(unlist(input$map_center$lat))
      zm = input$map_zoom
    
      # Create center-point
      center <- st_point(c(variables$lng, variables$lat))
      d = data.frame(a = 1)
      d$geom = st_sfc(center)
      center <- st_as_sf(d$geom, crs = 4326, relation_to_geometry = "field")
      
      # Transform projections
      buffer_point <- st_transform(center, "+proj=utm +zone=42N +datum=WGS84 +units=km")
      
      # Create buffer
      buffer <- st_buffer(buffer_point, input$buf_dist)
      row_numbers <- st_intersection(buffer, data2)
      
      # Change CRS to WGS84
      row_numbers <- st_transform(row_numbers, "WGS84")
      
      #Create list of points with lon lat
      buffer_points <- row_numbers$x
      lon <- c()
      lat <- c()
      for(point in buffer_points){
        simple_point <- unlist(point)
        lon <- c(lon,simple_point[1])
        lat <- c(lat,simple_point[2])
      }
      
      
      # Map colors - defining palette based on category
      pal <- colorFactor(unique(data2$colors), unique(data2$color_category)) 
      
      
      if(length(lon) != 0){ #If there are points within the buffer, show them
        this_map <- leaflet(row_numbers) %>% clearPopups() %>%
          addTiles() %>% 
          setView(lng = this_lng, lat = this_lat, zoom=zm) %>% 
          addCircles(~lon, ~lat, label = ~anlaegsbet, layerId = ~id, color = ~pal(color_category), fillOpacity=0.4)
      } else{ #If there are no points within the buffer dont change map
        this_map <- leaflet() %>% clearPopups() %>%
          addTiles() %>% 
          setView(lng = this_lng, lat = this_lat, zoom=zm)
      }

      this_map
    
    
    })
  
  # Show a popup at the given location
  showPopup <- function(id, lat, lng) {
    selectedPoint <- data2[data2$id == id,]
    content <- as.character(tagList(
      tags$h4(selectedPoint$anlaegsbet),
      tags$strong(HTML(sprintf("%s, %s (fra %s til %s)",
                               selectedPoint$stednavn, selectedPoint$datering, selectedPoint$fra_aar, selectedPoint$til_aar
      ))), tags$br(),tags$br(),
      tags$details(tags$summary("Læs mere...", style="color:blue"), sprintf("%s", selectedPoint$description)), tags$br()
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
  }

  
  # When map is clicked, show a popup with info
  observeEvent(input$map_shape_click, {
    
    leafletProxy("map") %>% clearPopups()
    isolate({
      showPopup(input$map_shape_click$id, input$map_shape_click$lat, input$map_shape_click$lng)
    })
    
  })
  
  # Upon click of action button, save suggestions in .csv-file
  observeEvent(input$button, {
    Desc_df = data.frame(anlaegsbet = input$descrip, description = input$text)
    now <- Sys.time()
    write.csv(Desc_df, file=paste0(format(now, "%Y%m%d_%H%M%S_"), "suggestions.csv"), row.names = FALSE)
    output$thanks <- renderText("Thank you! We will update the app with your suggestion as soon as possible.")
    
  })
  
  # Analysis section
  source("plot_functions_english.R")
  output$AnalysisIntro <- renderText({"Here, you can explore the findings in different municipalities. Hover over a municipality and click it if you are interested"})
  municipalities <- st_read("../data/municipal_mil_united.shp")
  plot_data <- read.csv("../data/preprocessed/municipality_analysis.csv")
  elev_plot_data <- read.csv("../data/preprocessed/municipal_elevation.csv")
  output$map_municipal <- renderLeaflet({
    this_lat <- 56.2
    this_lng <- 11
    zm = 7
    
    # Create map with municipalities
    leaflet() %>%
      addTiles() %>% 
      setView(lng = this_lng, lat = this_lat, zoom = 7) %>% 
      addPolygons(data = municipalities, 
                  opacity = 0.1,
                  weight = 4,
                  color = "forestgreen",
                  layerId = municipalities$KOMNAVN,
                  
                  # Highlight neighbourhoods upon mouseover
                  highlight = highlightOptions(
                    weight = 3,
                    fillOpacity = 0.5,
                    color = "dark green",
                    opacity = 1.0,
                    bringToFront = TRUE,
                    sendToBack = TRUE),                     
                  label = municipalities$KOMNAVN,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "10px",
                    direction = "auto"))
  })
  # Update the location selectInput on map clicks
  observeEvent(input$map_municipal_shape_click, { 
    m <- input$map_municipal_shape_click
    municipality <- m$id
    # Create plots to show in analysis section
    output$over_rep_plot <- renderPlot({create_rep_plot(kommun = municipality, alle_kommuner = plot_data)})
    output$count <- renderPlot({create_count_plot(kommun = municipality, alle_kommuner = plot_data)})
    output$top_elev <- renderPlot({elev_plot(kommune = municipality, elev_df = elev_plot_data)})
    
  })
}
shinyApp(ui = ui, server = server)
