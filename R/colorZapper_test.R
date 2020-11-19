#=======================================================================================================
# Test colorZapper with REPH data
#=========================================================================================================

# NOTES:
    # this script should run in plain R not in Rstudio
    # the working directory should be set with setwd("your_local_path/REPH_coloration")  
    # ⚠ CZdefine can be interrupted and resumed any time. The data is saved after each image. 

# Packages
    sapply( c('colorZapper', 'here'), require, character.only = TRUE)


### STEP 1

# Setup: only run once!
    cz_file = '~/Desktop/REPH.sqlite' 
    CZopen(path = cz_file) 

### STEP 2

# Process front
    CZaddFiles('DATA/example_files/head_t') # run once  

    # interactively define ROI-s: 
    # for standard_white and standard_grey one triangle is enough
    CZdefine(polygons = 1, marks = c('head_top','bill', 'standard_white', 'standard_grey') )


# Process head_l
    CZaddFiles('DATA/example_files/head_l') 
    CZdefine(polygons = 1, marks = c('head_left', 'standard_white', 'standard_grey') )

### STEP 3
    # extract color from the ROI-s    
    CZextractROI()

    # fetch the extracted data from the SQLITE file. 
    d = CZdata(what = 'ROI')

    # opens a pdf with photos and marks for review. 
    CZcheck()   













