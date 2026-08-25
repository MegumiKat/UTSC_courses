#######################################
# Intro to Tidyverse part 2
#######################################
# Things to cover:
#    a) selecting columns
#    b) creating new variable
#    c) string operation
#    d) merging datasets
#    e) dealing with dates
#    f) Basic plotting using ggplot
#######################################


# Visit https://open.toronto.ca/ and download the Apartment Building Evaluation data.


ABE <- read.csv("/Users/mark/Desktop/course/staa57/Apartment Building Evaluation.csv")


library(tidyverse)



###############################
#Selecting variables (columns)
###############################

# Selecting variables by using individual names.
ABE3= ABE %>% select(WARD, YEAR_BUILT, CONFIRMED_UNITS)

# keeping/selecting variables starting from RSN and ending at WARD
ABE3= ABE %>% select(RSN:WARD)

# selecting variables with name starting with "WARD"
ABE3 =ABE %>% select(starts_with("WARD"))

# selecting variables that does not start with "WARD"
ABE3 =ABE %>% select(!starts_with("WARD"))

# selecting variables that ends with "SCORE"
ABE3 =ABE %>% select(ends_with("SCORE"))


# selecting variables that contains "YEAR" at any position.
ABE3 =ABE %>% select(contains("YEAR"))

# selecting all the numeric variables
ABE3 =ABE %>% select(where(is.numeric))

# selecting all the variables that are not numeric variables
ABE3 =ABE %>% select_if(negate(is.numeric))

# selecting variables using multiple conditions
ABE3 =ABE %>% select(starts_with("WARD") & where(is.numeric))





########################
# Creating New Variable
########################

#creating a new variable with name "new_score" which is score/100
ABE4 =ABE %>% mutate(new_score=SCORE/100)

# creating a new variable as a function of two others (you can have as many of them)
ABE4 =ABE %>% mutate(new_var=CONFIRMED_UNITS/CONFIRMED_STOREYS)


# dividing each cell of a column by the summary of another(the same) column.
ABE4 =ABE %>% mutate(new_var=CONFIRMED_UNITS/sum(CONFIRMED_UNITS))





##########
# strings
##########

# creating a substring which starts at th 6th position and ends at 7th
ABE4 =ABE %>% mutate(new_var = str_sub(EVALUATION_COMPLETED_ON,start=6,end=7))

typeof(ABE4$new_var)

#creating a substring which starts at th 6th position and ends at 7th
# and converting it into a numeric variable
ABE4 =ABE %>% mutate(new_var = as.numeric(str_sub(EVALUATION_COMPLETED_ON,start=6,end=7)))

typeof(ABE4$new_var)




# Dates
# changing the format of the date variable from character to a date.
ABE4 = ABE %>% mutate(new_var=as.Date(EVALUATION_COMPLETED_ON))
typeof(ABE4$new_var)

#checking the format
ABE4 %>% select(EVALUATION_COMPLETED_ON, new_var) %>% glimpse


# count of observations that has a evaluation date after Jan 1st, 2020
sum(ABE4$new_var   >    as.Date("2020-01-01"))



# extracts any numeric value out of a string
ABE4 = ABE %>% mutate(new_var=str_extract_all(RESULTS_OF_SCORE,"[0-9]"))


# extracts any numeric number (as a whole) out of a string
ABE4 = ABE %>% mutate(new_var=(str_match_all(SITE_ADDRESS,"\\d+")))


# removes any numeric number from a string
ABE4 = ABE %>% mutate(new_var=(str_remove_all(SITE_ADDRESS,"\\d+")))


# A cheat sheet for string operations in tidyverse
# https://github.com/rstudio/cheatsheets/blob/main/strings.pdf






######################
# Combining data sets
######################

a=data.frame("x1"=c("A","B","C"),
             "x2"=c(1,2,3))
a


b=data.frame("x1"=c("A","B","D"),
             "x3"=c(T,F,T))
b

# keeps everything from the table on the left
left_join(a,b,by=c("x1"))

# keeps everything from the table on the right
right_join(a,b,by="x1")

# keeping only the matched rows
inner_join(a,b,by="x1")

# keeping all the observations from both of the tables
full_join(a,b,by = "x1")




# what to do when variable names are different
d=data.frame("d1"=c("A","B","D"),
             "x3"=c(T,F,T))

# merging using different variable names
left_join(a,d,by=c("x1"="d1"))




# keeping those observations from table (a) for which we have a matching row in table(b)
semi_join(a,b,by = "x1")

