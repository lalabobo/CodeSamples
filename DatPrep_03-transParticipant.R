#!/usr/bin/Rscript
library(data.table)
library(DBI)
library(RMySQL)

# The original table that the new table is based on is: each row is a participant in a game at each min
# This function prepare a table: a gameId with up to 10 participantId, with stats of every 3min as columns
# Each row is a participant of a game, containing info of both during game playing and at the end of a game, as well as time series

# 1. transpose aggregate attributes of each min to 3min interval 
timelineToParticipant<-function(startRank,batchSize,nameDate)
{
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	batchTable<-dbGetQuery(con,paste0("select * from lol.timeline_event_join_",nameDate,"_ranked where `rank` between ",startRank," and ",startRank+batchSize-1))
	
	batchTable<-batchTable[!names(batchTable) %in% c("itemId")]	# remove itemId
	DT<-data.table(batchTable)  # change into data.table for faster data processing of big table

	# frame=1 means min=0
	# here we only look at the first 30min with 3min interval because the avg gameMinutes is ~30min
	transposeTable<-data.frame(gameId=NA,version=NA,participantId=NA,rank=NA,win=NA
				  ,gameCount=NA,gameMinutes=NA,gameMode=NA,gameType=NA,mapId=NA
				  ,seasonId=NA,championId=NA,spell1Id=NA,spell2Id=NA
				  ,highestAchievedSeasonTier=NA,role=NA,lane=NA
				  ,masteryId1=NA,mrank1=NA,masteryId2=NA,mrank2=NA,masteryId3=NA,mrank3=NA
				  ,masteryId4=NA,mrank4=NA,masteryId5=NA,mrank5=NA,masteryId6=NA,mrank6=NA
				  ,masteryId7=NA,mrank7=NA,masteryId8=NA,mrank8=NA,masteryId9=NA,mrank9=NA
				  ,masteryId10=NA,mrank10=NA,masteryId11=NA,mrank11=NA,masteryId12=NA,mrank12=NA
				  ,masteryId13=NA,mrank13=NA,masteryId14=NA,mrank14=NA,masteryId15=NA,mrank15=NA
				  ,masteryId16=NA,mrank16=NA,masteryId17=NA,mrank17=NA,masteryId18=NA,mrank18=NA
				  ,masteryId19=NA,mrank19=NA,masteryId20=NA,mrank20=NA
				  ,runeId1=NA,rrank1=NA,runeId2=NA,rrank2=NA,runeId3=NA,rrank3=NA
				  ,runeId4=NA,rrank4=NA,runeId5=NA,rrank5=NA,runeId6=NA,rrank6=NA
				  ,runeId7=NA,rrank7=NA,runeId8=NA,rrank8=NA,runeId9=NA,rrank9=NA
				  ,runeId10=NA,rrank10=NA,
				  
				  Num_ItemPurchased_4=NA,Num_ItemPurchased_7=NA,
				  Num_ItemPurchased_10=NA,Num_ItemPurchased_13=NA,Num_ItemPurchased_16=NA,Num_ItemPurchased_19=NA,
				  Num_ItemPurchased_22=NA,Num_ItemPurchased_25=NA,Num_ItemPurchased_28=NA,Num_ItemPurchased_31=NA,
				  Num_ItemSold_4=NA,Num_ItemSold_7=NA,
				  Num_ItemSold_10=NA,Num_ItemSold_13=NA,Num_ItemSold_16=NA,Num_ItemSold_19=NA,
				  Num_ItemSold_22=NA,Num_ItemSold_25=NA,Num_ItemSold_28=NA,Num_ItemSold_31=NA,
				  Num_MonsterKilled_4=NA,Num_MonsterKilled_7=NA,
				  Num_MonsterKilled_10=NA,Num_MonsterKilled_13=NA,Num_MonsterKilled_16=NA,Num_MonsterKilled_19=NA,
				  Num_MonsterKilled_22=NA,Num_MonsterKilled_25=NA,Num_MonsterKilled_28=NA,Num_MonsterKilled_31=NA,
				  Num_Ward_Killed_4=NA,Num_Ward_Killed_7=NA,Num_Ward_Killed_10=NA,Num_Ward_Killed_13=NA,
				  Num_Ward_Killed_16=NA,Num_Ward_Killed_19=NA,Num_Ward_Killed_22=NA,Num_Ward_Killed_25=NA,
				  Num_Ward_Killed_28=NA,Num_Ward_Killed_31=NA,
				  Num_Ward_Place_4=NA,Num_Ward_Place_7=NA,Num_Ward_Place_10=NA,Num_Ward_Place_13=NA,
				  Num_Ward_Place_16=NA,Num_Ward_Place_19=NA,Num_Ward_Place_22=NA,Num_Ward_Place_25=NA,
				  Num_Ward_Place_28=NA,Num_Ward_Place_31=NA,
				  Num_Killedbld_4=NA,Num_Killedbld_7=NA,Num_Killedbld_10=NA,Num_Killedbld_13=NA,Num_Killedbld_16=NA,
				  Num_Killedbld_19=NA, Num_Killedbld_22=NA,Num_Killedbld_25=NA,Num_Killedbld_28=NA,Num_Killedbld_31=NA,
				  Num_KilleDchamp_4=NA,Num_KilleDchamp_7=NA,Num_KilleDchamp_10=NA,Num_KilleDchamp_13=NA,
				  Num_KilleDchamp_16=NA,Num_KilleDchamp_19=NA,Num_KilleDchamp_22=NA,Num_KilleDchamp_25=NA,
				  Num_KilleDchamp_28=NA,Num_KilleDchamp_31=NA,
				  Num_Assisting_Player_4=NA,Num_Assisting_Player_7=NA,Num_Assisting_Player_10=NA,Num_Assisting_Player_13=NA,
				  Num_Assisting_Player_16=NA,Num_Assisting_Player_19=NA,Num_Assisting_Player_22=NA,Num_Assisting_Player_25=NA,
				  Num_Assisting_Player_28=NA,Num_Assisting_Player_31=NA,
				  skillSlot1_4=NA,skillSlot1_7=NA,skillSlot1_10=NA,skillSlot1_13=NA,
				  skillSlot1_16=NA,skillSlot1_19=NA,skillSlot1_22=NA,skillSlot1_25=NA,skillSlot1_28=NA,skillSlot1_31=NA,
				  skillSlot2_4=NA,skillSlot2_7=NA,skillSlot2_10=NA,skillSlot2_13=NA,
				  skillSlot2_16=NA,skillSlot2_19=NA,skillSlot2_22=NA,skillSlot2_25=NA,skillSlot2_28=NA,skillSlot2_31=NA,
				  skillSlot3_4=NA,skillSlot3_7=NA,skillSlot3_10=NA,skillSlot3_13=NA,
				  skillSlot3_16=NA,skillSlot3_19=NA,skillSlot3_22=NA,skillSlot3_25=NA,skillSlot3_28=NA,skillSlot3_31=NA,
				  skillSlot4_4=NA,skillSlot4_7=NA,skillSlot4_10=NA,skillSlot4_13=NA,
				  skillSlot4_16=NA,skillSlot4_19=NA,skillSlot4_22=NA,skillSlot4_25=NA,skillSlot4_28=NA,skillSlot4_31=NA,
				  position_x_4=NA,position_x_7=NA,position_x_10=NA,position_x_13=NA,position_x_16=NA,position_x_19=NA,
				  position_x_22=NA,position_x_25=NA,position_x_28=NA,position_x_31=NA,
				  position_y_4=NA,position_y_7=NA,position_y_10=NA,position_y_13=NA,position_y_16=NA,
				  position_y_19=NA,position_y_22=NA,position_y_25=NA,position_y_28=NA,position_y_31=NA,
				  champKilled_position_x_4=NA,champKilled_position_x_7=NA,champKilled_position_x_10=NA,
				  champKilled_position_x_13=NA,champKilled_position_x_16=NA,champKilled_position_x_19=NA,
				  champKilled_position_x_22=NA,champKilled_position_x_25=NA,champKilled_position_x_28=NA,
				  champKilled_position_x_31=NA,
				  champKilled_position_y_4=NA, champKilled_position_y_7=NA,champKilled_position_y_10=NA,
				  champKilled_position_y_13=NA,champKilled_position_y_16=NA,champKilled_position_y_19=NA,
				  champKilled_position_y_22=NA,champKilled_position_y_25=NA,champKilled_position_y_28=NA,
				  champKilled_position_y_31=NA,
				  goldSpent_4=NA,goldSpent_7=NA,goldSpent_10=NA,goldSpent_13=NA,goldSpent_16=NA,goldSpent_19=NA,
				  goldSpent_22=NA,goldSpent_25=NA,goldSpent_28=NA,goldSpent_31=NA,
				  goldRecoup_4=NA,goldRecoup_7=NA,goldRecoup_10=NA,goldRecoup_13=NA,goldRecoup_16=NA,
				  goldRecoup_19=NA,goldRecoup_22=NA,goldRecoup_25=NA,goldRecoup_28=NA,goldRecoup_31=NA,
				  num_consumed_4=NA,num_consumed_7=NA,num_consumed_10=NA,num_consumed_13=NA,num_consumed_16=NA,
				  num_consumed_19=NA,num_consumed_22=NA,num_consumed_25=NA,num_consumed_28=NA,num_consumed_31=NA,
				  Num_AssistBld_4=NA,Num_AssistBld_7=NA,Num_AssistBld_10=NA,Num_AssistBld_13=NA,Num_AssistBld_16=NA,
				  Num_AssistBld_19=NA,Num_AssistBld_22=NA,Num_AssistBld_25=NA,Num_AssistBld_28=NA,Num_AssistBld_31=NA,
				  Num_AssistChamp_4=NA,Num_AssistChamp_7=NA,Num_AssistChamp_10=NA,Num_AssistChamp_13=NA,
				  Num_AssistChamp_16=NA,Num_AssistChamp_19=NA,Num_AssistChamp_22=NA,Num_AssistChamp_25=NA,
				  Num_AssistChamp_28=NA,Num_AssistChamp_31=NA,
				  Num_deaths_4=NA,Num_deaths_7=NA,Num_deaths_10=NA,Num_deaths_13=NA,Num_deaths_16=NA,
				  Num_deaths_19=NA,Num_deaths_22=NA,Num_deaths_25=NA,Num_deaths_28=NA,Num_deaths_31=NA,
				 
				  tags_Active_4=NA,tags_Active_7=NA,tags_Active_10=NA,tags_Active_13=NA,tags_Active_16=NA,
				  tags_Active_19=NA,tags_Active_22=NA,tags_Active_25=NA,tags_Active_28=NA,tags_Active_31=NA,
				  tags_Armor_4=NA,tags_Armor_7=NA,tags_Armor_10=NA,tags_Armor_13=NA,tags_Armor_16=NA,
				  tags_Armor_19=NA,tags_Armor_22=NA,tags_Armor_25=NA,tags_Armor_28=NA,tags_Armor_31=NA,
				  tags_ArmorPenetration_4=NA,tags_ArmorPenetration_7=NA,tags_ArmorPenetration_10=NA,tags_ArmorPenetration_13=NA,
				  tags_ArmorPenetration_16=NA,tags_ArmorPenetration_19=NA,tags_ArmorPenetration_22=NA,tags_ArmorPenetration_25=NA,
				  tags_ArmorPenetration_28=NA,tags_ArmorPenetration_31=NA
				  
				, tags_AttackSpeed_4=NA,tags_AttackSpeed_7=NA,tags_AttackSpeed_10=NA,tags_AttackSpeed_13=NA,tags_AttackSpeed_16=NA,tags_AttackSpeed_19=NA,tags_AttackSpeed_22=NA,tags_AttackSpeed_25=NA,tags_AttackSpeed_28=NA,tags_AttackSpeed_31=NA
				, tags_Aura_4=NA, tags_Aura_7=NA, tags_Aura_10=NA, tags_Aura_13=NA, tags_Aura_16=NA, tags_Aura_19=NA, tags_Aura_22=NA, tags_Aura_25=NA, tags_Aura_28=NA, tags_Aura_31=NA
				, tags_Boots_4=NA, tags_Boots_7=NA, tags_Boots_10=NA, tags_Boots_13=NA, tags_Boots_16=NA, tags_Boots_19=NA, tags_Boots_22=NA, tags_Boots_25=NA, tags_Boots_28=NA, tags_Boots_31=NA
				, tags_Consumable_4=NA, tags_Consumable_7=NA, tags_Consumable_10=NA, tags_Consumable_13=NA, tags_Consumable_16=NA, tags_Consumable_19=NA, tags_Consumable_22=NA, tags_Consumable_25=NA, tags_Consumable_28=NA, tags_Consumable_31=NA
				, tags_CooldownReduction_4=NA, tags_CooldownReduction_7=NA, tags_CooldownReduction_10=NA, tags_CooldownReduction_13=NA, tags_CooldownReduction_16=NA, tags_CooldownReduction_19=NA, tags_CooldownReduction_22=NA, tags_CooldownReduction_25=NA, tags_CooldownReduction_28=NA, tags_CooldownReduction_31=NA
				, tags_CriticalStrike_4=NA, tags_CriticalStrike_7=NA, tags_CriticalStrike_10=NA, tags_CriticalStrike_13=NA, tags_CriticalStrike_16=NA, tags_CriticalStrike_19=NA, tags_CriticalStrike_22=NA, tags_CriticalStrike_25=NA, tags_CriticalStrike_28=NA, tags_CriticalStrike_31=NA
				, tags_Damage_4=NA, tags_Damage_7=NA, tags_Damage_10=NA, tags_Damage_13=NA, tags_Damage_16=NA, tags_Damage_19=NA, tags_Damage_22=NA, tags_Damage_25=NA, tags_Damage_28=NA, tags_Damage_31=NA
				, tags_GoldPer_4=NA, tags_GoldPer_7=NA, tags_GoldPer_10=NA, tags_GoldPer_13=NA, tags_GoldPer_16=NA, tags_GoldPer_19=NA, tags_GoldPer_22=NA, tags_GoldPer_25=NA, tags_GoldPer_28=NA, tags_GoldPer_31=NA
				, tags_Health_4=NA, tags_Health_7=NA, tags_Health_10=NA, tags_Health_13=NA, tags_Health_16=NA, tags_Health_19=NA, tags_Health_22=NA, tags_Health_25=NA, tags_Health_28=NA, tags_Health_31=NA
				, tags_HealthRegen_4=NA, tags_HealthRegen_7=NA, tags_HealthRegen_10=NA, tags_HealthRegen_13=NA, tags_HealthRegen_16=NA, tags_HealthRegen_19=NA, tags_HealthRegen_22=NA, tags_HealthRegen_25=NA, tags_HealthRegen_28=NA, tags_HealthRegen_31=NA
				, tags_Jungle_4=NA, tags_Jungle_7=NA, tags_Jungle_10=NA, tags_Jungle_13=NA, tags_Jungle_16=NA, tags_Jungle_19=NA, tags_Jungle_22=NA, tags_Jungle_25=NA, tags_Jungle_28=NA, tags_Jungle_31=NA
				, tags_Lane_4=NA, tags_Lane_7=NA, tags_Lane_10=NA, tags_Lane_13=NA, tags_Lane_16=NA, tags_Lane_19=NA, tags_Lane_22=NA, tags_Lane_25=NA, tags_Lane_28=NA, tags_Lane_31=NA
				, tags_LifeSteal_4=NA, tags_LifeSteal_7=NA, tags_LifeSteal_10=NA, tags_LifeSteal_13=NA, tags_LifeSteal_16=NA, tags_LifeSteal_19=NA, tags_LifeSteal_22=NA, tags_LifeSteal_25=NA, tags_LifeSteal_28=NA, tags_LifeSteal_31=NA
				, tags_MagicPenetration_4=NA, tags_MagicPenetration_7=NA, tags_MagicPenetration_10=NA, tags_MagicPenetration_13=NA, tags_MagicPenetration_16=NA, tags_MagicPenetration_19=NA, tags_MagicPenetration_22=NA, tags_MagicPenetration_25=NA, tags_MagicPenetration_28=NA, tags_MagicPenetration_31=NA
				, tags_Mana_4=NA, tags_Mana_7=NA, tags_Mana_10=NA, tags_Mana_13=NA, tags_Mana_16=NA, tags_Mana_19=NA, tags_Mana_22=NA, tags_Mana_25=NA, tags_Mana_28=NA, tags_Mana_31=NA
				, tags_ManaRegen_4=NA, tags_ManaRegen_7=NA, tags_ManaRegen_10=NA, tags_ManaRegen_13=NA, tags_ManaRegen_16=NA, tags_ManaRegen_19=NA, tags_ManaRegen_22=NA, tags_ManaRegen_25=NA, tags_ManaRegen_28=NA, tags_ManaRegen_31=NA
				, tags_Movement_4=NA, tags_Movement_7=NA, tags_Movement_10=NA, tags_Movement_13=NA, tags_Movement_16=NA, tags_Movement_19=NA, tags_Movement_22=NA, tags_Movement_25=NA, tags_Movement_28=NA, tags_Movement_31=NA
				, tags_NonbootsMovement_4=NA, tags_NonbootsMovement_7=NA, tags_NonbootsMovement_10=NA, tags_NonbootsMovement_13=NA, tags_NonbootsMovement_16=NA, tags_NonbootsMovement_19=NA, tags_NonbootsMovement_22=NA, tags_NonbootsMovement_25=NA, tags_NonbootsMovement_28=NA, tags_NonbootsMovement_31=NA
				, tags_OnHit_4=NA, tags_OnHit_7=NA, tags_OnHit_10=NA, tags_OnHit_13=NA, tags_OnHit_16=NA, tags_OnHit_19=NA, tags_OnHit_22=NA, tags_OnHit_25=NA, tags_OnHit_28=NA, tags_OnHit_31=NA
				, tags_Slow_4=NA, tags_Slow_7=NA, tags_Slow_10=NA, tags_Slow_13=NA, tags_Slow_16=NA, tags_Slow_19=NA, tags_Slow_22=NA, tags_Slow_25=NA, tags_Slow_28=NA, tags_Slow_31=NA
				, tags_SpellBlock_4=NA, tags_SpellBlock_7=NA, tags_SpellBlock_10=NA, tags_SpellBlock_13=NA, tags_SpellBlock_16=NA, tags_SpellBlock_19=NA, tags_SpellBlock_22=NA, tags_SpellBlock_25=NA, tags_SpellBlock_28=NA, tags_SpellBlock_31=NA
				, tags_SpellDamage_4=NA, tags_SpellDamage_7=NA, tags_SpellDamage_10=NA, tags_SpellDamage_13=NA, tags_SpellDamage_16=NA, tags_SpellDamage_19=NA, tags_SpellDamage_22=NA, tags_SpellDamage_25=NA, tags_SpellDamage_28=NA, tags_SpellDamage_31=NA
				, tags_SpellVamp_4=NA, tags_SpellVamp_7=NA, tags_SpellVamp_10=NA, tags_SpellVamp_13=NA, tags_SpellVamp_16=NA, tags_SpellVamp_19=NA, tags_SpellVamp_22=NA, tags_SpellVamp_25=NA, tags_SpellVamp_28=NA, tags_SpellVamp_31=NA
				, tags_Stealth_4=NA, tags_Stealth_7=NA, tags_Stealth_10=NA, tags_Stealth_13=NA, tags_Stealth_16=NA, tags_Stealth_19=NA, tags_Stealth_22=NA, tags_Stealth_25=NA, tags_Stealth_28=NA, tags_Stealth_31=NA
				, tags_Tenacity_4=NA, tags_Tenacity_7=NA, tags_Tenacity_10=NA, tags_Tenacity_13=NA, tags_Tenacity_16=NA, tags_Tenacity_19=NA, tags_Tenacity_22=NA, tags_Tenacity_25=NA, tags_Tenacity_28=NA, tags_Tenacity_31=NA
				, tags_Trinket_4=NA, tags_Trinket_7=NA, tags_Trinket_10=NA, tags_Trinket_13=NA, tags_Trinket_16=NA, tags_Trinket_19=NA, tags_Trinket_22=NA, tags_Trinket_25=NA, tags_Trinket_28=NA, tags_Trinket_31=NA
				, tags_Vision_4=NA, tags_Vision_7=NA, tags_Vision_10=NA, tags_Vision_13=NA, tags_Vision_16=NA, tags_Vision_19=NA, tags_Vision_22=NA, tags_Vision_25=NA, tags_Vision_28=NA, tags_Vision_31=NA
				, FlatHPPoolMod_4=NA, FlatHPPoolMod_7=NA, FlatHPPoolMod_10=NA, FlatHPPoolMod_13=NA, FlatHPPoolMod_16=NA, FlatHPPoolMod_19=NA, FlatHPPoolMod_22=NA, FlatHPPoolMod_25=NA, FlatHPPoolMod_28=NA, FlatHPPoolMod_31=NA
				, FlatMPPoolMod_4=NA, FlatMPPoolMod_7=NA, FlatMPPoolMod_10=NA, FlatMPPoolMod_13=NA, FlatMPPoolMod_16=NA, FlatMPPoolMod_19=NA, FlatMPPoolMod_22=NA, FlatMPPoolMod_25=NA, FlatMPPoolMod_28=NA, FlatMPPoolMod_31=NA
				, PercentHPPoolMod_4=NA, PercentHPPoolMod_7=NA, PercentHPPoolMod_10=NA, PercentHPPoolMod_13=NA, PercentHPPoolMod_16=NA, PercentHPPoolMod_19=NA, PercentHPPoolMod_22=NA, PercentHPPoolMod_25=NA, PercentHPPoolMod_28=NA, PercentHPPoolMod_31=NA
				, PercentMPPoolMod_4=NA, PercentMPPoolMod_7=NA, PercentMPPoolMod_10=NA, PercentMPPoolMod_13=NA, PercentMPPoolMod_16=NA, PercentMPPoolMod_19=NA, PercentMPPoolMod_22=NA, PercentMPPoolMod_25=NA, PercentMPPoolMod_28=NA, PercentMPPoolMod_31=NA
				, FlatHPRegenMod_4=NA, FlatHPRegenMod_7=NA, FlatHPRegenMod_10=NA, FlatHPRegenMod_13=NA, FlatHPRegenMod_16=NA, FlatHPRegenMod_19=NA, FlatHPRegenMod_22=NA, FlatHPRegenMod_25=NA, FlatHPRegenMod_28=NA, FlatHPRegenMod_31=NA
				, PercentHPRegenMod_4=NA, PercentHPRegenMod_7=NA, PercentHPRegenMod_10=NA, PercentHPRegenMod_13=NA, PercentHPRegenMod_16=NA, PercentHPRegenMod_19=NA, PercentHPRegenMod_22=NA, PercentHPRegenMod_25=NA, PercentHPRegenMod_28=NA, PercentHPRegenMod_31=NA
				, FlatMPRegenMod_4=NA, FlatMPRegenMod_7=NA, FlatMPRegenMod_10=NA, FlatMPRegenMod_13=NA, FlatMPRegenMod_16=NA, FlatMPRegenMod_19=NA, FlatMPRegenMod_22=NA, FlatMPRegenMod_25=NA, FlatMPRegenMod_28=NA, FlatMPRegenMod_31=NA
				, PercentMPRegenMod_4=NA, PercentMPRegenMod_7=NA, PercentMPRegenMod_10=NA, PercentMPRegenMod_13=NA, PercentMPRegenMod_16=NA, PercentMPRegenMod_19=NA, PercentMPRegenMod_22=NA, PercentMPRegenMod_25=NA, PercentMPRegenMod_28=NA, PercentMPRegenMod_31=NA
				, FlatArmorMod_4=NA, FlatArmorMod_7=NA, FlatArmorMod_10=NA, FlatArmorMod_13=NA, FlatArmorMod_16=NA, FlatArmorMod_19=NA, FlatArmorMod_22=NA, FlatArmorMod_25=NA, FlatArmorMod_28=NA, FlatArmorMod_31=NA
				, PercentArmorMod_4=NA, PercentArmorMod_7=NA, PercentArmorMod_10=NA, PercentArmorMod_13=NA, PercentArmorMod_16=NA, PercentArmorMod_19=NA, PercentArmorMod_22=NA, PercentArmorMod_25=NA, PercentArmorMod_28=NA, PercentArmorMod_31=NA
				, FlatPhysicalDamageMod_4=NA, FlatPhysicalDamageMod_7=NA, FlatPhysicalDamageMod_10=NA, FlatPhysicalDamageMod_13=NA, FlatPhysicalDamageMod_16=NA, FlatPhysicalDamageMod_19=NA, FlatPhysicalDamageMod_22=NA, FlatPhysicalDamageMod_25=NA, FlatPhysicalDamageMod_28=NA, FlatPhysicalDamageMod_31=NA
				, PercentPhysicalDamageMod_4=NA, PercentPhysicalDamageMod_7=NA, PercentPhysicalDamageMod_10=NA, PercentPhysicalDamageMod_13=NA, PercentPhysicalDamageMod_16=NA, PercentPhysicalDamageMod_19=NA, PercentPhysicalDamageMod_22=NA, PercentPhysicalDamageMod_25=NA, PercentPhysicalDamageMod_28=NA, PercentPhysicalDamageMod_31=NA
				, FlatMagicDamageMod_4=NA, FlatMagicDamageMod_7=NA, FlatMagicDamageMod_10=NA, FlatMagicDamageMod_13=NA, FlatMagicDamageMod_16=NA, FlatMagicDamageMod_19=NA, FlatMagicDamageMod_22=NA, FlatMagicDamageMod_25=NA, FlatMagicDamageMod_28=NA, FlatMagicDamageMod_31=NA
				, PercentMagicDamageMod_4=NA, PercentMagicDamageMod_7=NA, PercentMagicDamageMod_10=NA, PercentMagicDamageMod_13=NA, PercentMagicDamageMod_16=NA, PercentMagicDamageMod_19=NA, PercentMagicDamageMod_22=NA, PercentMagicDamageMod_25=NA, PercentMagicDamageMod_28=NA, PercentMagicDamageMod_31=NA
				, FlatMovementSpeedMod_4=NA, FlatMovementSpeedMod_7=NA, FlatMovementSpeedMod_10=NA, FlatMovementSpeedMod_13=NA, FlatMovementSpeedMod_16=NA, FlatMovementSpeedMod_19=NA, FlatMovementSpeedMod_22=NA, FlatMovementSpeedMod_25=NA, FlatMovementSpeedMod_28=NA, FlatMovementSpeedMod_31=NA
				, PercentMovementSpeedMod_4=NA, PercentMovementSpeedMod_7=NA, PercentMovementSpeedMod_10=NA, PercentMovementSpeedMod_13=NA, PercentMovementSpeedMod_16=NA, PercentMovementSpeedMod_19=NA, PercentMovementSpeedMod_22=NA, PercentMovementSpeedMod_25=NA, PercentMovementSpeedMod_28=NA, PercentMovementSpeedMod_31=NA
				, FlatAttackSpeedMod_4=NA, FlatAttackSpeedMod_7=NA, FlatAttackSpeedMod_10=NA, FlatAttackSpeedMod_13=NA, FlatAttackSpeedMod_16=NA, FlatAttackSpeedMod_19=NA, FlatAttackSpeedMod_22=NA, FlatAttackSpeedMod_25=NA, FlatAttackSpeedMod_28=NA, FlatAttackSpeedMod_31=NA
				, PercentAttackSpeedMod_4=NA, PercentAttackSpeedMod_7=NA, PercentAttackSpeedMod_10=NA, PercentAttackSpeedMod_13=NA, PercentAttackSpeedMod_16=NA, PercentAttackSpeedMod_19=NA, PercentAttackSpeedMod_22=NA, PercentAttackSpeedMod_25=NA, PercentAttackSpeedMod_28=NA, PercentAttackSpeedMod_31=NA
				, PercentDodgeMod_4=NA, PercentDodgeMod_7=NA, PercentDodgeMod_10=NA, PercentDodgeMod_13=NA, PercentDodgeMod_16=NA, PercentDodgeMod_19=NA, PercentDodgeMod_22=NA, PercentDodgeMod_25=NA, PercentDodgeMod_28=NA, PercentDodgeMod_31=NA
				, FlatCritChanceMod_4=NA, FlatCritChanceMod_7=NA, FlatCritChanceMod_10=NA, FlatCritChanceMod_13=NA, FlatCritChanceMod_16=NA, FlatCritChanceMod_19=NA, FlatCritChanceMod_22=NA, FlatCritChanceMod_25=NA, FlatCritChanceMod_28=NA, FlatCritChanceMod_31=NA
				, PercentCritChanceMod_4=NA, PercentCritChanceMod_7=NA, PercentCritChanceMod_10=NA, PercentCritChanceMod_13=NA, PercentCritChanceMod_16=NA, PercentCritChanceMod_19=NA, PercentCritChanceMod_22=NA, PercentCritChanceMod_25=NA, PercentCritChanceMod_28=NA, PercentCritChanceMod_31=NA
				, FlatCritDamageMod_4=NA, FlatCritDamageMod_7=NA, FlatCritDamageMod_10=NA, FlatCritDamageMod_13=NA, FlatCritDamageMod_16=NA, FlatCritDamageMod_19=NA, FlatCritDamageMod_22=NA, FlatCritDamageMod_25=NA, FlatCritDamageMod_28=NA, FlatCritDamageMod_31=NA
				, PercentCritDamageMod_4=NA, PercentCritDamageMod_7=NA, PercentCritDamageMod_10=NA, PercentCritDamageMod_13=NA, PercentCritDamageMod_16=NA, PercentCritDamageMod_19=NA, PercentCritDamageMod_22=NA, PercentCritDamageMod_25=NA, PercentCritDamageMod_28=NA, PercentCritDamageMod_31=NA
				, FlatBlockMod_4=NA, FlatBlockMod_7=NA, FlatBlockMod_10=NA, FlatBlockMod_13=NA, FlatBlockMod_16=NA, FlatBlockMod_19=NA, FlatBlockMod_22=NA, FlatBlockMod_25=NA, FlatBlockMod_28=NA, FlatBlockMod_31=NA
				, PercentBlockMod_4=NA, PercentBlockMod_7=NA, PercentBlockMod_10=NA, PercentBlockMod_13=NA, PercentBlockMod_16=NA, PercentBlockMod_19=NA, PercentBlockMod_22=NA, PercentBlockMod_25=NA, PercentBlockMod_28=NA, PercentBlockMod_31=NA
				, FlatSpellBlockMod_4=NA, FlatSpellBlockMod_7=NA, FlatSpellBlockMod_10=NA, FlatSpellBlockMod_13=NA, FlatSpellBlockMod_16=NA, FlatSpellBlockMod_19=NA, FlatSpellBlockMod_22=NA, FlatSpellBlockMod_25=NA, FlatSpellBlockMod_28=NA, FlatSpellBlockMod_31=NA
				, PercentSpellBlockMod_4=NA, PercentSpellBlockMod_7=NA, PercentSpellBlockMod_10=NA, PercentSpellBlockMod_13=NA, PercentSpellBlockMod_16=NA, PercentSpellBlockMod_19=NA, PercentSpellBlockMod_22=NA, PercentSpellBlockMod_25=NA, PercentSpellBlockMod_28=NA, PercentSpellBlockMod_31=NA
				, FlatEXPBonus_4=NA, FlatEXPBonus_7=NA, FlatEXPBonus_10=NA, FlatEXPBonus_13=NA, FlatEXPBonus_16=NA, FlatEXPBonus_19=NA, FlatEXPBonus_22=NA, FlatEXPBonus_25=NA, FlatEXPBonus_28=NA, FlatEXPBonus_31=NA
				, FlatEnergyRegenMod_4=NA, FlatEnergyRegenMod_7=NA, FlatEnergyRegenMod_10=NA, FlatEnergyRegenMod_13=NA, FlatEnergyRegenMod_16=NA, FlatEnergyRegenMod_19=NA, FlatEnergyRegenMod_22=NA, FlatEnergyRegenMod_25=NA, FlatEnergyRegenMod_28=NA, FlatEnergyRegenMod_31=NA
				, FlatEnergyPoolMod_4=NA, FlatEnergyPoolMod_7=NA, FlatEnergyPoolMod_10=NA, FlatEnergyPoolMod_13=NA, FlatEnergyPoolMod_16=NA, FlatEnergyPoolMod_19=NA, FlatEnergyPoolMod_22=NA, FlatEnergyPoolMod_25=NA, FlatEnergyPoolMod_28=NA, FlatEnergyPoolMod_31=NA
				, PercentLifeStealMod_4=NA, PercentLifeStealMod_7=NA, PercentLifeStealMod_10=NA, PercentLifeStealMod_13=NA, PercentLifeStealMod_16=NA, PercentLifeStealMod_19=NA, PercentLifeStealMod_22=NA, PercentLifeStealMod_25=NA, PercentLifeStealMod_28=NA, PercentLifeStealMod_31=NA
				, PercentSpellVampMod_4=NA, PercentSpellVampMod_7=NA, PercentSpellVampMod_10=NA, PercentSpellVampMod_13=NA, PercentSpellVampMod_16=NA, PercentSpellVampMod_19=NA, PercentSpellVampMod_22=NA, PercentSpellVampMod_25=NA, PercentSpellVampMod_28=NA, PercentSpellVampMod_31=NA
				, currentGold_4=NA, currentGold_7=NA, currentGold_10=NA, currentGold_13=NA, currentGold_16=NA, currentGold_19=NA, currentGold_22=NA, currentGold_25=NA, currentGold_28=NA, currentGold_31=NA
				, totalGold_4=NA, totalGold_7=NA, totalGold_10=NA, totalGold_13=NA, totalGold_16=NA, totalGold_19=NA, totalGold_22=NA, totalGold_25=NA, totalGold_28=NA, totalGold_31=NA
				, level_4=NA, level_7=NA, level_10=NA, level_13=NA, level_16=NA, level_19=NA, level_22=NA, level_25=NA, level_28=NA, level_31=NA
				, xp_4=NA, xp_7=NA, xp_10=NA, xp_13=NA, xp_16=NA, xp_19=NA, xp_22=NA, xp_25=NA, xp_28=NA, xp_31=NA
				, minionsKilled_4=NA, minionsKilled_7=NA, minionsKilled_10=NA, minionsKilled_13=NA, minionsKilled_16=NA, minionsKilled_19=NA, minionsKilled_22=NA, minionsKilled_25=NA, minionsKilled_28=NA, minionsKilled_31=NA
				, jungleMinionsKilled_4=NA, jungleMinionsKilled_7=NA, jungleMinionsKilled_10=NA, jungleMinionsKilled_13=NA, jungleMinionsKilled_16=NA, jungleMinionsKilled_19=NA, jungleMinionsKilled_22=NA, jungleMinionsKilled_25=NA, jungleMinionsKilled_28=NA, jungleMinionsKilled_31=NA
				)

	j<-startRank 	# rank pointer also row number in the new table
	b<-0 	# carry on the row number
	# each gameId has a rank. Loop through each gameId
	for (j in startRank:(startRank+batchSize-1))
	{		
		x<-1 	# participantId pointer. Can be from 1 to <=10
		for (x in 1:DT[DT$rank==j,max(participantId)])
		{
			perGame<-DT[DT$rank==j]  # filter to a table of one game
			perPar<-DT[DT$rank==j&DT$participantId==x]  # filter to a table of a participant of a game
			# gameId level columns
			transposeTable[b+x,1]<-perGame[,max(gameId,na.rm=TRUE)] 	# gameId
			transposeTable[b+x,2]<-perGame[,max(version,na.rm=TRUE)]  	# version
			transposeTable[b+x,3]<-x 		# participantId
			transposeTable[b+x,4]<-j 		# rank
			transposeTable[b+x,5]<-perPar[,max(win,na.rm=TRUE)] # win
			transposeTable[b+x,6]<-perPar[,max(gameCount,na.rm=TRUE)]  # gameCount
			transposeTable[b+x,7]<-perGame[,max(gameMinutes,na.rm=TRUE)] # gameMinutes
			transposeTable[b+x,8]<-perGame[,max(gameMode,na.rm=TRUE)] # gameMode
			transposeTable[b+x,9]<-perGame[,max(gameType,na.rm=TRUE)] # gameType
			transposeTable[b+x,10]<-perGame[,max(mapId,na.rm=TRUE)] # mapId
			transposeTable[b+x,11]<-perGame[,max(seasonId,na.rm=TRUE)] # seasonId
			
			# participantId level columns
			transposeTable[b+x,12]<-perPar[,max(championId,na.rm=TRUE)] 	# championId
			transposeTable[b+x,13]<-perPar[,max(spell1Id,na.rm=TRUE)] 	# spell1Id
			transposeTable[b+x,14]<-perPar[,max(spell2Id,na.rm=TRUE)] 	# spell2Id
			transposeTable[b+x,15]<-perPar[,max(highestAchievedSeasonTier,na.rm=TRUE)] 	# highestAchievedSeasonTier
			transposeTable[b+x,16]<-perPar[,max(role,na.rm=TRUE)] 	# role
			transposeTable[b+x,17]<-perPar[,max(lane,na.rm=TRUE)]  	# lane
			transposeTable[b+x,18]<-perPar[,max(masteryId1,na.rm=TRUE)]     #  masteryId1
			transposeTable[b+x,19]<-perPar[,max(mrank1,na.rm=TRUE)]     #  mrank1
			transposeTable[b+x,20]<-perPar[,max(masteryId2,na.rm=TRUE)]     #  masteryId2
			transposeTable[b+x,21]<-perPar[,max(mrank2,na.rm=TRUE)]     #  mrank2
			transposeTable[b+x,22]<-perPar[,max(masteryId3,na.rm=TRUE)]     #  masteryId3
			transposeTable[b+x,23]<-perPar[,max(mrank3,na.rm=TRUE)]     #  mrank3
			transposeTable[b+x,24]<-perPar[,max(masteryId4,na.rm=TRUE)]     #  masteryId4
			transposeTable[b+x,25]<-perPar[,max(mrank4,na.rm=TRUE)]     #  mrank4
			transposeTable[b+x,26]<-perPar[,max(masteryId5,na.rm=TRUE)]     #  masteryId5
			transposeTable[b+x,27]<-perPar[,max(mrank5,na.rm=TRUE)]     #  mrank5
			transposeTable[b+x,28]<-perPar[,max(masteryId6,na.rm=TRUE)]     #  masteryId6
			transposeTable[b+x,29]<-perPar[,max(mrank6,na.rm=TRUE)]     #  mrank6
			transposeTable[b+x,30]<-perPar[,max(masteryId7,na.rm=TRUE)]     #  masteryId7
			transposeTable[b+x,31]<-perPar[,max(mrank7,na.rm=TRUE)]     #  mrank7
			transposeTable[b+x,32]<-perPar[,max(masteryId8,na.rm=TRUE)]     #  masteryId8
			transposeTable[b+x,33]<-perPar[,max(mrank8,na.rm=TRUE)]     #  mrank8
			transposeTable[b+x,34]<-perPar[,max(masteryId9,na.rm=TRUE)]     #  masteryId9
			transposeTable[b+x,35]<-perPar[,max(mrank9,na.rm=TRUE)]     #  mrank9
			transposeTable[b+x,36]<-perPar[,max(masteryId10,na.rm=TRUE)]     #  masteryId10
			transposeTable[b+x,37]<-perPar[,max(mrank10,na.rm=TRUE)]     #  mrank10
			transposeTable[b+x,38]<-perPar[,max(masteryId11,na.rm=TRUE)]     #  masteryId11
			transposeTable[b+x,39]<-perPar[,max(mrank11,na.rm=TRUE)]     #  mrank11
			transposeTable[b+x,40]<-perPar[,max(masteryId12,na.rm=TRUE)]     #  masteryId12
			transposeTable[b+x,41]<-perPar[,max(mrank12,na.rm=TRUE)]     #  mrank12
			transposeTable[b+x,42]<-perPar[,max(masteryId13,na.rm=TRUE)]     #  masteryId13
			transposeTable[b+x,43]<-perPar[,max(mrank13,na.rm=TRUE)]     #  mrank13
			transposeTable[b+x,44]<-perPar[,max(masteryId14,na.rm=TRUE)]     #  masteryId14
			transposeTable[b+x,45]<-perPar[,max(mrank14,na.rm=TRUE)]     #  mrank14
			transposeTable[b+x,46]<-perPar[,max(masteryId15,na.rm=TRUE)]     #  masteryId15
			transposeTable[b+x,47]<-perPar[,max(mrank15,na.rm=TRUE)]     #  mrank15
			transposeTable[b+x,48]<-perPar[,max(masteryId16,na.rm=TRUE)]     #  masteryId16
			transposeTable[b+x,49]<-perPar[,max(mrank16,na.rm=TRUE)]     #  mrank16
			transposeTable[b+x,50]<-perPar[,max(masteryId17,na.rm=TRUE)]     #  masteryId17
			transposeTable[b+x,51]<-perPar[,max(mrank17,na.rm=TRUE)]     #  mrank17
			transposeTable[b+x,52]<-perPar[,max(masteryId18,na.rm=TRUE)]     #  masteryId18
			transposeTable[b+x,53]<-perPar[,max(mrank18,na.rm=TRUE)]     #  mrank18
			transposeTable[b+x,54]<-perPar[,max(masteryId19,na.rm=TRUE)]     #  masteryId19
			transposeTable[b+x,55]<-perPar[,max(mrank19,na.rm=TRUE)]     #  mrank19
			transposeTable[b+x,56]<-perPar[,max(masteryId20,na.rm=TRUE)]     #  masteryId20
			transposeTable[b+x,57]<-perPar[,max(mrank20,na.rm=TRUE)]     #  mrank20
			transposeTable[b+x,58]<-perPar[,max(runeId1,na.rm=TRUE)]     #  runeId1
			transposeTable[b+x,59]<-perPar[,max(rrank1,na.rm=TRUE)]     #  rrank1
			transposeTable[b+x,60]<-perPar[,max(runeId2,na.rm=TRUE)]     #  runeId2
			transposeTable[b+x,61]<-perPar[,max(rrank2,na.rm=TRUE)]     #  rrank2
			transposeTable[b+x,62]<-perPar[,max(runeId3,na.rm=TRUE)]     #  runeId3
			transposeTable[b+x,63]<-perPar[,max(rrank3,na.rm=TRUE)]     #  rrank3
			transposeTable[b+x,64]<-perPar[,max(runeId4,na.rm=TRUE)]     #  runeId4
			transposeTable[b+x,65]<-perPar[,max(rrank4,na.rm=TRUE)]     #  rrank4
			transposeTable[b+x,66]<-perPar[,max(runeId5,na.rm=TRUE)]     #  runeId5
			transposeTable[b+x,67]<-perPar[,max(rrank5,na.rm=TRUE)]     #  rrank5
			transposeTable[b+x,68]<-perPar[,max(runeId6,na.rm=TRUE)]     #  runeId6
			transposeTable[b+x,69]<-perPar[,max(rrank6,na.rm=TRUE)]     #  rrank6
			transposeTable[b+x,70]<-perPar[,max(runeId7,na.rm=TRUE)]     #  runeId7
			transposeTable[b+x,71]<-perPar[,max(rrank7,na.rm=TRUE)]     #  rrank7
			transposeTable[b+x,72]<-perPar[,max(runeId8,na.rm=TRUE)]     #  runeId8
			transposeTable[b+x,73]<-perPar[,max(rrank8,na.rm=TRUE)]     #  rrank8
			transposeTable[b+x,74]<-perPar[,max(runeId9,na.rm=TRUE)]     #  runeId9
			transposeTable[b+x,75]<-perPar[,max(rrank9,na.rm=TRUE)]     #  rrank9
			transposeTable[b+x,76]<-perPar[,max(runeId10,na.rm=TRUE)]     #  runeId10
			transposeTable[b+x,77]<-perPar[,max(rrank10,na.rm=TRUE)]     #  rrank10
			
			# from here, we're doig aggregation attributes for every 3min interval (time series)
			i<-78 	# column pointer - batchTable
	
			# populate each column
			for (i in 78:(ncol(batchTable)-1)) # the batchTable. Don't count the last column rank.
			{
				k<-4 	# frame pointer
				a<-(i-78)*10+77	# column accumulator - transposeTable. Not all games last more than 21 frames
				
				# aggregated each 3 frames of each participantId in a gameId
				# we only look at 30 frames (1 frame = 1 min)
				for (k in seq(from=4,to=31,by=3))	# frame = 1 is the 0min so frame 4 is actually the end of min 3
				{
					colName<-colnames(batchTable)[i] # <- added 1 column in both batchTable and transposeTable. Need to adjust the numbers here
					if (!(i %in% c(89:92,161:166)))	# those columns aggregated in other ways other than sum					
						transposeTable[b+x,a+k%/%3]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","sum(as.numeric(",colName,"),na.rm=TRUE)]")))
					if (i %in% c(162:166))  # level needs to take the max
						transposeTable[b+x,a+k%/%3]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","max(as.numeric(",colName,"),na.rm=TRUE)]")))
					if (i %in% c(89:92,161)) # need to be avg
						transposeTable[b+x,a+k%/%3]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","mean(as.numeric(",colName,"),na.rm=TRUE)]")))
				#	if (i %in% c(128,129,131,133,135,137,139,141,143,144,146,148,150,152,154,156,157)) 	# need to be multiplied
				#		transposeTable[b+x,a+k%/%2]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","prod(as.numeric(",colName,"),na.rm=TRUE)]")))
					k<-k+3
				}
			}
		}
			b<-b+x
	}
	# write into the db========================
	#return(transposeTable)
	dbWriteTable(con,paste0("participant_rollup_",nameDate),transposeTable,append=TRUE) 
	dbDisconnect(con)
	print(paste0("Finished gameId rank from ",startRank," to ",startRank+batchSize-1))
}
#timelineToParticipant(startRank,1)


