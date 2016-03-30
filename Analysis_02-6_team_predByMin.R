library(caret)
library(ggplot2)
library(RMySQL)
library(dplyr)
library(foreach)
library(randomForest)
library(qdapTools)
library(pROC)
library(doMC)
registerDoMC(4)
library(xgboost)
library(glmnet)
library(jsonlite)
library(RJSONIO)


# 0. read a sql file as a string
read_sql<-function(path)
{
  if (file.exists(path))
    sql<-readChar(path,nchar= file.info(path)$size)
  else 
    {
        sql<-NA
        print("The sql URL doesn't exist.")
    }
  return(sql)
}

# --------------------------------1. data prep ------------------------------------------
# 1.1 grab data of the basic of champ and game setup at 0 min
dataBasicSetup<-function()
{
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
    sql_url<-"/src/lol/SQL/07-4-1_team_basic.sql"
    sql<-read_sql(sql_url)
    data<-dbGetQuery(con,sql)
    dbDisconnect(con)
    return(data)
}

# 1.2 grab data for each min with the basic of champ and game setup at 0 min
dataByMin<-function(numMin)
{
    con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
    sql_url<-"/src/lol/SQL/07-4-2_team_byMin.sql"
    sql<-read_sql(sql_url)
    sql<-gsub("numMin",numMin,sql)
    data<-dbGetQuery(con,sql)
    dbDisconnect(con)
    return(data)
}


# --------------------------------------------- 2. data manipulation ------------------------------
# 2.1 convert data type to only numeric and factor 
# as most functions here can only handle factor and numeric
format<-function(data)
  {
    i<-1
    for (i in 1:ncol(data))
      {
         if (class(data[,i])=="int") data[,i]<-as.numeric(data[,i])
         if (class(data[,i])=="logical") data[,i]<-as.factor(data[,i])
      }
    return(data)
  }
  
# 2.2 remove columns with >1024 levels as gbm cannot handle it
checkFactor<-function(data)
  {
    ret<-NA 
    i<-1  # column pointer
    j<-1  # retured vector pointer
    for (i in 1:ncol(data))
      {
        if (is.factor(data[,i]))
          {
            if ((length(levels(data[,i])))>1024)  # levels() counts include empty levels while unique() only counts populated levels
              {
                ret[j]<-i
                j<-j+1
              }
              
          }
      }

    return(ret)
  }

# 2.3 remove columns variance = 0 or cannot scale/normalise
oneValue<-function(data)
    {
        ret<-NA  # returned vector pointer
        i<-1 # column pointer
        j<-1 # returned vector pointer
        for (i in 1:ncol(data))
        {
            if (is.factor(data[,i]))    
                {
                    if (length(levels(data[,i]))==1)   
                        {
                            ret[j]<-i
                            j<-j+1
                        }
                }
            if (is.numeric(data[,i]))
                {
                    if (sum(!is.na(data[,i]))>0)
                        {
                            if (sd(data[,i],na.rm=T)==0)  
                                {
                                    ret[j]<-i
                                    j<-j+1
                                }                        
                        }
                    else print(paste0("The ",i,"th column ",colnames(data)[i]," has all NAs."))
                  }
        }
    return(ret)    
    }


# 2.4 check if any factors for normalisation
hasFactor<-function(data)
  {
    ret<-data.frame(col=NA,str=NA) 
    i<-1  # column pointer
    j<-1  # retured vector pointer
    for (i in 1:ncol(data))
      {
        if ((is.factor(data[,i])) | is.character(data[,i]))
          {
            ret[j,1]<-colnames(data)[i]
            ret[j,2]<-toString(str(data[,i]))
          }
      }

    return(ret)
  }

