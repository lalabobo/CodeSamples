#!/usr/bin/Rscript

#==============================windows batch command prefix======================
# this is for batch command
# trailingOnly=TRUE means that only your arguments are returned, check:
# print(commandsArgs(trailingOnly=FALSE))
#args<-commandArgs(trailingOnly = TRUE)

#setwd('C://Users//Sarah//dropbox//R//lol')

library(jsonlite)
library(RMySQL)
library(DBI) 


#==================================================================

ifNull<-function(input)
	{
		if (class(try(input))=="try-error")
			output<-NA
		else if (is.null(input)) 
			output<-NA
		else 
			output<-input
		return(output)
	}

ifNAinVector<-function(input)
	{
		i<-1
		res<--1  # initiate a default value for the vector 
		for (i in 1: length(input))
			{
				if (!is.na(input[i]))
					res<-c(res,input[i])
				i<-i+1
			}
	#	res<-res[-c(1)] # remove the element at position 1
		return(res)
	}

#================================functions to grab each table

teams<-function(jsonMatch)
	{
		team<-data.frame(gameId=NA,teamId=NA,win=NA,firstBlood=NA,firstTower=NA,firstInhibitor=NA,
 					firstBaron=NA,firstDragon=NA,towerKills=NA,inhibitorKills=NA,baronKills=NA,
 					dragonKills=NA,vilemawKills=NA,dominionVictoryScore=NA,ban1=NA,ban2=NA,ban3=NA)
		a<-1 # a represent the teamId 1 or 2
		for (a in 1:2)
			{
				team[a,1]<-jsonMatch$gameId
				team[a,2]<-jsonMatch$teams$teamId[a]
				team[a,3]<-jsonMatch$teams$win[a]
				team[a,4]<-jsonMatch$teams$firstBlood[a]
				team[a,5]<-jsonMatch$teams$firstTower[a]
				team[a,6]<-jsonMatch$teams$firstInhibitor[a]
				team[a,7]<-jsonMatch$teams$firstBaron[a]
				team[a,8]<-jsonMatch$teams$firstDragon[a]
				team[a,9]<-jsonMatch$teams$towerKills[a]
				team[a,10]<-jsonMatch$teams$inhibitorKills[a]
				team[a,11]<-jsonMatch$teams$baronKills[a]
				team[a,12]<-jsonMatch$teams$dragonKills[a]
				#if (!is.null(jsonMatch$teams$vilemawKills[a])) 
				team[a,13]<-jsonMatch$teams$vilemawKills[a]
				team[a,14]<-jsonMatch$teams$dominionVictoryScore[a]
				if (length(jsonMatch$teams$bans[[a]])==0)
					{
						team[a,15]<-NA
						team[a,16]<-NA
						team[a,17]<-NA
					}
					

				else 
					{
						team[a,15]<-jsonMatch$teams$bans[[a]][1,1]
						team[a,16]<-jsonMatch$teams$bans[[a]][2,1]
						team[a,17]<-jsonMatch$teams$bans[[a]][3,1]
					}	

					
				a<-a+1
			}
		return(team)	
	}



#========================================================================================
## grab the team info, both the win and lose teams




