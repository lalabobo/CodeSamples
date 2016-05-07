#!/usr/bin/Rscript

#-------------windows batch command prefix (obsolete) ----------------
# this is for batch command
# trailingOnly=TRUE means that only your arguments are returned, check:
# print(commandsArgs(trailingOnly=FALSE))
#args<-commandArgs(trailingOnly = TRUE)

# NOTE all regions have the same champion, item, etc stats.
# This script only needs to be run when there is an update on item, champion, masteries and runes.
#setwd('C://Users//Sarah//dropbox//R//lol')

library(jsonlite)
library(RMySQL)
library(DBI) 

# Summary
# 01 - convert each json files into table format and append to corresponding table in db
# 02 - read json files, call all parsers and write them into db
# 03 - with the input of x (version number: x.y.z), check the availabilty of a version and whether ther version is already recorded, and execute all parsers
# 04 - find the the largest x (version number: x.y.z), figure out the latest version number and execute the parsing


# 01 - convert each json files into table format and append to corresponding table in db
## 1.1 check if a field in a json file is NA
ifNull<-function(input)
{
	if ((class(try(input))=="try-error") ||(class(try(input))=="list") || (is.null(input))) 
		output<-NA
	else 
		output<-input
	return(output)
}

## 1.2 parser for item json
ItemJSONConverter<-function(item,jsonData)  # input an array of item names and json file
{
	ItemTable<-data.frame(ID=NA,Name=NA,description=NA,Version=NA,group=NA,
						 #isRune=NA,tier=NA,type=NA,
						 from=NA,hideFromAll=NA,into=NA,image_full=NA,image_sprite=NA,
						 goldBase=NA,goldPurchasable=NA,goldTotal=NA,goldSell=NA,Tags=NA,
						 map1=NA,map8=NA,map10=NA,map12=NA,depth=NA, 
						 PlainText=NA,consumed=NA,stacks=NA,colloq=NA,consumeOnFull=NA,
						 specialRecipe=NA,inStore=NA,requiredChampion=NA,Effect1Amount=NA,Effect2Amount=NA,
						 Effect3Amount=NA,Effect4Amount=NA,Effect5Amount=NA,Effect6Amount=NA,Effect7Amount=NA,
						 Effect8Amount=NA,	
						 #rFlatHPModPerLevel=NA,rFlatMPModPerLevel=NA,rFlatHPRegenModPerLevel=NA,
						 #rFlatMPRegenModPerLevel=NA,rFlatArmorModPerLevel=NA,rFlatArmorPenetrationMod=NA,rFlatArmorPenetrationModPerLevel=NA,rPercentArmorPenetrationMod=NA,
						 #rPercentArmorPenetrationModPerLevel=NA,rFlatPhysicalDamageModPerLevel=NA,rFlatMagicDamageModPerLevel=NA,
						 #rFlatMovementSpeedModPerLevel=NA,rPercentMovementSpeedModPerLevel=NA,rPercentAttackSpeedModPerLevel=NA,
						 #rFlatDodgeMod=NA,rFlatDodgeModPerLevel=NA,rFlatCritChanceModPerLevel=NA,rFlatCritDamageModPerLevel=NA,
						 #rFlatSpellBlockModPerLevel=NA,rPercentCooldownMod=NA,rPercentCooldownModPerLevel=NA,rFlatTimeDeadMod=NA,
						 #rFlatTimeDeadModPerLevel=NA,rPercentTimeDeadMod=NA,rPercentTimeDeadModPerLevel=NA,rFlatGoldPer10Mod=NA,
						 #rFlatMagicPenetrationMod=NA,rFlatMagicPenetrationModPerLevel=NA,rPercentMagicPenetrationMod=NA,
						 #rPercentMagicPenetrationModPerLevel=NA,rFlatEnergyRegenModPerLevel=NA,rFlatEnergyModPerLevel=NA,
						 FlatHPPoolMod=NA,FlatMPPoolMod=NA,
						 PercentHPPoolMod=NA,PercentMPPoolMod=NA,FlatHPRegenMod=NA,PercentHPRegenMod=NA,FlatMPRegenMod=NA,
						 PercentMPRegenMod=NA,FlatArmorMod=NA,PercentArmorMod=NA,FlatPhysicalDamageMod=NA,
						 PercentPhysicalDamageMod=NA,FlatMagicDamageMod=NA,PercentMagicDamageMod=NA,FlatMovementSpeedMod=NA,
						 PercentMovementSpeedMod=NA,FlatAttackSpeedMod=NA,PercentAttackSpeedMod=NA,
						 PercentDodgeMod=NA,FlatCritChanceMod=NA,PercentCritChanceMod=NA,FlatCritDamageMod=NA,
						 PercentCritDamageMod=NA,FlatBlockMod=NA,PercentBlockMod=NA,
						 FlatSpellBlockMod=NA,PercentSpellBlockMod=NA,FlatEXPBonus=NA,FlatEnergyRegenMod=NA,
						 FlatEnergyPoolMod=NA,PercentLifeStealMod=NA,PercentSpellVampMod=NA
						 )
						 
	i<-1 # pointer of item list
	j<-0 # pointer of the ItemStats list
#	for (i in 32:35) # for test
	for (i in 1:length(item)) 
	{
		id<-item[i]
		k<-1 # the number of tags
		# check if tags = list()
		if (eval(parse(text=paste0("length(jsonData$data$'",id,"'$tags)")))==0) n<-1 	# n is the nubmer of tags
		else n<-eval(parse(text=paste0("length(jsonData$data$'",id,"'$tags)")))
		for (k in 1:n)
		{
			a<-j+k   # itemTable row index
	#		print (paste0("j is ",j,"and k is ",k))		# for debugging
	#		print (paste0("tag number ",id,as.integer(eval(parse(text=paste0("length(jsonData$data$'",id,"'$tags)")))))) # for debugging
			ItemTable[a,1]<-id
			ItemTable[a,2]<-eval(parse(text=paste0("jsonData$data$'",id,"'$name")))
			ItemTable[a,3]<-eval(parse(text=paste0("jsonData$data$'",id,"'$description")))
			ItemTable[a,4]<-eval(parse(text=paste0("jsonData$version")))
			ItemTable[a,5]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$group"))))
			ItemTable[a,6]<-paste0(eval(parse(text=paste0("jsonData$data$'",id,"'$from"))),collapse=', ')
			ItemTable[a,7]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$hideFromAll"))))
			ItemTable[a,8]<-paste0(eval(parse(text=paste0("jsonData$data$'",id,"'$into"))),collapse=', ')
			ItemTable[a,9]<-eval(parse(text=paste0("jsonData$data$'",id,"'$image$full")))
			ItemTable[a,10]<-eval(parse(text=paste0("jsonData$data$'",id,"'$image$sprite")))
			ItemTable[a,11]<-eval(parse(text=paste0("jsonData$data$'",id,"'$gold$base")))
			ItemTable[a,12]<-eval(parse(text=paste0("jsonData$data$'",id,"'$gold$purchasable")))
			ItemTable[a,13]<-eval(parse(text=paste0("jsonData$data$'",id,"'$gold$total")))
			ItemTable[a,14]<-eval(parse(text=paste0("jsonData$data$'",id,"'$gold$sell")))
			ItemTable[a,15]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$tags","[",k,"]"))))
			ItemTable[a,16]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$maps$'1'"))))
			ItemTable[a,17]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$maps$'8'"))))
			ItemTable[a,18]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$maps$'10'"))))
			ItemTable[a,19]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$maps$'12'"))))
			ItemTable[a,20]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$depth"))))
			ItemTable[a,21]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$plaintext"))))
			ItemTable[a,22]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$consumed"))))
			ItemTable[a,23]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$stacks"))))
			ItemTable[a,24]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$colloq"))))
			ItemTable[a,25]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$consumeOnFull"))))
			ItemTable[a,26]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$specialRecipe"))))
			ItemTable[a,27]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$inStore"))))
			ItemTable[a,28]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$requiredChampion"))))
			ItemTable[a,29]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect1Amount"))))
			ItemTable[a,30]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect2Amount"))))
			ItemTable[a,31]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect3Amount"))))
			ItemTable[a,32]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect4Amount"))))
			ItemTable[a,33]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect5Amount"))))
			ItemTable[a,34]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect6Amount"))))
			ItemTable[a,35]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect7Amount"))))
			ItemTable[a,36]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$effect$Effect8Amount"))))

			stats<-colnames(ItemTable)
			b<-37	# b is the column pointer
			# Loop through all the stats columns
			for (b in 37:length(stats))
			{
				ItemTable[a,b]<-ifNull(eval(parse(text=paste0("jsonData$data$'",id,"'$stats$",stats[b]))))
			}
		}
	j<-a
	}

	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"items",ItemTable,append=TRUE)  # append the result to the itemTable in db
	dbDisconnect(con)
	print(paste0("Add the item stats of ",ItemTable[1,4]," to the db.",collapse=''))
}