# ---------------------------------- 3. xgb cross validation & training ---------------------
xgbModel<-function(xgbData)
{
    set.seed(29)
    trainIndex<-createDataPartition(xgbData$win,p=.8,list=F,time=1)
    dtrain<-xgbData[trainIndex,-which(colnames(xgbData) %in% "win")]
    dtrain_resp<-(xgbData[trainIndex,])$win
    dtrain<-xgb.DMatrix(data = as.matrix(dtrain), label = dtrain_resp)

    dtest<-xgbData[trainIndex,-which(colnames(xgbData) %in% "win")]
    dtest_resp<-(xgbData[trainIndex,])$win
    dtest<-xgb.DMatrix(data = as.matrix(dtest), label = dtest_resp)


    # use xgboost to select variables (speed improvement)
    set.seed(17)

    # use to tune parameters. When it stops, it will break loop so can't continue in a customised loop.
    # have to set prediction = T to be able to return a data table contins metrics for training and testing datasets
    #param<-list(max.depth = 6, eta = 0.5, objective = "binary:logistic"
    #            ,min_child_weight = round(nrow(data) * .05,0),subsample = 0.8, gamma = 1
    #            , colsample_bytree = 0.8)
    #system.time(xgb_model<-xgb.cv(params = param, data=dtrain,nround=1000,nthread=4,nfold=5,prediction=T, eval_metric="rmse",early.stop.round=10))

 # xgb.cv could only return a dt with mean and std of evaluation metrics

    #test-auc:0.575226+0.003435 max_depth =6 round = 99 eta = 0.3
    #test-auc:0.575552+0.004191 max_depth =10 round = 138 eta = 0.3
    #test-auc:0.575946+0.000975 max_depth =6 round = 344 eta = 0.1
    #test-auc:0.575705+0.001989 max_depth =6 round = 115 eta = 0.5

    xgb_time<-system.time(xgb_model<-xgb.train(data = dtrain, nrounds = 1000, nthread = 4,
                                                max.depth = 6, eta = 0.5, objective = "binary:logistic"
                                                ,min_child_weight = round(nrow(data) * .05,0),subsample = 0.8, gamma = 1
                                                , colsample_bytree = 0.8,eval_metric = 'auc', eval_metric = 'rmse'
                                                ,early.stop.round=10,watchlist=list(test=dtest,train=dtrain)))

    print("Finish xgb training.")
    return(list(xgb_model,xgb_time))

}




# ----------------------------------- 4. glmnet cross validation & training ------------------
# https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html
>
# 4.1 apply poly transform
polyTransform<-function(data)
{
    # apply poly transforms
        predictors<-data[,-which(colnames(data) %in% "win")]
        colNum<-ncol(predictors)
        colName<-colnames(predictors)
        resp<-data$win
        rowNum<-nrow(data)
        #for (p in 1:6)
        for (p in seq_along(colName)) # p is the pointer of column in the colName
            {
                d<-3 # target degree in poly
                j<-1
                
                x<-predictors[,p]  # grab that column
                # manually calculate steps in poly() as I keep running into "degree' must be less than number of unique points" error
                # decide the appropriate degree based on the following steps
                xbar<-mean(predictors[,p])
                x<-x - xbar
                X<-outer(x,0L:d,"^") # outer product with FUN = ^ 
                QR<-qr(X)
                t<-min(length(unique(x)),QR$rank)  # the threshold of degree
                if (d >= t) # degree has to <length(unique(x) and <=QR$rank
                    { d<-t-1 }
                #else d<-3
                
                if (p == 1) { newData<-data.frame()} # initiate a newData DF
                
                tempPoly<-poly(x,d) # 'degree' must be less than number of unique points"
                for (j in 1:d)  # j is the pointer of degree
                    {
                        newData[1:rowNum,paste0(colName[p],"_",j)]<-tempPoly[,j] # access each new column and copy into the newData
                    }

                print(paste0("Finished poly transform on the ",p,"th variable."))
                p<-p+1
            }
    return(newData)
}

# modified auc function
auc_adj<-function(y, prob) 
{
    rprob = rank(prob)
    n1 = sum(y)
    n0 = length(y) - n1
    u = sum(rprob[y == 1]) - n1 * (n1 + 1)/2
    n1 = n1 + 0.0 # this changes n1 to float so n1 * n2 won't exceed the max length as int. float can take larger number.
    u/(n1 * n0)
}