## grab participants details in a game
participants<-function(jsonMatch)
	{
		participant<-data.frame(gameId=NA,participantId=NA,teamId=NA,championId=NA,spell1Id=NA,spell2Id=NA,
								masteryId1=NA,mrank1=NA,masteryId2=NA,mrank2=NA,masteryId3=NA,mrank3=NA,
								masteryId4=NA,mrank4=NA,masteryId5=NA,mrank5=NA,masteryId6=NA,mrank6=NA,
								masteryId7=NA,mrank7=NA,masteryId8=NA,mrank8=NA,masteryId9=NA,mrank9=NA,
								masteryId10=NA,mrank10=NA,masteryId11=NA,mrank11=NA,masteryId12=NA,mrank12=NA,
								masteryId13=NA,mrank13=NA,masteryId14=NA,mrank14=NA,masteryId15=NA,mrank15=NA,
								masteryId16=NA,mrank16=NA,masteryId17=NA,mrank17=NA,masteryId18=NA,mrank18=NA,
								masteryId19=NA,mrank19=NA,masteryId20=NA,mrank20=NA,runeId1=NA,rrank1=NA,
								runeId2=NA,rrank2=NA,runeId3=NA,rrank3=NA,runeId4=NA,rrank4=NA,
								runeId5=NA,rrank5=NA,runeId6=NA,rrank6=NA,runeId7=NA,rrank7=NA,
								runeId8=NA,rrank8=NA,runeId9=NA,rrank9=NA,runeId10=NA,rrank10=NA,
								highestAchievedSeasonTier=NA,
								#participantId=NA,
								win=NA,item0=NA,
								item1=NA,item2=NA,item3=NA,item4=NA,item5=NA,item6=NA,kills=NA,
								deaths=NA,assists=NA,largestKillingSpree=NA,largestMultiKill=NA,
								killingSprees=NA,longestTimeSpentLiving=NA,doubleKills=NA,tripleKills=NA,
								quadraKills=NA,pentaKills=NA,unrealKills=NA,totalDamageDealt=NA,magicDamageDealt=NA,
								physicalDamageDealt=NA,trueDamageDealt=NA,largestCriticalStrike=NA,totalDamageDealtToChampions=NA,
								magicDamageDealtToChampions=NA,physicalDamageDealtToChampions=NA,trueDamageDealtToChampions=NA,
								totalHeal=NA,totalUnitsHealed=NA,totalDamageTaken=NA,magicalDamageTaken=NA,physicalDamageTaken=NA,
								trueDamageTaken=NA,goldEarned=NA,goldSpent=NA,turretKills=NA,inhibitorKills=NA,totalMinionsKilled=NA,
								neutralMinionsKilled=NA,totalTimeCrowdControlDealt=NA,champLevel=NA,visionWardsBoughtInGame=NA,
								sightWardsBoughtInGame=NA,wardsPlaced=NA,wardsKilled=NA,firstBloodKill=NA,firstBloodAssist=NA,
								firstTowerKill=NA,firstTowerAssist=NA,firstInhibitorKill=NA,firstInhibitorAssist=NA,
								combatPlayerScore=NA,objectivePlayerScore=NA,totalPlayerScore=NA,totalScoreRank=NA,
								#participantId=NA,
								creepsPerMinDeltas_10_20=NA, creepsPerMinDeltas_0_10=NA,xpPerMinDeltas_10_20=NA,
								xpPerMinDeltas_0_10=NA,goldPerMinDeltas_10_20=NA,goldPerMinDeltas_0_10=NA,csDiffPerMinDeltas_10_20=NA,
								csDiffPerMinDeltas_0_10=NA,xpDiffPerMinDeltas_10_20=NA,xpDiffPerMinDeltas_0_10=NA,
								damageTakenPerMinDeltas_10_20=NA,damageTakenPerMinDeltas_0_10=NA,damageTakenDiffPerMinDeltas_10_20=NA,
								damageTakenDiffPerMinDeltas_0_10=NA,role=NA,lane=NA)
		a<-1
		for (a in 1:10)
			{
				participant[a,1]<-jsonMatch$gameId
				participant[a,2]<-jsonMatch$participants$participantId[a]
				participant[a,3]<-jsonMatch$participants$teamId[a]
				participant[a,4]<-jsonMatch$participants$championId[a]
				participant[a,5]<-jsonMatch$participants$spell1Id[a]
				participant[a,6]<-jsonMatch$participants$spell2Id[a]

				participant[a,7]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][1,1]",collapse=''))))
				participant[a,8]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][1,2]",collapse=''))))
				participant[a,9]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][2,1]",collapse=''))))
				participant[a,10]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][2,2]",collapse=''))))
				participant[a,11]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][3,1]",collapse=''))))
				participant[a,12]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][3,2]",collapse=''))))
				participant[a,13]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][4,1]",collapse=''))))
				participant[a,14]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][4,2]",collapse=''))))
				participant[a,15]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][5,1]",collapse=''))))
				participant[a,16]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][5,2]",collapse=''))))
				participant[a,17]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][6,1]",collapse=''))))
				participant[a,18]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][6,2]",collapse=''))))
				participant[a,19]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][7,1]",collapse=''))))
				participant[a,20]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][7,2]",collapse=''))))
				participant[a,21]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][8,1]",collapse=''))))
				participant[a,22]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][8,2]",collapse=''))))
				participant[a,23]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][9,1]",collapse=''))))
				participant[a,24]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][9,2]",collapse=''))))
				participant[a,25]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][10,1]",collapse=''))))
				participant[a,26]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][10,2]",collapse=''))))
				participant[a,27]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][11,1]",collapse=''))))
				participant[a,28]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][11,2]",collapse=''))))
				participant[a,29]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][12,1]",collapse=''))))
				participant[a,30]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][12,2]",collapse=''))))
				participant[a,31]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][13,1]",collapse=''))))
				participant[a,32]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][13,2]",collapse=''))))
				participant[a,33]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][14,1]",collapse=''))))
				participant[a,34]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][14,2]",collapse=''))))
				participant[a,35]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][15,1]",collapse=''))))
				participant[a,36]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][15,2]",collapse=''))))
				participant[a,37]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][16,1]",collapse=''))))
				participant[a,38]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][16,2]",collapse=''))))
				participant[a,39]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][17,1]",collapse=''))))
				participant[a,40]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][17,2]",collapse=''))))
				participant[a,41]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][18,1]",collapse=''))))
				participant[a,42]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][18,2]",collapse=''))))
				participant[a,43]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][19,1]",collapse=''))))
				participant[a,44]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][19,2]",collapse=''))))
				participant[a,45]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][20,1]",collapse=''))))
				participant[a,46]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][20,2]",collapse=''))))

				
				participant[a,47]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][1,1]",collapse=''))))
				participant[a,48]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][1,2]",collapse=''))))
				participant[a,49]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][2,1]",collapse=''))))
				participant[a,50]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][2,2]",collapse=''))))
				participant[a,51]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][3,1]",collapse=''))))
				participant[a,52]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][3,2]",collapse=''))))
				participant[a,53]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][4,1]",collapse=''))))
				participant[a,54]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][4,2]",collapse=''))))
				participant[a,55]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][5,1]",collapse=''))))
				participant[a,56]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][5,2]",collapse=''))))
				participant[a,57]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][6,1]",collapse=''))))
				participant[a,58]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][6,2]",collapse=''))))
				participant[a,59]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][7,1]",collapse=''))))
				participant[a,60]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][7,2]",collapse=''))))
				participant[a,61]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][8,1]",collapse=''))))
				participant[a,62]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][8,2]",collapse=''))))
				participant[a,63]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][9,1]",collapse=''))))
				participant[a,64]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][9,2]",collapse=''))))
				participant[a,65]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][10,1]",collapse=''))))
				participant[a,66]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][10,2]",collapse=''))))
		
				participant[a,67]<-jsonMatch$participants$highestAchievedSeasonTier[a]
				#participant[a,68]<-jsonMatch$participants$stats$participantId[a]  
				participant[a,68]<-as.character(jsonMatch$participants$stats$win[a])
				participant[a,69]<-jsonMatch$participants$stats$item0[a]
				participant[a,70]<-jsonMatch$participants$stats$item1[a]
				participant[a,71]<-jsonMatch$participants$stats$item2[a]
				participant[a,72]<-jsonMatch$participants$stats$item3[a]
				participant[a,73]<-jsonMatch$participants$stats$item4[a]
				participant[a,74]<-jsonMatch$participants$stats$item5[a]
				participant[a,75]<-jsonMatch$participants$stats$item6[a]
				participant[a,76]<-jsonMatch$participants$stats$kills[a]
				participant[a,77]<-jsonMatch$participants$stats$deaths[a]
				participant[a,78]<-jsonMatch$participants$stats$assists[a]
				participant[a,79]<-jsonMatch$participants$stats$largestKillingSpree[a]
				participant[a,80]<-jsonMatch$participants$stats$largestMultiKill[a]
				participant[a,81]<-jsonMatch$participants$stats$killingSprees[a]
				participant[a,82]<-jsonMatch$participants$stats$longestTimeSpentLiving[a]
				participant[a,83]<-jsonMatch$participants$stats$doubleKills[a]
				participant[a,84]<-jsonMatch$participants$stats$tripleKills[a]
				participant[a,85]<-jsonMatch$participants$stats$quadraKills[a]
				participant[a,86]<-jsonMatch$participants$stats$pentaKills[a]
				participant[a,87]<-jsonMatch$participants$stats$unrealKills[a]
				participant[a,88]<-jsonMatch$participants$stats$totalDamageDealt[a]
				participant[a,89]<-jsonMatch$participants$stats$magicDamageDealt[a]
				participant[a,90]<-jsonMatch$participants$stats$physicalDamageDealt[a]
				participant[a,91]<-ifNull(jsonMatch$participants$stats$trueDamageDealt[a])
				participant[a,92]<-ifNull(jsonMatch$participants$stats$largestCriticalStrike[a])
				participant[a,93]<-jsonMatch$participants$stats$totalDamageDealtToChampions[a]
				participant[a,94]<-jsonMatch$participants$stats$magicDamageDealtToChampions[a]
				participant[a,95]<-jsonMatch$participants$stats$physicalDamageDealtToChampions[a]
				participant[a,96]<-ifNull(jsonMatch$participants$stats$trueDamageDealtToChampions[a])
				participant[a,97]<-ifNull(jsonMatch$participants$stats$totalHeal[a])
				participant[a,98]<-ifNull(jsonMatch$participants$stats$totalUnitsHealed[a])
				participant[a,99]<-jsonMatch$participants$stats$totalDamageTaken[a]
				participant[a,100]<-jsonMatch$participants$stats$magicalDamageTaken[a]
				participant[a,101]<-jsonMatch$participants$stats$physicalDamageTaken[a]
				participant[a,102]<-ifNull(jsonMatch$participants$stats$trueDamageTaken[a])
				participant[a,103]<-jsonMatch$participants$stats$goldEarned[a]
				participant[a,104]<-jsonMatch$participants$stats$goldSpent[a]
				participant[a,105]<-ifNull(jsonMatch$participants$stats$turretKills[a])
				participant[a,106]<-ifNull(jsonMatch$participants$stats$inhibitorKills[a])
				participant[a,107]<-jsonMatch$participants$stats$totalMinionsKilled[a]
				participant[a,108]<-jsonMatch$participants$stats$neutralMinionsKilled[a]
				participant[a,109]<-ifNull(jsonMatch$participants$stats$totalTimeCrowdControlDealt[a])
				participant[a,110]<-jsonMatch$participants$stats$champLevel[a]
				participant[a,111]<-ifNull(jsonMatch$participants$stats$visionWardsBoughtInGame[a])
				participant[a,112]<-ifNull(jsonMatch$participants$stats$sightWardsBoughtInGame[a])
				participant[a,113]<-ifNull(jsonMatch$participants$stats$wardsPlaced[a])
				participant[a,114]<-ifNull(jsonMatch$participants$stats$wardsKilled[a])
				if (!is.null(jsonMatch$participants$stats$firstBloodKill[a]))
					participant[a,115]<-as.character(jsonMatch$participants$stats$firstBloodKill[a])
				if (!is.null(jsonMatch$participants$stats$firstBloodAssist[a]))
					participant[a,116]<-as.character(jsonMatch$participants$stats$firstBloodAssist[a])
				if (!is.null(jsonMatch$participants$stats$firstTowerKill[a]))
					participant[a,117]<-as.character(jsonMatch$participants$stats$firstTowerKill[a])
				else participant[a,117]<-NA
				if (!is.null(jsonMatch$participants$stats$firstTowerAssist[a]))
					participant[a,118]<-as.character(jsonMatch$participants$stats$firstTowerAssist[a])
				else participant[a,118]<-NA
				if (!is.null(jsonMatch$participants$stats$firstInhibitorKill[a]))
					participant[a,119]<-as.character(jsonMatch$participants$stats$firstInhibitorKill[a])
				else participant[a,119]<-NA
				if (!is.null(jsonMatch$participants$stats$firstInhibitorAssist[a]))
					participant[a,120]<-as.character(jsonMatch$participants$stats$firstInhibitorAssist[a])
				else participant[a,120]<-NA
				participant[a,121]<-jsonMatch$participants$stats$combatPlayerScore[a]
				participant[a,122]<-jsonMatch$participants$stats$objectivePlayerScore[a]
				participant[a,123]<-jsonMatch$participants$stats$totalPlayerScore[a]
				participant[a,124]<-jsonMatch$participants$stats$totalScoreRank[a]
				#participant[a,126]<-jsonMatch$participants$timeline$participantId[a]

				participant[a,125]<-ifNull(jsonMatch$participants$timeline$creepsPerMinDeltas$'10-20'[a])
				participant[a,126]<-ifNull(jsonMatch$participants$timeline$creepsPerMinDeltas$'0-10'[a])
				participant[a,127]<-ifNull(jsonMatch$participants$timeline$xpPerMinDeltas$'10-20'[a])
				participant[a,128]<-ifNull(jsonMatch$participants$timeline$xpPerMinDeltas$'0-10'[a])
				participant[a,129]<-ifNull(jsonMatch$participants$timeline$goldPerMinDeltas$'10-20'[a])
				participant[a,130]<-ifNull(jsonMatch$participants$timeline$goldPerMinDeltas$'0-10'[a])
				participant[a,131]<-ifNull(jsonMatch$participants$timeline$csDiffPerMinDeltas$'10-20'[a])
				participant[a,132]<-ifNull(jsonMatch$participants$timeline$csDiffPerMinDeltas$'0-10'[a])
				participant[a,133]<-ifNull(jsonMatch$participants$timeline$xpDiffPerMinDeltas$'10-20'[a])
				participant[a,134]<-ifNull(jsonMatch$participants$timeline$xpDiffPerMinDeltas$'0-10'[a])
				participant[a,135]<-ifNull(jsonMatch$participants$timeline$damageTakenPerMinDeltas$'10-20'[a])
				participant[a,136]<-ifNull(jsonMatch$participants$timeline$damageTakenPerMinDeltas$'0-10'[a])
				participant[a,137]<-ifNull(jsonMatch$participants$timeline$damageTakenDiffPerMinDeltas$'10-20'[a])
				participant[a,138]<-ifNull(jsonMatch$participants$timeline$damageTakenDiffPerMinDeltas$'0-10'[a])
				participant[a,139]<-jsonMatch$participants$timeline$role[a]
				participant[a,140]<-jsonMatch$participants$timeline$lane[a]
				a<-a+1
			}	
		return(participant)						
	}


