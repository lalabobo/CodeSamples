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

# Summary
# process data so it is ready for xgboost and glmnet
# 1. data prep
# 2. data manipulation
# 3. Execution: data prep and transformation
# build a xgboost and glmnet models for each interval and aim to answer: 
    # 1) at which interval we can have the best prediction of win rate?
    # 2) how does the importance of each variable change over time?
# 4. xgb cross validation & training
# 5. glmnet cross validation & training
# 6. model performance
# 7. chart the coefficients over time



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
    if (numMin<=22) # numMin before players can surrender
    {
        sql_url<-"/src/lol/SQL/07-4-2_team_byMin.sql"
    }
    else 
    {
        sql_url<-"/src/lol/SQL/07-4-2_team_byMinOver22.sql"  # only look at those still playing and remove those games that are ended
    }  
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
        # if a variable is discrete and only has one level, add to the ret array
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
            # if a variable is numeric, not NA and has no variance, add to the ret array
            if (sum(!is.na(data[,i]))>0)
            {
                if (sd(data[,i],na.rm=T)==0)  
                {
                    ret[j]<-i
                    j<-j+1
                }                        
            }
            else 
            {
                ret[j]<-i  # if a variable is numeric and has all NAs
                print(paste0("The ",i,"th column ",colnames(data)[i]," has all NAs."))
                j<-j+1
            }
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



# ----------------------------------- 3. Execution: data prep and transformation -----------------------------------
# 3.1 general data prep
dataPrep<-function(data) # i is the numMin. We start from 1 rather than 4 is to let grab the basic champ and game setup data beore a game starts
{
    data<-format(data) # format the dataset to only have numeric and factor
    
    remove<-oneValue(data) # remove variables that have one value
    if (!is.na(remove[1])) # if the first one is NA, then there is no index added
    {
        data<-data[,-remove]
    }
    
    factor<-hasFactor(data) # check if there are still factors in the dataset
    if (is.na(factor[,1]) || is.na(factor[,2]))  # expect to be NA to indicate no factors
    {
        return(data)
    }
    else print("There are unexpected factors in the dataset.")
}

# 3.2 normalise variables
normalise<-function(predictors)
{
    # normalisation
    preProcValues<-preProcess(predictors,method=c("center","scale"))
    predictors_scaled<-predict(preProcValues,predictors)
    #data_scaled<-predictors_scaled
    #data_scaled[,"response"]<-eval(parse(text=paste0("data$",respCol)))
    print(paste0("Finished normalising the data."))
    #return(data_scaled)
    return(predictors_scaled)
}