# remove those obs from table(a) for which we have a matching row in table(b)
anti_join(a,b,by="x1")



?bind_rows
# Row bind and column bind
#putting one dataset on top of the other(variable names are matched)
z=bind_rows(a,b)


#putting two data sets side by side (no matching is done)
new_data=bind_cols(a,b)



# A very useful cheat sheet
# https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf






#################################
# Few more functions for dates
#################################
library(lubridate)
ABE4 = ABE %>% mutate(new_var=as.Date(EVALUATION_COMPLETED_ON))

ABE4 = ABE4 %>% mutate(YEAR=year(new_var), MONTH = month(new_var), DAY = day(new_var))

ABE4 = ABE4 %>% mutate(new_date= dmy(paste(DAY,MONTH,YEAR,sep="-")))

ABE4 = ABE4 %>% mutate(new_date= format(dmy(paste(DAY,MONTH,YEAR,sep="-")), format= "%m-%d-%Y"))

ABE4 = ABE4 %>% mutate(new_date = make_date(YEAR, MONTH, DAY))

ABE4 = ABE4 %>% mutate(week_day = wday(new_date))

ABE4 = ABE4 %>% mutate(week_day = wday(new_date,label=TRUE))

ABE4 = ABE4 %>% mutate(week_day = month(new_date,label=TRUE, abbr=FALSE))

as.Date("2021-12-31")-as.Date("2020-10-31")

ABE4 = ABE4 %>% mutate(week_day = wday(new_date), .after=RSN)


# A very useful cheatsheet for lubridate
# https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf





####################################################
# Creating a variable based on another variable(s) 
####################################################


ABE = ABE %>% mutate(new_score = 
                       case_when( SCORE >80 ~ 3,
                                  SCORE >60 ~ 2,
                                  TRUE ~ 1), .after = SCORE)


ABE = ABE %>% mutate(letter_score = 
                       case_when( SCORE >=80 ~ "A",
                                  SCORE >=70 ~ "B",
                                  SCORE >=60 ~ "C",
                                  SCORE >=50 ~ "D",
                                  TRUE ~ "F"), .after = SCORE)





#####################################
# Basic plotting (old school codes)
#####################################

set.seed(57)
ABE2 = ABE %>%sample_n(300)  

plot(ABE2$CONFIRMED_UNITS,ABE2$SCORE)

hist(ABE2$SCORE)

boxplot(ABE2$SCORE)


##############################
# Basic plotting using ggplot
##############################

#### (basic scatter plot)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,y=SCORE))+geom_point()


#### (adding color)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,y=SCORE,color=PROPERTY_TYPE))+geom_point()


####(adding shapes)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,y=SCORE,shape=PROPERTY_TYPE))+geom_point()


#### (adding both shape and color)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point()

#### (adding labels)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")


#### (legend position)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")+
  theme(legend.position = "bottom")



#### (changing shape and color label)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 shape=PROPERTY_TYPE, 
                 color=PROPERTY_TYPE)) + geom_point() +
  ggtitle("Score by confirmed units") +
  xlab("Confirmed Units")+
  ylab("Score")+
  theme(legend.position = c(0.5,0.5))+
  labs(shape="Property type", color="Property type")



#### (histogram)
ggplot(ABE2, aes(x=SCORE)) + geom_histogram()



#### (bins of histogram)
ggplot(ABE2, aes(x=SCORE)) + geom_histogram(bins=10)



#### (boxplot)
ggplot(ABE2, aes(x=SCORE)) + geom_boxplot()



##############################################
# Factor and Ordered factor
##############################################


###############
# Use of factor (R does not know yet that new_score is a factor)
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 color=new_score)) + geom_point()


# Creating a factor variable
ABE2 = ABE2 %>% mutate(new_score2 = factor(new_score)) 


# Sample plot again using the factor variable
ggplot(ABE2, aes(x=CONFIRMED_UNITS,
                 y=SCORE,
                 color=new_score2)) + geom_point()




#######################
# Use of ordered factor
ggplot(ABE2, aes(x=new_score2, y=SCORE)) + geom_boxplot()


# re-ordering a factor
ABE2 = ABE2 %>% mutate(new_score3 = 
                         factor(new_score,levels=c(2,1,3),order=T))

table(ABE2$new_score3)


ggplot(ABE2, aes(x=new_score3, y=SCORE)) + geom_boxplot()


min(ABE2$new_score2)   #invalid
min(ABE2$new_score3)   #valid