## grab participant identities. Usually, only the user we access the match info from will has non-NA info
participantIdentities<-function(jsonMatch)
 	{
 		participants<-data.frame(gameId=NA,participantId=NA,platformId=NA,accountId=NA,summonerName=NA,
 								summonerId=NA,currentPlatformId=NA,currentAccountId=NA,matchHistoryUri=NA,
 								profileIcon=NA)
 		a<-1
 		for (a in 1:10)
 			{
 				participants[a,1]<-jsonMatch$gameId
 				participants[a,2]<-jsonMatch$participantIdentities$participantId[a]
 				participants[a,3]<-ifNull(jsonMatch$participantIdentities$player$platformId[a])
 				participants[a,4]<-ifNull(jsonMatch$participantIdentities$player$accountId[a])
 				participants[a,5]<-ifNull(jsonMatch$participantIdentities$player$summonerName[a])
 				participants[a,6]<-ifNull(jsonMatch$participantIdentities$player$summonerId[a])
 				participants[a,7]<-ifNull(jsonMatch$participantIdentities$player$currentPlatformId[a])
 				participants[a,8]<-ifNull(jsonMatch$participantIdentities$player$currentAccountId[a])
 				participants[a,9]<-ifNull(jsonMatch$participantIdentities$player$matchHistoryUri[a])
 				participants[a,10]<-ifNull(jsonMatch$participantIdentities$player$profileIcon[a])
 				a<-a+1
 			}
 		return(participants)
 	}

