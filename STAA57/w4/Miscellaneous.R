library(tidyverse)

#############################################
# WIDE to LONG and LONG to WIDE format data
#############################################

library(gapminder)
data(gapminder)

# Creating a small dataset for our examples
d2 = gapminder %>% filter(country %in% c("Canada" , "China" , "Cuba") &
                            year %in% c(1952, 1957, 1962, 1967))



# Creating a wide format data
d2.wide = d2 %>% pivot_wider(id_cols = c(country, continent),
                             names_from = year,
                             names_prefix = "Year_",
                             values_from = lifeExp)


# Another example of pivot_wider
d3.wide = d2 %>% pivot_wider(id_cols = c(country, continent),
                             names_from = year,
                             names_prefix = "Year_",
                             values_from = c(lifeExp,pop))


# wide to long format
d2.long = d2.wide %>% pivot_longer(cols=c(Year_1952,Year_1957,Year_1962,Year_1967),
                                   names_to = "Year",
                                   values_to = "Life_Exp")



############
# Exercise:
############
d = data.frame("Patient_Id" = c(101,101,101,202,202,202,303,303,303),
               "Visit" = c("V1","V2","V3", "V1","V2","V3","V1","V2","V3"),
               "BMI" = c(30, 32, 35, 29, 27, 26, 19, 21, 25))

# Create a wide data using d

d %>%  pivot_wider(id_cols = Patient_Id,
                   names_from= Visit,
                   values_from = BMI)

# convert it back to long format

d %>%  pivot_wider(id_cols = Patient_Id,
                   names_from= Visit,
                   values_from = BMI) %>% 
  pivot_longer(cols=c(V1,V2,V3), names_to = "Visit", values_to = "BMI")





###############
# Matrix in R
###############

m = matrix(c(10,11,12,13,14,15,16,17,18),ncol=3)

m

m2 = matrix(c(10,11,12,13,14,15,16,17,18), ncol=3, byrow=T)

m2


m %*% m2   # Matrix multiplication

m*m2

t(m) # transpose

diag(m)  #diagonal elements of a matrix

solve( matrix(c(1,2,2,1),ncol=2) ) #inverse



# Matrix indexing

m[2 , 3]   # returns the element corresponding to 2nd row and 3rd column

m[2 , ]    # returns entire 2nd row

m[ , 3]    # returns 3rd column



# Indexing works on datasets too
gapminder[1,] # first row of the dataset

gapminder[1, 4] # first row and 2nd, 3rd and 4th column of the dataset


# indexing on a tibble returns a tibble, 
# the following line coverts it into a long list (vector)
gapminder[c(1,2,3),4] %>% unlist(use.names = F)




###############
# Lists in R
###############

my_list= list(a=c(1:10),
              b = c(50:70),
              c=m)

my_list


# accessing elements of a list
my_list$a

my_list[[1]]




##############################
# lapply(), sapply(), apply()
##############################

lapply(my_list, mean)   # calculates mean for each element of a list, returns a list

sapply(my_list, mean)   # similar to lapply(), but returns a vector


# apply (apply a function to the margins[ro or column] of a matrix )
m
apply(m,1,mean)   # calculates mean for each row (1 represents row)


apply(m,1,FUN = ) # we can also provide any user defined function


apply(m,2,mean) # calculates mean for each column




###############################
# Exporting r data file to csv
###############################

setwd("C:/Users/shahr/OneDrive - University of Toronto/STAA57_Teaching/2023_Winter/Lectures/")

write.csv(gapminder, file="gapminder.csv")

write.csv(gapminder, file="gapminder.csv", row.names = FALSE)





####################################
# xlsx package in R (requires JAVA)
####################################


# Ref: https://www.learnbyexample.org/read-and-write-excel-files-in-r/






##################
# Foreign package
##################

# This package helps to read data files saved in other file formats created
# by other software like SAS, SPSS, Minitab, STATA etc.

# https://www.rdocumentation.org/packages/foreign/versions/0.8-84





#######################################
# Removing objects from the environment
#######################################
rm(gapminder)  # removes one element

rm(list=ls())  # removed everything

gc()    # clears free memory