## 1.3 - parser for champion json
ChampJSONConverter<-function(champion,jsonData)  # input an array of champion names and jsonFile
{
	ChampBaseStats<-data.frame(Type=NA,Version=NA,Format=NA,ChampionID=NA,champKey=NA,
								Name=NA,Title=NA,Blurb=NA,Attack=NA,Defense=NA, 
								Magic=NA,Difficulty=NA,Image_Full=NA,Image_sprite=NA,
								Image_group=NA,Tags=NA,parType=NA,HP=NA,HPperLevel=NA,
								MP=NA,MPperLevel=NA,MoveSpeed=NA,Armor=NA,ArmorPerLevel=NA,
								SpellBlock=NA,SpellBlockPerLevel=NA,AttackRange=NA,HPregen=NA,
								HPregenPerLevel=NA,MPregen=NA,MPregenPerLevel=NA,Crit=NA,
								CritPerLevel=NA,AttackDamage=NA,AttackDamagePerLevel=NA,
								AttackSpeedOffset=NA,AttackSpeedPerLevel=NA)

	i<-1
	for (i in 1:length(champion))
	{
		id<-champion[i]
		ChampBaseStats[i,1]<-jsonData$type
		ChampBaseStats[i,2]<-jsonData$version
		ChampBaseStats[i,3]<-jsonData$format 
		ChampBaseStats[i,4]<-id
		ChampBaseStats[i,5]<-eval(parse(text=paste("jsonData$data$",id,"$key")))
		ChampBaseStats[i,6]<-eval(parse(text=paste("jsonData$data$",id,"$name")))
		ChampBaseStats[i,7]<-eval(parse(text=paste("jsonData$data$",id,"$title")))
		ChampBaseStats[i,8]<-eval(parse(text=paste("jsonData$data$",id,"$blurb")))
		ChampBaseStats[i,9]<-eval(parse(text=paste("jsonData$data$",id,"$info$attack")))
		ChampBaseStats[i,10]<-eval(parse(text=paste("jsonData$data$",id,"$info$defense")))
		ChampBaseStats[i,11]<-eval(parse(text=paste("jsonData$data$",id,"$info$magic")))
		ChampBaseStats[i,12]<-eval(parse(text=paste("jsonData$data$",id,"$info$difficulty")))
		ChampBaseStats[i,13]<-eval(parse(text=paste("jsonData$data$",id,"$image$full")))
		ChampBaseStats[i,14]<-eval(parse(text=paste("jsonData$data$",id,"$image$sprite")))
		ChampBaseStats[i,15]<-eval(parse(text=paste("jsonData$data$",id,"$image$group")))
		ChampBaseStats[i,16]<-paste(eval(parse(text=paste("jsonData$data$",id,"$tags"))),collapse=', ')
		ChampBaseStats[i,17]<-eval(parse(text=paste("jsonData$data$",id,"$partype")))
		ChampBaseStats[i,18]<-eval(parse(text=paste("jsonData$data$",id,"$stats$hp")))
		ChampBaseStats[i,19]<-eval(parse(text=paste("jsonData$data$",id,"$stats$hpperlevel")))
		ChampBaseStats[i,20]<-eval(parse(text=paste("jsonData$data$",id,"$stats$mp")))
		ChampBaseStats[i,21]<-eval(parse(text=paste("jsonData$data$",id,"$stats$mpperlevel")))
		ChampBaseStats[i,22]<-eval(parse(text=paste("jsonData$data$",id,"$stats$movespeed")))
		ChampBaseStats[i,23]<-eval(parse(text=paste("jsonData$data$",id,"$stats$armor")))
		ChampBaseStats[i,24]<-eval(parse(text=paste("jsonData$data$",id,"$stats$armorperlevel")))
		ChampBaseStats[i,25]<-eval(parse(text=paste("jsonData$data$",id,"$stats$spellblock")))
		ChampBaseStats[i,26]<-eval(parse(text=paste("jsonData$data$",id,"$stats$spellblockperlevel")))
		ChampBaseStats[i,27]<-eval(parse(text=paste("jsonData$data$",id,"$stats$attackrange")))
		ChampBaseStats[i,28]<-eval(parse(text=paste("jsonData$data$",id,"$stats$hpregen")))
		ChampBaseStats[i,29]<-eval(parse(text=paste("jsonData$data$",id,"$stats$hpregenperlevel")))
		ChampBaseStats[i,30]<-eval(parse(text=paste("jsonData$data$",id,"$stats$mpregen")))
		ChampBaseStats[i,31]<-eval(parse(text=paste("jsonData$data$",id,"$stats$mpregenperlevel")))
		ChampBaseStats[i,32]<-eval(parse(text=paste("jsonData$data$",id,"$stats$crit")))
		ChampBaseStats[i,33]<-eval(parse(text=paste("jsonData$data$",id,"$stats$critperlevel")))
		ChampBaseStats[i,34]<-eval(parse(text=paste("jsonData$data$",id,"$stats$attackdamage")))
		ChampBaseStats[i,35]<-eval(parse(text=paste("jsonData$data$",id,"$stats$attackdamageperlevel")))
		ChampBaseStats[i,36]<-eval(parse(text=paste("jsonData$data$",id,"$stats$attackspeedoffset")))
		ChampBaseStats[i,37]<-eval(parse(text=paste("jsonData$data$",id,"$stats$attackspeedperlevel")))
		i<-i+1
	}
	#return(ChampBaseStats)
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"champions",ChampBaseStats,append=TRUE) # append the result to the champions table in db
	dbDisconnect(con)
	print(paste0("Add the champion stats of ",ChampBaseStats[1,2]," to the db.",collapse=''))
}