#=============================================================

matchJSONConverter<-function(batchSize=10,startBatch=1,endBatch=1)
	{
		region<-"NA1"
		
		con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
		totalRow<-dbGetQuery(con,"select count(*) from lol.accountprofile")
		## calculate the total batch number
		batchNum<-ceiling(totalRow[1,]/batchSize)
		j<-startBatch # pointer of a batch
		for (j in startBatch:min(endBatch,batchNum))
			{
				# grab the number = batchSize gameId each time. 
				res<-dbSendQuery(con,paste0("select accountId,gameId from lol.accountprofile where gameParsed_ind is null and gameId!=0 order by ID limit ",batchSize,collapse=''))
				acctgameId<-dbFetch(res)
				dbClearResult(res)
				# Remove gameId or accountId = 0 (recode of NULL)
				a<-1
				for (a in 1:nrow(acctgameId)) # if the first row is Na, 0, row count and any subsetting will ignore the 1st row
					{
						if (is.na(acctgameId[a,1]))
							acctgameId<-acctgameId[-c(a),]
						else acctgameId
						a<-a+1
					}
				rowNum<-nrow(acctgameId)

				i<-1  # pointer within a batch
				for (i in 1:rowNum)
					{
						matchJSONURL<-paste0("https://acs.leagueoflegends.com/v1/stats/game/",region,"/",acctgameId[i,2],"?visiblePlatformId=NA1&visibleAccountId=",acctgameId[i,1],collapse='')
						if (class(try(fromJSON(matchJSONURL)))=="try-error") 
							# gameParsed_ind=2 means 404 error where there is no game to parse
							{dbSendQuery(con,paste0("update lol.accountprofile set gameParsed_ind=2 where accountId=",acctgameId[i,1]," and gameId=",acctgameId[i,2],collapse=''))}
						else
							{

								jsonMatch<-fromJSON(matchJSONURL)
								# get game overview by team
								team<-teams(jsonMatch)
								dbWriteTable(con,"teams",team,append=TRUE) 
								# get game overview by participant
								participant<-participants(jsonMatch)
								dbWriteTable(con,"participants",participant,append=TRUE) 
								# get all participants' identity in a game
								participantIdentity<-participantIdentities(jsonMatch)
								dbWriteTable(con,"participantidentities",participantIdentity,append=TRUE) 
								# append any non-existing accountId to accountids_unique_short
								res<-ifNAinVector(participantIdentity[,4])
								if (length(res)>1) # in case if all accountId is NA
									{
										result<-res[-c(1)] # remove NA in the accountId column of the data frame
									 	dbSendQuery(con,paste0("insert ignore lol.accountids_unique_short (accountId) VALUES(",paste(result,collapse="),("),")"))
									}
								# gameParsed_ind=1 means the game has been parsed
								dbSendQuery(con,paste0("update lol.accountprofile set gameParsed_ind=1 where accountId=",acctgameId[i,1]," and gameId=",acctgameId[i,2],collapse=''))
								print(paste0("Added gameId ",acctgameId[i,2]," of ",acctgameId[i,1]," to teams, participants, and participantidentities db.",collapse=''))

								
							}
						i<-i+1
					}
				print(paste0("Batch ",j," is done."))	

										
			}
		dbDisconnect(con)	
	}


#==================Execute the functions=================
con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
startBatch<-floor(dbGetQuery(con,"select min(ID) from lol.accountprofile where gameParsed_ind is NULL")/10)[,1]
dbDisconnect(con)
matchJSONConverter(80,startBatch,startBatch+50) #30min per 100 batches

#============================================= need to check if the banteam always exists
## grab the banteam info
#banteams<-function(jsonMatch)
#	{
#		team<-data.frame(gameId=NA,teamId=NA,win=NA,firstBlood=NA,firstTower=NA,firstInhibitor=NA,
#					firstBaron=NA,firstDragon=NA,towerKills=NA,inhibitorKills=NA,baronKills=NA,
# 					dragonKills=NA,vilemawKills=NA,dominionVictoryScore=NA,bans=NA)
#		a<-1
#		for (a in 1:length(jsonMatch$teams$bansteams$gameId))
#			{
#				team[a,1]<-jsonMatch$teams$bansteams$gameId
#				team[a,2]<-jsonMatch$teams$bansteams$teamId[a]
#				team[a,3]<-jsonMatch$teams$bansteams$win[a]
#				team[a,4]<-jsonMatch$teams$bansteams$firstBlood[a]
#				team[a,5]<-jsonMatch$teams$bansteams$firstTower[a]
#				team[a,6]<-jsonMatch$teams$bansteams$firstInhibitor[a]
#				team[a,7]<-jsonMatch$teams$bansteams$firstBaron[a]
#				team[a,8]<-jsonMatch$teams$bansteams$firstDragon[a]
#				team[a,9]<-jsonMatch$teams$bansteams$towerKills[a]
#				team[a,10]<-jsonMatch$teams$bansteams$inhibitorKills[a]
#				team[a,11]<-jsonMatch$teams$bansteams$baronKills[a]
#				team[a,12]<-jsonMatch$teams$bansteams$dragonKills[a]
#				team[a,13]<-jsonMatch$teams$bansteams$vilemawKills[a]
#				team[a,14]<-jsonMatch$teams$bansteams$dominionVictoryScore[a]
#				team[a,15]<-jsonMatch$teams$bansteams$bans[a]
#				a<-a+1
#			}
#		return(team)	
#	}

## create a ban team table
#banTeam<-banteams(jsonMatch)#!/usr/bin/Rscript

