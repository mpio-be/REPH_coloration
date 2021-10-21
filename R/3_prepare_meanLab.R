
# PACKAGES 
  sapply( c('data.table', 'magrittr', 'stringr', 'here', 'ggplot2', 
          'foreach', 'colorspace'),
          require, character.only = TRUE)

# COLLECT raw DATA 
  d = fread( here('DATA/RGB.csv') )

# PERFORM calibration

  # some values have R+G+B = 0 making calibration unfeasible (RGB/0=impossible)
  d = subset(d, d$R!=0 | d$G!=0 | d$B!=0)
  
  # create unique ID to associate body part+grey+white
  d$uniqueid = paste(d$parts, d$path, d$id, sep="_")
  
  # body parts
  wi = d$mark=="wing"
  ch = d$mark=="cheek"
  bl = d$mark=="belly"
  cn = d$mark=="chin"
  bi = d$mark=="bill"
  cr = d$mark=="crown"
  
  # calibration patches
  gr = d$mark=="standard_grey"
  wh = d$mark=="standard_white"
  
  # calibration loop
  #R[roi]=(R[roi]/(R[grey]/((R[grey]+G[grey]+B[grey])/3))/(R[white]/((R[white]+G[white]+B[white])/3))
  for(i in length(d$uniqueid)){
    #wing
    d$R[wi] <- (d$R[wi]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[wi] <- (d$G[wi]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[wi] <- (d$B[wi]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    
    #cheek
    d$R[ch] <- (d$R[ch]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[ch] <- (d$G[ch]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[ch] <- (d$B[ch]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    
    #belly
    d$R[bl] <- (d$R[bl]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[bl] <- (d$G[bl]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[bl] <- (d$B[bl]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    
    #chin
    d$R[cn] <- (d$R[cn]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[cn] <- (d$G[cn]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[cn] <- (d$B[cn]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    
    #bill 
    d$R[bi] <- (d$R[bi]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[bi] <- (d$G[bi]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[bi] <- (d$B[bi]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    
    #crown
    d$R[cr] <- (d$R[cr]/mean(d$R[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$R[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$G[cr] <- (d$G[cr]/mean(d$G[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$G[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
    d$B[cr] <- (d$B[cr]/mean(d$B[gr]/((d$R[gr]+d$G[gr]+d$B[gr])/3)))/mean(d$B[wh]/((d$R[wh]+d$G[wh]+d$B[wh])/3))
  }
  
  
  # check for calibrated values above 255 threshold.In case: subset(XXX, XXX$R<=255)
  max(d$R)
  max(d$G) 
  max(d$B) 
  
  d[R >= 255, .N]
  # 1037470 excluded! 
  
  d = d[R <= 255]
  
  # make sure it's a table
  d = as.data.table(d)

# PREPARE means LAB and hex
  m = d[, .(R = mean(R,na.rm = TRUE), G = mean(G,na.rm = TRUE), B = mean(B,na.rm = TRUE)), 
        by = .(parts, mark, path)]
  m[, id := .I] 
  m = na.omit(m) # This should not be! malformed ROI-s ?
 
  m[, col := rgb(R,G,B, max=255), by = id]
  x = data.table(m[, as( hex2RGB(col), "LAB") ]@coords )
  setnames(x, c('L', 'a', 'b'))
  m = cbind(m, x)

# EXPORT
  fwrite(m, here('DATA/Lab_means.csv')   )

  