# 2. read a sql file as a string
read_sql<-function(path)
{
  if (file.exists(path))
    sql<-readChar(path,nchar= file.info(path)$size)
  else sql<-NA
  return(sql)
}

# 3. execute timelineToParticipant() by batch
# make sure the script can automatically run through multiple tables

nameDateList<-c("150528","150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
					,"150610","150611","150612","150613","150614")

runMultiTables<-function(nameDateList)
{
	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	exist<-dbGetQuery(con,"show tables from lol like 'participant_rollup_%'")
	
	if (nrow(exist)==1) 	# initialise the 1st transposed & aggregated table
	{
		nameDate<-nameDateList[nrow(exist)]
		startRank<-1
		timelineToParticipant(startRank,1,nameDate)	 # get the 1st gameId and setup unique index
		sql<-read_sql("/src/lol/SQL/99-1-uniqueIndex_TransParticipant.sql") 	# add unique index on gameIdParticipantId, set rank to be int
		sql<-gsub("nameDate",nameDate,sql)
		dbSendQuery(con,sql)
		timelineToParticipant(startRank+1,100,nameDate)
	}
	
	else
	{
		nameDate<-nameDateList[nrow(exist)-1] 	# -1 is due to we have lol.participant_rollup_old
		maxRank<-dbGetQuery(con,paste0("select max(rank) from lol.participant_rollup_",nameDate))
		totalRank<-dbGetQuery(con,paste0("select max(rank) from lol.timeline_event_join_",nameDate,"_ranked"))
		startRank<-maxRank[1,1]+1
	
		if (maxRank[1,1]<=totalRank[1,1]-100 & maxRank[1,1]<totalRank[1,1]) 	# rank is not finished parsed and has more than 100 ranks
		{
			timelineToParticipant(startRank,100,nameDate) 	# parse as normal
		}
		else if (maxRank[1,1]>totalRank[1,1]-100 & maxRank[1,1]<totalRank[1,1]) 	# rank is not finished parsed but has less than 100 ranks
		{
			batchSize<-totalRank[1,1]-maxRank[1,1]
			timelineToParticipant(startRank,batchSize,nameDate) 	# only parse the differece, which will be <100
		}
		else 
		{
			nameDate<-nameDateList[nrow(exist)] 	# move to the next date
			startRank<-1	# start from rank 1
			timelineToParticipant(startRank,1,nameDate)	 # get the 1st gameId and setup unique index
			sql<-read_sql("/src/lol/SQL/99-1-uniqueIndex_TransParticipant.sql") 	# add unique index on gameIdParticipantId, set rank to be int
			sql<-gsub("nameDate",nameDate,sql)
			dbSendQuery(con,sql)
			timelineToParticipant(startRank+1,100,nameDate)
		}
	}
	dbDisconnect(con)
}

time<-system.time(runMultiTables(nameDateList))


