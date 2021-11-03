
# PACKAGES
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 'colorZapper', 
          'foreach', 'doParallel'),
          require, character.only = TRUE)

# SETTINGS
  parts = c('front', 'head_l', 'head_t', 'wing_l')
  basepicdir <- "//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA_RENAMED_ROTATED_lowres/"

  dbs = here('DATA/sqlite_files') %>% list.files(full.names = TRUE)
  picdirs = paste0(basepicdir, parts)

  X = data.table(parts, dbs, picdirs)
  X[, i := .I]

# GET DATA
  o = X[, {CZopen(dbs);CZdata(what= 'ROI')}, by =parts ]

  fwrite(o, here('//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA/RGB.csv')   )
