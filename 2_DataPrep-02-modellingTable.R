library(DBI)
library(RMySQL)

# Summary
# batching the 03-participant_rollup sql scripts by timeline date

# read a sql file as a string
read_sql<-function(path)
{
   if (file.exists(path))
     sql<-readChar(path,nchar= file.info(path)$size)
   else sql<-NA
   return(sql)
}

execSQLs<-function(startDate,endDate)
{
   con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
   finalTable<-dbGetQuery(con,"show tables from lol like 'timeline_event_join_%'")
   days<-seq(as.Date(startDate),as.Date(endDate),by="1 day")    # get days into a vector
   days<-days[!days %in% c(as.Date("2015-06-03"),as.Date("2015-06-04"))]  # no matching tables for those two days
   j<-1  # index in the days array
   for (j in seq_along(days))
   {
       # check if timelines table has for that date (there are some dates missing)
        nameDate<-paste0(format(days[j],"%y"),format(days[j],"%m"),format(days[j],"%d"))
       # this is a hack to check if a table exists
       # if the json of that date is already parsed 
       if (class(try(dbGetQuery(con, paste0("select 1 from lol.timelines_",nameDate," limit 1;"))))!='try-error')
       {
   
           # have to break 03_participant_rollup.sql into individual script because dbSentQuery can only execute on script each time
           # in each individual script, don't run drop table script
           # the matching adding index script has the matching number
           i<-2    # start from 03-2-participant_rollup. i is the sql file number
           for (i in 2:14)    # make sure it iterates on a vector. from sql 03-2 to 03-14
           {
               path<-paste0("/src/lol/SQL/03-",i,"-participant_rollup.sql")
               sql_join<-read_sql(path)  # sql file for join
               path<-paste0("/src/lol/SQL/03-99-",i,"-index.sql")
               sql_index<-read_sql(path)   # sql file for indexing
               sql_table<-gsub("nameDate",nameDate,"timeline_event_join_nameDate_ranked")
               if (!(sql_table %in% finalTable[,1])) # if the table not exist in the db
               {
                   if (!(is.na(sql_join)))  # if the script exist
                   {
                     # get the date into the sql script
                     sql_join<-gsub("nameDate",nameDate,sql_join)
                     dbSendQuery(con,sql_join)
                     print(paste0("Finished creating ",nameDate," script 03-",i,"."))
                   }    
                   if (!(is.na(sql_index)))
                   {
                     # get the date into the sql script
                     sql_index<-gsub("nameDate",nameDate,sql_index)
                     dbSendQuery(con,sql_index)
                   }
               }
           }
   
            tableName<-paste0("timelineevents_",nameDate,"_derive")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_",nameDate,"_derive_getVersion")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_",nameDate,"_derive_temp")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_",nameDate,"_derive_agg")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate)
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate,"_rollup")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate,"_rollup_temp1")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate,"_rollup_temp2")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate,"_rollup_temp3")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timelineevents_item_",nameDate,"_rollup_temp4")
            dbSendQuery(con,paste0("drop table lol.",tableName))
            
            tableName<-paste0("timeline_event_join_",nameDate)
            dbSendQuery(con,paste0("drop table lol.",tableName))
       }
   }
   dbDisconnect(con)
}
 
execSQLs("2015-05-29","2015-06-14")   