# 1.4 - parses for item limitation per group 
itemGroupJSONConvert<-function(verNum,jsonItem) # jsonItem is the item json file
{
	ItemGroupLimit<-data.frame(jsonItem$group)
	ItemGroupLimit["Version"]<-verNum	# add a new column called Version and take the verNum
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"itemgroup",ItemGroupLimit,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the item group limit of ",ItemGroupLimit[1,3]," to the db.",collapse=''))
}


# 1.5 - parser for tags category
TagsCategoryJSONConvert<-function(verNum,jsonItem)  # jsonItem is the item json file
{
	temp<-data.frame(jsonItem$tree)
	TagsCategory<-data.frame(header=NA,tags=NA,version=NA)
	i<-1    # i represents the row of the data frame
	a<-nrow(temp)
	b<-0  # pointer in the TagsCategory
	for (i in 1:a)
	{
		j<-1    # j represents the length of the vector of each [,2]
		for (j in 1:length(temp[i,2][[1]]))
		{
			TagsCategory[b+j,1]<-temp[i,1]
			TagsCategory[b+j,2]<-temp[i,2][[1]][j]	
		}
		b<-b+j
	}

	TagsCategory[,3]<-verNum
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"tagscategory",TagsCategory,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the tags category table of ",TagsCategory[1,3]," to the db.",collapse=''))
	#return(TagsCategory)
}


