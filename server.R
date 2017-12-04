library(shiny)
library(dplyr)
library(magick)
library(glue)
library(jsonlite)
library(longurl)

server <- function(input, output, session) {
  
  observe({
    session$sendCustomMessage(type = 'tw_consumer_key',
                              message = list(key = Sys.getenv("TWITTER_CONSUMER_KEY")))
  })
  
  jp_font <- normalizePath("./www/font/migu-1m-regular.ttf")
  size <- "717x433!"
  icon_size <- "200x200!"
  tw_logo <- image_read("./www/img/twitter.png")
  
  # card
  card <- image_read("./www/img/card.png") %>%
    image_resize(size)
  
  # icon
  icon_path <- "./www/img/default.png"
  tmp <- reactiveValues(icon_path = icon_path)
  
  ## When uploading new image
  observeEvent(input$upload, {
    if (length(input$upload$datapath)){
      tmp$icon_path <<- input$upload$datapath
      updateCheckboxGroupInput(session, "effects", selected = "")
    }
  })
    
  ## When uploading new image
  observeEvent(input$insert_by_twitter, {
    payload <- jsonlite::fromJSON(input$insert_by_twitter)
    tmp$icon_path <<- payload$icon_path
    site_url <- payload$site_url
    df_expanded_url <- site_url %>% 
      longurl::expand_urls()
    if(!is.null(site_url) && df_expanded_url$status_code[[1]]==200L){
      site_url <- df_expanded_url %>% 
        dplyr::pull(expanded_url)
    }
    updateTextInput(session, "username", value = payload$username)
    updateTextInput(session, "tw_account", value = payload$tw_account)
    updateTextInput(session, "site_url", value = site_url)
    updateTextAreaInput(session, "serif", value = payload$serif)
    updateCheckboxGroupInput(session, "effects", selected = "")
  })
    
  # plot
  output$card <- renderImage({
    # elements
    bg_color <- input$bg_color
    username <- input$username
    post <- input$post
    tw_account <- input$tw_account
    site_url <- input$site_url
    serif <- input$serif
    other <- input$other
    
    icon <- tmp$icon_path %>% 
      image_read() %>% 
      image_convert("png") %>% 
      image_scale(icon_size)
    
    # Boolean operators
    if("edge" %in% input$effects)
      icon <- image_edge(icon)
    
    if("charcoal" %in% input$effects)
      icon <- image_charcoal(icon)
    
    if("negate" %in% input$effects)
      icon <- image_negate(icon)    
    
    if("flip" %in% input$effects)
      icon <- image_flip(icon)
    
    if("flop" %in% input$effects)
      icon <- image_flop(icon)
    
    icon <- icon %>% 
      image_implode(input$implode)
      
  
    card <- card %>% 
      image_background(bg_color) %>% # OK
      image_annotate(text = username, location = "+320+200", font = jp_font, size = 50) %>% # OK
      image_annotate(text = post, location = "+320+170", font = jp_font, size = 20) %>% # OK
      image_composite(tw_logo, offset = "+320+280") %>% 
      image_annotate(text = glue::glue("  @{tw_account}"), location = "+350+285", font = jp_font, size = 20) %>% # OK
      image_annotate(text = glue::glue("URL: {site_url}"), location = "+320+320", font = jp_font, size = 20) %>% # OK
      image_annotate(text = other, location = "+320+350", font = jp_font, size = 20) %>% # OK
      image_composite(icon, offset = "+60+50") %>% 
      image_annotate(text = serif, location = "+80+300", font = jp_font, size = 20)
    
    
    
    # Numeric operators
    tmpfile <- card %>% 
      image_write(tempfile(fileext='png'), format = 'png')
    
    # Return a list
    list(src = tmpfile, contentType = "image/png")
  
  })
}