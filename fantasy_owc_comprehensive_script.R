# read datasets
entry_list <- read.csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_entry_list_2020.csv",stringsAsFactors=FALSE)
picks <- read.csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_picks_2020.csv",stringsAsFactors=FALSE)
race_results <- read.csv("/Users/cd1n3vski/Documents/Misc/Racing Material/IndyCar Data Materials/Data Sets/INDY_20.csv",stringsAsFactors=FALSE)
fantasy_results <- read.csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_race_results.csv",stringsAsFactors=FALSE)
championship_standings <- read.csv("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_points_standings.csv",stringsAsFactors=FALSE)

# set event names
race_name <- "Road America 1" # update for each race
event_name <- "INDYCARGP" # update for each race

# if/else sequence to ensure race has not already been calculate and that race can be found in picks and official results
if(!(gsub(" ",".",race_name) %in% names(fantasy_results)) && race_name %in% unique(race_results$race) && race_name %in% unique(picks$race)) {
  # create object with results from most recent race (driver, finish, start, points)
  race <- race_results[race_results$race==race_name,c(2,1,5,10)]
  
  # create object with picks for the most recent race
  race_picks <- picks[picks$race==race_name,]
  picks_submitted <- race_picks[race_picks$pick_number==1,]
  picks_join <- plyr::join(entry_list,picks_submitted,by="name",type="full")
  picks_missing <- picks_join$name[is.na(picks_join$pick_number)]
  
  # calculating race results
  fantasy_race_results <- as.data.frame(matrix(nrow=nrow(fantasy_results),ncol=12))
  names(fantasy_race_results) <- c("name","pick1","pick2","pick3","pick4","pick5","pick1points","pick2points","pick3points"
                                   ,"pick4points","pick5points","race_points")
  for(i in 1:nrow(fantasy_race_results)) {
    if(fantasy_results$name[i] %in% picks_missing) {
      fantasy_race_results$name[i] <- fantasy_results$name[i]
      fantasy_race_results$pick1[i] <- "None"
      fantasy_race_results$pick2[i] <- "None"
      fantasy_race_results$pick3[i] <- "None"
      fantasy_race_results$pick4[i] <- "None"
      fantasy_race_results$pick5[i] <- "None"
      fantasy_race_results$pick1points[i] <- 0
      fantasy_race_results$pick2points[i] <- 0
      fantasy_race_results$pick3points[i] <- 0
      fantasy_race_results$pick4points[i] <- 0
      fantasy_race_results$pick5points[i] <- 0
      fantasy_race_results$race_points[i] <- 0
    } else {
      temp_picks <- race_picks[race_picks$name==fantasy_results$name[i],]
      fantasy_race_results$name[i] <- fantasy_results$name[i]
      fantasy_race_results$pick1[i] <- temp_picks$pick[temp_picks$pick_number==1]
      fantasy_race_results$pick2[i] <- temp_picks$pick[temp_picks$pick_number==2]
      fantasy_race_results$pick3[i] <- temp_picks$pick[temp_picks$pick_number==3]
      fantasy_race_results$pick4[i] <- temp_picks$pick[temp_picks$pick_number==4]
      fantasy_race_results$pick5[i] <- temp_picks$pick[temp_picks$pick_number==5]
      fantasy_race_results$pick1points[i] <- race$points[race$driver==temp_picks$pick[temp_picks$pick_number==1]]
      fantasy_race_results$pick2points[i] <- race$points[race$driver==temp_picks$pick[temp_picks$pick_number==2]]
      fantasy_race_results$pick3points[i] <- race$points[race$driver==temp_picks$pick[temp_picks$pick_number==3]]
      fantasy_race_results$pick4points[i] <- race$points[race$driver==temp_picks$pick[temp_picks$pick_number==4]]
      fantasy_race_results$pick5points[i] <- race$points[race$driver==temp_picks$pick[temp_picks$pick_number==5]]
      fantasy_race_results$race_points[i] <- sum(fantasy_race_results$pick1points[i],fantasy_race_results$pick2points[i],fantasy_race_results$pick3points[i],fantasy_race_results$pick4points[i],fantasy_race_results$pick5points[i])
    }
  }
  
  # ordering points scored by everyone's respective picks
  for(i in 1:nrow(fantasy_race_results)) {
    temp_order <- fantasy_race_results[i,c("pick1points","pick2points","pick3points","pick4points","pick5points")]
    points_sort <- c()
    points_sort <- sort(temp_order,decreasing=TRUE)
    names(points_sort) <- c("score1","score2","score3","score4","score5")
    fantasy_race_results$score1[i] <- points_sort$score1
    fantasy_race_results$score2[i] <- points_sort$score2
    fantasy_race_results$score3[i] <- points_sort$score3
    fantasy_race_results$score4[i] <- points_sort$score4
    fantasy_race_results$score5[i] <- points_sort$score5
  }
  
  fantasy_race_classification <- fantasy_race_results[order(-fantasy_race_results$race_points
                                                            ,-fantasy_race_results$score1
                                                            ,-fantasy_race_results$score2
                                                            ,-fantasy_race_results$score3
                                                            ,-fantasy_race_results$score4
                                                            ,-fantasy_race_results$score5),c("name","race_points")]
  for(i in 1:nrow(fantasy_race_classification)) {
    fantasy_race_classification$Finish[i] <- i
  }
  names(fantasy_race_classification) <- c("Name","Points","Finish")
  fantasy_race_classification <- fantasy_race_classification[,c("Finish","Name","Points")]
  
  results_join <- plyr::join(fantasy_results,fantasy_race_results,by="name",type="full")
  fantasy_results_new <- results_join[,c(1:ncol(fantasy_results),ncol(results_join))]
  names(fantasy_results_new)[1:(ncol(fantasy_results_new)-1)] <- gsub("."," ",names(fantasy_results),fixed=TRUE)
  names(fantasy_results_new)[ncol(fantasy_results_new)] <- race_name
  
  # calculation points standings
  points_standings <- as.data.frame(matrix(nrow=nrow(fantasy_results_new),ncol=2))
  names(points_standings) <- c("name","points")
  points_standings$name <- fantasy_results_new$name
  for(i in 1:nrow(fantasy_results_new)) {
    points_standings$points[i] <- sum(fantasy_results_new[i,2:ncol(fantasy_results_new)])
  }
  
  # ordering points standings
  points_standings <- points_standings[order(points_standings$points,decreasing=TRUE),]
  
  # adding championship position to points standings
  for(i in 1:nrow(points_standings)) {
    points_standings$position[i] <- i
  }
  
  # joining twitter handle
  points_standings <- plyr::join(points_standings,entry_list,by="name",type="full")
  
  # calculating points diff
  champ_leader_points <- points_standings$points[1]
  for(i in 1:nrow(points_standings)) {
    points_standings$difference[i] <- points_standings$points[i] - champ_leader_points
  }
  
  # calculating change in position
  if(ncol(fantasy_results_new)>2) {
    names(championship_standings)[names(championship_standings)=="position"] <- "prev_position"
    temp_standings <- plyr::join(points_standings,championship_standings,by="name",type="inner")
    points_standings$change <- ifelse(temp_standings$prev_position - temp_standings$position>0
                                      ,paste0("^ ",temp_standings$prev_position - temp_standings$position)
                                      ,ifelse(temp_standings$prev_position - temp_standings$position==0,"-"
                                              ,paste0("v ",temp_standings$position - temp_standings$prev_position)))
  } else {
    points_standings$change <- "-"
  }
  # re-ordering columns
  points_standings <- points_standings[,c(3,1,5,2,6,7)]
  
  # selecting picks to be exported
  picks_nrm <- fantasy_race_results[,c("name","pick1","pick2","pick3","pick4","pick5")]
  names(picks_nrm) <- c("Name","Pick 1","Pick 2","Pick 3","Pick 4","Pick 5")
  
  # calculating cumulative picks
  driver_list <- unique(race_results$driver[race_results$race %in% names(fantasy_results_new)[2:ncol(fantasy_results_new)]])
  cumulative_picks <- as.data.frame(matrix(nrow=length(driver_list)*nrow(entry_list),ncol=3))
  names(cumulative_picks) <- c("Name","Driver","Number of Picks")
  temp_cumulative_picks <- picks[picks$race %in% names(fantasy_results_new),]
  
  for(i in 1:nrow(entry_list)) {
    for(j in 1:length(driver_list)) {
      cumulative_picks$Name[(length(driver_list)*(i-1))+j] <- entry_list$name[i]
      cumulative_picks$Driver[(length(driver_list)*(i-1))+j] <- driver_list[j]
      cumulative_picks$`Number of Picks`[(length(driver_list)*(i-1))+j] <- sum(temp_cumulative_picks$pick[temp_cumulative_picks$name==entry_list$name[i]]==driver_list[j])
    }
  }
  cumulative_picks <- cumulative_picks[order(cumulative_picks$Name,-cumulative_picks$`Number of Picks`,cumulative_picks$Driver),]
  
  # calculating driver picks per race
  driver_entry_list <- race_results$driver[race_results$race==race_name]
  driver_picks <- as.data.frame(matrix(nrow=length(driver_entry_list),ncol=2))
  names(driver_picks) <- c("Driver","Number of Picks")
  for(i in 1:nrow(driver_picks)) {
    driver_picks$Driver[i] <- driver_entry_list[i]
    driver_picks$`Number of Picks`[i] <- nrow(race_picks[race_picks$pick==driver_entry_list[i],])
  }
  driver_picks <- driver_picks[order(-driver_picks$`Number of Picks`,driver_picks$Driver),]
  
  # writing race results to file
  write.csv(fantasy_results_new,"/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_race_results.csv",row.names=FALSE)
  
  # writing points standings to file
  write.csv(points_standings,"/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_points_standings.csv",row.names=FALSE)
  
  # writing picks to file
  race_num <- ncol(fantasy_results_new) - 1
  picks_file_path <- paste0("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/Picks/",race_num,". ",race_name," Picks.csv")
  write.csv(picks_nrm,picks_file_path,row.names=FALSE)
  
  # writing cumulative picks to file
  write.csv(cumulative_picks,"/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/fantasy_indycar_cumulative_picks.csv",row.names=FALSE)
  
  # writing driver picks to file
  driver_picks_file_path <- paste0("/Users/cd1n3vski/Desktop/Fantasy Open Wheel Challenge/2020 - Test Case:Dev/Driver Picks/",race_num,". ",race_name," Driver Picks.csv")
  write.csv(driver_picks,driver_picks_file_path,row.names=FALSE)
  
  print("Race results successfully calculated. Check corresponding files for results.")
} else {
  if(gsub(" ",".",race_name) %in% names(fantasy_results)) {
    print("Race results already calculated. Update race name variable")
  } else if(!(race_name %in% unique(race_results$race)) && !(race_name %in% unique(picks$race))) {
    print("Race not found in official results OR in picks. Double check race name to ensure it is spelled correctly and consistent")
  } else if(!(race_name %in% unique(race_results$race))) {
    print("Race not found in official results. Double check race name to ensure it is spelled correctly and consistent")
  } else if(!(race_name %in% unique(picks$race))) {
    print("Race not found in picks. Double check race name to ensure it is spelled correctly and consistent")
  }
}

