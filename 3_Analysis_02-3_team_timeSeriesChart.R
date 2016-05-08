library(RMySQL)
library(ggplot2)
library(data.table)
library(RJSONIO)
library(jsonlite)
library(plyr)

# chart the time series of measures during games
# 1. calculate avg & confidence interview and accumulative version of each min for winning and losing games
# 2. chart time series measure winning and losing curve

# 1. calculate avg & confidence interview and accumulative version of each min for winning and losing games
## aim to generate a win curve and a lose curve
tsAggregate<-function(data,column,value)
{
    ret<-data.frame(colName=NA,min=NA,avg_win=NA,avg_lose=NA,volPercent_win=NA,volPercent_lose=NA,sd_win=NA,CIlower_win=NA,CIupper_win=NA,sd_lose=NA,CIlower_lose=NA,CIupper_lose=NA
                    ,avg_win_cum=NA,avg_lose_cum=NA,sd_win_cum=NA,CIlower_win_cum=NA,CIupper_win_cum=NA,sd_lose_cum=NA,CIlower_lose_cum=NA,CIupper_lose_cum=NA)
    
    value<-eval(parse(text=paste0("data$",value))) 
    if (class(value)=='integer' | class(value)=='numeric')
    {
        cols<-eval(parse(text=paste0("unique(data$",column,")")))  # grab all ts for a variable
        cols<-as.character(cols)
        numTS<-length(cols)  # total number of ts, should be 10, e.g. ,4 7, 10,..., 31
        # grab the main column name without the min number (e.g., FlatHPPoolMod from FlatHPPoolMod_4). The cols[1] is always *_4
        colName<-gsub("_4","",cols[1])  # A space (), then any character (.) any number of times (*) until the end of the string ($). See ?regex to learn regular expressions.

        i<-1  # ts index of a variable
        data$variable<-as.character(data$variable)
        DT<-as.data.table(data)  # use data.table for fast processing of large table
        totalRow<-nrow(DT)
        
        #initialise an empty vector for calculating accumulative stats
        minRow<-length(DT[DT$variable==cols[i],value])
        container<-data.frame(value=rep(0,minRow))
        container[,"win"]<-DT[DT$variable==cols[i],win]
        
        # from the 1st to the last ts index of a variable
        for (i in 1:numTS)  # incremental the index
        {
            ret[i,1]<-colName
            # to get the minNum, after stripping "_capped", the number is always in the end so we will reverse the string and take the number before "_"
            # 1) strip "_capped"; 2) separate the string into a letter vector (converted from list); 
            # 3) reverse and paste0; 4) remove everything after "#_"; 5) split into letter vector and reverse and paste0. convert into numeric
            ret[i,2]<-as.numeric(paste0(rev(strsplit(sub("_.*$","",paste0(rev(strsplit(gsub("_capped","",cols[i]),split="")[[1]]),collapse="")),split="")[[1]]),collapse=""))
            ret[i,3]<-DT[DT$variable==cols[i]&DT$win==1,mean(value,na.rm=T)] # avg by Min of win at each min
            ret[i,4]<-DT[DT$variable==cols[i]&DT$win==0,mean(value,na.rm=T)] # avg by Min of lose
            ret[i,5]<-DT[DT$variable==cols[i]&DT$win==1,length(value)]/(totalRow/2)  # percentage of win rows 
            ret[i,6]<-DT[DT$variable==cols[i]&DT$win==0,length(value)]/(totalRow/2)  # percentage of lose rows 
            ret[i,7]<-DT[DT$variable==cols[i]&DT$win==1,sd(value,na.rm=T)]  # std_win
            ret[i,8]<-ret[i,3]-1.96*ret[i,7]  # confidence interval upper of win
            ret[i,9]<-ret[i,3]+1.96*ret[i,7]  # confidence interval upper bound of win
            ret[i,10]<-DT[DT$variable==cols[i]&DT$win==0,sd(value,na.rm=T)]  # std_lose
            ret[i,11]<-ret[i,3]-1.96*ret[i,10]  # confidence interval upper of lose
            ret[i,12]<-ret[i,3]+1.96*ret[i,10]  # confidence interval upper bound of lose
            
            # cumulate the value column by min
            container[,1]<-container[,1]+DT[DT$variable==cols[i],value]
            
            ret[i,13]<-mean(subset(container,win==1,select=value)[,1])  # avg_win_cum. don't add [,1], the class is data frame
            ret[i,14]<-mean(subset(container,win==0,select=value)[,1])  # avg_lose_cum
            ret[i,15]<-sd(subset(container,win==1,select=value)[,1])  # sd_win_cum
            ret[i,16]<-ret[i,13]-1.96*ret[i,15]  # CIlower_win_cum
            ret[i,17]<-ret[i,13]+1.96*ret[i,15]  # CIupper_win_cum
            ret[i,18]<-sd(subset(container,win==0,select=value)[,1])  # sd_lose_cum
            ret[i,19]<-ret[i,14]-1.96*ret[i,18]  # CIlower_lose_cum
            ret[i,20]<-ret[i,14]+1.96*ret[i,18]  # CIupper_lose_cum
            
            print(paste0("Finished the ",i,"th out of ",numTS," columns."))
            i<-i+1
        }
    }
    
    else print(paste0("The column ",column," is not numeric."))
    return(ret)
}