# 1.6 - parser for rune json
RuneJSONConverter<-function(rune,jsonRune)
{
	RuneTable<-data.frame(ID=NA,Name=NA,description=NA,Version=NA,isRune=NA,tier=NA,type=NA,
						 image_full=NA,image_sprite=NA,group=NA,PlainText=NA,Tags=NA,
						# goldBase=NA,goldTotal=NA,goldSell=NA,goldPurchasable=NA,consumed=NA,stacks=NA,
						# depth=NA,consumeOnFull=NA,from=NA,into=NA,specialRecipe=NA,inStore=NA,hideFromAll=NA,requiredChampion=NA,				 
						 FlatHPPoolMod=NA,rFlatHPModPerLevel=NA,
						 FlatMPPoolMod=NA,rFlatMPModPerLevel=NA,PercentHPPoolMod=NA,PercentMPPoolMod=NA,
						 FlatHPRegenMod=NA,rFlatHPRegenModPerLevel=NA,
						 PercentHPRegenMod=NA,FlatMPRegenMod=NA,rFlatMPRegenModPerLevel=NA,
						 PercentMPRegenMod=NA,FlatArmorMod=NA,rFlatArmorModPerLevel=NA,PercentArmorMod=NA,
						 rFlatArmorPenetrationMod=NA,rFlatArmorPenetrationModPerLevel=NA,rPercentArmorPenetrationMod=NA,
						 rPercentArmorPenetrationModPerLevel=NA,FlatPhysicalDamageMod=NA,rFlatPhysicalDamageModPerLevel=NA,
						 PercentPhysicalDamageMod=NA,FlatMagicDamageMod=NA,rFlatMagicDamageModPerLevel=NA,
						 PercentMagicDamageMod=NA,FlatMovementSpeedMod=NA,rFlatMovementSpeedModPerLevel=NA,
						 PercentMovementSpeedMod=NA,rPercentMovementSpeedModPerLevel=NA,
						 FlatAttackSpeedMod=NA,PercentAttackSpeedMod=NA,rPercentAttackSpeedModPerLevel=NA,
						 rFlatDodgeMod=NA,rFlatDodgeModPerLevel=NA,PercentDodgeMod=NA,FlatCritChanceMod=NA,
						 rFlatCritChanceModPerLevel=NA,PercentCritChanceMod=NA,FlatCritDamageMod=NA,
						 rFlatCritDamageModPerLevel=NA,PercentCritDamageMod=NA,FlatBlockMod=NA,PercentBlockMod=NA,
						 FlatSpellBlockMod=NA,rFlatSpellBlockModPerLevel=NA,PercentSpellBlockMod=NA,FlatEXPBonus=NA,
						 rPercentCooldownMod=NA,rPercentCooldownModPerLevel=NA,rFlatTimeDeadMod=NA,
						 rFlatTimeDeadModPerLevel=NA,rPercentTimeDeadMod=NA,rPercentTimeDeadModPerLevel=NA,rFlatGoldPer10Mod=NA,
						 rFlatMagicPenetrationMod=NA,rFlatMagicPenetrationModPerLevel=NA,rPercentMagicPenetrationMod=NA,
						 rPercentMagicPenetrationModPerLevel=NA,FlatEnergyRegenMod=NA,rFlatEnergyRegenModPerLevel=NA,
						 FlatEnergyPoolMod=NA,rFlatEnergyModPerLevel=NA,PercentLifeStealMod=NA,PercentSpellVampMod=NA
						 #map1=NA,map8=NA,map10=NA,map12=NA
						 )
	i<-1 # pointer of rune list. Rune list is a vector of rune id, such as 10001.
	j<-0 # pointer of the runeStats list
	for (i in 1:length(rune))	# Loop through the rune list
	#for (i in 1:1)	# for testing
	{
		id<-rune[i]
		k<-1 # the number of tags
		# check if  tags = list()
		if (eval(parse(text=paste0("length(jsonRune$data$'",id,"'$tags)")))==0) n<-1 	# n is the number of tags
		else n<-eval(parse(text=paste0("length(jsonRune$data$'",id,"'$tags)")))
		
		# the number of loop = the number of tags k
		for (k in 1:n)	
		{
			a<-j+k
			RuneTable[a,1]<-id
			RuneTable[a,2]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$name")))
			RuneTable[a,3]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$description")))
			RuneTable[a,4]<-eval(parse(text=paste0("jsonRune$version")))
			RuneTable[a,5]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$rune$isrune")))
			RuneTable[a,6]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$rune$tier")))
			RuneTable[a,7]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$rune$type")))
			RuneTable[a,8]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$image$full")))
			RuneTable[a,9]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$image$sprite")))
			RuneTable[a,10]<-eval(parse(text=paste0("jsonRune$data$'",id,"'$image$group")))
			RuneTable[a,11]<-ifNull(eval(parse(text=paste0("jsonRune$data$'",id,"'$plaintext"))))
			RuneTable[a,12]<-ifNull(eval(parse(text=paste0("jsonRune$data$'",id,"'$tags","[",k,"]"))))

			stats<-colnames(RuneTable)
			b<-13	# b is the column pointer. 
			# Loop through all the stats columns
			for (b in 13:length(stats))
			{
				RuneTable[a,b]<-ifNull(eval(parse(text=paste0("jsonRune$data$'",id,"'$stats$",stats[b]))))
				b<-b+1
			}
			k<-k+1
		}

	j<-a
	}
		
	#return(RuneTable)
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"runes",RuneTable,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the rune stats of ",RuneTable[1,4]," to the db.",collapse=''))
}