#==============================windows batch command prefix======================
# this is for batch command
# trailingOnly=TRUE means that only your arguments are returned, check:
# print(commandsArgs(trailingOnly=FALSE))
#args<-commandArgs(trailingOnly = TRUE)

#setwd('C://Users//Sarah//dropbox//R//lol')

library(jsonlite)
library(RMySQL)
library(DBI) 


#==================================================================

ifNull<-function(input)
	{
		if (class(try(input))=="try-error")
			output<-NA
		else if (is.null(input)) 
			output<-NA
		else 
			output<-input
		return(output)
	}

ifNAinVector<-function(input)
	{
		i<-1
		res<--1  # initiate a default value for the vector 
		for (i in 1: length(input))
			{
				if (!is.na(input[i]))
					res<-c(res,input[i])
				i<-i+1
			}
	#	res<-res[-c(1)] # remove the element at position 1
		return(res)
	}

#================================functions to grab each table

teams<-function(jsonMatch)
	{
		team<-data.frame(gameId=NA,teamId=NA,win=NA,firstBlood=NA,firstTower=NA,firstInhibitor=NA,
 					firstBaron=NA,firstDragon=NA,towerKills=NA,inhibitorKills=NA,baronKills=NA,
 					dragonKills=NA,vilemawKills=NA,dominionVictoryScore=NA,ban1=NA,ban2=NA,ban3=NA)
		a<-1 # a represent the teamId 1 or 2
		for (a in 1:2)
			{
				team[a,1]<-jsonMatch$gameId
				team[a,2]<-jsonMatch$teams$teamId[a]
				team[a,3]<-jsonMatch$teams$win[a]
				team[a,4]<-jsonMatch$teams$firstBlood[a]
				team[a,5]<-jsonMatch$teams$firstTower[a]
				team[a,6]<-jsonMatch$teams$firstInhibitor[a]
				team[a,7]<-jsonMatch$teams$firstBaron[a]
				team[a,8]<-jsonMatch$teams$firstDragon[a]
				team[a,9]<-jsonMatch$teams$towerKills[a]
				team[a,10]<-jsonMatch$teams$inhibitorKills[a]
				team[a,11]<-jsonMatch$teams$baronKills[a]
				team[a,12]<-jsonMatch$teams$dragonKills[a]
				#if (!is.null(jsonMatch$teams$vilemawKills[a])) 
				team[a,13]<-jsonMatch$teams$vilemawKills[a]
				team[a,14]<-jsonMatch$teams$dominionVictoryScore[a]
				if (length(jsonMatch$teams$bans[[a]])==0)
					{
						team[a,15]<-NA
						team[a,16]<-NA
						team[a,17]<-NA
					}
					

				else 
					{
						team[a,15]<-jsonMatch$teams$bans[[a]][1,1]
						team[a,16]<-jsonMatch$teams$bans[[a]][2,1]
						team[a,17]<-jsonMatch$teams$bans[[a]][3,1]
					}	

					
				a<-a+1
			}
		return(team)	
	}



#========================================================================================
## grab the team info, both the win and lose teams




