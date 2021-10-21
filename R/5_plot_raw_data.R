
# PACKAGES 
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 
            'lme4', 'emmeans', 'ggplot2', 'ggpubr', 'patchwork', 
            'viridis', 'sjPlot'),
          require, character.only = TRUE)

# COLLECT DATA 
  d =  fread(here('DATA/color_indices.csv')) 
  x = d[!str_detect(mark, 'standard'), .(ID,sex, parts,mark,L,a,b,col)]
  
  x[, mark := factor(mark, 
              levels = c("bill", "crown","chin", "belly", "cheek","wing"))]


 
# PLOT raw data
  ggplot(x, aes (a,b,color = L) ) +
    geom_point(alpha = 0.6,stroke = 0, shape = 19, size = 2) +
    scale_color_viridis() + theme_pubclean()  
  
  ggplot(x, aes (a,b,color = L) ) +
    facet_wrap(~mark) +
    geom_point(alpha = 0.6,stroke = 0) +
    scale_color_viridis()  + theme_pubclean()
  
# PLOT xy, color
  z = x[mark == "crown"]
  ggplot(z, aes(L, a)) +
    facet_grid(~sex) +
    geom_point(alpha = 0.8, stroke = 0, shape = 19, size = 4, col = z$col) +
    scale_color_viridis() +
    theme_pubclean() +
    ggtitle("crown")
  
  ggplot(z, aes(a, b)) +
    facet_grid(~sex) +
    geom_point(alpha = 0.8, stroke = 0, shape = 19, size = 4, col = z$col) +
    scale_color_viridis() +
    theme_pubclean() +
    ggtitle("crown")

# PLOT color by sex
  g1 =
  ggplot(x, aes(L, sex)) +
    facet_wrap(~mark, scales = 'free', ncol = 1) +
    geom_jitter(alpha = 0.8, stroke = 0, shape = 19, size = 4, col = x$col) +
    scale_color_viridis() +
    theme_pubclean() 

  g2 =
    ggplot(x, aes(a, sex)) +
    geom_jitter(alpha = 0.8, stroke = 0, shape = 19, size = 4, col = x$col) +
    facet_wrap(~mark, scales = 'free', ncol = 1) +
    scale_color_viridis() +
    theme_pubclean() 

  g3 =
    ggplot(x, aes(b, sex)) +
    geom_jitter(alpha = 0.8, stroke = 0, shape = 19, size = 4, col = x$col) +
    facet_wrap(~mark, scales = 'free', ncol = 1) +
    scale_color_viridis() +
    theme_pubclean() 


  g1 + g2 + g3