# 1.7 - parser for mastery category json
MasCatJSONConverter<-function(jsonData)
{
	MasCatTable<-data.frame(Type=NA,Version=NA,Category=NA,Level=NA,ID=NA,PreReq=NA)
	i<-1 	# the category pointer
	a<-0
	category<-names(jsonData$tree)
	for (i in 1:length(category))
	{
		j<-1 	# the level pointer
		for (j in 1:6)
		{
			k<-1
			for (k in 1:nrow(eval(parse(text=paste0("jsonData$tree$",category[i],"[[",j,"]]")))))
			{
				MasCatTable[a+k,1]<-jsonData$type
				MasCatTable[a+k,2]<-jsonData$version
				MasCatTable[a+k,3]<-category[i]
				MasCatTable[a+k,4]<-j
				MasCatTable[a+k,5]<-eval(parse(text=paste0("jsonData$tree$",category[i],"[[",j,"]][",k,",1]")))
				MasCatTable[a+k,6]<-eval(parse(text=paste0("jsonData$tree$",category[i],"[[",j,"]][",k,",2]")))
			}
			a<-a+k-1
		}
	}
	#return(MasCatTable)
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"masterycategory",MasCatTable,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the mastery of ",MasCatTable[1,2]," to the db.",collapse=''))	
}

