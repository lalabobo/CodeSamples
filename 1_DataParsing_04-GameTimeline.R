#!/usr/bin/Rscript

#============================windows batch command prefix (obsolte) ====================
# this is for batch command
# trailingOnly=TRUE means that only your arguments are returned, check:
# print(commandsArgs(trailingOnly=FALSE))
#args<-commandArgs(trailingOnly = TRUE)

## obtain the timeline stat of a match and convert the json into relational tables
## this script needs to run after jsonTimelineOverview.R to get the gameId and game duration
library(jsonlite)
library(RMySQL)
library(DBI) 

#============================= for testing ==============================================
#jsonTimeline<-fromJSON("https://acs.leagueoflegends.com/v1/stats/game/NA1/1757032319/timeline")
#jsonTimeline<-fromJSON("https://acs.leagueoflegends.com/v1/stats/game/NA1/1757032319?visiblePlatformId=NA1&visibleAccountId=200047556")
#===============================

# Summary
# 1. check if a field in a json file is NULL
# 2. parse timelie stats info into a table
# 3. parse item purchase and spell building into a table
# 4. parse timelie stats for a game
# 5. run by batch


# 1. check if a field in a json file is NULL
ifNull<-function(input)
{
	if ((class(try(input))=="try-error") ||(class(try(input))=="list") || (is.null(input))) 
		output<-NA
	else 
		output<-paste0(input,collapse=',')
	return(output)
}


# 2. parse timelie stats info into a table
TimelineStats<-function(jsonTimeline,gameId)
{
	matchTimeline<-data.frame(gameId=NA,participantFrames=NA,timestamp=NA,frameInterval=NA,participantId=NA,position_x=NA,
								position_y=NA,currentGold=NA,totalGold=NA,level=NA,xp=NA,minionsKilled=NA,
								jungleMinionsKilled=NA,dominionScore=NA,teamScore=NA)
	j<-1 # index of participants
	for (j in 1:min(10,length(jsonTimeline$frames$participantFrames))) # there are at most 10 participants in a game
	{	
		i<-1 # index of frame/min
		a<-(j-1)*nrow(jsonTimeline$frames$participantFrames$'1')	# at each frame, we will grab info for all participats
		for (i in 1:nrow(jsonTimeline$frames$participantFrames$'1'))	# the upper bound is determined by the total mins of a game
		{
			matchTimeline[i+a,1]<-gameId
			matchTimeline[i+a,2]<-i
			matchTimeline[i+a,3]<-eval(parse(text=paste0("jsonTimeline$frames$timestamp[",i,"]")))
			matchTimeline[i+a,4]<-jsonTimeline$frameInterval
			matchTimeline[i+a,5]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$participantId[",i,"]"))))
			matchTimeline[i+a,6]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$position$x[",i,"]"))))
			matchTimeline[i+a,7]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$position$y[",i,"]"))))
			matchTimeline[i+a,8]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$currentGold[",i,"]"))))
			matchTimeline[i+a,9]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$totalGold[",i,"]"))))
			matchTimeline[i+a,10]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$level[",i,"]"))))
			matchTimeline[i+a,11]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$xp[",i,"]"))))
			matchTimeline[i+a,12]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$minionsKilled[",i,"]"))))
			matchTimeline[i+a,13]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$jungleMinionsKilled[",i,"]"))))
			matchTimeline[i+a,14]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$dominionScore[",i,"]"))))
			matchTimeline[i+a,15]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$participantFrames$'",j,"'$teamScore[",i,"]"))))
		}
	}
	return(matchTimeline)		
}



