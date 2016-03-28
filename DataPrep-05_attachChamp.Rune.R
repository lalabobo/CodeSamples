#!/usr/bin/Rscript
library(DBI)
library(RMySQL)
# this script does
# 1. attach champion stats
# 2. attach rune stats
# 3. accumulate runes stats from runeId1 to runeId10, on top of item stats

# read a sql file as a string
read_sql<-function(path)
{
  if (file.exists(path))
    sql<-readChar(path,nchar= file.info(path)$size)
  else sql<-NA
  return(sql)
}



# if a table exist
ifExists<-function(con,table,index,range)
{
    a<-index
    for (index in a:length(range))
    {
        # table already exists
        if (class(try(dbGetQuery(con, paste0("select 1 from lol.",table,range[index]," limit 1"))))!='try-error') # If the table exists
            {
                index<-index+1
                print(paste0("Continue with index ", index))
            }
        else 
            {
                break
                print(paste0("The loop is broken out at index ",index))
            }
    }
    return(index)    

}


# loop through the nameDates 
exec<-function()
{
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
    nameDateList<-c("150528","150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
       				,"150610","150611","150612","150613","150614")
    #nameDateList<-"150528"
    i<-1    # index of nameDate
    #i<-2
#=== checking table     
    table<-"participant_champion_"
    i<-ifExists(con,table,i,nameDateList)   # if already attach the champion stats to this table, return to the next nameDate that hasn't been done.
    b<-i
    if (b>length(nameDateList)) print("No participant_champion table is needed to generate.")
    # outter loop: loop through all dates
    else {
            for (i in b:length(nameDateList))
            #for (i in i:1)
            {
                nameDate<-nameDateList[i]
                # check if 03-#-TransParticipant.R finishes a nameDate or not
                table_ranked<-paste0("select count(distinct gameId) from lol.timeline_event_join_",nameDate,"_ranked")
                res1<-dbGetQuery(con,table_ranked)
                table_rollup<-paste0("select count(distinct gameId) from lol.participant_rollup_",nameDate)
                res2<-dbGetQuery(con,table_rollup)
                # only a finished nameDate can continue
                if (res1[1,1]==res2[1,1]) 
                {
                    
                    path<-"/src/lol/SQL/04-participant_champion.sql"
                    sql_champion<-read_sql(path)  # sql file for join
                    sql_champion<-gsub("nameDate",nameDate,sql_champion)
                    dbSendQuery(con,paste0("drop table if exists lol.",table,nameDate))
                    dbSendQuery(con,sql_champion)   # join champion table to the participant_rollup for each day
                    
        
                    j<-1    # rune number  
                    table<-paste0("participant_champion_rune_",nameDateList[i],"_")
                    range<-c(j:10) # in total 10 runes
                    j<-ifExists(con,table,j,range) # check if a table already exist. if so, increment j
                    a<-j
                    # inner loop: loop through join each rune
                    for (j in a:10) # there are at most 10 runes
                    {
                       print(paste0("beginning ",j))
                       # for the initial table: item stats + runeId1 stats
                       # continue if the table doesn't exist
                        if (j==1) 
                        {
                            path<-"/src/lol/SQL/05-1-participant_champion_rune.sql" # set up to initiate stacking up stats
                            sql_rune_1<-read_sql(path)   # sql file for indexing
                            
                            sql_rune_1<-gsub("next",j,gsub("nameDate",nameDate,sql_rune_1))     # initiate the first table participant_championi_rune_1
                            dbSendQuery(con,paste0("drop table if exists lol.",table,"_",j))
                            
                            sql_rune<-gsub("rrankNum",paste0("rrank",j),gsub("runeIdNum",paste0("runeId",j),sql_rune_1))
                            dbSendQuery(con,paste0("alter table lol.participant_champion_",nameDate," modify version varchar(10),add index runeId",j,"version (runeId",j,",version),add unique index gameIdParticipantId (gameId,participantId);"))
                            dbSendQuery(con,sql_rune)
                        }
                        # accumulcate stats from runeId2 and onwards
                        # continue if the table doesn't exist
                        if (j>1) 
                        {
                            path<-"/src/lol/SQL/05-2-participant_champion_rune.sql"
                            sql_rune_2<-read_sql(path)   # sql file for indexing
                            
                            sql_rune_2<-gsub("prev",j-1,gsub("next",j,gsub("nameDate",nameDate,sql_rune_2)))  # join the rune table to the previous table to calculate the effect of multiple runes incrementally
                            sql_rune<-gsub("rrankNum",paste0("rrank",j),gsub("runeIdNum",paste0("runeId",j),sql_rune_2))
                            # adding index
                            dbSendQuery(con,paste0("alter table lol.participant_champion_rune_",nameDate,"_",j-1," modify version varchar(10),add index runeId",j,"version (runeId",j,",version), add unique index gameIdParticipantId (gameId,participantId);"))
                            dbSendQuery(con,paste0("drop table if exists lol.",table,"_",j))
                            dbSendQuery(con,sql_rune)
                        }
                        print(paste0("end of loop 1 ",j))
                    }
                }
                else print(paste0("The table participant_rollup_",nameDate," hasn't finished yet."))
        
            }
        }
    dbDisconnect(con)
    print(paste0("end of outer loop ",j))
#    source("/src/lol/2-DataPrep/05-calc_join_full.R")
}

exec()

