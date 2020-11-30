# R parser for google scholar
library(rvest)

gscholar_link <- "https://scholar.google.com/citations?user=563lZEwAAAAJ&hl=en"
readme_loc <- "README.md"

citations <- read_html(gscholar_link) %>%
  html_table(header = TRUE, fill = TRUE) %>% 
  .[[2]] %>%
  .[-1,] %>% 
  janitor::clean_names() %>% 
  .$x %>% 
  {paste("-", .)} %>%
  {c("  <summary>publications extracted from google scholar</summary>", "", .,"", "</details>")}


readme_txt <- readLines(readme_loc)
lines_before <- grep("<summary>publications extracted from google scholar</summary>", readme_txt)-1
lines_after <- grep("</details>", readme_txt)
lines_after <- lines_after[lines_after>lines_before][1]+1
writeLines(c(
  readme_txt[1:lines_before],
  citations,
  readme_txt[lines_after:length(readme_txt)]
), con = readme_loc)
