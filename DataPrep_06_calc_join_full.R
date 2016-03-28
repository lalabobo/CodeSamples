#!/usr/bin/Rscript
library(DBI)
library(RMySQL)

# 1.  calculate and consolidate Flat~ by including Percent~ stats in participant_champion_rune & apply capping (participant_champion_rune_nameDate_calc)
# 2.  grab the rune tier, type and tag from each participant_champion_rune table (participant_champion_rune_nameDate_join)
# 3.  attach variables that are intentionally dropped due to reaching the column number limit (participant_champion_rune_nameDate_full)


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

# run all the script 05-3 ~ 05-5 one after another
exec<-function()
{
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
#    nameDateList<-c("150528","150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
    nameDateList<-c("150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
                    ,"150610","150611","150612","150613","150614")
    i<-1
    for (i in 1:length(nameDateList))   # go through each nameDate
    #for (i in 1:1)     for testing
    {
        nameDate<-nameDateList[i]
        table<-paste0("participant_champion_rune_",nameDate,"_10")
        # If the table exists, means 04-attachChamp_Rune.R for that nameDate has finished
        if (class(try(dbGetQuery(con, paste0("select 1 from lol.",table," limit 1"))))!='try-error') 
            {
                # 1.  calculate and consolidate Flat~ by including Percent~ stats in participant_champion_rune & apply capping (participant_champion_rune_nameDate_calc)
                table<-paste0("participant_champion_rune_",nameDate,"_calc")
                # only continue if table _calc doesn't exist
                if (class(try(dbGetQuery(con, paste0("select 1 from lol.",table," limit 1"))))=='try-error') 
                {
                    path<-"/src/lol/SQL/05-3-participant_champion_rune_calculate.sql"
                    sql_calc<-read_sql(path)  # sql file for join
                    sql_calc<-gsub("nameDate",nameDate,sql_calc)
                    dbSendQuery(con,sql_calc)   # join champion table to the participant_rollup for each day
                    print(paste0("Generated participant_champion_rune_",nameDate,"_calc"))
                }
            
                # 2.  grab the rune tier, type and tag from each participant_champion_rune table (participant_champion_rune_nameDate_join)
                table<-paste0("participant_champion_rune_",nameDate,"_join")
                # only continue if the final table _join doesn't exist
                if (class(try(dbGetQuery(con, paste0("select 1 from lol.",table," limit 1"))))=='try-error') 
                {
                   # loop through each table of a nameDate
                   j<-1     # table index from 1 - 10
                   # start with participant_champion_rune_join_calc; end up with participant_champion_rune_join_endIndex

                        endIndex<-j
                        endTable<-paste0("participant_champion_rune_",nameDate,"_join_",endIndex)
                        # only continue if the table doesn't exist
                        if ((j==1) & (class(try(dbGetQuery(con, paste0("select 1 from lol.",endTable," limit 1"))))=='try-error')) 
                        {
                            path<-"/src/lol/SQL/05-4-participant_champion_rune_join_1.sql"
                            sql_join<-read_sql(path)  # sql file for join
                            sql_join<-gsub("nameDate",nameDate,sql_join)
                            sql_join<-gsub("runeIdNum",paste0("runeId",j),sql_join)
                            sql_join<-gsub("endIndex",endIndex,sql_join)
                            dbSendQuery(con,sql_join)   # join champion table to the participant_rollup for each day
                            print(paste0("Created ",endTable))
                        
                        }
                        else print(paste0("Table ",endTable," already exists."))
                        
                    j<-2 
                    for (j in 2:10) # the numbers here correspond to rune number
                   {                       
                        startIndex<-j-1
                        endIndex<-j
                        endTable<-paste0("participant_champion_rune_",nameDate,"_join_",endIndex)
                        # start with participant_champion_rune_join_startIndex; end up with participant_champion_rune_join_endIndex
                        if ((j>1 & j<9) & (class(try(dbGetQuery(con, paste0("select 1 from lol.",endTable," limit 1"))))=='try-error'))
                        {
                            path<-"/src/lol/SQL/05-4-participant_champion_rune_join_2.sql"
                            sql_join<-read_sql(path)  # sql file for join
                            sql_join<-gsub("nameDate",nameDate,sql_join)
                            sql_join<-gsub("runeIdNum",paste0("runeId",j),sql_join)
                            sql_join<-gsub("endIndex",endIndex,sql_join)
                            sql_join<-gsub("startIndex",startIndex,sql_join)
                            dbSendQuery(con,sql_join)   # join champion table to the participant_rollup for each day
                            print(paste0("Created ",endTable))
                            
                            # drop table_startIndex
            #                path<-"/src/lol/SQL/00-dropIfExists.sql"
            #                sql_drop<-read_sql(path)  # sql file for join
            #                dropTable<-paste0("participant_champion_rune_nameDate_join_",startIndex)
            #                sql_drop<-gsub("tableName",dropTable,sql_drop)
            #                dbSendQuery(con,sql_drop)
                            
                        }
                        
                        # start with participant_champion_rune_join_startIndex; end up with participant_champion_rune_join
                        # runeId10_tier, type, etc are already in lol.participant_champion_rune_150528_10 -> _calc
                        if  (j==9) 
                        {
                            path<-"/src/lol/SQL/05-4-participant_champion_rune_join_3.sql"
                            sql_join<-read_sql(path)  # sql file for join
                            sql_join<-gsub("nameDate",nameDate,sql_join)
                            sql_join<-gsub("runeIdNum",paste0("runeId",j),sql_join)
                            sql_join<-gsub("endIndex",endIndex,sql_join)
                            sql_join<-gsub("startIndex",startIndex,sql_join)
                            dbSendQuery(con,sql_join)   # join champion table to the participant_rollup for each day
                            print(paste0("Created ",endTable))
                            
                            # drop table_startIndex
            #                path<-"/src/lol/SQL/00-dropIfExists.sql"
            #                sql_drop<-read_sql(path)  # sql file for join
            #                dropTable<-paste0("participant_champion_rune_nameDate_join_",startIndex)
            #                sql_drop<-gsub("tableName",dropTable,sql_drop)
            #                dbSendQuery(con,sql_drop)
                        }
                   }

                }
                
                
                # 3.  attach variables that are intentionally dropped due to reaching the column number limit (participant_champion_rune_nameDate_full)
                table<-paste0("participant_champion_rune_",nameDate,"_full")
                # only continue if table doesn't exist
                if (class(try(dbGetQuery(con, paste0("select 1 from lol.",table," limit 1"))))=='try-error') 
                {
                    path<-"/src/lol/SQL/05-5-participant_champion_rune_full.sql"
                    sql_full<-read_sql(path)  # sql file for join
                    sql_full<-gsub("nameDate",nameDate,sql_full)
                    dbSendQuery(con,sql_full)   # join champion table to the participant_rollup for each day
                    print(paste0("Created ",table))
                }
                
                # 4. drop tables
                j<-1    # table index participant_champion_rune_nameDate_#
               table<-paste0("participant_champion_rune_",nameDate,"_",j)
                for (j in 1:10)
                {
                   if (class(try(dbGetQuery(con, paste0("select 1 from lol.participant_champion_rune_",nameDate,"_full limit 1"))))!='try-error') 
                    # continue only if step 3 finishes
                    {
                        table<-paste0("participant_champion_rune_",nameDate,"_",j)
                        path<-"/src/lol/SQL/00-dropIfExists.sql"
                        sql_drop<-read_sql(path)
                        sql_drop<-gsub("tableName",table,sql_drop)
                        dbSendQuery(con,sql_drop) # drop table 
                        print(paste0("Dropped table ",table))
                    }
                    
                    
     #           }
                
                
            }
        else print(paste("The table ",table," doesn't exist."))
        
        print(paste0("Finished checking nameDate ",nameDateList[i]))

    }
    
    dbDisconnect(con)  
    source("/src/lol/2-DataPrep/05-unionForModelling.R")
}

exec()
