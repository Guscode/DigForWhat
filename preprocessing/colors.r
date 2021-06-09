#This script creates a .csv file with colors for finding types in the digforwhat app
#Created by Frida Hæstrup, Gustav Aarup Lauridsen and Marie Mortensen
setwd("../digforwhat/app/")
#Load data
data <- sf::st_read("../data/anlaeg_all_4326.shp")
data <- data[!(!is.na(data$anlaegsbet) & data$anlaegsbet==""), ] #Remove missing values

# Extract top50 most frequent
top50 <- head(names(summary(as.factor(data$anlaegsbet))),50)

# Assign rest to category "Other"
color_category <- c()
for (bet in data$anlaegsbet){
  if (bet %in% top50){
    color_category <- c(color_category, bet)
  }else{
    color_category <- c(color_category, "Other")
  }
}

# Create df with categories and color ids
color_df <- as.data.frame(sample(rainbow(50))) #extract 50 colors
colnames(color_df) <- c("colors")
color_df$color_category <- unique(color_category[color_category!="Other"]) #add colors
color_df <- rbind(color_df, c("#000000", "other")) #make other color black

# Save color_category to csv
write.csv(color_df, file="../data/preprocessed/color_category.csv", row.names = FALSE)

