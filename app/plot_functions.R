#Function for fixing x-axis text
addline_format <- function(x,...){
  gsub('\\s','\n',x)
}

#Function for representation plot
create_rep_plot <- function(kommun, alle_kommuner){
  kommune_df <- alle_kommuner[alle_kommuner$kommune==kommun,]
  kom <- kommune_df[kommune_df$count>=10,]
  if(nrow(kom)<5){
    kom <- kommune_df[kommune_df$count>=5,]
  }
  if(nrow(kom)<5){
    kom <- kommune_df[kommune_df$count>=3,]
  }
  kom <- kom[order(kom$percentage_increase, decreasing=T),] %>% head(5) %>% na.omit()
  kom <- kom[kom$percentage_increase>0,]
  kom$anlaegsbet <- factor(kom$anlaegsbet, levels = kom[order(kom$percentage_increase),]$anlaegsbet)
  
  p <- ggplot(kom, aes(x=anlaegsbet, y=percentage_increase, fill = percentage_increase)) +
    geom_bar(stat="identity", width=0.7)+
    scale_fill_gradient(
      low = "#132B43",
      high = "#56B1F7",
      space = "Lab",
      na.value = "grey50",
      guide = "colourbar",
      aesthetics = "fill")+
    theme_minimal()+ theme(axis.title=element_text(size=9),
                           legend.position = "none")+
    geom_text(aes(label = paste("+", round(percentage_increase,1), "%", sep="")), vjust=-.3, color="black")+
    xlab("")+ylab(paste("% Flere fundet i ", kommun, " kommune ift. gennemsnit", sep=""))+
    ggtitle(paste("Fundet oftere i", kommun, "kommune"))+
    scale_x_discrete(labels=addline_format(kom[order(kom$percentage_increase),]$anlaegsbet))+
    ylim(0, max(kom$percentage_increase)+(0.1*max(kom$percentage_increase)))
  options(repr.p.width=4,repr.p.height=3)
  
  return(p)
}

#function for count plot
create_count_plot <- function(kommun, alle_kommuner){
  kommune_df <- alle_kommuner[alle_kommuner$kommune==kommun,]
  kom <- kommune_df[order(kommune_df$count, decreasing=T),] %>% head(7) %>% na.omit()
  kom$anlaegsbet <- factor(kom$anlaegsbet, levels = kom[order(kom$count),]$anlaegsbet)
  
  p <- ggplot(kom, aes(x=anlaegsbet, y=count, fill = count)) +
    geom_bar(stat="identity", width=0.7)+
    scale_fill_gradient(
      low = "#132B43",
      high = "#56B1F7",
      space = "Lab",
      na.value = "grey50",
      guide = "colourbar",
      aesthetics = "fill")+
    theme_minimal()+ theme(axis.title=element_text(size=9),
                           legend.position = "none")+
    geom_text(aes(label = count), vjust=-.3, color="black")+
    xlab("")+ylab(paste("Antal fundet i ", kommun, " kommune", sep=""))+
    scale_x_discrete(labels=addline_format(kom[order(kom$count),]$anlaegsbet))+
    ggtitle(paste("Mest fundet i", kommun, "kommune"))+ylim(0, max(kom$count)+(0.1*max(kom$count)))
  options(repr.p.width=4,repr.p.height=3)
  
  return(p)
}

#Function for elevation plot
elev_plot <- function(kommune, elev_df){
df <- elev_df %>% 
    filter(kommunenav==kommune) %>% 
    arrange(desc(mean_elev)) %>% 
    filter(sd<mean_elev) %>% 
    head(10)
  
p <- df %>%  ggplot(aes(x=anlaegsbet,
             y=mean_elev, 
             fill=anlaegsbet)) +  
  geom_col() + 
  geom_errorbar(aes(ymin=mean_elev-sd, ymax=mean_elev+sd), width=1, alpha = 0.5) + 
  theme_minimal() + 
  scale_fill_brewer(palette = "Paired") + 
  theme(legend.position = "none") + 
  scale_x_discrete(labels=addline_format(df$anlaegsbet))+
  labs(x= "Anlægsbetegnelse", y = "Højde (meter)") +
  ggtitle(paste("Gennemsnitshøjde af 10 højeste anlæg i", kommune, "kommune"))
  
return(p)
  }
  