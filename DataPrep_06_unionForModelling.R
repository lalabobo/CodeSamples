#!/usr/bin/Rscript
library(DBI)
library(RMySQL)
#  union across all nameDates to form one table

# union function: combine 2 tables together at a time
union<-function(con,startTable,resultTable)
{
    dbSendQuery(con,paste0("insert into ",resultTable," select * from lol.",startTable))   # put all participant_champion_rune_nameDate_join_index in one table
}

# read a sql file as a string
read_sql<-function(path)
{
      if (file.exists(path))
            sql<-readChar(path,nchar= file.info(path)$size)
      else sql<-NA
      return(sql)
}

# union tables in a loop
exec<-function()
{
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
    nameDateList<-c("150528","150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
           				,"150610","150611","150612","150613","150614")
    
    nameDate_begin<-nameDateList[1]
    nameDate_stop<-nameDateList[length(nameDateList)]
    resultTable<-paste0("participant_champion_rune_",nameDate_begin,"_",nameDate_stop,"_union")
    # 1. insert each nameDate to the unioned table
    # if the final union table doesn't exist
    if (class(try(dbGetQuery(con, paste0("select 1 from lol.",resultTable," limit 1"))))=='try-error') # if the resultTable hasn't been initialised
    {
        # if the last nameDate full table is ready
        if (class(try(dbGetQuery(con, paste0("select 1 from lol.participant_champion_rune_",nameDate_stop,"_full limit 1"))))!='try-error')
            {
                # initialise the unioned table with index
                startTable<-paste0("participant_champion_rune_",nameDate_begin,"_full")
                dbGetQuery(con,paste0("create table lol.",resultTable," (unique index gameIdParticipant (gameId,participantId), index parsedDate (parsedDate))  as select * from lol.",startTable))
            
            }
    }   
    else print(paste0("The final union table ",resultTable," already exist."))
    
        
    # continue if _full hasn't have all parsedDate records unioned
    if (dbGetQuery(con,paste0("select max(parsedDate) from lol.",resultTable))!=nameDate_stop)
        {
            # uinion additional. Duplicates won't get in due to unique index
            i<-2
            for (i in 2:length(nameDateList))
                {
                    startTable<-paste0("participant_champion_rune_",nameDateList[i],"_full")
                    a<-dbGetQuery(con,paste0("select parsedDate from lol.",resultTable," where parsedDate=",nameDateList[i]," limit 1"))
                    if (is.na(a[1,1]))     # if the resultTable hasn't had the nameDate table in it, then insert
                        {
                            nameDate<-nameDateList[i]
                            startTable<-paste0("participant_champion_rune_",nameDate,"_full")
                            union(con,startTable,resultTable)
                        }
                            
                }
        }
    else     # modify the data type if the union table is done
        {
            endTable<-paste0("participant_champion_rune_",nameDate_begin,"_",nameDate_stop,"_gameResult")
            # continue if _gameResult table hasn't been created yet
            if (class(try(dbGetQuery(con, paste0("select 1 from lol.",endTable," limit 1"))))=='try-error')
                {
                    # ======= recode NA for both continuous and discrete columns
                    # drop if exists
                    #path<-"/src/lol/SQL/00-dropIfExists.sql"
                    #sql_drop<-read_sql(path)
                    #sql_drop<-gsub("tableName",paste0(resultTable,"_RF"),sql_drop)
                    #dbSendQuery(con,sql_drop)
                    # this copy is for RF or other modelling tools
                    #dbSendQuery(con,paste0("create table lol.",resultTable,"_RF as select * from lol.",resultTable))
                    
                    # =========== only recode rune columns' NAs
                    # drop if exists
                    #path<-"/src/lol/SQL/00-dropIfExists.sql"
                    #sql_drop<-read_sql(path)
                    #sql_drop<-gsub("tableName",paste0(resultTable,"_SVD"),sql_drop)
                    #dbSendQuery(con,sql_drop)
                    # create a copy for SVD
                    #dbSendQuery(con,paste0("rename table lol.",resultTable," to lol.",resultTable,"_SVD"))  # rename the original union table
                    
                    
                    # 2. attach the end game stats of each participant
                    # 2.1 modify the data type
                    # for random forest and other model building (recode both continuous and discrete variables' NAs)
                    #path<-"/src/lol/SQL/05-7-modify_union_table_RF.sql"
                    #sql_modify<-read_sql(path)
                    #sql_modify<-gsub("tableName",resultTable,sql_modify)
                    #dbSendQuery(con,sql_modify)
                    # for SVD (only rune columns' NAs are recoded)
                    #path<-"/src/lol/SQL/05-7-modify_union_table_SVD.sql"
                    #sql_modify<-read_sql(path)
                    #sql_modify<-gsub("tableName",resultTable,sql_modify)
                    #dbSendQuery(con,sql_modify)
                    # for original union table (NAs keep intact)
                    path<-"/src/lol/SQL/05-7-modify_union_table.sql"
                    sql_modify<-read_sql(path)
                    sql_modify<-gsub("tableName",resultTable,sql_modify)
                    dbSendQuery(con,sql_modify)
                    
                    
                    # 2.2 get _perMin end game stats
                    
                    # for RF
                    # drop if exists
                    #path<-"/src/lol/SQL/00-dropIfExists.sql"
                    #sql_drop<-read_sql(path)
                    #sql_drop<-gsub("tableName",paste0(endTable,"_RF"),sql_drop)
                    #dbSendQuery(con,sql_drop)
                    
                    #path<-"/src/lol/SQL/05-8-attach_endResult.sql"
                    #sql_gameResult<-read_sql(path)
                    #sql_gameResult<-gsub("endTable",paste0(endTable,"_RF"),sql_gameResult)
                    #sql_gameResult<-gsub("resultTable",paste0(resultTable,"_RF"),sql_gameResult)
                    #dbSendQuery(con,sql_gameResult)
                    
                    # for SVD
                    # drop if exists
                    #path<-"/src/lol/SQL/00-dropIfExists.sql"
                    #sql_drop<-read_sql(path)
                    #sql_drop<-gsub("tableName",paste0(endTable,"_SVD"),sql_drop)
                    #dbSendQuery(con,sql_drop)
                    
                    #path<-"/src/lol/SQL/05-8-attach_endResult.sql"
                    #sql_gameResult<-read_sql(path)
                    #sql_gameResult<-gsub("endTable",paste0(endTable,"_SVD"),sql_gameResult)
                    #sql_gameResult<-gsub("resultTable",paste0(resultTable,"_SVD"),sql_gameResult)
                    #dbSendQuery(con,sql_gameResult)
            
                    # for intact union table
                    # drop if exists
                    path<-"/src/lol/SQL/00-dropIfExists.sql"
                    sql_drop<-read_sql(path)
                    sql_drop<-gsub("tableName",endTable,sql_drop)
                    dbSendQuery(con,sql_drop)
                    
                    path<-"/src/lol/SQL/05-8-attach_endResult.sql"
                    sql_gameResult<-read_sql(path)
                    sql_gameResult<-gsub("endTable",endTable,sql_gameResult)
                    sql_gameResult<-gsub("resultTable",resultTable,sql_gameResult)
                    dbSendQuery(con,sql_gameResult)
                }
            else  # if _gameResult table already exists
                {
                    # 3. update gameCount with the correct values
                    
                     # drop if exists
        #            path<-"/src/lol/SQL/00-dropIfExists.sql"
        #            sql_drop<-read_sql(path)
        #            acctTable<-paste0("parAccountid_",nameDate_begin,"_",nameDate_stop)   # acctTable
        #            sql_drop<-gsub("tableName",acctTable,sql_drop)
        #            dbSendQuery(con,sql_drop)
                    
        # Note: a lot of accountId won't be able to attach gameCount cos the current way cannot guarantee if accountId in a given game is parsed as well.
        #            path<-"/src/lol/SQL/00-dropIfExists.sql"
        #            sql_drop<-read_sql(path)
        #            gameCountTable<-paste0("gameCount_",nameDate_begin,"_",nameDate_stop)   #gameCountTable
        #            sql_drop<-gsub("tableName",acctTable,sql_drop)
        #            dbSendQuery(con,sql_drop)
                    
        #            path<-"/src/lol/SQL/00-dropIfExists.sql"
        #            sql_drop<-read_sql(path)
        #            readyTable<-paste0("participant_champion_rune_",nameDate_begin,"_",nameDate_stop,"_ready")   # readyTable
        #            sql_drop<-gsub("tableName",acctTable,sql_drop)
        #            dbSendQuery(con,sql_drop)
                    
                    # 3.1 attach accountId from participantidentities table
        #            path<-"/src/lol/SQL/05-9-attach_accountId.sql"
        #            sql_acctId<-read_sql(path)
        #            sql_acctId<-gsub("endTable",endTable,sql_acctId)   # use _gameResult
        #            sql_acctId<-gsub("resultTable",acctTable,sql_acctId)
        #            dbSendQuery(con,sql_acctId)
                    
                    # 3.2 attach gameCount from usergametable 
                    # because we don't have all accountId information for each game, we will end up a lot of Null. So far only 1/9 can be found in the usergametable
        #            path<-"/src/lol/SQL/05-10-attach_gameCount.sql"
        #            sql_gameCount<-read_sql(path)
        #            sql_gameCount<-gsub("endTable",acctTable,sql_gameCount)
        #            sql_gameCount<-gsub("resultTable",gameCountTable,sql_gameCount)
        #            dbSendQuery(con,sql_gameCount)
                    
                    # 3.3 attach gameCount to the union table
        #            path<-"/src/lol/SQL/05-11-readyTable.sql"
        #            sql_ready<-read_sql(path)
        #            sql_ready<-gsub("endTable1",endTable,sql_ready)
        #            sql_ready<-gsub("endTable2",gameCountTable,sql_ready)
        #            sql_ready<-gsub("resultTable",readyTable,sql_ready)
        #            dbSendQuery(con,sql_ready)
                }
        
        }    
        

}    
exec()

        