## grab participants details in a game
participants<-function(jsonMatch)
	{
		participant<-data.frame(gameId=NA,participantId=NA,teamId=NA,championId=NA,spell1Id=NA,spell2Id=NA,
								masteryId1=NA,mrank1=NA,masteryId2=NA,mrank2=NA,masteryId3=NA,mrank3=NA,
								masteryId4=NA,mrank4=NA,masteryId5=NA,mrank5=NA,masteryId6=NA,mrank6=NA,
								masteryId7=NA,mrank7=NA,masteryId8=NA,mrank8=NA,masteryId9=NA,mrank9=NA,
								masteryId10=NA,mrank10=NA,masteryId11=NA,mrank11=NA,masteryId12=NA,mrank12=NA,
								masteryId13=NA,mrank13=NA,masteryId14=NA,mrank14=NA,masteryId15=NA,mrank15=NA,
								masteryId16=NA,mrank16=NA,masteryId17=NA,mrank17=NA,masteryId18=NA,mrank18=NA,
								masteryId19=NA,mrank19=NA,masteryId20=NA,mrank20=NA,runeId1=NA,rrank1=NA,
								runeId2=NA,rrank2=NA,runeId3=NA,rrank3=NA,runeId4=NA,rrank4=NA,
								runeId5=NA,rrank5=NA,runeId6=NA,rrank6=NA,runeId7=NA,rrank7=NA,
								runeId8=NA,rrank8=NA,runeId9=NA,rrank9=NA,runeId10=NA,rrank10=NA,
								highestAchievedSeasonTier=NA,
								#participantId=NA,
								win=NA,item0=NA,
								item1=NA,item2=NA,item3=NA,item4=NA,item5=NA,item6=NA,kills=NA,
								deaths=NA,assists=NA,largestKillingSpree=NA,largestMultiKill=NA,
								killingSprees=NA,longestTimeSpentLiving=NA,doubleKills=NA,tripleKills=NA,
								quadraKills=NA,pentaKills=NA,unrealKills=NA,totalDamageDealt=NA,magicDamageDealt=NA,
								physicalDamageDealt=NA,trueDamageDealt=NA,largestCriticalStrike=NA,totalDamageDealtToChampions=NA,
								magicDamageDealtToChampions=NA,physicalDamageDealtToChampions=NA,trueDamageDealtToChampions=NA,
								totalHeal=NA,totalUnitsHealed=NA,totalDamageTaken=NA,magicalDamageTaken=NA,physicalDamageTaken=NA,
								trueDamageTaken=NA,goldEarned=NA,goldSpent=NA,turretKills=NA,inhibitorKills=NA,totalMinionsKilled=NA,
								neutralMinionsKilled=NA,totalTimeCrowdControlDealt=NA,champLevel=NA,visionWardsBoughtInGame=NA,
								sightWardsBoughtInGame=NA,wardsPlaced=NA,wardsKilled=NA,firstBloodKill=NA,firstBloodAssist=NA,
								firstTowerKill=NA,firstTowerAssist=NA,firstInhibitorKill=NA,firstInhibitorAssist=NA,
								combatPlayerScore=NA,objectivePlayerScore=NA,totalPlayerScore=NA,totalScoreRank=NA,
								#participantId=NA,
								creepsPerMinDeltas_10_20=NA, creepsPerMinDeltas_0_10=NA,xpPerMinDeltas_10_20=NA,
								xpPerMinDeltas_0_10=NA,goldPerMinDeltas_10_20=NA,goldPerMinDeltas_0_10=NA,csDiffPerMinDeltas_10_20=NA,
								csDiffPerMinDeltas_0_10=NA,xpDiffPerMinDeltas_10_20=NA,xpDiffPerMinDeltas_0_10=NA,
								damageTakenPerMinDeltas_10_20=NA,damageTakenPerMinDeltas_0_10=NA,damageTakenDiffPerMinDeltas_10_20=NA,
								damageTakenDiffPerMinDeltas_0_10=NA,role=NA,lane=NA)
		a<-1
		for (a in 1:10)
			{
				participant[a,1]<-jsonMatch$gameId
				participant[a,2]<-jsonMatch$participants$participantId[a]
				participant[a,3]<-jsonMatch$participants$teamId[a]
				participant[a,4]<-jsonMatch$participants$championId[a]
				participant[a,5]<-jsonMatch$participants$spell1Id[a]
				participant[a,6]<-jsonMatch$participants$spell2Id[a]

				participant[a,7]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][1,1]",collapse=''))))
				participant[a,8]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][1,2]",collapse=''))))
				participant[a,9]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][2,1]",collapse=''))))
				participant[a,10]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][2,2]",collapse=''))))
				participant[a,11]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][3,1]",collapse=''))))
				participant[a,12]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][3,2]",collapse=''))))
				participant[a,13]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][4,1]",collapse=''))))
				participant[a,14]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][4,2]",collapse=''))))
				participant[a,15]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][5,1]",collapse=''))))
				participant[a,16]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][5,2]",collapse=''))))
				participant[a,17]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][6,1]",collapse=''))))
				participant[a,18]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][6,2]",collapse=''))))
				participant[a,19]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][7,1]",collapse=''))))
				participant[a,20]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][7,2]",collapse=''))))
				participant[a,21]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][8,1]",collapse=''))))
				participant[a,22]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][8,2]",collapse=''))))
				participant[a,23]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][9,1]",collapse=''))))
				participant[a,24]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][9,2]",collapse=''))))
				participant[a,25]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][10,1]",collapse=''))))
				participant[a,26]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][10,2]",collapse=''))))
				participant[a,27]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][11,1]",collapse=''))))
				participant[a,28]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][11,2]",collapse=''))))
				participant[a,29]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][12,1]",collapse=''))))
				participant[a,30]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][12,2]",collapse=''))))
				participant[a,31]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][13,1]",collapse=''))))
				participant[a,32]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][13,2]",collapse=''))))
				participant[a,33]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][14,1]",collapse=''))))
				participant[a,34]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][14,2]",collapse=''))))
				participant[a,35]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][15,1]",collapse=''))))
				participant[a,36]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][15,2]",collapse=''))))
				participant[a,37]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][16,1]",collapse=''))))
				participant[a,38]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][16,2]",collapse=''))))
				participant[a,39]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][17,1]",collapse=''))))
				participant[a,40]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][17,2]",collapse=''))))
				participant[a,41]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][18,1]",collapse=''))))
				participant[a,42]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][18,2]",collapse=''))))
				participant[a,43]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][19,1]",collapse=''))))
				participant[a,44]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][19,2]",collapse=''))))
				participant[a,45]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][20,1]",collapse=''))))
				participant[a,46]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$masteries[[",a,"]][20,2]",collapse=''))))

				
				participant[a,47]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][1,1]",collapse=''))))
				participant[a,48]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][1,2]",collapse=''))))
				participant[a,49]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][2,1]",collapse=''))))
				participant[a,50]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][2,2]",collapse=''))))
				participant[a,51]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][3,1]",collapse=''))))
				participant[a,52]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][3,2]",collapse=''))))
				participant[a,53]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][4,1]",collapse=''))))
				participant[a,54]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][4,2]",collapse=''))))
				participant[a,55]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][5,1]",collapse=''))))
				participant[a,56]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][5,2]",collapse=''))))
				participant[a,57]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][6,1]",collapse=''))))
				participant[a,58]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][6,2]",collapse=''))))
				participant[a,59]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][7,1]",collapse=''))))
				participant[a,60]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][7,2]",collapse=''))))
				participant[a,61]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][8,1]",collapse=''))))
				participant[a,62]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][8,2]",collapse=''))))
				participant[a,63]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][9,1]",collapse=''))))
				participant[a,64]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][9,2]",collapse=''))))
				participant[a,65]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][10,1]",collapse=''))))
				participant[a,66]<-ifNull(eval(parse(text=paste0("jsonMatch$participants$runes[[",a,"]][10,2]",collapse=''))))
		
				participant[a,67]<-jsonMatch$participants$highestAchievedSeasonTier[a]
				#participant[a,68]<-jsonMatch$participants$stats$participantId[a]  
				participant[a,68]<-as.character(jsonMatch$participants$stats$win[a])
				participant[a,69]<-jsonMatch$participants$stats$item0[a]
				participant[a,70]<-jsonMatch$participants$stats$item1[a]
				participant[a,71]<-jsonMatch$participants$stats$item2[a]
				participant[a,72]<-jsonMatch$participants$stats$item3[a]
				participant[a,73]<-jsonMatch$participants$stats$item4[a]
				participant[a,74]<-jsonMatch$participants$stats$item5[a]
				participant[a,75]<-jsonMatch$participants$stats$item6[a]
				participant[a,76]<-jsonMatch$participants$stats$kills[a]
				participant[a,77]<-jsonMatch$participants$stats$deaths[a]
				participant[a,78]<-jsonMatch$participants$stats$assists[a]
				participant[a,79]<-jsonMatch$participants$stats$largestKillingSpree[a]
				participant[a,80]<-jsonMatch$participants$stats$largestMultiKill[a]
				participant[a,81]<-jsonMatch$participants$stats$killingSprees[a]
				participant[a,82]<-jsonMatch$participants$stats$longestTimeSpentLiving[a]
				participant[a,83]<-jsonMatch$participants$stats$doubleKills[a]
				participant[a,84]<-jsonMatch$participants$stats$tripleKills[a]
				participant[a,85]<-jsonMatch$participants$stats$quadraKills[a]
				participant[a,86]<-jsonMatch$participants$stats$pentaKills[a]
				participant[a,87]<-jsonMatch$participants$stats$unrealKills[a]
				participant[a,88]<-jsonMatch$participants$stats$totalDamageDealt[a]
				participant[a,89]<-jsonMatch$participants$stats$magicDamageDealt[a]
				participant[a,90]<-jsonMatch$participants$stats$physicalDamageDealt[a]
				participant[a,91]<-ifNull(jsonMatch$participants$stats$trueDamageDealt[a])
				participant[a,92]<-ifNull(jsonMatch$participants$stats$largestCriticalStrike[a])
				participant[a,93]<-jsonMatch$participants$stats$totalDamageDealtToChampions[a]
				participant[a,94]<-jsonMatch$participants$stats$magicDamageDealtToChampions[a]
				participant[a,95]<-jsonMatch$participants$stats$physicalDamageDealtToChampions[a]
				participant[a,96]<-ifNull(jsonMatch$participants$stats$trueDamageDealtToChampions[a])
				participant[a,97]<-ifNull(jsonMatch$participants$stats$totalHeal[a])
				participant[a,98]<-ifNull(jsonMatch$participants$stats$totalUnitsHealed[a])
				participant[a,99]<-jsonMatch$participants$stats$totalDamageTaken[a]
				participant[a,100]<-jsonMatch$participants$stats$magicalDamageTaken[a]
				participant[a,101]<-jsonMatch$participants$stats$physicalDamageTaken[a]
				participant[a,102]<-ifNull(jsonMatch$participants$stats$trueDamageTaken[a])
				participant[a,103]<-jsonMatch$participants$stats$goldEarned[a]
				participant[a,104]<-jsonMatch$participants$stats$goldSpent[a]
				participant[a,105]<-ifNull(jsonMatch$participants$stats$turretKills[a])
				participant[a,106]<-ifNull(jsonMatch$participants$stats$inhibitorKills[a])
				participant[a,107]<-jsonMatch$participants$stats$totalMinionsKilled[a]
				participant[a,108]<-jsonMatch$participants$stats$neutralMinionsKilled[a]
				participant[a,109]<-ifNull(jsonMatch$participants$stats$totalTimeCrowdControlDealt[a])
				participant[a,110]<-jsonMatch$participants$stats$champLevel[a]
				participant[a,111]<-ifNull(jsonMatch$participants$stats$visionWardsBoughtInGame[a])
				participant[a,112]<-ifNull(jsonMatch$participants$stats$sightWardsBoughtInGame[a])
				participant[a,113]<-ifNull(jsonMatch$participants$stats$wardsPlaced[a])
				participant[a,114]<-ifNull(jsonMatch$participants$stats$wardsKilled[a])
				if (!is.null(jsonMatch$participants$stats$firstBloodKill[a]))
					participant[a,115]<-as.character(jsonMatch$participants$stats$firstBloodKill[a])
				if (!is.null(jsonMatch$participants$stats$firstBloodAssist[a]))
					participant[a,116]<-as.character(jsonMatch$participants$stats$firstBloodAssist[a])
				if (!is.null(jsonMatch$participants$stats$firstTowerKill[a]))
					participant[a,117]<-as.character(jsonMatch$participants$stats$firstTowerKill[a])
				else participant[a,117]<-NA
				if (!is.null(jsonMatch$participants$stats$firstTowerAssist[a]))
					participant[a,118]<-as.character(jsonMatch$participants$stats$firstTowerAssist[a])
				else participant[a,118]<-NA
				if (!is.null(jsonMatch$participants$stats$firstInhibitorKill[a]))
					participant[a,119]<-as.character(jsonMatch$participants$stats$firstInhibitorKill[a])
				else participant[a,119]<-NA
				if (!is.null(jsonMatch$participants$stats$firstInhibitorAssist[a]))
					participant[a,120]<-as.character(jsonMatch$participants$stats$firstInhibitorAssist[a])
				else participant[a,120]<-NA
				participant[a,121]<-jsonMatch$participants$stats$combatPlayerScore[a]
				participant[a,122]<-jsonMatch$participants$stats$objectivePlayerScore[a]
				participant[a,123]<-jsonMatch$participants$stats$totalPlayerScore[a]
				participant[a,124]<-jsonMatch$participants$stats$totalScoreRank[a]
				#participant[a,126]<-jsonMatch$participants$timeline$participantId[a]

				participant[a,125]<-ifNull(jsonMatch$participants$timeline$creepsPerMinDeltas$'10-20'[a])
				participant[a,126]<-ifNull(jsonMatch$participants$timeline$creepsPerMinDeltas$'0-10'[a])
				participant[a,127]<-ifNull(jsonMatch$participants$timeline$xpPerMinDeltas$'10-20'[a])
				participant[a,128]<-ifNull(jsonMatch$participants$timeline$xpPerMinDeltas$'0-10'[a])
				participant[a,129]<-ifNull(jsonMatch$participants$timeline$goldPerMinDeltas$'10-20'[a])
				participant[a,130]<-ifNull(jsonMatch$participants$timeline$goldPerMinDeltas$'0-10'[a])
				participant[a,131]<-ifNull(jsonMatch$participants$timeline$csDiffPerMinDeltas$'10-20'[a])
				participant[a,132]<-ifNull(jsonMatch$participants$timeline$csDiffPerMinDeltas$'0-10'[a])
				participant[a,133]<-ifNull(jsonMatch$participants$timeline$xpDiffPerMinDeltas$'10-20'[a])
				participant[a,134]<-ifNull(jsonMatch$participants$timeline$xpDiffPerMinDeltas$'0-10'[a])
				participant[a,135]<-ifNull(jsonMatch$participants$timeline$damageTakenPerMinDeltas$'10-20'[a])
				participant[a,136]<-ifNull(jsonMatch$participants$timeline$damageTakenPerMinDeltas$'0-10'[a])
				participant[a,137]<-ifNull(jsonMatch$participants$timeline$damageTakenDiffPerMinDeltas$'10-20'[a])
				participant[a,138]<-ifNull(jsonMatch$participants$timeline$damageTakenDiffPerMinDeltas$'0-10'[a])
				participant[a,139]<-jsonMatch$participants$timeline$role[a]
				participant[a,140]<-jsonMatch$participants$timeline$lane[a]
				a<-a+1
			}	
		return(participant)						
	}