# 3. parse item purchase and spell building into a table
TimelineEvents<-function(jsonTimeline,frameNum,gameId)
{
	EventTimeline<-data.frame(gameId=NA,participantFrames=NA,type=NA,timestamp=NA,frameInterval=NA,
								participantId=NA,itemId=NA,afterId=NA,beforeId=NA,
								skillSlot=NA,levelUpType=NA,position_x=NA,position_y=NA,
								killerId=NA,victimId=NA,assistingParticipantIds=NA,
								teamId=NA,buildingType=NA,laneType=NA,towerType=NA,
								monsterType=NA,wardType=NA,creatorId=NA)
	j<-1    # frame number
	a<-0 # number of rows taken by the previous frame
	for (j in 1:(min(frameNum,length(jsonTimeline$frames$events))))
	{
		i<-1 # line number in each frame
		for (i in 1:max(nrow(jsonTimeline$frames$events[[j]]),1))	# events[[1]] is empty but want to use NA to keep the record
		{
			EventTimeline[i+a,1]<-gameId
			EventTimeline[i+a,2]<-j
			EventTimeline[i+a,3]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'type']"))))
			EventTimeline[i+a,4]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'timestamp']"))))
			EventTimeline[i+a,5]<-jsonTimeline$frameInterval
			EventTimeline[i+a,6]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'participantId']"))))
			EventTimeline[i+a,7]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'itemId']"))))
			EventTimeline[i+a,8]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'afterId']"))))
			EventTimeline[i+a,9]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'beforeId']"))))
			EventTimeline[i+a,10]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'skillSlot']"))))
			EventTimeline[i+a,11]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'levelUpType']"))))
			EventTimeline[i+a,12]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]]$position$x[",i,"]"))))
			EventTimeline[i+a,13]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]]$position$y[",i,"]"))))
			EventTimeline[i+a,14]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'killerId']"))))
			EventTimeline[i+a,15]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'victimId']"))))
			EventTimeline[i+a,16]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'assistingParticipantIds'][[1]]"))))
			EventTimeline[i+a,17]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'teamId']"))))
			EventTimeline[i+a,18]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'buildingType']"))))
			EventTimeline[i+a,19]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'laneType']"))))
			EventTimeline[i+a,20]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'towerType'"))))
			EventTimeline[i+a,21]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'monsterType'"))))
			EventTimeline[i+a,22]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'wardType'"))))
			EventTimeline[i+a,23]<-ifNull(eval(parse(text=paste0("jsonTimeline$frames$events[[",j,"]][",i,",'creatorId'"))))
		}
		a<-a+max(nrow(jsonTimeline$frames$events[[j]]),1)	# accumulate the records of the next participant after finishing the previous one
		j<-j+1
	}
	return(EventTimeline)		
}


# 4. parse timelie stats for a game
convertTimeline<-function(region,gameId)  
{	
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	timelineJSONURL<-paste0("https://acs.leagueoflegends.com/v1/stats/game/",region,"/",gameId,"/timeline",collapse='')
	if (class(try(fromJSON(timelineJSONURL)))=="try-error") # if the json file exists, continue
	{	
		# gameParsed_ind=2 means 404 error where there is no game to parse
		dbSendQuery(con,paste0("update lol.games set timelineParsed_ind=2 where gameId=",gameId,collapse=''))
	}
	else
	{
		# parse timeline json files
		jsonTimeline<-fromJSON(timelineJSONURL)
		gameDuration<-dbGetQuery(con,paste0("select gameDuration from lol.accountprofile where gameId =",gameId,collapse=''))
		gameDuration<-gameDuration[,1]
		frameNum<-ceiling(gameDuration/60)+1
		
		# get timeline stats of each game
		Timelines<-TimelineStats(jsonTimeline,gameId)
		dbWriteTable(con,"timelines",Timelines,append=TRUE)
		# obtain a item purchase and spell building table 
		timelineEvents<-TimelineEvents(jsonTimeline,frameNum,gameId)
		dbWriteTable(con,"timelineevents",timelineEvents,append=TRUE) 
		
		# gameParsed_ind=1 means a game is parsed
		dbSendQuery(con,paste0("update lol.games set timelineParsed_ind=1 where gameId=",gameId,collapse=''))	
		print(paste0("Added gameId ",gameId," timeline and timelineEvents to dbs.",collapse=''))
	}
	dbDisconnect(con)	
}


# 5. run by batch
runBatch<-function(batchSize,region,numBatch)
{
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	j<-1  # index of the number of batch
	for (j in 1:numBatch)
	{
		# grab the number = batchSize gameId each time
		ret<-dbGetQuery(con,paste0("select gameId,ID from lol.games where timelineParsed_ind is null and gameId!=0 order by ID limit ",batchSize,collapse=''))
		acctgameId<-ret[,1]  # an array of gameIds for parsing
		ids<-ret[,2] # an array of IDs (auto incrementing)
		numGames<-length(acctgameId)
		i<-1  # index of games in numGames
		
			for (i in 1:numGames)
			{
				convertTimeline(region,acctgameId[i])
			}
		print(paste0("Finished batch NO.",j," with starting ID ",ids[1]," and ending ID ",ids[batchSize],"."))
	}
	dbDisconnect(con)
}
runBatch(100,'NA1',1000)
