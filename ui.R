library(shiny)
library(shinydashboard)
library(colourpicker)
library(htmltools)

header <- dashboardHeader(
  title = "HOXO-M Card",
  tags$li(id="login-status", class = "dropdown",
    tags$li(id="login-user", class = "dropdown", style = "padding-top: 15px; padding-bottom: 15px; color: #fff;"),
    tags$li(id="login-link", class = "dropdown", actionLink("twLogin", "Sign in with Twitter"))
  )
)

body <- dashboardBody(
  tags$head(
    hd_hello,
    includeScript("www/js/app.js"),
    tags$meta(`name`="twitter:card", content="summary_large_image"),
    tags$meta(`name`="twitter:title", content=paste0("hoxo-m, "))
  ),
  fluidRow(
    column(width = 9,
           box(
               title = "名刺",
               width = NULL, solidHeader = TRUE,
               imageOutput("card", height = 500),
               textAreaInput("tweet", "ツイートして名刺をシェアしましょう", value = "匿名知的集団ホクソエムに加入しました！", width = "700px",
                             placeholder = "ツイート内容を記入してください"),
               actionButton("twShare64Btn", "Twitterでシェアする")
           )
    ),
    column(width = 3,
           box(width = NULL, status = "warning",
               actionButton("insert", "Twitterのデータを入力する"),
               tags$br(),
               tags$br(),
               fileInput("upload", "アイコン画像をアップロード", accept = c('image/png', 'image/jpeg')),
               colourInput("bg_color", "背景色選択", "orange"),
               textInput("username", "名前", value = "なまえ"),
               textInput("post", "役職", value = "主任"),
               textInput("tw_account", "Twitterアカウント", value = ""),
               textInput("site_url", "Webサイト", value = ""),
               textAreaInput("other", "他なんでも", value = ""),
               textAreaInput("serif", "コメント", value = "進捗どうですか"),
               checkboxGroupInput("effects", "エフェクト",
                                  choices = list("edge", "charcoal", "negate", "flip", "flop")),
               sliderInput("implode", "Implode", -1, 1, 0, step = 0.01)
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body,
  skin = 'yellow'
)