## grab participant identities. Usually, only the user we access the match info from will has non-NA info
participantIdentities<-function(jsonMatch)
 	{
 		participants<-data.frame(gameId=NA,participantId=NA,platformId=NA,accountId=NA,summonerName=NA,
 								summonerId=NA,currentPlatformId=NA,currentAccountId=NA,matchHistoryUri=NA,
 								profileIcon=NA)
 		a<-1
 		for (a in 1:10)
 			{
 				participants[a,1]<-jsonMatch$gameId
 				participants[a,2]<-jsonMatch$participantIdentities$participantId[a]
 				participants[a,3]<-ifNull(jsonMatch$participantIdentities$player$platformId[a])
 				participants[a,4]<-ifNull(jsonMatch$participantIdentities$player$accountId[a])
 				participants[a,5]<-ifNull(jsonMatch$participantIdentities$player$summonerName[a])
 				participants[a,6]<-ifNull(jsonMatch$participantIdentities$player$summonerId[a])
 				participants[a,7]<-ifNull(jsonMatch$participantIdentities$player$currentPlatformId[a])
 				participants[a,8]<-ifNull(jsonMatch$participantIdentities$player$currentAccountId[a])
 				participants[a,9]<-ifNull(jsonMatch$participantIdentities$player$matchHistoryUri[a])
 				participants[a,10]<-ifNull(jsonMatch$participantIdentities$player$profileIcon[a])
 				a<-a+1
 			}
 		return(participants)
 	}

