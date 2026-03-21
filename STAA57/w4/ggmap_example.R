ABE <- read.csv("/Users/mark/Desktop/course/staa57/Apartment Building Evaluation.csv")


library(tidyverse)


ggplot(ABE,aes(y=LATITUDE,x=LONGITUDE))+geom_point()



library(ggmap)


###########
p <- ggmap(get_googlemap(center = c(lon = -79.4, lat = 43.7),
                         zoom = 11, scale = 2,
                         maptype ='terrain',
                         color = 'color'))

p+geom_point(ABE,aes(y=LATITUDE,x=LONGITUDE))

# https://towardsdatascience.com/a-guide-to-using-ggmap-in-r-b283efdff2af

###########




# Alternate solutions
library(ggpubr)
library(jpeg)
img=readJPEG("C:/Users/shahr/OneDrive - University of Toronto/STAA57_Teaching/Lectures/toronto.jpg")


ggplot(ABE,aes(y=LATITUDE,x=LONGITUDE))+background_image(img)+geom_point()