# 1.8 - parser for masteries json
MasteryJSONConverter<-function(jsonData)
{
	MasteryTable<-data.frame(Type=NA,Version=NA,ID=NA,Name=NA,Description=NA,
							Image_Full=NA,Image_Sprite=NA,Image_group=NA,Ranks=NA,PreReq=NA)
	masteryID<-names(jsonData$data)
	i<-1 # pointer of mastery list
	for (i in 1:length(masteryID))	# Loop through the rune list
	{
		MasteryTable[i,1]<-jsonData$type
		MasteryTable[i,2]<-jsonData$version
		MasteryTable[i,3]<-masteryID[i]
		MasteryTable[i,4]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$name")))
		MasteryTable[i,5]<-paste0(eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$description"))),collapse=',')
		MasteryTable[i,6]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$image$full")))
		MasteryTable[i,7]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$image$sprite")))
		MasteryTable[i,8]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$image$group")))
		MasteryTable[i,9]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$ranks")))
		MasteryTable[i,10]<-eval(parse(text=paste0("jsonData$data$'",masteryID[i],"'$prereq")))
	}
	
	#return(MasteryTable)
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"masteries",MasteryTable,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the mastery of ",MasteryTable[1,2]," to the db.",collapse=''))
}


# 1.9 parser for summoners json
summonerJSONConverter<-function(jsonData)
{
	summonerTable<-data.frame(Type=NA,Version=NA,ID=NA,Name=NA,Description=NA,Tooltip=NA,
								maxRank=NA,Cooldown=NA,CooldownBurn=NA,Cost=NA,CostBurn=NA,
								Effect=NA,effectBurn=NA,sKey=NA,summonerLevel=NA,
								Modes=NA,costType=NA,sRange=NA,rangeBurn=NA,Image_full=NA,
								Image_sprite=NA,Image_group=NA,Resource=NA
								)
	i<-1
	spells<-names(jsonData$data)
	for (i in 1:length(spells))
	{
		summonerTable[i,1]<-jsonData$type
		summonerTable[i,2]<-jsonData$version
		summonerTable[i,3]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$id")))
		summonerTable[i,4]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$name")))
		summonerTable[i,5]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$description")))
		summonerTable[i,6]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$tooltip")))
		summonerTable[i,7]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$maxrank")))
		summonerTable[i,8]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$cooldown"))) 
		summonerTable[i,9]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$cooldownBurn"))) 
		summonerTable[i,10]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$cost")))
		summonerTable[i,11]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$costBurn"))) 
		summonerTable[i,12]<-ifNull(eval(parse(text=paste0("jsonData$data$",spells[i],"$effect"))))
		summonerTable[i,13]<-paste0(ifNull(eval(parse(text=paste0("jsonData$data$",spells[i],"$effectBurn")))),collapse=', ')
		summonerTable[i,14]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$key"))) 
		summonerTable[i,15]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$summonerLevel"))) 
		summonerTable[i,16]<-paste0(eval(parse(text=paste0("jsonData$data$",spells[i],"$modes"))),collapse=', ')
		summonerTable[i,17]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$costType")))
		summonerTable[i,18]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$range"))) 
		summonerTable[i,19]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$rangeBurn")))
		summonerTable[i,20]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$image$full")))
		summonerTable[i,21]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$image$sprite"))) 
		summonerTable[i,22]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$image$group")))   
		summonerTable[i,23]<-eval(parse(text=paste0("jsonData$data$",spells[i],"$resource")))  
	}
	#return(summonerTable)
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	dbWriteTable(con,"summoners",summonerTable,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Add the summoner spells of ",summonerTable[1,2]," to the db.",collapse=''))
}



# 02 - read json files, call all parsers and write them into db
convert<-function(verNum)	# execute all parsers for one version number
{
	## convert item json
	itemURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/item.json",collapse='')
	jsonItem<-fromJSON(itemURL)
	item<-names(jsonItem$data)
	#call the function
	ItemJSONConverter(item,jsonItem)

	# item limitation per group
	itemGroupJSONConvert(verNum,jsonItem)

	# tags category
	TagsCategoryJSONConvert(verNum,jsonItem)

	## convert champion json
	champURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/champion.json")
	jsonChamp<-fromJSON(champURL)
	champion<-names(jsonChamp$data)
	# call the function
	ChampJSONConverter(champion,jsonChamp)

	## convert rune json
	runeURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/rune.json")
	jsonRune<-fromJSON(runeURL)
	rune<-names(jsonRune$data)
	# call the function
	RuneJSONConverter(rune,jsonRune)
	
	## convert mastery json
	masteryURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/mastery.json")
	jsonMastery<-fromJSON(masteryURL)
	MasCatJSONConverter(jsonMastery)
	MasteryJSONConverter(jsonMastery)
	
	## convert summoner json
	summonerURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/summoner.json")
	jsonSummoner<-fromJSON(summonerURL)
	summonerJSONConverter(jsonSummoner)
}

# 03 - with the input of x (version number: x.y.z), check the availabilty of a version and whether ther version is already recorded, and execute all parsers
## add new verNum to the patchDate table
checkVersionNum<-function(checkXFrom=6)
{
	x<-checkXFrom	# it can be 4 or 5
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	existing<-dbGetQuery(con,"select distinct version from lol.patchdate") # get version numbers that are already parsed and stored in db
	
	for (x in checkXFrom:(checkXFrom+1))	# version number x.y.z
	{
		y<-1
		for (y in 1:30)	# assume the max of y is 30
		{
			z<-1
			for (z in 1:10)	# assume the max of z is 10
			{
				verNum<-paste0(x,".",y,".",z,collapse='')
				itemURL<-paste0("http://ddragon.leagueoflegends.com/cdn/",verNum,"/data/en_US/item.json",collapse='')
				# check if the json file with the version number exists
				if ((class(try(fromJSON(itemURL)))=="list") && !(verNum %in% existing[,1]))
				{
					convert(verNum)  # parse all json files one by one into its table
					## add the new version number to patchDate db
					dbSendQuery(con,paste0("INSERT ignore lol.patchdate (version) VALUES('",verNum,"')"))
				}
				z<-z+1		
			}
			y<-y+1
		}
		x<-x+1	
	}	
	dbDisconnect(con)
	return(verNum)
}


# 04 - find the the largest x (version number: x.y.z), figure out the latest version number and execute the parsing
con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
ret<-dbGetQuery(con,"select max(version) from lol.items")  # can be any table (from ddragon) that has version column
x<-ret[1,1]  # grab the version number
dbDisconnect(con)
checkXFrom<-as.numeric(substr(x,1,1)) # grab the x out of x.y.z
checkVersionNum(checkXFrom)  # figure out the latest version number and execute the parsing
