
# PACKAGES 
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 
          'foreach', 'colorspace', 'sdb'),
          require, character.only = TRUE)

# COLLECT DATA 
  d = fread( here('DATA/Lab_means.csv' ) )
  d[, id := .I]
  d[, ID := str_split(path, '_', simplify= TRUE)[1] %>% str_remove('ID'), by = id]

  s = dbq(q = 'SELECT ID, sex from REPHatBARROW.SEX')

  d = merge(d, s, by = 'ID')

# PREPARE colour indices

  # Colour elaboration score: 
      # dist between each plumage patch and the centroid of the entire sample (joint average for L, a, and b). 
      # d[, ces := sqrt((L-mean(L))^2+(a-mean(a))^2+(b-mean(b))^2) ]            



# EXPORT
  # fwrite( d , here('DATA/color_indices.csv')   )

  


  