# generate descriptive charts on team_rollup table
# focus on the relationship between winRate and final results (e.g. gold, xp, damage, MP, etc)
library(RMySQL)
library(data.table)
library(jsonlite)
library(RJSONIO)
library(ggplot2)
library(plyr)


# 1. Grab interested columns and more measures
con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1') 
# grab the data from team_rollup with extra measures
data<-dbGetQuery(con,"select *
                      ,magicDamageDealt_perMin/totalDamageDealt_perMin as magicDamage_prop
                      ,physicalDamageDealt_perMin/totalDamageDealt_perMin as physicalDamage_prop
                      ,magicDamageDealtToChampions_perMin/totalDamageDealtToChampions_perMin as magicDamageToChamp_prop
                      ,physicalDamageDealtToChampions_perMin/totalDamageDealtToChampions_perMin as physicalDamageToChamp_prop
                      ,totalHeal_perMin/totalDamageDealtToChampions_perMin as heal_vs_damage
                      ,totalDamageTaken_perMin/totalDamageDealt_perMin as damangeTaken_vs_Dealt
                      ,totalDamageTaken_perMin/totalDamageDealtToChampions_perMin as damageTaken_vs_DealtChamp
                      from lol.team_rollup")
dbDisconnect(con)

# 2. discretise the given column by equal volume bin and calculate the avg, cumulative percentage and winrate
histPercent<-function(data,column,numInterval)
{
    ret<-data.frame(colName=NA,avg=NA,volPercent=NA,winrate=NA,CIlower=NA,CIupper=NA)
    col<-eval(parse(text=paste0("data$",column)))  # grab the selected column
    if (class(col)=='integer' | class(col)=='numeric')
    {
        a<-data$win
        DF<-merge(col,a,by="row.names") # merge win column and other columns by row.names. Notice that in the result DF, x = given column, y = win 
        DF<-DF[,-1]  # remove the row.names column. Turn into data table
        # order DF by the given column
        DF<-DF[order(DF$x),]
        
        interval<-floor(nrow(DF)/numInterval)  # make sure interval is int 3050
        totalRow<-nrow(DF)
        
        # from the 1st to the last interval
        for (i in 1:numInterval)  # incremental the interval
        {
            if (i == 1)
            {
                lowBound<-1  # lowBound and upperBound are row indices
                upperBound<-totalRow - interval * (numInterval - 1)
            }
            else
            {
                lowBound<-upperBound + 1
                upperBound<-upperBound + interval
            }
            ret[i,1]<-column  # column name
            ret[i,2]<-mean(DF[lowBound:upperBound,1])  # avg
            ret[i,3]<-round(i*interval/totalRow,2)  # vol percentage
            ret[i,4]<-round(sum(DF[lowBound:upperBound,2])/nrow(DF[lowBound:upperBound,]),4)  # win rate
            ret[i,5]<-mean(DF[lowBound:upperBound,1])-1.96*sd(DF[lowBound:upperBound,1]) # Confidence interval lower bound
            ret[i,6]<-mean(DF[lowBound:upperBound,1])+1.96*sd(DF[lowBound:upperBound,1]) # Confidence interval uppder bound
            i<-i+1
        }
    }                           
    
    else print(paste0("The column ",column," is not numeric."))
    return(ret)
}

# bad/unsensible measures are commented out
measures<-c("goldEarned_perMin","kills_perMin","deaths_perMin","assists_perMin","KDA_ratio"
    #,"largestKillingSpree","largestMultiKill"
    ,"killingSprees","longestTimeSpentLiving"
    #,"avg_longestTimeSpentLiving"
    ,"std_longestTimeSpentLiving","doubleKills"
    #,"tripleKills","quadraKills"
    #,"pentaKills","unrealKills"
    ,"totalDamageDealt_perMin","magicDamageDealt_perMin","physicalDamageDealt_perMin"
    ,"trueDamageDealt_perMin","largestCriticalStrike_perMin","totalDamageDealtToChampions_perMin","magicDamageDealtToChampions_perMin"
    ,"physicalDamageDealtToChampions_perMin","trueDamageDealtToChampions_perMin","totalHeal_perMin"
    #,"totalUnitsHealed_perMin"
    ,"totalDamageTaken_perMin","magicalDamageTaken_perMin","physicalDamageTaken_perMin","trueDamageTaken_perMin"
    ,"turretKills_perMin","inhibitorKills_perMin","totalMinionsKilled_perMin","neutralMinionsKilled_perMin"
    ,"totalTimeCrowdControlDealt_perMin","champLevel_perMin"
    #,"sightWardsBoughtInGame_perMin"
    #,"wardsPlaced_perMin","wardsKilled_perMin"
    #,"magicDamage_prop","physicalDamage_prop"
    #,"magicDamageToChamp_prop"
    ,"physicalDamageToChamp_prop","heal_vs_damage","damangeTaken_vs_Dealt"
    ,"damageTaken_vs_DealtChamp")

# measures that are interesting for official charting 
tableMeasures<-c("goldEarned_perMin","kills_perMin","deaths_perMin","assists_perMin","KDA_ratio"
                 ,"totalDamageDealt_perMin","magicDamageDealt_perMin","physicalDamageDealt_perMin"
                ,"trueDamageDealt_perMin","totalDamageTaken_perMin","magicalDamageTaken_perMin"
                ,"physicalDamageTaken_perMin","trueDamageTaken_perMin","totalMinionsKilled_perMin")



# 3. chart a number of end game measures against winrate
endGameChart<-function(data,measures,numInterval,tableMeasures)
{
    i<-1 # measure list index
    for (i in 1:length(measures))
    {
        ret<-histPercent(data,measures[i],numInterval)
        print(paste0("Finished creating ret table for the ",i,"th variable ", measures[i],"."))
        rowNum<-min(rownames(ret[ret$winrate>0.5,]))  # get the first winrate>0.5 row number
        mName<-sub("_.*","",measures[i])    # grab the substring before "_"
        chartURL<-paste0("/src/lol/4-plot/team_measures/team_",mName,".jpg") 
        jpeg(chartURL,height=400,width=600) 
        g<-ggplot() +
                geom_line(data = ret,aes(x = avg, y = winrate),group = 1,size = 1) +  # use group = 1 so R know all those values are for the same serie
                geom_line(data = ret,aes(x = CIlower, y = winrate),group = 1,size = 1,color="red") +
                geom_line(data = ret,aes(x = CIupper, y = winrate),group = 1,size = 1,color="red") +
                xlab(measures[i])
        print(g)   # need to use print so the image can be saved within the for loop
        dev.off()
        if (measures[i] %in% tableMeasures)   # convert DF to JSON for charting
        {
           # the direct convert using toJSON needs to be reformatmted and ensure numeric stays numeric
            b<-jsonlite::toJSON(ret)
            saveURL<-paste0("/usr/share/nginx/html/generated/chartJSON/data/game/",mName,".json")
            write(b,file=saveURL)
            print(paste0("Created the json file for ",mName))
        }
    }
}
endGameChart(data,measures,50,tableMeasures)