tableMeasures<-c("gameId","win"
                ,"totalGold_4","totalGold_7","totalGold_10","totalGold_13","totalGold_16","totalGold_19","totalGold_22","totalGold_25","totalGold_28","totalGold_31"
                ,"minionsKilled_4","minionsKilled_7","minionsKilled_10","minionsKilled_13","minionsKilled_16","minionsKilled_19","minionsKilled_22","minionsKilled_25","minionsKilled_28","minionsKilled_31"
                ,"jungleMinionsKilled_4","jungleMinionsKilled_7","jungleMinionsKilled_10","jungleMinionsKilled_13","jungleMinionsKilled_16","jungleMinionsKilled_19","jungleMinionsKilled_22","jungleMinionsKilled_25","jungleMinionsKilled_28","jungleMinionsKilled_31"
                ,"FlatHPPoolMod_4","FlatHPPoolMod_7","FlatHPPoolMod_10","FlatHPPoolMod_13","FlatHPPoolMod_16","FlatHPPoolMod_19","FlatHPPoolMod_22","FlatHPPoolMod_25","FlatHPPoolMod_28","FlatHPPoolMod_31"
                ,"FlatMPPoolMod_4","FlatMPPoolMod_7","FlatMPPoolMod_10","FlatMPPoolMod_13","FlatMPPoolMod_16","FlatMPPoolMod_19","FlatMPPoolMod_22","FlatMPPoolMod_25","FlatMPPoolMod_28","FlatMPPoolMod_31"
                ,"FlatHPRegenMod_4","FlatHPRegenMod_7","FlatHPRegenMod_10","FlatHPRegenMod_13","FlatHPRegenMod_16","FlatHPRegenMod_19","FlatHPRegenMod_22","FlatHPRegenMod_25","FlatHPRegenMod_28","FlatHPRegenMod_31"
                ,"FlatArmorMod_4","FlatArmorMod_7","FlatArmorMod_10","FlatArmorMod_13","FlatArmorMod_16","FlatArmorMod_19","FlatArmorMod_22","FlatArmorMod_25","FlatArmorMod_28","FlatArmorMod_31"
                ,"FlatPhysicalDamageMod_4","FlatPhysicalDamageMod_7","FlatPhysicalDamageMod_10","FlatPhysicalDamageMod_13","FlatPhysicalDamageMod_16","FlatPhysicalDamageMod_19","FlatPhysicalDamageMod_22","FlatPhysicalDamageMod_25","FlatPhysicalDamageMod_28","FlatPhysicalDamageMod_31"
                ,"FlatMagicDamageMod_4","FlatMagicDamageMod_7","FlatMagicDamageMod_10","FlatMagicDamageMod_13","FlatMagicDamageMod_16","FlatMagicDamageMod_19","FlatMagicDamageMod_22","FlatMagicDamageMod_25","FlatMagicDamageMod_28","FlatMagicDamageMod_31"
                ,"FlatMovementSpeedMod_4","FlatMovementSpeedMod_7","FlatMovementSpeedMod_10","FlatMovementSpeedMod_13","FlatMovementSpeedMod_16","FlatMovementSpeedMod_19","FlatMovementSpeedMod_22","FlatMovementSpeedMod_25","FlatMovementSpeedMod_28","FlatMovementSpeedMod_31"
                ,"FlatAttackSpeedMod_4","FlatAttackSpeedMod_7","FlatAttackSpeedMod_10","FlatAttackSpeedMod_13","FlatAttackSpeedMod_16","FlatAttackSpeedMod_19","FlatAttackSpeedMod_22","FlatAttackSpeedMod_25","FlatAttackSpeedMod_28","FlatAttackSpeedMod_31"
                ,"FlatCritChanceMod_4_capped","FlatCritChanceMod_7_capped","FlatCritChanceMod_10_capped","FlatCritChanceMod_13_capped","FlatCritChanceMod_16_capped","FlatCritChanceMod_19_capped","FlatCritChanceMod_22_capped","FlatCritChanceMod_25_capped","FlatCritChanceMod_28_capped","FlatCritChanceMod_31_capped"
                ,"FlatSpellBlockMod_4","FlatSpellBlockMod_7","FlatSpellBlockMod_10","FlatSpellBlockMod_13","FlatSpellBlockMod_16","FlatSpellBlockMod_19","FlatSpellBlockMod_22","FlatSpellBlockMod_25","FlatSpellBlockMod_28","FlatSpellBlockMod_31"
                ,"Num_ItemPurchased_4","Num_ItemPurchased_7","Num_ItemPurchased_10","Num_ItemPurchased_13","Num_ItemPurchased_16"
                ,"Num_ItemPurchased_19","Num_ItemPurchased_22","Num_ItemPurchased_25","Num_ItemPurchased_28","Num_ItemPurchased_31"
                ,"Num_MonsterKilled_4","Num_MonsterKilled_7","Num_MonsterKilled_10","Num_MonsterKilled_13","Num_MonsterKilled_16"
                ,"Num_MonsterKilled_19","Num_MonsterKilled_22","Num_MonsterKilled_25","Num_MonsterKilled_28","Num_MonsterKilled_31"
                ,"Num_Ward_Killed_4","Num_Ward_Killed_7","Num_Ward_Killed_10","Num_Ward_Killed_13","Num_Ward_Killed_16"
                ,"Num_Ward_Killed_19","Num_Ward_Killed_22","Num_Ward_Killed_25","Num_Ward_Killed_28","Num_Ward_Killed_31"
                ,"Num_Ward_Place_4","Num_Ward_Place_7","Num_Ward_Place_10","Num_Ward_Place_13","Num_Ward_Place_16"
                ,"Num_Ward_Place_19","Num_Ward_Place_22","Num_Ward_Place_25","Num_Ward_Place_28","Num_Ward_Place_31"
                ,"Num_Killedbld_4","Num_Killedbld_7","Num_Killedbld_10","Num_Killedbld_13","Num_Killedbld_16"
                ,"Num_Killedbld_19","Num_Killedbld_22","Num_Killedbld_25","Num_Killedbld_28","Num_Killedbld_31"
                ,"Num_KilledChamp_4","Num_KilledChamp_7","Num_KilledChamp_10","Num_KilledChamp_13","Num_KilledChamp_16"
                ,"Num_KilledChamp_19","Num_KilledChamp_22","Num_KilledChamp_25","Num_KilledChamp_28","Num_KilledChamp_31"
                ,"Num_Assisting_Player_4","Num_Assisting_Player_7","Num_Assisting_Player_10","Num_Assisting_Player_13","Num_Assisting_Player_16"
                ,"Num_Assisting_Player_19","Num_Assisting_Player_22","Num_Assisting_Player_25","Num_Assisting_Player_28","Num_Assisting_Player_31"
                ,"num_consumed_4","num_consumed_7","num_consumed_10","num_consumed_13","num_consumed_16"
                ,"num_consumed_19","num_consumed_22","num_consumed_25","num_consumed_28","num_consumed_31"
                ,"Num_AssistBld_4","Num_AssistBld_7","Num_AssistBld_10","Num_AssistBld_13","Num_AssistBld_16"
                ,"Num_AssistBld_19","Num_AssistBld_22","Num_AssistBld_25","Num_AssistBld_28","Num_AssistBld_31"
                ,"Num_AssistChamp_4","Num_AssistChamp_7","Num_AssistChamp_10","Num_AssistChamp_13","Num_AssistChamp_16"
                ,"Num_AssistChamp_19","Num_AssistChamp_22","Num_AssistChamp_25","Num_AssistChamp_28","Num_AssistChamp_31"
                ,"Num_deaths_4","Num_deaths_7","Num_deaths_10","Num_deaths_13","Num_deaths_16"
                ,"Num_deaths_19","Num_deaths_22","Num_deaths_25","Num_deaths_28","Num_deaths_31"
                ,"goldSpent_4","goldSpent_7","goldSpent_10","goldSpent_13","goldSpent_16"
                ,"goldSpent_19","goldSpent_22","goldSpent_25","goldSpent_28","goldSpent_31"
)

