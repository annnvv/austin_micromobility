  # render function
  renderMyDocument <- function(month_num, month_str) {
    rmarkdown::render("05_parametrized_report/report_by_month.Rmd", 
                      params = list(month_num = month_num, month_str = month_str
    ), output_file = paste0("report_output/Austin_micromobility_report_", month_str, ".html"))
  }
  
  month_num <- seq(4, 7, by = 1)
  month_str <- c("April", "May", "June", "July")

  # apply render function
  if (length(month_num) == length(month_str)) {
    for (i in 1:length(month_num)) {
      renderMyDocument(month_num[i], month_str[i])
    } 
  } else{
    print("Length of month_num and month_str do not equal")
  }