glmnetModel<-function(data)
  {
    ret<-data.frame(alpha=NA,lambda.min=NA,MSE=NA,auc=NA)

    # apply poly transform to the dataset
    newData<-as.matrix(polyTransform(data))

    #newData<-as.matrix(data[,-which(colnames(data) %in% "win")])


    i<-1 # row pointer in ret
    for (a in seq(from = 0, to = 1, by = 0.1))
      {
        cvfit<-cv.glmnet(x = newData, y = data$win, alpha = a, family = "binomial"
                        , nfold = 10, type.measure = "mse", parallel = T)
        # if see error “(list) object cannot be coerced to type 'double' ”, that means the predictors (i.e. x) is not matrix
        # if see error "Error in predmat[which, seq(nlami)] = preds : replacement has length zero", that means you do not have an observation in each class in each fold.
        #   It would be rather difficult to estimate the probability of belonging to a class without any data observation in each class in each fold.  

        
        pred<-predict(cvfit,newx = newData,s="lambda.min",type="response")

        ret[i,1]<-a
        ret[i,2]<-cvfit$lambda.min
        ret[i,3]<-mean((data$win-pred)^2)
        ret[i,4]<-auc_adj(data$win,as.vector(pred))
        
        print(paste0("Finished a = ",a))
      i<-i+1
    }
  return(ret)
}
#glmnet_time<-system.time(glmnet_cv<-glmnetModel(glmnetData))
# alpha = 0.9 has the best
#  alpha   lambda.min       MSE       auc
#1   0.5 0.0011703223 0.2443953 0.5827933
#2   0.6 0.0005580846 0.2443685 0.5830076
#3   0.7 0.0006323614 0.2443824 0.5828969
#4   0.8 0.0003166279 0.2443558 0.5831097
#5   0.9 0.0002814470 0.2443556 0.5831110
#6   1.0 0.0003348507 0.2443682 0.5830095




# ----------------------------------- 5. Execution: model performance ------------------------
modelPerf<-function()
{
    # initiate a data frame to store xgb model performance
    ret_model<-data.frame(dataset = NA, Model = NA, MSE = NA, AUC = NA, userTime = NA, systemTime = NA, elapsedTime = NA)
    ret_list<-list() # an overall list with [[1]]: ret_model, and [[2]] and more for each variable importance data frame
    j<-1 # j is the pointer of ret rowNum
    for (i in seq(from = 1, to = 31, by = 3)) # i is the numMin. We start from 1 rather than 4 is to let grab the basic champ and game setup data beore a game starts
        {
            if (i == 1) # only grab basic champ and game setup data
                {
                    data<-dataBasicSetup()
                    ret_model[j,1]<-"basic"
                }
            else 
                {
                    data<-dataByMin(i) # grab data by numMin
                    ret_model[j,1]<-paste0(i,"min")
                }
            print(paste0("Finished loading data of the ",i,"th min."))
                
            data<-format(data) # format the dataset to only have numeric and factor
            
            remove<-checkFactor(data) # remove factors with >1024 levels
            if (!is.na(remove[1])) # if the first one is NA, then there is no index added
                  data<-data[,-remove]
                
            
            remove<-oneValue(data) # remove variabes that have one value
            if (!is.na(remove[1])) # if the first one is NA, then there is no index added
                data<-data[,-remove]
            
            set.seed(12)
            data<-na.roughfix(data) # impute NAs
            
            # normalisation
            preProcValues<-preProcess(data[,-which(names(data) %in% "win")],method=c("center","scale"))
            predictors_scaled<-predict(preProcValues,data[,-which(names(data) %in% "win")])
            print(paste0("Finished preparing the data of the ",i,"th min."))
            
            factor<-hasFactor(predictors_scaled) # check if there are still factors in the dataset
            if (is.na(factor[,1]) || is.na(factor[,2]))
                {
                    # -------------------------- xgb -------------------------------------------
                    # xgb data
                    xgbData<-predictors_scaled
                    xgbData[,"win"]<-data$win
                    # train xgb model
                    xgb<-xgbModel(xgbData)
                    xgb_model<-xgb[[1]]
                    xgb_time<-xgb[[2]]
                    
                    # model result
                    ret_model[j,2]<-"xgb"
                    ret_model[j,3]<-mean((data$win - predict(xgb_model,as.matrix(xgbData)))^2)
                    ret_model[j,4]<-xgb_model$bestScore  # the best according to the eval_metric
                    ret_model[j,5]<-xgb_time[[1]] # user time
                    ret_model[j,6]<-xgb_time[[2]] # system time
                    ret_model[j,7]<-xgb_time[[3]] # elapsed time
                    print(paste0("Finish xgb training for ",i,"th min."))
                    
                    # grab importance
                    varImp.xgb<-as.data.frame(xgb.importance(model=xgb_model))
                    # attach the column names to the varImp list
                    cols<-as.data.frame(colnames(predictors_scaled))
                    cols[,"rowName"]<-rownames(cols)
                    varImp.xgb[,"varName"]<-lookup(varImp.xgb[,1],cols[,c(2,1)])
                    
                    # put the importance list to the result list
                    ret_list[[j+1]]<-varImp.xgb
                    print("Obtained variable importance list.")
                   
                    
                    # ------------------------------ glmnet ------------------------------
                     j<-j+1
                     glmnetData<-predictors_scaled

                     # use xgb importance to select variables
                     impVar<-as.numeric(varImp.xgb$Feature)
                     glmnetData<-glmnetData[,impVar]
                     glmnetData[,"win"]<-data$win

                     # glmnet tuning
                     #glmnet_time<-system.time(glmnet_cv<-glmnetModel(glmnetData))
                     # in this case, alpha = 0.9 is the best

                     #glmnetX<-as.matrix(glmnetData[,-which(colnames(glmnetData) %in% "win")])
                     glmnetX<-newData<-as.matrix(polyTransform(data))    # use poly transform
                        
                     glmnet_time<-system.time(glmnet_model<-glmnet(x = glmnetX, y = glmnetData$win,
                            family = "binomial", alpha = 0.3))

                     pred<-predict(glmnet_model,newx = glmnetX,s= min(glmnet_model$lambda),type="response")

                     # model result
                     ret_model[j,1]<-ret_model[j-1,1]
                     ret_model[j,2]<-"glmnet"
                     ret_model[j,3]<-mean((data$win - pred)^2)
                     ret_model[j,4]<-auc_adj(data$win,as.vector(pred))[1] # the original formula will have "In n1 * n0 : NAs produced by integer overflow"
                     ret_model[j,5]<-glmnet_time[[1]] # user time
                     ret_model[j,6]<-glmnet_time[[2]] # system time
                     ret_model[j,7]<-glmnet_time[[3]] # elapsed time
                     # put the importance list to the result list
                     ret_list[[j+1]]<-coef(glmnet_model,s=min(glmnet_model$lambda))
                     print(paste0("Finish glmnet training for ",i,"th min."))
                    
                    
                }
            else print("There are still factors after normalisation.")
            i<-i+3
            j<-j+1
            
        }
    
     ret_list[[1]]<-ret_model
     return(ret_list)  # <--------- may want to return a list with variable importance
}
byMinRet<-modelPerf()
# attributes such as Flat~, rFlat~ are item + rune

