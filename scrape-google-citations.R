# R parser for google scholar
library(rvest)

gscholar_link <- "https://scholar.google.com/citations?hl=en&user=05N5-HMAAAAJ&view_op=list_works&alert_preview_top_rm=2&sortby=pubdate"
readme_loc <- "README.md"

citations <- read_html(gscholar_link) %>%
  html_nodes(xpath=sprintf(".//tr/td[%d]", 1)) %>% 
  .[c(-1,-2,-3)] %>%
  purrr::map_chr(~paste0(html_nodes(., xpath=".//text()"), collapse="; ")) %>%
  stringr::str_replace("(.*)(, )(\\d\\d\\d\\d$)", "\\1\\3") %>%
  {paste("-", .)} %>%
  {c("  <summary>publications extracted from google scholar</summary>", "<br />", "", ., "", "</details>")}


readme_txt <- readLines(readme_loc)
lines_before <- grep("<summary>publications extracted from google scholar</summary>", readme_txt)-1
lines_after <- grep("</details>", readme_txt)
lines_after <- lines_after[lines_after>lines_before][1]+1
writeLines(c(
  readme_txt[1:lines_before],
  citations,
  readme_txt[lines_after:length(readme_txt)]
), con = readme_loc)