#=============================================================

matchJSONConverter<-function(batchSize=10,startBatch=1,endBatch=1)
	{
		region<-"NA1"
		
		con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
		totalRow<-dbGetQuery(con,"select count(*) from lol.accountprofile")
		## calculate the total batch number
		batchNum<-ceiling(totalRow[1,]/batchSize)
		j<-startBatch # pointer of a batch
		for (j in startBatch:min(endBatch,batchNum))
			{
				# grab the number = batchSize gameId each time. 
				res<-dbSendQuery(con,paste0("select accountId,gameId from lol.accountprofile where gameParsed_ind is null and gameId!=0 order by ID limit ",batchSize,collapse=''))
				acctgameId<-dbFetch(res)
				dbClearResult(res)
				# Remove gameId or accountId = 0 (recode of NULL)
				a<-1
				for (a in 1:nrow(acctgameId)) # if the first row is Na, 0, row count and any subsetting will ignore the 1st row
					{
						if (is.na(acctgameId[a,1]))
							acctgameId<-acctgameId[-c(a),]
						else acctgameId
						a<-a+1
					}
				rowNum<-nrow(acctgameId)

				i<-1  # pointer within a batch
				for (i in 1:rowNum)
					{
						matchJSONURL<-paste0("https://acs.leagueoflegends.com/v1/stats/game/",region,"/",acctgameId[i,2],"?visiblePlatformId=NA1&visibleAccountId=",acctgameId[i,1],collapse='')
						if (class(try(fromJSON(matchJSONURL)))=="try-error") 
							# gameParsed_ind=2 means 404 error where there is no game to parse
							{dbSendQuery(con,paste0("update lol.accountprofile set gameParsed_ind=2 where accountId=",acctgameId[i,1]," and gameId=",acctgameId[i,2],collapse=''))}
						else
							{

								jsonMatch<-fromJSON(matchJSONURL)
								# get game overview by team
								team<-teams(jsonMatch)
								dbWriteTable(con,"teams",team,append=TRUE) 
								# get game overview by participant
								participant<-participants(jsonMatch)
								dbWriteTable(con,"participants",participant,append=TRUE) 
								# get all participants' identity in a game
								participantIdentity<-participantIdentities(jsonMatch)
								dbWriteTable(con,"participantidentities",participantIdentity,append=TRUE) 
								# append any non-existing accountId to accountids_unique_short
								res<-ifNAinVector(participantIdentity[,4])
								if (length(res)>1) # in case if all accountId is NA
									{
										result<-res[-c(1)] # remove NA in the accountId column of the data frame
									 	dbSendQuery(con,paste0("insert ignore lol.accountids_unique_short (accountId) VALUES(",paste(result,collapse="),("),")"))
									}
								# gameParsed_ind=1 means the game has been parsed
								dbSendQuery(con,paste0("update lol.accountprofile set gameParsed_ind=1 where accountId=",acctgameId[i,1]," and gameId=",acctgameId[i,2],collapse=''))
								print(paste0("Added gameId ",acctgameId[i,2]," of ",acctgameId[i,1]," to teams, participants, and participantidentities db.",collapse=''))

								
							}
						i<-i+1
					}
				print(paste0("Batch ",j," is done."))	

										
			}
		dbDisconnect(con)	
	}


#==================Execute the functions=================
con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
startBatch<-floor(dbGetQuery(con,"select min(ID) from lol.accountprofile where gameParsed_ind is NULL")/10)[,1]
dbDisconnect(con)
matchJSONConverter(80,startBatch,startBatch+50) #30min per 100 batches

#============================================= need to check if the banteam always exists
## grab the banteam info
#banteams<-function(jsonMatch)
#	{
#		team<-data.frame(gameId=NA,teamId=NA,win=NA,firstBlood=NA,firstTower=NA,firstInhibitor=NA,
#					firstBaron=NA,firstDragon=NA,towerKills=NA,inhibitorKills=NA,baronKills=NA,
# 					dragonKills=NA,vilemawKills=NA,dominionVictoryScore=NA,bans=NA)
#		a<-1
#		for (a in 1:length(jsonMatch$teams$bansteams$gameId))
#			{
#				team[a,1]<-jsonMatch$teams$bansteams$gameId
#				team[a,2]<-jsonMatch$teams$bansteams$teamId[a]
#				team[a,3]<-jsonMatch$teams$bansteams$win[a]
#				team[a,4]<-jsonMatch$teams$bansteams$firstBlood[a]
#				team[a,5]<-jsonMatch$teams$bansteams$firstTower[a]
#				team[a,6]<-jsonMatch$teams$bansteams$firstInhibitor[a]
#				team[a,7]<-jsonMatch$teams$bansteams$firstBaron[a]
#				team[a,8]<-jsonMatch$teams$bansteams$firstDragon[a]
#				team[a,9]<-jsonMatch$teams$bansteams$towerKills[a]
#				team[a,10]<-jsonMatch$teams$bansteams$inhibitorKills[a]
#				team[a,11]<-jsonMatch$teams$bansteams$baronKills[a]
#				team[a,12]<-jsonMatch$teams$bansteams$dragonKills[a]
#				team[a,13]<-jsonMatch$teams$bansteams$vilemawKills[a]
#				team[a,14]<-jsonMatch$teams$bansteams$dominionVictoryScore[a]
#				team[a,15]<-jsonMatch$teams$bansteams$bans[a]
#				a<-a+1
#			}
#		return(team)	
#	}

## create a ban team table
#banTeam<-banteams(jsonMatch)
