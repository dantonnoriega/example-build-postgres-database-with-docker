# GOAL: pivot data from wide to long, limit time frame, export
# SOURCE: (download manually)
# - https://fred.stlouisfed.org/graph/?id=CPIENGSL,CUSR0000SAD,CUSR0000SAN,CUSR0000SAS367,CUSR0000SAS2RS,CUSR0000SAS,CUSR0000SA311,CUSR0000SAC,#

files <- list.files(here::here("data"), full.names = TRUE, pattern = 'fredgraph.*')
#> [1] "fredgraph.csv"  

# load and transform
dat <- 
  purrr::map_dfr(files, readr::read_csv, na = c("", ".")) |>
  tidyr::pivot_longer(cols = !c("DATE"), names_to = 'index', values_to = "value") |>
  dplyr::rename(date = "DATE") |>
  tidyr::drop_na(value) |>
  dplyr::filter(date >= as.Date('1956-01-01')) |>
  dplyr::arrange(date, index)
dat
# export
readr::write_csv(dat, here::here('data/fred_cpi_1956_2023.csv'))

# fun plot
gg <- 
  dat |>
  ggplot2::ggplot(ggplot2::aes(x = date, y = value, color = index)) +
  ggplot2::geom_line(lwd = 0.8, alpha = 0.6) +
  ggplot2::theme_minimal()
#
gg
#
plotly::ggplotly(gg)