# 2. chart ts measure winning and losing curve
chartTSmeasures<-function(tableMeasures)
{
    # grab data
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
    team_ts<-dbGetQuery(con,"select * from lol.team_rollup")   
    dbDisconnect(con)
    # columns that we're interested in charting
    team_ts<-team_ts[,names(team_ts) %in% tableMeasures]  # only pick those (i.e. totalGold_#) byMin for json and D3 charts
    i<-1  # the #th variable.
    totalNumVar<-(ncol(team_ts)-2)/10  # total number of ts variables minus gameId and win columns
    
    # loop through all variables
    for (i in 1:totalNumVar)
    {
        startIndex<-(i-1)*10+2+1 # +2 because of gameId and win
        endIndex<-i*10+2
        temp<-team_ts[,c(1:2,startIndex:endIndex)]  # 1 & 2 are gameId and win
        temp<-melt(temp,na.rm=F,id.vars=c("gameId","win"))  # melt the wide table to a long table.
        
        temp[is.na(temp)]<-0
        
        print(paste0("Start with variable ",temp[1,3], " the ",i,"th one.")) # here totalGold_4 meant for totalGold
        ret<-tsAggregate(temp,"variable","value")  # generate the avg and confidence intervals table for charting
        print(paste0("Finished the variable ",temp[1,3], " the ",i,"th one."))
        
        var<-ret[1,1] # grab the colName
        chartURL<-paste0("/src/lol/4-plot/team_ts_measures/",var,".jpg") 
        jpeg(chartURL,height=400,width=600) 
        g<-ggplot() +
                geom_line(data = ret,aes(x = min, y = avg_win),group = 1,size = 1,color="green") +
                geom_line(data = ret,aes(x = min, y = avg_lose),group = 1,size = 1,color="red") +
                xlab("the nth minute") +
                ylab(paste0("avg of ",var)) +
                geom_line(data = ret,aes(x = min, y = CIlower_win),group = 1,size = 1,color="blue") +
                geom_line(data = ret,aes(x = min, y = CIupper_win),group = 1,size = 1,color="blue") +
                geom_line(data = ret,aes(x = min, y = CIlower_lose),group = 1,size = 1,color="orange") +
                geom_line(data = ret,aes(x = min, y = CIupper_lose),group = 1,size = 1,color="orange") 
        print(g)   # need to use print so the image can be saved within the for loop
        dev.off()
        
        chartURL<-paste0("/src/lol/4-plot/team_ts_measures_cum/",var,".jpg") 
        jpeg(chartURL,height=400,width=600) 
        g<-ggplot() +
                geom_line(data = ret,aes(x = min, y = avg_win_cum),group = 1,size = 1,color="green") +
                geom_line(data = ret,aes(x = min, y = avg_lose_cum),group = 1,size = 1,color="red") +
                xlab("the nth minute") +
                ylab(paste0("accumulative avg of ",var)) +
                geom_line(data = ret,aes(x = min, y = CIlower_win_cum),group = 1,size = 1,color="blue") +
                geom_line(data = ret,aes(x = min, y = CIupper_win_cum),group = 1,size = 1,color="blue") +
                geom_line(data = ret,aes(x = min, y = CIlower_lose_cum),group = 1,size = 1,color="orange") +
                geom_line(data = ret,aes(x = min, y = CIupper_lose_cum),group = 1,size = 1,color="orange") 
        print(g)   # need to use print so the image can be saved within the for loop
        dev.off()
        
        # save ret into json files for D3 charting
        # the direct convert using toJSON needs to be reformatmted and ensure numeric stays numeric
        b<-jsonlite::toJSON(ret)  # ret[[1]] is the variable names (repeat)
        saveURL<-paste0("/usr/share/nginx/html/generated/chartJSON/data/timeSeries/",var,".json")
        write(b,file=saveURL)
            
        print(paste0("Finished charting the ",i,"th variable out of ",totalNumVar," variables."))
        i<-i+1
    }
}
chartTSmeasures(tableMeasures)
