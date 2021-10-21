
# PACKAGES
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 'colorZapper', 
          'foreach', 'doParallel', 'DBI'),
          require, character.only = TRUE)

# SETTINGS
  parts      = c('front', 'head_l', 'head_t', 'wing_l')
  basepicdir = '//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA_RENAMED_ROTATED_lowres/'

  dbs = here('DATA/sqlite_files') %>% list.files(full.names = TRUE)
  picdirs = paste0(basepicdir, parts)

  X = data.table(parts, dbs, picdirs)
  X[, i := .I]

# UPDATE photos directory
  X[, {CZopen(dbs) ; CZsetwd(picdirs) }, by = i ]

  # remove absolute path from files
  foreach(i = 1 : 4 ) %do% {
    CZopen(X[i, dbs])
    x = dbGetQuery(getOption('cz.con'), 'SELECT * from files')  %>% setDT
    
    x[, path := str_remove(path, X[i, picdirs]   )]
    
    dbExecute(getOption('cz.con'), 'delete from files')
    
    dbWriteTable(getOption('cz.con'),'files', x, append = TRUE, row.names  = FALSE )
    
  }
  
  
# RUN CZextractROI

  registerDoParallel(50)
  
  X[, { CZopen(dbs); CZextractROI() }, by = i]

  stopImplicitCluster()

# post processing notes
  