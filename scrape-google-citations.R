# R parser for google scholar
library(rvest)

gscholar_link <- "https://scholar.google.com/citations?hl=en&user=05N5-HMAAAAJ&view_op=list_works&alert_preview_top_rm=2&sortby=pubdate"
readme_loc <- "README.md"

# Fetching Google Scholar data with error handling
citations <- tryCatch({
  read_html(gscholar_link, options = "RECOVER", user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36") |>
    html_nodes(xpath = sprintf(".//tr/td[%d]", 1)) |> 
    (\(x) x[c(-1, -2, -3)])() |>
    purrr::map_chr(~paste0(html_nodes(., xpath=".//text()"), collapse="; ")) |>
    stringr::str_replace("(.*)(, )(\\d\\d\\d\\d$)", "\\1\\3") |>
    (\(x) paste("-", x))() |>
    (\(x) c(
      "  <summary>publications extracted from google scholar</summary>",
      "<br />", "", x, "", "</details>"
    ))()
}, error = function(e) {
  message("Error fetching data from Google Scholar: ", e$message)
  NULL
})

readme_txt <- readLines(readme_loc)
lines_before <- grep("<summary>publications extracted from google scholar</summary>", readme_txt)-1
lines_after <- grep("</details>", readme_txt)
lines_after <- lines_after[lines_after>lines_before][1]+1
writeLines(c(
  readme_txt[1:lines_before],
  citations,
  readme_txt[lines_after:length(readme_txt)]
), con = readme_loc)