chartData<-byMinRet[[1]]
chartData[,1]<-as.numeric(gsub("min","",gsub("basic","1",chartData[,1])))
# ----------------------- chart predByMin -----------------------------------
# 22min has the best prediction (min rmse, max auc)
chartURL<-paste0("/src/lol/4-plot/team_predByMin_MSE.jpg") 
jpeg(chartURL,height=400,width=600) 
 g<-ggplot() +   # in aes, add group = categoricalColumn to tell r the line is for one category; add color = "category" to automatically add legend
             geom_line(data = filter(chartData,Model=="xgb"),aes(x = dataset, y = MSE,group = Model,color="xgb"),size = 1) +
             geom_line(data = filter(chartData,Model=="glmnet"),aes(x = dataset, y = MSE,group = Model,color="glmnet"),size = 1) +
             xlab("byMin") +
             ylab("MSE")
print(g)   # need to use print so the image can be saved within the for loop
dev.off()


chartURL<-paste0("/src/lol/4-plot/team_predByMin_auc.jpg") 
jpeg(chartURL,height=400,width=600) 
 g<-ggplot() +
             geom_line(data = filter(chartData,Model=="xgb"),aes(x = dataset, y = AUC,group = Model,color="xgb"),size = 1) +
             geom_line(data = filter(chartData,Model=="glmnet"),aes(x = dataset, y = AUC,group = Model,color="glmnet"),size = 1) +
             xlab("byMin") +
             ylab("auc")
print(g)   # need to use print so the image can be saved within the for loop
dev.off()
  