# winner tweet
cat("Congrats to ",fantasy_race_classification$Name[1]," ("
    ,entry_list$handle[entry_list$name==fantasy_race_classification$Name[1]],") on winning the #",event_name
    ,"!\n\nPoints - ",fantasy_race_classification$Points[1]
    ,"\n",fantasy_race_results$pick1[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_results$pick1points[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ,"\n",fantasy_race_results$pick2[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_results$pick2points[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ,"\n",fantasy_race_results$pick3[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_results$pick3points[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ,"\n",fantasy_race_results$pick4[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_results$pick4points[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ,"\n",fantasy_race_results$pick5[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_results$pick5points[fantasy_race_results$name==fantasy_race_classification$Name[1]]
    ,"\n\n#FantasyOWC"
    ,sep="")

# top 10 tweet
cat("Top 10 finishers in the #",event_name
    ,".\n\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[1]]
    ," - ",fantasy_race_classification$Points[1]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[2]]
    ," - ",fantasy_race_classification$Points[2]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[3]]
    ," - ",fantasy_race_classification$Points[3]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[4]]
    ," - ",fantasy_race_classification$Points[4]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[5]]
    ," - ",fantasy_race_classification$Points[5]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[6]]
    ," - ",fantasy_race_classification$Points[6]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[7]]
    ," - ",fantasy_race_classification$Points[7]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[8]]
    ," - ",fantasy_race_classification$Points[8]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[9]]
    ," - ",fantasy_race_classification$Points[9]
    ,"\n",entry_list$handle[entry_list$name==fantasy_race_classification$Name[10]]
    ," - ",fantasy_race_classification$Points[10]
    ,"\n\n#FantasyOWC"
    ,sep="")

# Elimination zone warning
cat("ELIMINATION ZONE:\n\nOn the bubble\n" ,entry_list$handle[entry_list$name==points_standings$name[33]]," ",points_standings$points[33]
    ,"\n\nBelow the cut\n",entry_list$handle[entry_list$name==points_standings$name[34]]," ",points_standings$points[34]-points_standings$points[33]
    ,"\n",entry_list$handle[entry_list$name==points_standings$name[35]]," ",points_standings$points[35]-points_standings$points[33]
    ,"\n",entry_list$handle[entry_list$name==points_standings$name[36]]," ",points_standings$points[36]-points_standings$points[33]
    ,"\n",entry_list$handle[entry_list$name==points_standings$name[37]]," ",points_standings$points[37]-points_standings$points[33]
    ,"\n\n#FantasyOWC"
    ,sep="")



TO DO:
  Create df with finishing position and write to a file
Incorporate penalties and test that they work correctly
Incorporate pick for Indianapolis pole position





