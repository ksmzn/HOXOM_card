hd_hello <- htmltools::htmlDependency(
  name = "hello",
  version = "1.15.1",
  src = list(href="//unpkg.com"),
  script = c("hellojs/dist/hello.all.js")
)