#========================================================================================================================
# Extract ROIs from pictures
#========================================================================================================================

# Packages
sapply( c('data.table', 'magrittr', 'sdb', 'ggplot2', 'colorZapper', 'here', 'doFuture'),
        require, character.only = TRUE)

# set working directory
path_pictures = '//ds/raw_data_kemp/FIELD/Barrow/REPH_BODY_PICTURES/DATA_RENAMED_lowres/front'

# set the directory containing the existing SQLITE file (e.g., front)
cz_file = './DATA/REPH_front.sqlite'

# open the SQLITE file
CZopen(path = cz_file)  

# add pictures from the folder (e.g., front)
CZaddFiles(path_pictures)

# register cores
# registerDoFuture()
# plan(multiprocess)

# extract the RGB in the ROIs
CZextractROI(parallel = FALSE) # parallel FALSE/TRUE 
