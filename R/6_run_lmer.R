
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


# RUN lmer models on sex*mark interaction 
  fm2 = lmer(L ~ sex * mark + (1|ID), x)

  fm3 = lmer(a ~ sex * mark + (1|ID), x)
  
  fm4 = lmer(b ~ sex * mark + (1|ID), x)
  

# PLOT effects    

    g2 =
    plot_model(fm2, type = "eff", terms = c("mark", "sex"), sort.est = TRUE)+
       theme_pubclean() + ggtitle("") + xlab('')
  
    g3 =
    plot_model(fm3, type = "eff", terms = c("mark", "sex"), sort.est = TRUE)+
       theme_pubclean() + ggtitle("") + xlab('') 
  
    g4 =
      plot_model(fm4, type = "eff", terms = c("mark", "sex"), sort.est = TRUE)+
     theme_pubclean() + ggtitle("") + xlab('') 


    g2 + g3 + g4
  