# ----------------------------------- glmnet coef format ---------------------------------
# put each min coefs together and convert it into a data frame for charting
j<-3 # calculate min
for (i in seq(from = 3, to = 23, by = 2 ))  # i is the pointer in the byMinRet list, used to access glmnet coefs
    {
        byMin<-byMinRet[[i]]
        a<-byMin[,1] # this return a numeric vector with row name = variable name
        
        if (i == 3)
            {
                # initiate the result table
                glmnet_coefs<-data.frame(variable = NA, coef = a, min = NA, rank = NA)
                glmnet_coefs$variable<-rownames(glmnet_coefs)
                glmnet_coefs$min<-(j-3)*3+1
                glmnet_coefs$rank<-round(rank(-abs(glmnet_coefs$coef)),0)
                
            }
        else
            {
                # additional rows will be appended
                temp<-data.frame(variable = NA, coef = a, min = NA, rank = NA)
                temp$variable<-rownames(temp)
                temp$min<-(j-3)*3+1
                temp$rank<-round(rank(-abs(temp$coef)),0)
                glmnet_coefs<-rbind(glmnet_coefs,temp)
            }
        j<-j+1   
        
    }

# create a column of variable with the min# stripped out

glmnet_coefs[,"variable_clean"]<-sub("(.*)_[0-9]+$","\\1",gsub("_capped","",glmnet_coefs$variable))
# .: any character
# *: any length
# (): indicate extraction
# [0-9]: any digit. It could be rewritten as \\d. Note: [\\d] doesn't work. 
# +: repeat the type of character in front of it. Here is to repeat number/digit
# $: till the end of the string
# \\n: indicate which extraction to take. Here we grab the first extraction in ()

# create a json file
b<-jsonlite::toJSON(glmnet_coefs)  # ret[[1]] is the variable names (repeat)
saveURL<-paste0("/usr/share/nginx/html/generated/chartJSON/data/game/glmnet_coefs.json")
write(b,file=saveURL)

# ------------------------- chart glmnet coefs ------------------------------------
# game play status
variables<-c("totalGold","sum_level","minionsKilled","Num_Killedbld","jungleMinionsKilled",
             "Num_KilleDchamp","Num_deaths","Num_AssistBld","Num_AssistChamp")
#variables<-"totalGold"
s<-"ggplot() + "
for (i in seq_along(variables))
{
     # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_coefs,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_gamePlay.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()

# champion status
variables<-c("Champ_SpellBlockPerLevel","Champ_MPperLevel","Champ_HP","Champ_Attack","Champ_MP",
            "Champ_Magic","Champ_HPregenPerLevel","Champ_AttackDamage","Champ_AttackSpeedOffset",
            "Champ_MoveSpeed","Champ_HPregen","Champ_MPregen","Champ_AttackDamagePerLevel",
            "parType_Wind","Champ_Armor","Champ_HPperLevel","Champ_Defense","Champ_MPregenPerLevel","tags_Mage_Fighter")

s<-"ggplot() + "
for (i in seq_along(variables))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_coefs,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_champ.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()

# build status
variables<-c("FlatCritChanceMod","tags_CriticalStrike","FlatMagicDamageMod","FlatMovementSpeedMod"
        ,"FlatPhysicalDamageMod","PercentSpellVampMod","FlatMPRegenMod","tags_Boots"
        ,"FlatAttackSpeedMod","tags_SpellDamage","tags_SpellBlock","tags_GoldPer",
        ,"FlatCritDamageMod","rFlatArmorPenetrationMod","tags_ArmorPenetration")
 s<-"ggplot() + "
for (i in seq_along(variables))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_coefs,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_build.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off() 

# ------------------------- xgb importance ---------------------- <--------- not done
j<-3 # calculate min
for (i in seq(from = 2, to = 22, by = 2 ))  # i is the pointer in the byMinRet list, used to access glmnet coefs
    {
        byMin<-byMinRet[[i]]
        a<-byMin[,1] # this return a numeric vector with row name = variable name
        
        if (i == 2)
            {
                # initiate the result table
                xgb_imp<-data.frame(variable = NA, coef = a, min = NA, rank = NA)
                xgb_imp$variable<-rownames(glmnet_coefs)
                xgb_imp$min<-(j-3)*3+1
                xgb_imp$rank<-round(rank(-abs(glmnet_coefs$coef)),0)
                
            }
        else
            {
                # additional rows will be appended
                temp<-data.frame(variable = NA, coef = a, min = NA, rank = NA)
                temp$variable<-rownames(temp)
                temp$min<-(j-3)*3+1
                temp$rank<-round(rank(-abs(temp$coef)),0)
                glmnet_coefs<-rbind(glmnet_coefs,temp)
            }
        j<-j+1   
        
    }