# 3.3 apply poly transform
polyTransform<-function(predictors)
{
    # apply poly transforms
    colNum<-ncol(predictors)
    colName<-colnames(predictors)
    rowNum<-nrow(predictors)
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
        {
            d<-t-1
        }
        if (p == 1) 
        {
            newData<-data.frame()  # initiate a newData DF
        } 
        
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

# 3.4 modified auc function
auc_adj<-function(y, prob) 
{
    rprob = rank(prob)
    n1 = sum(y)
    n0 = length(y) - n1
    u = sum(rprob[y == 1]) - n1 * (n1 + 1)/2
    n1 = n1 + 0.0 # this changes n1 to float so n1 * n2 won't exceed the max length as int. float can take larger number.
    u/(n1 * n0)
}

# 3.5 quantile one continuous variable by ntile 
quantile<-function(predictor,ntile)  # the predictor has to be continuous variable
{
    ret<-data.frame(min = NA, max = NA, group = NA)
    p<-sort(predictor)
    numRow<-length(p)
    levelVol<-round(numRow / ntile, 0)

    for(i in 1:ntile)
    {
        if (i<ntile)
        {
            start<-(i-1)*levelVol+1
            end<-i*levelVol
            g<-p[start:end]
        }
        else
        {
            start<-(i-1)*levelVol+1
            end<-numRow
            g<-p[start:end] # grab the rest of records
        }
        ret[i,"min"]<-min(g)
        ret[i,"max"]<-max(g)
        ret[i,"group"]<-i
        #print(paste0("quantile() on ",i,"th tile."))
    }
    # aggregate by min and max to condense the table
    retAgg<-aggregate(x=ret,by=list(min = ret$min,max = ret$max),FUN=min)   # aggregate the table by min & max
    retAgg<-retAgg[,3:5] # grab the column min, max and group
    retAgg[,"group"]<-1:nrow(retAgg) # reassign group so no gap
    print("Finished quantile().")
    return(retAgg)  # return raw ntile table
}
    
# 3.6 quantileAdj on one continuous variable
# further adjust the borders of a level so any two levels don't share values
# e.g., [1,1.5] & [1.5,2] => [1,1.46] & [1.5,2]
quantileAdj<-function(predictor,ret)
{
    groupBy<-data.frame(table(predictor)) # get the freq table
    groupBy<-groupBy[with(groupBy,order(groupBy$predictor)),]  # sort by Var1 asc order
    numRow<-nrow(ret)
    numLevel<-nrow(groupBy)
    j<-1
    
    for(i in 1:(numRow-1))  # i is the row index of ret
    {
        if (ret[i,"max"] == ret[i+1,"min"]) # if a previous row's max == a later row's min. i.e. share border
        {
            #print(paste0("Working on the ",i,"th row in the ret to adjust the border."))
            # find out which row in groupBy table matches ret[i,"max"]
            # reset the border based on the volume of the shared value
            for(j in j:(numLevel-1)) # j is the row index of groupBy table. no need to go from the first every time as the groupBy table is sorted
            {
                #print(paste0("starting ",j))
                if (ret[i,"max"] == groupBy[j,"predictor"]) # find the row index in the groupBy table                                {
                {    
                    #print(paste0("groupBy table ",j,"th row/group"))
                    if (j < numLevel)
                    {
                        ret[i+1,"min"] <- as.numeric(as.character(groupBy[j+1,"predictor"])) # if not convert to charac and numeric, it will return the level number. has to convert to char to be able to convert to numeric
                        #print("updating")
                        #print(j)
                    }
                    break
                }
            }
            j<-j+1    
        }
    }
    print("Finished quantileAdj().")
    regroup<-aggregate(x=ret,by=list(min = ret$min,max = ret$max),FUN=min) # aggregate the table by min & max
    regroup<-regroup[,3:5] # grab the column min, max and group
    regroup[,"group"]<-1:nrow(regroup) # reassign group so no gap
    return(ret)
    #regroup(predictor,groupBy,regroup,ntile)
}
    
# 3.7 modiy min/max of a level for regrouping, including handling when the number of unique levels < ntile
regroup<-function(predictor,ret,ntile)   
{
    uniVal<-sort(unique(predictor))  # return a sorted vector of values in the predictor
    l<-length(uniVal) # number of unique value of the ith predictor
    ret<-data.frame(min = NA, max = NA, group = NA) 
    if (l>2) # so the column i isn't a dummy variable for discrete column. dummy variable only has two values.
    {
        
        if (l<=ntile) # the number of unique value <= 10, each value is a discrete level
        {
            print("The number of values in the predictor <= ntile.")
            # the frequency table groupBy will be ordered by the value of predictor
            # the order will be aligned with uniVal
            groupBy<-data.frame(table(predictor))
            groupBy<-groupBy[order(groupBy$predictor),]
            groupBy[,"group"]<-1:nrow(groupBy)
            numRow<-nrow(groupBy)
            for(j in 1:numRow) # j is the row index of groupBy table, i.e. the jth unique level
            {
                #print(paste0("The ",j,"th row in the groupBy table."))
                g<-groupBy[j,"Freq"]
                print(j)
                ret[j,"min"]<-uniVal[j]
                ret[j,"max"]<-uniVal[j]
                # if a level has <5% data, group it into the level with largest vol
                if (g < round(sum(groupBy$Freq) * 0.05,0))
                {
                    if (j == 1) { groupBy[j+1,"group"]<-groupBy[j,"group"]} # if j is the first entry, assign j to j+1
                    if (j == numRow) { groupBy[j,"group"]<-groupBy[j-1,"group"]} # if j is the last entry, assign j-1 to j
                    if (j > 1 & j < numRow)
                    {
                        if (groupBy[j-1,"Freq"] > groupBy[j+1,"Freq"])  # combine with a level that has fewer vol
                        {
                            groupBy[j+1,"group"]<-groupBy[j,"group"]
                        }
                        else 
                        {
                            groupBy[j,"group"]<-groupBy[j-1,"group"]
                        }
                    }
                } # <--- the problem that group may not without gaps
                ret[j,"group"]<-groupBy[j,"group"]
            } 
            # modify the min and max for rows that are in the same group
            print("Modify the min and max within the same group.")
            temp<-ret
            ret<-data.frame(min = NA, max = NA, group = NA)  
            uniGroup<-unique(groupBy$group)
            j<-1 # row index in the new ret. Each row is a different group. 
            # update the min and max and rename the group so no gap
            for(i in uniGroup)
            {
                ret[j,"min"]<-apply(filter(temp,group == i),2,function(x) min(x))[1]
                ret[j,"max"]<-apply(filter(temp,group == i),2,function(x) max(x))[2]
                ret[j,"group"]<-j
                j<-j+1
            }
        }
        else ret<-quantile(predictor, ntile)
    }
    print("Finished regroup().")
    return(ret)
}        
 
 
# 3.8 discretise a continuous variable based on the regrouping result
discretise<-function(predictor,colName,ret)
{
    discData<-data.frame()
    numRow<-length(predictor)
    numGroup<-nrow(ret)
    for(i in 1:numGroup) # i is the index of groups
    {
        # discretise a continuous variable into dummy variable
        discData[1:numRow,paste0(colName,"_d",i,"_[",round(ret$min[i],2),",",round(ret$max[i],2),"]")]<-0  # by default, 0 for every row
        matchedRow<-which(predictor >= ret$min[i] & predictor <= ret$max[i])  # return the row number that value matches
        discData[matchedRow,paste0(colName,"_d",i,"_[",round(ret$min[i],2),",",round(ret$max[i],2),"]")]<-1 # assign 1 to those records that belong to that group
    }
    print("Finished discretise().")
    return(discData)
}


# 3.9  data transform
regTrans<-function(predictors,ntile)
{
     # poly transfer
     newData<-polyTransform(predictors)
     
     # discretise a cotinuous variable
     numCol<-ncol(predictors)
     for(i in 1:numCol) # i is the column index
     {
        print(paste0("Start on the ",i,"th predictor."))
        colName<-colnames(predictors)[i]
        predictor<-predictors[,i] # grab one column
        # this will run through both quantile(), quantileAdj() and regroup() to adjust the min and max border so no overlapping between groups
        retAgg<-quantile(predictor,ntile)
        ret<-quantileAdj(predictor,retAgg)
        result<-regroup(predictor,ret,ntile) 
        
        
        if (!(is.na(result[1,1]))) # if result isn't NA, which means the variable isn't a dummy from being discrete originally
        { 
            discData<-discretise(predictor,colName,result)
            newData<-cbind(newData,discData)
        }
        print(paste0("Finished the ",i,"th predictor."))
     }
     # normalise after polytransfer and discretise
     remove<-oneValue(newData) # remove variables that have one value
     if (!is.na(remove[1])) # if the first one is NA, then there is no index added
     {
        newData<-newData[,-remove]
     }
     newData<-normalise(newData)
     return(newData)
}
#newData<-regTrans(s,10)
 


# ---------------------------------- 4. xgb cross validation & training ---------------------
# find the best eta through cross validation
xgbcv<-function(xgbData)
{
    ret<-data.frame(eta = NA, test.rmse.mean = NA, test.auc.mean = NA

    # use xgboost to select variables (speed improvement)
    
    predictors<-xgbData[,-which(colnames(xgbData) %in% "win")]
    resp<-xgbData$win
    dataReady<-xgb.DMatrix(data = as.matrix(predictors), label = resp)
    
    # use to tune parameters. When it stops, it will break loop so can't continue in a customised loop.
    # have to set prediction = T to be able to return a data table contins metrics for training and testing datasets
    i<-1 # row index of ret
    set.seed(17)
    for(eta in seq(from = 0.1, to = 1, by = 0.1))
    {
        system.time(xgb_model<-xgb.cv(data=dataReady,nround=1000,nthread=4,nfold=5,prediction=T
                                    ,max.depth = 6, eta = eta, objective = "binary:logistic"
                                    ,min_child_weight = round(nrow(data) * .05,0), subsample = 0.8, gamma = 1
                                    ,colsample_bytree = 0.8, eval_metric="rmse",eval_metric="auc",early.stop.round=10))
        ret[i,"eta"]<-eta
        ret[i,"test.rmse.mean"]<-min(xgb_model$dt$test.rmse.mean)
        ret[i,"test.auc.mean"]<-max(xgb_model$dt$test.auc.mean)
        i<-i+1
    }
    print(ret)
    bestEta<-filter(ret,test.auc.mean == max(ret$test.rmse.mean))$eta # use the eta that has the largest auc, also this eta yield the smallest rmse
    return(bestEta)
}


xgbModel<-function(xgbData, bestEta)
{
    ret<-data.frame(train_mse = NA, train_auc = NA, test_mse = NA, test_auc = NA
                    , userTime = NA, systemTime = NA, elapsedTime = NA)
    # set up the training and testing dataset
    set.seed(29)
    trainIndex<-createDataPartition(xgbData$win,p=.8,list=F,time=1)
    dtrain<-xgbData[trainIndex,-which(colnames(xgbData) %in% "win")]
    dtrain_resp<-(xgbData[trainIndex,])$win
    dtrain<-xgb.DMatrix(data = as.matrix(dtrain), label = dtrain_resp)

    dtest<-xgbData[-trainIndex,-which(colnames(xgbData) %in% "win")]
    dtest_resp<-(xgbData[-trainIndex,])$win
    dtest<-xgb.DMatrix(data = as.matrix(dtest), label = dtest_resp)

    # train xgb
    xgb_time<-system.time(xgb_model<-xgb.train(data = dtrain, nrounds = 1000, nthread = 4
                                                ,max.depth = 6, eta = bestEta, objective = "binary:logistic"
                                                ,min_child_weight = round(nrow(data) * .05,0),subsample = 0.8, gamma = 1
                                                ,colsample_bytree = 0.8,eval_metric = 'auc', eval_metric = 'rmse'
                                                ,early.stop.round=10,watchlist=list(test=dtest,train=dtrain)))
    pred_train<-predict(xgb_model,dtrain)
    pred_test<-predict(xgb_model,dtest)
    ret[1,"train_mse"]<-mean((dtrain_resp - pred_train)^2)
    ret[1,"train_auc"]<-auc_adj(dtrain_resp,as.vector(pred_train))
    ret[1,"test_mse"]<-mean((dtest_resp - pred_test)^2)
    ret[1,"test_auc"]<-auc_adj(dtest_resp,as.vector(pred_test))
    ret[1,"userTime"]<-xgb_time[[1]]
    ret[1,"systemTime"]<-xgb_time[[2]]
    ret[1,"elapsedTime"]<-xgb_time[[3]]
    
    print("Finish xgb training.")
    return(list(ret,xgb_model))
}


# ----------------------------------- 5. glmnet cross validation & training ------------------
# https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html

# glmnet cross validation to find out
glmnetcv<-function(newData, resp)
{
    ret<-data.frame(alpha=NA,lambda.min=NA,MSE=NA,auc=NA)
    predictors<-as.matrix(newData[,-which(colnames(newData) %in% resp)])
    resp<-newData[,which(colnames(newData) %in% resp)]
    i<-1 # row pointer in ret
    for (a in seq(from = 0, to = 1, by = 0.1))  # loop through different alpha. a = 1 lasso L1 (pick 1 drop the rest); a = 0 ridge L2 (similar coefficients)
    {
        cvfit<-cv.glmnet(x = predictors, y = resp, alpha = a, family = "binomial"
                         , nfold = 10, type.measure = "mse", parallel = T)
        # if see error “(list) object cannot be coerced to type 'double' ”, that means the predictors (i.e. x) is not matrix
        # if see error "Error in predmat[which, seq(nlami)] = preds : replacement has length zero", that means you do not have an observation in each class in each fold.
        #   It would be rather difficult to estimate the probability of belonging to a class without any data observation in each class in each fold.  
        # as.matrix has to be applied before and outside of cv.glmnet, or will see error "Error in as.matrix(cbind2(1, newx) %*% nbeta) : 
            # error in evaluating the argument 'x' in selecting a method for function 'as.matrix': Error in cbind2(1, newx) %*% nbeta : 
            # not-yet-implemented method for <data.frame> %*% <dgCMatrix>"
    
        pred<-predict(cvfit,newx = predictors,s="lambda.min",type="response")

        ret[i,1]<-a
        ret[i,2]<-cvfit$lambda.min  # lambda.min gives the min mean cv error
        ret[i,3]<-mean((data$win-pred)^2)
        ret[i,4]<-auc_adj(data$win,as.vector(pred))
        
        print(paste0("Finished a = ",a))
        i<-i+1
  }
  print(ret)
  bestAlpha<-filter(ret,MSE == min(ret$MSE))$alpha  # return the alpha that has the smallest MSE
  return(bestAlpha)
}

glmnetModel<-function(newData,bestAlpha,resp)
{
    ret<-data.frame(train_mse = NA, train_auc = NA, test_mse = NA, test_auc = NA
                    , userTime = NA, systemTime = NA, elapsedTime = NA)
    # set up the training and testing dataset
    set.seed(29)
    trainIndex<-createDataPartition(newData$win,p=.8,list=F,time=1)
    dtrain<-as.matrix(newData[trainIndex,-which(colnames(newData) %in% resp)])
    dtrain_resp<-newData[trainIndex,which(colnames(newData) %in% resp)]
    
    dtest<-as.matrix(newData[-trainIndex,-which(colnames(newData) %in% resp)])
    dtest_resp<-as.matrix(newData[-trainIndex,which(colnames(newData) %in% resp)])
 
    # train glmnet with the beatAlpha 
    glmnet_time<-system.time(glmnet_model<-glmnet(x = dtrain, y = dtrain_resp,
                            family = "binomial", alpha = bestAlpha))
    
    pred_train<-predict(glmnet_model,newx = dtrain, s = min(glmnet_model$lambda), type = "response")
    pred_test<-predict(glmnet_model,newx = dtest, s = min(glmnet_model$lambda), type = "response")
    ret[1,"train_mse"]<-mean((dtrain_resp - pred_train)^2)
    ret[1,"train_auc"]<-auc_adj(dtrain_resp,as.vector(pred_train))
    ret[1,"test_mse"]<-mean((dtest_resp - pred_test)^2)
    ret[1,"test_auc"]<-auc_adj(dtest_resp,as.vector(pred_test))
    ret[1,"userTime"]<-glmnet_time[[1]]
    ret[1,"systemTime"]<-glmnet_time[[2]]
    ret[1,"elapsedTime"]<-glmnet_time[[3]]
    
    print("Finished training xgb.")
    return(list(ret,glmnet_model))
}


# --------------------------------- 5. execute: model performance by min ---------------------------
modelPerf<-function()  # including both glmnet and xgb
{
    # initiate a data frame to store xgb model performance
    ret_model<-data.frame(dataset = NA, Model = NA, train_mse = NA, train_auc = NA, test_mse = NA, test_auc = NA
                            , userTime = NA, systemTime = NA, elapsedTime = NA)
    
    ret_list<-list() # an overall list with [[1]]: ret_model, and [[2]] and more for each variable importance data frame
    j<-1 # j is the pointer of ret rowNum
    for(i in seq(from = 1, to = 31, by = 3))  # i indicates each min interval
    {
        print(paste0("Start with ",i,"th min."))
        if (i == 1) # only grab basic champ and game setup data
        {
            data<-dataBasicSetup()
            ret_model[j,1]<-"basic" 
        }
        if (i > 1) 
        {
            data<-dataByMin(i) # grab data by numMin
            ret_model[j,1]<-paste0(i,"min")  
        }
        
        # the dataPrep() includes:
            # format(): format the dataset to only have numeric and factor
            # oneValue(): remove variables that have one value
            # hasFactor(): check if there are factors in the dataset
        data<-dataPrep(data)
        print(paste0("Finished loading data of the ",i,"th min."))
        
        # ----------------------- xgb cross validation & training -------------------
        # set up the training and testing dataset
        set.seed(29)
        trainIndex<-createDataPartition(data$win,p=.8,list=F,time=1)
        predictors_train<-data[trainIndex,-which(colnames(data) %in% "win")]
        resp_train<-data[trainIndex,which(colnames(data) %in% "win")]

        # cross validation to find the best eta
        xgbData_train<-normalise(predictors_train)
        xgbData_train[,"win"]<-resp_train
        bestEta<-xgbcv(xgbData_train)  # use cross validation to find the best Eta
        
        #train xgb using the best Eta. each byMin dataset would use its own bestEta
        predictors<-data[,-which(colnames(data) %in% "win")]
        predictors_scaled<-normalise(predictors)
        xgbData<-predictors_scaled
        xgbData[,"win"]<-data$win
        xgb<-xgbModel(xgbData, bestEta)  # xgb would have two items in the list. [[1]] is the training stats; [[2]] is the model.
        # model result.
        ret_model[j,2]<-"xgb"
        ret_model[j,3]<-xgb[[1]]$train_mse
        ret_model[j,4]<-xgb[[1]]$train_auc
        ret_model[j,5]<-xgb[[1]]$test_mse
        ret_model[j,6]<-xgb[[1]]$test_auc
        ret_model[j,7]<-xgb[[1]]$userTime
        ret_model[j,8]<-xgb[[1]]$systemTime
        ret_model[j,9]<-xgb[[1]]$elapsedTime
        print(paste0("Finish xgb training for ",i,"th min."))
        
        # grab importance
        model<-xgb[[2]]
        varImp.xgb<-as.data.frame(xgb.importance(model = model))
        # attach the column names to the varImp list
        cols<-as.data.frame(colnames(predictors_scaled))
        cols[,"rowName"]<-rownames(cols)
        varImp.xgb[,"varName"]<-lookup(varImp.xgb[,1],cols[,c(2,1)])
        
        # put the importance list to the result list
        ret_list[[j+1]]<-varImp.xgb
        print("Obtained variable importance list.")

        
       # ----------------------- glmnet cross validation & training -------------------
        # cross validation to find the best eta
        j<-j+1 # move to the next row in ret_model to store stats for glmnet
        predictors<-data[,-which(colnames(data) %in% "win")]
        
        # use xgb importance to select variables
        impVar<-as.numeric(varImp.xgb$Feature)
        glmnetPredictors<-predictors[,impVar]
         
        # transform predictors: poly, normalise, discretise
            # polyTransform(): attach extra columns with poly transform
            # quantile(): quantile a continuous variable by ntile
            # quantileAdj():adjust the borders of a level so any two levels don't share values
            # regroup(): modify min/max of a level for regrouping, including handling when the number of unique levels < ntile and if a level has <5% volume
            # discretise(): discretise a continuous variable based on the regrouping result
            # normalise()
        newData<-regTrans(glmnetPredictors,10)
        newData[,"win"]<-data$win   

        # glmnet tuning
        # find the appropriate alpha that an give the minimum error
        print("Start glmnetcv().")
        set.seed(29)
        trainIndex<-createDataPartition(newData$win,p=.8,list=F,time=1)
        newData_train<-newData[trainIndex,]
        bestAlpha<-glmnetcv(newData_train, "win") 
        # train the model with the bestAlpha
        print("Start glmnetModel().")
        glmnetRet<-glmnetModel(newData,bestAlpha,"win")  # glmnetRet is a list, containing [[1]] training stats and [[2]] the model object
        # model result
        ret_model[j,1]<-ret_model[j-1,1]
        ret_model[j,2]<-"glmnet"
        ret_model[j,3]<-glmnetRet[[1]]$train_mse
        ret_model[j,4]<-glmnetRet[[1]]$train_auc
        ret_model[j,5]<-glmnetRet[[1]]$test_mse
        ret_model[j,6]<-glmnetRet[[1]]$test_auc
        ret_model[j,7]<-glmnetRet[[1]]$userTime
        ret_model[j,8]<-glmnetRet[[1]]$systemTime
        ret_model[j,9]<-glmnetRet[[1]]$elapsedTime
        # put the coefficient list to the result list
        ret_list[[j+1]]<-coef(glmnetRet[[2]],s=min(glmnetRet[[2]]$lambda))
        print("Obtained variable coefficient list.")
        print(paste0("Finish glmnet training for ",i,"th min."))
                    
        i<-i+3
        j<-j+1            
   }
   ret_list[[1]]<-ret_model
   return(ret_list) 
}
byMinRet<-modelPerf()
# attributes such as Flat~, rFlat~ are item + rune


# ------------------------------ 6. model performance ----------------------------------
chartData<-byMinRet[[1]]
chartData[,1]<-as.numeric(gsub("min","",gsub("basic","1",chartData[,1])))
# ----------------------- chart predByMin -----------------------------------
# 22min has the best prediction (min rmse, max auc)
chartURL<-paste0("/src/lol/4-plot/team_predByMin_MSE.jpg") 
jpeg(chartURL,height=400,width=600) 
 g<-ggplot() +   # in aes, add group = categoricalColumn to tell r the line is for one category; add color = "category" to automatically add legend
             geom_line(data = filter(chartData,Model=="xgb"),aes(x = dataset, y = test_mse,group = Model,color="xgb"),size = 1) +
             geom_line(data = filter(chartData,Model=="glmnet"),aes(x = dataset, y = test_mse,group = Model,color="glmnet"),size = 1) +
             xlab("byMin") +
             ylab("Test_mse")
print(g)   # need to use print so the image can be saved within the for loop
dev.off()


chartURL<-paste0("/src/lol/4-plot/team_predByMin_auc.jpg") 
jpeg(chartURL,height=400,width=600) 
 g<-ggplot() +
             geom_line(data = filter(chartData,Model=="xgb"),aes(x = dataset, y = test_auc,group = Model,color="xgb"),size = 1) +
             geom_line(data = filter(chartData,Model=="glmnet"),aes(x = dataset, y = test_auc,group = Model,color="glmnet"),size = 1) +
             xlab("byMin") +
             ylab("test_auc")
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
        #glmnet_coefs$rank<-round(rank(-abs(glmnet_coefs$coef)),0)
        glmnet_coefs$rank<-round(rank(glmnet_coefs$coef),0)
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

# create a column of variable with the min# and transform suffix stripped out

#glmnet_coefs[,"variable_clean"]<-sub("(.*)_[0-9]+$","\\1",gsub("_capped","",glmnet_coefs$variable))
#sub("(.*)_[a-z][0-9]+.*$","\\1",a)  # a is "Champ_AttackSpeedOffset_d10_[1.22,5.53]"
#sub("(.*)_[a-z][0-9]+.*$","\\1",d) # "tags_SpellDamage_22_d1_[-0.7,-0.7]"
#glmnet_coefs[,"variable_clean"]<-sub("(.*)_[a-z][0-9]+.*$","\\1",gsub("_capped_[0-9]+","",b)) # "FlatAttackSpeedMod_22_capped_1"
variable_clean<-sub("(.*)_[a-z][0-9]+.*$","\\1",gsub("_capped_[0-9]+","",glmnet_coefs$variable))
variable_clean<-sub("(.*)_[0-9]+.*$","\\1",variable_clean)
glmnet_coefs[,"variable_clean"]<-sub("(.*)_[0-9]+$","\\1",variable_clean)
#https://stat545-ubc.github.io/block022_regular-expression.html
# .: any character
# *: any length
# (): indicate extraction
# [0-9]: any digit. It could be rewritten as \\d. Note: [\\d] doesn't work. 
# +: matches the previous type at least 1 times. Here is to repeat number/digit
# $: till the end of the string
# \\n: indicate which extraction to take. Here we grab the first extraction in ()

# rank variable based on their abs(coef)
glmnet_coefs[,"abs_coef"]<-abs(glmnet_coefs$coef)
# return a table group by min and variable_clean
by_absCoef<-group_by(glmnet_coefs,min,variable_clean)
# also return the min and max coef to obtain if a variable has positive or negative impaact
glmnet_coef_agg<-data.frame(summarise(by_absCoef,max(abs_coef),min(coef),max(coef)))
glmnet_coef_agg["sign"]<-substr(as.character(glmnet_coef_agg$'max.coef.' + glmnet_coef_agg$'min.coef.'),1,1)
glmnet_coef_agg["sign"]<-gsub("[0-9]","+",glmnet_coef_agg$sign)

# add rank by abs_coef for each minute
glmnet_imp<-data.frame()  # initiate an empty data frame
for (i in seq(from = 1, to = 31, by = 3)) # i is the minute 
{
    f<-filter(glmnet_coef_agg,min == i & variable_clean != "(Intercept)")  # remove intercept
    f[,"rank"]<-rank(-f$'max.abs_coef.')
    glmnet_imp<-rbind(glmnet_imp,f)
    
}



# create a default table where every variable has ranks for all 10 intervals and replace the entries that have non-default ranks and etc.
variables<-c("totalGold","sum_level","minionsKilled","Num_deaths","Num_KilleDchamp",
            "PLATINUM","DIAMOND","Num_AssistChamp","jungleMinionsKilled","Num_MonsterKilled",
            "SILVER","Num_Killedbld","Num_AssistBld",
            "Champ_SpellBlockPerLevel","Champ_HP","Champ_Attack","Champ_MPregen",
            "Champ_MPperLevel","Champ_AttackSpeedOffset","Champ_Magic","Champ_HPregenPerLevel",
            "Champ_MP","Champ_AttackDamagePerLevel","Champ_MoveSpeed","Champ_HPperLevel",
            "Champ_Defense","Champ_HPregen","Champ_Armor","tags_Mage_Fighter",
            "parType_Wind","Champ_AttackDamage","Champ_MPregenPerLevel",
            "FlatMPRegenMod","FlatMovementSpeedMod","FlatPhysicalDamageMod","tags_Boots",
             "FlatCritChanceMod", "FlatMagicDamageMod", "FlatAttackSpeedMod", "tags_SpellDamage",
             "rFlatArmorPenetrationMod","tags_CriticalStrike","PercentSpellVampMod","FlatMPRegenMod",
             "tags_SpellBlock","tags_GoldPer","FlatCritDamageMod","tags_ArmorPenetration")
glmnet_impFullRank<-data.frame(min = rep(seq(from = 1, to = 31, by = 3),each = length(variables)),variable_clean = rep(variables,11))
glmnet_impFullRank<-merge(x = glmnet_impFullRank,y = glmnet_imp,by = c("min","variable_clean"),all.x = TRUE)
glmnet_impFullRank[is.na(glmnet_impFullRank$rank),"rank"]<-50 # default to 50 as the max is 42

# because we can achieve the best prediction at 22th minute, we only chart until the 22th minute
#glmnet_imp22<-filter(glmnet_impFullRank,min <= 22 & (!is.na(min)))

variables_gamePlay<-c("totalGold","sum_level","minionsKilled","Num_deaths","Num_KilleDchamp",
            "PLATINUM","DIAMOND","Num_AssistChamp","jungleMinionsKilled","Num_MonsterKilled",
            "SILVER","Num_Killedbld","Num_AssistBld")

variables_champ<-c("Champ_SpellBlockPerLevel","Champ_HP","Champ_Attack","Champ_MPregen",
            "Champ_MPperLevel","Champ_AttackSpeedOffset","Champ_Magic","Champ_HPregenPerLevel",
            "Champ_MP","Champ_AttackDamagePerLevel","Champ_MoveSpeed","Champ_HPperLevel",
            "Champ_Defense","Champ_HPregen","Champ_Armor","tags_Mage_Fighter",
            "parType_Wind","Champ_AttackDamage","Champ_MPregenPerLevel")

variables_build<-c("FlatMPRegenMod","FlatMovementSpeedMod","FlatPhysicalDamageMod","tags_Boots",
             "FlatCritChanceMod", "FlatMagicDamageMod", "FlatAttackSpeedMod", "tags_SpellDamage",
             "rFlatArmorPenetrationMod","tags_CriticalStrike","PercentSpellVampMod","FlatMPRegenMod",
             "tags_SpellBlock","tags_GoldPer","FlatCritDamageMod","tags_ArmorPenetration")

#glmnet_gamePlay<-filter(glmnet_imp22,variable_clean %in% variables_gamePlay)
#glmnet_champ<-filter(glmnet_imp22,variable_clean %in% variables_champ)
#glmnet_build<-filter(glmnet_imp22,variable_clean %in% variables_build)

glmnet_gamePlay<-filter(glmnet_impFullRank,variable_clean %in% variables_gamePlay)
glmnet_champ<-filter(glmnet_impFullRank,variable_clean %in% variables_champ)
glmnet_build<-filter(glmnet_impFullRank,variable_clean %in% variables_build)

glmnet_gamePlay[,"TypeOfVariable"]<-"Game Play"
glmnet_champ[,"TypeOfVariable"]<-"Champion Attributes"
glmnet_build[,"TypeOfVariable"]<-"Build"

glmnet_gamePlay<-glmnet_gamePlay[order(glmnet_gamePlay$min,glmnet_gamePlay$rank),]


glmnet_impReady<-rbind(glmnet_gamePlay,glmnet_champ,glmnet_build)

for(i in 1:nrow(glmnet_impReady))
{
    if (is.na(glmnet_impReady[i,'sign']))
    {
        glmnet_impReady[i,'coef']<-0
    }
    else if (glmnet_impReady[i,'sign'] == '+')
    {
        glmnet_impReady[i,'coef']<-glmnet_impReady$max.coef[i]
    }
    else glmnet_impReady[i,'coef']<-glmnet_impReady$min.coef[i]
}

glmnet_impFiltered<-filter(glmnet_impReady,variable_clean!='DIAMOND' & variable_clean != 'SILVER' & variable_clean != 'PLATINUM')

# create a json file
b<-jsonlite::toJSON(glmnet_impFiltered)  # ret[[1]] is the variable names (repeat)
saveURL<-paste0("/usr/share/nginx/html/generated/chartJSON/data/game/glmnet_imp.json")
write(b,file=saveURL)



# ------------------------- chart glmnet coefs ------------------------------------
# game play status
s<-"ggplot() + "
for (i in seq_along(variables_gamePlay))  # loop through the variable name
{
     # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_impFullRank,variable_clean==variables_gamePlay[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables_gamePlay[",i,"]),size = 1) + ")
    s<-paste0(s,l)
    
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_gamePlay.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()

# champion status
# champion status variables ordered by their importance. more importance at front
s<-"ggplot() + "
for (i in seq_along(variables_champ))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_impFullRank,variable_clean==variables_champ[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables_champ[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_champ.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()

# build status
 s<-"ggplot() + "
for (i in seq_along(variables_build))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(glmnet_impFullRank,variable_clean==variables_build[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables_build[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/glmnet_byMin_build.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off() 

# ------------------------- xgb importance ---------------------- 
j<-1 # calculate min
for (i in seq(from = 2, to = 22, by = 2 ))  # i is the pointer in the byMinRet list, used to access glmnet coefs
{
    byMin<-byMinRet[[i]]
    temp<-byMin[,c("varName","Gain")] # this return a numeric vector with row name = variable name
    temp[,"min"]<-j
    temp[,"rank"]<-1:nrow(byMin)
    
    if (i == 2) 
    { 
        xgb_imp<-temp
    } 
    else 
    { 
        xgb_imp<-rbind(xgb_imp,temp)
    }
        
    i<-i+2
    j<-j+3
}

# change column name
colnames(xgb_imp)[1]<-"variable"
xgb_imp[,"variable_clean"]<-sub("(.*)_[0-9]+.*$","\\1",gsub("_capped","",xgb_imp[,"variable"]))


# create a default table where every variable has ranks for all 10 intervals and replace the entries that have non-default ranks and etc.
variables<-c("totalGold","sum_level","minionsKilled","Num_deaths","Num_KilleDchamp",
            "PLATINUM","DIAMOND","Num_AssistChamp","jungleMinionsKilled","Num_MonsterKilled",
            "SILVER","Num_Killedbld","Num_AssistBld",
            "Champ_SpellBlockPerLevel","Champ_HP","Champ_Attack","Champ_MPregen",
            "Champ_MPperLevel","Champ_AttackSpeedOffset","Champ_Magic","Champ_HPregenPerLevel",
            "Champ_MP","Champ_AttackDamagePerLevel","Champ_MoveSpeed","Champ_HPperLevel",
            "Champ_Defense","Champ_HPregen","Champ_Armor","tags_Mage_Fighter",
            "parType_Wind","Champ_AttackDamage","Champ_MPregenPerLevel",
            "FlatMPRegenMod","FlatMovementSpeedMod","FlatPhysicalDamageMod","tags_Boots",
             "FlatCritChanceMod", "FlatMagicDamageMod", "FlatAttackSpeedMod", "tags_SpellDamage",
             "rFlatArmorPenetrationMod","tags_CriticalStrike","PercentSpellVampMod","FlatMPRegenMod"
             #,"tags_SpellBlock","tags_GoldPer","FlatCritDamageMod","tags_ArmorPenetration"
             )
             
xgb_impFullRank<-data.frame(min = rep(seq(from = 1, to = 31, by = 3),each = length(variables)),variable_clean = rep(variables,11))
xgb_impFullRank<-merge(x = xgb_impFullRank,y = xgb_imp,by = c("min","variable_clean"),all.x = TRUE)
xgb_impFullRank[is.na(xgb_impFullRank$rank),"rank"]<-50 # default to 50 as the max is 42

# because we can achieve the best prediction at 22th minute, we only chart until the 22th minute
#xgb_imp22<-filter(xgb_impFullRank,min <= 22)

# create a json file
b<-jsonlite::toJSON(xgb_impFullRank)  # ret[[1]] is the variable names (repeat)
saveURL<-paste0("/usr/share/nginx/html/generated/chartJSON/data/game/xgb_imp.json")
write(b,file=saveURL)


# ------------------------- chart xgb gain ------------------------------------
# game play status
variables<-c("totalGold","sum_level","minionsKilled","Num_deaths","Num_KilleDchamp",
            "PLATINUM","DIAMOND","Num_AssistChamp","jungleMinionsKilled","Num_MonsterKilled",
            "SILVER","Num_Killedbld","Num_AssistBld")


s<-"ggplot() + "
for (i in seq_along(variables))  # loop through the variable name
{
     # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(xgb_impFullRank,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/xgb_byMin_gamePlay.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()


# champion status
# champion status variables ordered by their importance. more importance at front
variables<-c("Champ_SpellBlockPerLevel","Champ_HP","Champ_Attack","Champ_MPregen",
            "Champ_MPperLevel","Champ_AttackSpeedOffset","Champ_Magic","Champ_HPregenPerLevel",
            "Champ_MP","Champ_AttackDamagePerLevel","Champ_MoveSpeed","Champ_HPperLevel",
            "Champ_Defense","Champ_HPregen","Champ_Armor","tags_Mage_Fighter",
            "parType_Wind","Champ_AttackDamage","Champ_MPregenPerLevel")

s<-"ggplot() + "
for (i in seq_along(variables))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(xgb_impFullRank,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/xgb_byMin_champ.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off()


# build status
variables<-c("FlatMPRegenMod","FlatMovementSpeedMod","FlatPhysicalDamageMod","tags_Boots",
             "FlatCritChanceMod", "FlatMagicDamageMod", "FlatAttackSpeedMod", "tags_SpellDamage",
             "rFlatArmorPenetrationMod","tags_CriticalStrike","PercentSpellVampMod","FlatMPRegenMod"
             #,"tags_SpellBlock", "tags_GoldPer","FlatCritDamageMod","tags_ArmorPenetration"
             )
 s<-"ggplot() + "
for (i in seq_along(variables))
{
    # draw a line for each variable in the list
    l<-paste0("geom_line(data = filter(xgb_impFullRank,variable_clean==variables[",i,"]),aes(x = min, y = rank,group = variable_clean,color=variables[",i,"]),size = 1) + ")
    s<-paste0(s,l)
}    
s<-paste0(s,"xlab(\"byMin\") +","ylab(\"rank\")")
chartURL<-paste0("/src/lol/4-plot/xgb_byMin_build.jpg") 
jpeg(chartURL,height=400,width=600) 
g<-eval(parse(text = s)) 
print(g)
dev.off() 

