############################
### Vectors in R         ###
############################


######################
#Creating vectors in R
######################

# By manually entering numbers using the c( ) command. Here c stands for concatenate.
x= c(3,6,2,8,10)
x


# By using the : sign.  a:b means a to b increasing by 1 
x=c(1:10)
x



# using the sequence command
# the following creates a sequence from 1 t0 10 but increasing by 2
x=seq(1,10,by=2)
x



# using the repeat command
# the following line repeats 3, 5 times
x=rep(3,5)   
x



# A vector of five elements. Each will be zero by default.
x=numeric(length=5)
x



# Creating a list of doubles(regular numbers)
x = c(4,6,9,10.5)
class(x)
x


# Creating a list of integers
y = c(4L,6L,9L,10L)
class(y)
y


# Vectors do not need to be numeric all the time.
# we can create vectors with characters/strings in it.
x= c("HH","HT", "TH","TT")
class(x)
x


# A character vector where the characters are numbers
x= c("647", "416", "905")
class(x)
x


# logical(Boolean) vector
x = c(4,5,6,7)
y = (x<6)
class(y)



#converting character to numeric and numeric to character
as.numeric(x)

as.character(x)



#use of multiple type in one vector
x=c(5, "H")  # saves as character

x=c(TRUE, 4L)  # saves as integer




##############################
# List and Matrices ##########
##############################
x=c(1:5)
y = c(6:16)

c(x,y)   # creates a longer vector


# creates a 2x2 matrix
m=matrix(c(1,2,3,4),nrow=2)
m

# creating a list (list of objects of unequal size and different formats)
z = list(x,y)  #puts two vectors as part of a list z, items can be accessed separately


z = list(x,y,m)


# Getting elements out of a list
class(z[3])

class(z[[3]])




####################
## Vector operations
####################

x= c(3,6,2,8,10)

x+2 # adds 2 to each element of x

x^5 # raises each element of x to the power of 5

y= c(1,2,3,4,5)
x+y


# operation using unequal size (be careful)
z=c(1,2)

x+z  #  




## Logical check for a vector

#Just like a scalar, we can evaluate logical conditions using a vector as well. This is an _element-wise_ operation. Which means R will check every element of that vector to see if the condition is met or not. The output will be a TRUE/FALSE vector.



#Let's star with a new vector which has 5 elements
x= c(3,6,2,8,10)
x


# Checking every element to see if it's greater than 5
# The output will be a TRUE/FALSE vector
# TRUE if the element is >5, FALSE otherwise.
x>5   


#Checking every element if it's equal to 2
x==2




## Counting number of elements that satisfy a certain condition

#Logical checks produces TRUE/FALSE vectors. In the background which is 1 and 0. If we use sum( ) function on this TRUE/FALSE vector we get the total number elements which resulted in a "TRUE" .




# using the same x vector
x= c(3,6,2,8,10)

 

sum(x>5)   # what would it do?




#count of elements in x that are less or equal to 8
sum(x<=8)





######################
## Sub-setting a vector
######################


# To pick elements from a vector we use the open bracket [ ] after the name of the vector and write which elements we want out of it.


#Starting with same x vector
x= c(3,6,2,8,10)

x[1]            # gives us the first element of x (in python it is x[0])
x[ c(1,3,4) ]   # gives us the 1st, 3rd and 4th element

x[-1]           # gives everything EXCEPT the first one  


x[-1:-2]        # gives everything except the first two

x[-c(1,2)]

length(x)       # gives the number of items in a vector

x[length(x)]    # gives the last element of a vector


##############
## Sub-setting a vector based on logical check
##############
# Suppose we want to keep only those elements of a vector that satisfies 
# a certain condition. 
# we can also put a TRUE/FALSE vector inside the open bracket, R will then
# print only those elements which corresponds to TRUE.


# the following line will print only the 1st, 3rd, and 4th element of x.
x[ c(TRUE, FALSE, TRUE, TRUE, FALSE) ]


x[ x>5 ]    # what are we doing in this line?


sum(x[x>5])   # what are we doing in this line?


#Instead of printing we can save this subset under another name
y=x[x>5]
y



# Operation of a vector using loop
v=vector()

for(i in 1:10){
  v[i] = sqrt(i)
}




###############################
#calculating summary statistics
###############################
mean(r)  # calculates the mean of a vector
 
sum(r)   # calculates the sum of a vector

var(r)   # variance of a vector
sd(r)    # standard deviation of a vector

min(r)   # minimum of a vector
max(r)   # maximum of a vector

median(r)# median
range(r) # range

quantile(r) # different quantiles/percentiles
IQR(r)      # 75th percentile - 25th percentile





#############################################
# Basic Plotting(old school coding)
# we will learn more advanced way of plotting
#in couple of weeks using ggplot
##############################################

x = seq(-10,10,by=0.1)

y= x^3-3*x^2+2*x-5

plot(x,y)  # a basic plot

plot(x,y,type="o", 
     main= "First Plot",  xlab="X-axis label", ylab="Y-axis label",
     col="red",lwd=2)

# adding lines on a plot
abline(h=0)    # adding a horizontal line at y=0
abline(v=0)    # adding a vertical line at x=0

abline(a=0,b=1) # adding a line with equation y = a+bx


# lines() adds layer of another plot on top of plot that already exists  

points(x=5,y=-500)                 # adding points on a graph
text("random text", x=-5,y=500)    # add





##################
# functions in R #
##################

#a function that takes the argument y, squares it and returns the value
my_function = function(y){
  z=y^2
  return(z)
}


#calling the function with an argument 4
my_function(4)


my_function() # will produce an error since no argument is provided


my_function(c(4,6,8))







# A function that takes two arguments and returns the multiplication of them
my_function2=function(y,z){
  s=y^z
  return(s)
}

#calling the function
my_function2(3,4)   # first argument will be treated as y , second one as z

my_function2(z=3,y=4)





# A function with default argument
my_function3=function(y=2,z=5){
  s=y^z
  return(s)
}

my_function3()




#############################################
# A function replicating roll of a fair die
#############################################



########################################################################
########################################################################
# Calculating(approximating) probability of an even number 
new_function=function(){
  s=sample(c(1,2,3,4,5,6),size=1)   # rolling a fair die once
  return(s)
}

# Replicating the function 100K times
output=replicate(10000,new_function())

# probability of an even number
sum(output %in% c(2,4,6))/length(output)   # should be closer to 0.5






########################################################################
########################################################################
# Calculating(approximating) probability of an even number 
new_function=function(){
  s=sample(c(1,2,3,4,5,6),size=1)   # rolling a fair die once
  if(s %in% c(2,4,6)){
    return(1)
  }else{
    return(0)
  }
}

# Replicating the function 100K times
output=replicate(10000,new_function())

# probability of an even number
sum(output)/length(output)   # should be closer to 0.5
mean(output)





########################################################################
########################################################################
# calculating probability of sum of two faces being 11
new_function=function(){
  s=sample(c(1,2,3,4,5,6),size=2,replace=T)
  z= (sum(s)==11)
  return(z)
}

# Replicating the function 100K times
output=replicate(10000,new_function())

sum(output)/length(output)     # should be close to 1/18
mean(output)





#########################################################################
#########################################################################
# Calculating frequency table for sum of two faces

new_function=function(){
  s=sample(c(1,2,3,4,5,6),size=2,replace=T)
  return(sum(s))
}

# Replicating the function 100K times
output=replicate(10000,new_function())

# Frequency table
table(output)


#table with proportions
prop.table(table(output))


# plot of output
plot(prop.table(table(output)))