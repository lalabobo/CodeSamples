#!/usr/bin/Rscript
library(data.table)
library(DBI)
library(RMySQL)

# This function prepare a table: a gameId with up to 10 participantId, with stats of every 2min as columns
# This intends to answer the question: as a player what is the winning pattern?
# This table doesn't consider championId, masteries and runes
timelineToParticipant<-function(startRank,batchSize,nameDate)
{

	con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
	batchTable<-dbGetQuery(con,paste0("select * from lol.timeline_event_join_",nameDate,"_ranked where `rank` between ",startRank," and ",startRank+batchSize-1))
	
	batchTable<-batchTable[-c(79,16)]	# remove Num_SkillLevelUp and itemId
	DT<-data.table(batchTable)

# frame=1 means min=0
# here we only look at the first 20min with 2min interval
transposeTable<-data.frame(gameId=NA,version=NA,participantId=NA,rank=NA,win=NA,
				  gameMinutes=NA,gameMode=NA,gameType=NA,seasonId=NA,championId=NA,spell1Id=NA,spell2Id=NA,
				  highestAchievedSeasonTier=NA,role=NA,lane=NA
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
				  Num_ItemPurchased_3=NA,Num_ItemPurchased_5=NA,
				  Num_ItemPurchased_7=NA,Num_ItemPurchased_9=NA,Num_ItemPurchased_11=NA,Num_ItemPurchased_13=NA,
				  Num_ItemPurchased_15=NA,Num_ItemPurchased_17=NA,Num_ItemPurchased_19=NA,Num_ItemPurchased_21=NA,
				  Num_ItemSold_3=NA,Num_ItemSold_5=NA,
				  Num_ItemSold_7=NA,Num_ItemSold_9=NA,Num_ItemSold_11=NA,Num_ItemSold_13=NA,
				  Num_ItemSold_15=NA,Num_ItemSold_17=NA,Num_ItemSold_19=NA,Num_ItemSold_21=NA,
				  Num_ChampKilled_3=NA,Num_ChampKilled_5=NA,Num_ChampKilled_7=NA,Num_ChampKilled_9=NA,
				  Num_ChampKilled_11=NA,Num_ChampKilled_13=NA,Num_ChampKilled_15=NA,Num_ChampKilled_17=NA,
				  Num_ChampKilled_19=NA,Num_ChampKilled_21=NA,Num_MonsterKilled_3=NA,Num_MonsterKilled_5=NA,
				  Num_MonsterKilled_7=NA,Num_MonsterKilled_9=NA,Num_MonsterKilled_11=NA,Num_MonsterKilled_13=NA,
				  Num_MonsterKilled_15=NA,Num_MonsterKilled_17=NA,Num_MonsterKilled_19=NA,Num_MonsterKilled_21=NA,
				  Num_Building_Killed_3=NA,Num_Building_Killed_5=NA,
				  Num_Building_Killed_7=NA,Num_Building_Killed_9=NA,Num_Building_Killed_11=NA,Num_Building_Killed_13=NA,
				  Num_Building_Killed_15=NA,Num_Building_Killed_17=NA,Num_Building_Killed_19=NA,Num_Building_Killed_21=NA,				  
				  Num_Assisting_Player_3=NA,Num_Assisting_Player_5=NA,Num_Assisting_Player_7=NA,Num_Assisting_Player_9=NA,
				  Num_Assisting_Player_11=NA,Num_Assisting_Player_13=NA,Num_Assisting_Player_15=NA,Num_Assisting_Player_17=NA,
				  Num_Assisting_Player_19=NA,Num_Assisting_Player_21=NA,KilledByPlayer_3=NA,KilledByPlayer_5=NA,
				  KilledByPlayer_7=NA,KilledByPlayer_9=NA,KilledByPlayer_11=NA,KilledByPlayer_13=NA,KilledByPlayer_15=NA,
				  KilledByPlayer_17=NA,KilledByPlayer_19=NA,KilledByPlayer_21=NA,Num_Victim_3=NA,Num_Victim_5=NA,
				  Num_Victim_7=NA,Num_Victim_9=NA,Num_Victim_11=NA,Num_Victim_13=NA,Num_Victim_15=NA,Num_Victim_17=NA,
				  Num_Victim_19=NA,Num_Victim_21=NA,Num_Ward_Used_3=NA,Num_Ward_Used_5=NA,Num_Ward_Used_7=NA,Num_Ward_Used_9=NA,
				  Num_Ward_Used_11=NA,Num_Ward_Used_13=NA,Num_Ward_Used_15=NA,Num_Ward_Used_17=NA,
				  Num_Ward_Used_19=NA,Num_Ward_Used_21=NA,
				  skillSlot1_3=NA,skillSlot1_5=NA,skillSlot1_7=NA,skillSlot1_9=NA,
				  skillSlot1_11=NA,skillSlot1_13=NA,skillSlot1_15=NA,skillSlot1_17=NA,skillSlot1_19=NA,skillSlot1_21=NA,
				  skillSlot2_3=NA,skillSlot2_5=NA,skillSlot2_7=NA,skillSlot2_9=NA,
				  skillSlot2_11=NA,skillSlot2_13=NA,skillSlot2_15=NA,skillSlot2_17=NA,skillSlot2_19=NA,skillSlot2_21=NA,
				  skillSlot3_3=NA,skillSlot3_5=NA,skillSlot3_7=NA,skillSlot3_9=NA,
				  skillSlot3_11=NA,skillSlot3_13=NA,skillSlot3_15=NA,skillSlot3_17=NA,skillSlot3_19=NA,skillSlot3_21=NA,
				  skillSlot4_3=NA,skillSlot4_5=NA,skillSlot4_7=NA,skillSlot4_9=NA,
				  skillSlot4_11=NA,skillSlot4_13=NA,skillSlot4_15=NA,skillSlot4_17=NA,skillSlot4_19=NA,skillSlot4_21=NA,
				  position_x_3=NA,position_x_5=NA,position_x_7=NA,position_x_9=NA,position_x_11=NA,position_x_13=NA,
				  position_x_15=NA,position_x_17=NA,position_x_19=NA,position_x_21=NA,position_y_3=NA,position_y_5=NA,
				  position_y_7=NA,position_y_9=NA,position_y_11=NA,position_y_13=NA,position_y_15=NA,position_y_17=NA,
				  position_y_19=NA,position_y_21=NA,champKilled_position_x_3=NA,champKilled_position_x_5=NA,champKilled_position_x_7=NA,
				  champKilled_position_x_9=NA,champKilled_position_x_11=NA,champKilled_position_x_13=NA,champKilled_position_x_15=NA,
				  champKilled_position_x_17=NA,champKilled_position_x_19=NA,champKilled_position_x_21=NA,champKilled_position_y_3=NA,
				  champKilled_position_y_5=NA,champKilled_position_y_7=NA,champKilled_position_y_9=NA,champKilled_position_y_11=NA,
				  champKilled_position_y_13=NA,champKilled_position_y_15=NA,champKilled_position_y_17=NA,champKilled_position_y_19=NA,
				  champKilled_position_y_21=NA,goldSpent_3=NA,goldSpent_5=NA,goldSpent_7=NA,goldSpent_9=NA,goldSpent_11=NA,goldSpent_13=NA,
				  goldSpent_15=NA,goldSpent_17=NA,goldSpent_19=NA,goldSpent_21=NA,goldRecoup_3=NA,goldRecoup_5=NA,goldRecoup_7=NA,
				  goldRecoup_9=NA,goldRecoup_11=NA,goldRecoup_13=NA,goldRecoup_15=NA,goldRecoup_17=NA,goldRecoup_19=NA,goldRecoup_21=NA,
				  num_consumed_3=NA,num_consumed_5=NA,num_consumed_7=NA,num_consumed_9=NA,num_consumed_11=NA,num_consumed_13=NA,num_consumed_15=NA,
				  num_consumed_17=NA,num_consumed_19=NA,num_consumed_21=NA,tags_Active_3=NA,tags_Active_5=NA,tags_Active_7=NA,tags_Active_9=NA,
				  tags_Active_11=NA,tags_Active_13=NA,tags_Active_15=NA,tags_Active_17=NA,tags_Active_19=NA,tags_Active_21=NA,tags_Armor_3=NA,
				  tags_Armor_5=NA,tags_Armor_7=NA,tags_Armor_9=NA,tags_Armor_11=NA,tags_Armor_13=NA,tags_Armor_15=NA,tags_Armor_17=NA,tags_Armor_19=NA,
				  tags_Armor_21=NA,tags_ArmorPenetration_3=NA,tags_ArmorPenetration_5=NA,tags_ArmorPenetration_7=NA,tags_ArmorPenetration_9=NA,
				  tags_ArmorPenetration_11=NA,tags_ArmorPenetration_13=NA,tags_ArmorPenetration_15=NA,tags_ArmorPenetration_17=NA,tags_ArmorPenetration_19=NA,
				  tags_ArmorPenetration_21=NA
				  , tags_AttackSpeed_3=NA,tags_AttackSpeed_5=NA,tags_AttackSpeed_7=NA,tags_AttackSpeed_9=NA,tags_AttackSpeed_11=NA,tags_AttackSpeed_13=NA,tags_AttackSpeed_15=NA,tags_AttackSpeed_17=NA,tags_AttackSpeed_19=NA,tags_AttackSpeed_21=NA
, tags_Aura_3=NA, tags_Aura_5=NA, tags_Aura_7=NA, tags_Aura_9=NA, tags_Aura_11=NA, tags_Aura_13=NA, tags_Aura_15=NA, tags_Aura_17=NA, tags_Aura_19=NA, tags_Aura_21=NA
, tags_Boots_3=NA, tags_Boots_5=NA, tags_Boots_7=NA, tags_Boots_9=NA, tags_Boots_11=NA, tags_Boots_13=NA, tags_Boots_15=NA, tags_Boots_17=NA, tags_Boots_19=NA, tags_Boots_21=NA
, tags_Consumable_3=NA, tags_Consumable_5=NA, tags_Consumable_7=NA, tags_Consumable_9=NA, tags_Consumable_11=NA, tags_Consumable_13=NA, tags_Consumable_15=NA, tags_Consumable_17=NA, tags_Consumable_19=NA, tags_Consumable_21=NA
, tags_CooldownReduction_3=NA, tags_CooldownReduction_5=NA, tags_CooldownReduction_7=NA, tags_CooldownReduction_9=NA, tags_CooldownReduction_11=NA, tags_CooldownReduction_13=NA, tags_CooldownReduction_15=NA, tags_CooldownReduction_17=NA, tags_CooldownReduction_19=NA, tags_CooldownReduction_21=NA
, tags_CriticalStrike_3=NA, tags_CriticalStrike_5=NA, tags_CriticalStrike_7=NA, tags_CriticalStrike_9=NA, tags_CriticalStrike_11=NA, tags_CriticalStrike_13=NA, tags_CriticalStrike_15=NA, tags_CriticalStrike_17=NA, tags_CriticalStrike_19=NA, tags_CriticalStrike_21=NA
, tags_Damage_3=NA, tags_Damage_5=NA, tags_Damage_7=NA, tags_Damage_9=NA, tags_Damage_11=NA, tags_Damage_13=NA, tags_Damage_15=NA, tags_Damage_17=NA, tags_Damage_19=NA, tags_Damage_21=NA
, tags_GoldPer_3=NA, tags_GoldPer_5=NA, tags_GoldPer_7=NA, tags_GoldPer_9=NA, tags_GoldPer_11=NA, tags_GoldPer_13=NA, tags_GoldPer_15=NA, tags_GoldPer_17=NA, tags_GoldPer_19=NA, tags_GoldPer_21=NA
, tags_Health_3=NA, tags_Health_5=NA, tags_Health_7=NA, tags_Health_9=NA, tags_Health_11=NA, tags_Health_13=NA, tags_Health_15=NA, tags_Health_17=NA, tags_Health_19=NA, tags_Health_21=NA
, tags_HealthRegen_3=NA, tags_HealthRegen_5=NA, tags_HealthRegen_7=NA, tags_HealthRegen_9=NA, tags_HealthRegen_11=NA, tags_HealthRegen_13=NA, tags_HealthRegen_15=NA, tags_HealthRegen_17=NA, tags_HealthRegen_19=NA, tags_HealthRegen_21=NA
, tags_Jungle_3=NA, tags_Jungle_5=NA, tags_Jungle_7=NA, tags_Jungle_9=NA, tags_Jungle_11=NA, tags_Jungle_13=NA, tags_Jungle_15=NA, tags_Jungle_17=NA, tags_Jungle_19=NA, tags_Jungle_21=NA
, tags_Lane_3=NA, tags_Lane_5=NA, tags_Lane_7=NA, tags_Lane_9=NA, tags_Lane_11=NA, tags_Lane_13=NA, tags_Lane_15=NA, tags_Lane_17=NA, tags_Lane_19=NA, tags_Lane_21=NA
, tags_LifeSteal_3=NA, tags_LifeSteal_5=NA, tags_LifeSteal_7=NA, tags_LifeSteal_9=NA, tags_LifeSteal_11=NA, tags_LifeSteal_13=NA, tags_LifeSteal_15=NA, tags_LifeSteal_17=NA, tags_LifeSteal_19=NA, tags_LifeSteal_21=NA
, tags_MagicPenetration_3=NA, tags_MagicPenetration_5=NA, tags_MagicPenetration_7=NA, tags_MagicPenetration_9=NA, tags_MagicPenetration_11=NA, tags_MagicPenetration_13=NA, tags_MagicPenetration_15=NA, tags_MagicPenetration_17=NA, tags_MagicPenetration_19=NA, tags_MagicPenetration_21=NA
, tags_Mana_3=NA, tags_Mana_5=NA, tags_Mana_7=NA, tags_Mana_9=NA, tags_Mana_11=NA, tags_Mana_13=NA, tags_Mana_15=NA, tags_Mana_17=NA, tags_Mana_19=NA, tags_Mana_21=NA
, tags_ManaRegen_3=NA, tags_ManaRegen_5=NA, tags_ManaRegen_7=NA, tags_ManaRegen_9=NA, tags_ManaRegen_11=NA, tags_ManaRegen_13=NA, tags_ManaRegen_15=NA, tags_ManaRegen_17=NA, tags_ManaRegen_19=NA, tags_ManaRegen_21=NA
, tags_Movement_3=NA, tags_Movement_5=NA, tags_Movement_7=NA, tags_Movement_9=NA, tags_Movement_11=NA, tags_Movement_13=NA, tags_Movement_15=NA, tags_Movement_17=NA, tags_Movement_19=NA, tags_Movement_21=NA
, tags_NonbootsMovement_3=NA, tags_NonbootsMovement_5=NA, tags_NonbootsMovement_7=NA, tags_NonbootsMovement_9=NA, tags_NonbootsMovement_11=NA, tags_NonbootsMovement_13=NA, tags_NonbootsMovement_15=NA, tags_NonbootsMovement_17=NA, tags_NonbootsMovement_19=NA, tags_NonbootsMovement_21=NA
, tags_OnHit_3=NA, tags_OnHit_5=NA, tags_OnHit_7=NA, tags_OnHit_9=NA, tags_OnHit_11=NA, tags_OnHit_13=NA, tags_OnHit_15=NA, tags_OnHit_17=NA, tags_OnHit_19=NA, tags_OnHit_21=NA
, tags_Slow_3=NA, tags_Slow_5=NA, tags_Slow_7=NA, tags_Slow_9=NA, tags_Slow_11=NA, tags_Slow_13=NA, tags_Slow_15=NA, tags_Slow_17=NA, tags_Slow_19=NA, tags_Slow_21=NA
, tags_SpellBlock_3=NA, tags_SpellBlock_5=NA, tags_SpellBlock_7=NA, tags_SpellBlock_9=NA, tags_SpellBlock_11=NA, tags_SpellBlock_13=NA, tags_SpellBlock_15=NA, tags_SpellBlock_17=NA, tags_SpellBlock_19=NA, tags_SpellBlock_21=NA
, tags_SpellDamage_3=NA, tags_SpellDamage_5=NA, tags_SpellDamage_7=NA, tags_SpellDamage_9=NA, tags_SpellDamage_11=NA, tags_SpellDamage_13=NA, tags_SpellDamage_15=NA, tags_SpellDamage_17=NA, tags_SpellDamage_19=NA, tags_SpellDamage_21=NA
, tags_SpellVamp_3=NA, tags_SpellVamp_5=NA, tags_SpellVamp_7=NA, tags_SpellVamp_9=NA, tags_SpellVamp_11=NA, tags_SpellVamp_13=NA, tags_SpellVamp_15=NA, tags_SpellVamp_17=NA, tags_SpellVamp_19=NA, tags_SpellVamp_21=NA
, tags_Stealth_3=NA, tags_Stealth_5=NA, tags_Stealth_7=NA, tags_Stealth_9=NA, tags_Stealth_11=NA, tags_Stealth_13=NA, tags_Stealth_15=NA, tags_Stealth_17=NA, tags_Stealth_19=NA, tags_Stealth_21=NA
, tags_Tenacity_3=NA, tags_Tenacity_5=NA, tags_Tenacity_7=NA, tags_Tenacity_9=NA, tags_Tenacity_11=NA, tags_Tenacity_13=NA, tags_Tenacity_15=NA, tags_Tenacity_17=NA, tags_Tenacity_19=NA, tags_Tenacity_21=NA
, tags_Trinket_3=NA, tags_Trinket_5=NA, tags_Trinket_7=NA, tags_Trinket_9=NA, tags_Trinket_11=NA, tags_Trinket_13=NA, tags_Trinket_15=NA, tags_Trinket_17=NA, tags_Trinket_19=NA, tags_Trinket_21=NA
, tags_Vision_3=NA, tags_Vision_5=NA, tags_Vision_7=NA, tags_Vision_9=NA, tags_Vision_11=NA, tags_Vision_13=NA, tags_Vision_15=NA, tags_Vision_17=NA, tags_Vision_19=NA, tags_Vision_21=NA
, FlatHPPoolMod_3=NA, FlatHPPoolMod_5=NA, FlatHPPoolMod_7=NA, FlatHPPoolMod_9=NA, FlatHPPoolMod_11=NA, FlatHPPoolMod_13=NA, FlatHPPoolMod_15=NA, FlatHPPoolMod_17=NA, FlatHPPoolMod_19=NA, FlatHPPoolMod_21=NA
, FlatMPPoolMod_3=NA, FlatMPPoolMod_5=NA, FlatMPPoolMod_7=NA, FlatMPPoolMod_9=NA, FlatMPPoolMod_11=NA, FlatMPPoolMod_13=NA, FlatMPPoolMod_15=NA, FlatMPPoolMod_17=NA, FlatMPPoolMod_19=NA, FlatMPPoolMod_21=NA
, PercentHPPoolMod_3=NA, PercentHPPoolMod_5=NA, PercentHPPoolMod_7=NA, PercentHPPoolMod_9=NA, PercentHPPoolMod_11=NA, PercentHPPoolMod_13=NA, PercentHPPoolMod_15=NA, PercentHPPoolMod_17=NA, PercentHPPoolMod_19=NA, PercentHPPoolMod_21=NA
, PercentMPPoolMod_3=NA, PercentMPPoolMod_5=NA, PercentMPPoolMod_7=NA, PercentMPPoolMod_9=NA, PercentMPPoolMod_11=NA, PercentMPPoolMod_13=NA, PercentMPPoolMod_15=NA, PercentMPPoolMod_17=NA, PercentMPPoolMod_19=NA, PercentMPPoolMod_21=NA
, FlatHPRegenMod_3=NA, FlatHPRegenMod_5=NA, FlatHPRegenMod_7=NA, FlatHPRegenMod_9=NA, FlatHPRegenMod_11=NA, FlatHPRegenMod_13=NA, FlatHPRegenMod_15=NA, FlatHPRegenMod_17=NA, FlatHPRegenMod_19=NA, FlatHPRegenMod_21=NA
, PercentHPRegenMod_3=NA, PercentHPRegenMod_5=NA, PercentHPRegenMod_7=NA, PercentHPRegenMod_9=NA, PercentHPRegenMod_11=NA, PercentHPRegenMod_13=NA, PercentHPRegenMod_15=NA, PercentHPRegenMod_17=NA, PercentHPRegenMod_19=NA, PercentHPRegenMod_21=NA
, FlatMPRegenMod_3=NA, FlatMPRegenMod_5=NA, FlatMPRegenMod_7=NA, FlatMPRegenMod_9=NA, FlatMPRegenMod_11=NA, FlatMPRegenMod_13=NA, FlatMPRegenMod_15=NA, FlatMPRegenMod_17=NA, FlatMPRegenMod_19=NA, FlatMPRegenMod_21=NA
, PercentMPRegenMod_3=NA, PercentMPRegenMod_5=NA, PercentMPRegenMod_7=NA, PercentMPRegenMod_9=NA, PercentMPRegenMod_11=NA, PercentMPRegenMod_13=NA, PercentMPRegenMod_15=NA, PercentMPRegenMod_17=NA, PercentMPRegenMod_19=NA, PercentMPRegenMod_21=NA
, FlatArmorMod_3=NA, FlatArmorMod_5=NA, FlatArmorMod_7=NA, FlatArmorMod_9=NA, FlatArmorMod_11=NA, FlatArmorMod_13=NA, FlatArmorMod_15=NA, FlatArmorMod_17=NA, FlatArmorMod_19=NA, FlatArmorMod_21=NA
, PercentArmorMod_3=NA, PercentArmorMod_5=NA, PercentArmorMod_7=NA, PercentArmorMod_9=NA, PercentArmorMod_11=NA, PercentArmorMod_13=NA, PercentArmorMod_15=NA, PercentArmorMod_17=NA, PercentArmorMod_19=NA, PercentArmorMod_21=NA
, FlatPhysicalDamageMod_3=NA, FlatPhysicalDamageMod_5=NA, FlatPhysicalDamageMod_7=NA, FlatPhysicalDamageMod_9=NA, FlatPhysicalDamageMod_11=NA, FlatPhysicalDamageMod_13=NA, FlatPhysicalDamageMod_15=NA, FlatPhysicalDamageMod_17=NA, FlatPhysicalDamageMod_19=NA, FlatPhysicalDamageMod_21=NA
, PercentPhysicalDamageMod_3=NA, PercentPhysicalDamageMod_5=NA, PercentPhysicalDamageMod_7=NA, PercentPhysicalDamageMod_9=NA, PercentPhysicalDamageMod_11=NA, PercentPhysicalDamageMod_13=NA, PercentPhysicalDamageMod_15=NA, PercentPhysicalDamageMod_17=NA, PercentPhysicalDamageMod_19=NA, PercentPhysicalDamageMod_21=NA
, FlatMagicDamageMod_3=NA, FlatMagicDamageMod_5=NA, FlatMagicDamageMod_7=NA, FlatMagicDamageMod_9=NA, FlatMagicDamageMod_11=NA, FlatMagicDamageMod_13=NA, FlatMagicDamageMod_15=NA, FlatMagicDamageMod_17=NA, FlatMagicDamageMod_19=NA, FlatMagicDamageMod_21=NA
, PercentMagicDamageMod_3=NA, PercentMagicDamageMod_5=NA, PercentMagicDamageMod_7=NA, PercentMagicDamageMod_9=NA, PercentMagicDamageMod_11=NA, PercentMagicDamageMod_13=NA, PercentMagicDamageMod_15=NA, PercentMagicDamageMod_17=NA, PercentMagicDamageMod_19=NA, PercentMagicDamageMod_21=NA
, FlatMovementSpeedMod_3=NA, FlatMovementSpeedMod_5=NA, FlatMovementSpeedMod_7=NA, FlatMovementSpeedMod_9=NA, FlatMovementSpeedMod_11=NA, FlatMovementSpeedMod_13=NA, FlatMovementSpeedMod_15=NA, FlatMovementSpeedMod_17=NA, FlatMovementSpeedMod_19=NA, FlatMovementSpeedMod_21=NA
, PercentMovementSpeedMod_3=NA, PercentMovementSpeedMod_5=NA, PercentMovementSpeedMod_7=NA, PercentMovementSpeedMod_9=NA, PercentMovementSpeedMod_11=NA, PercentMovementSpeedMod_13=NA, PercentMovementSpeedMod_15=NA, PercentMovementSpeedMod_17=NA, PercentMovementSpeedMod_19=NA, PercentMovementSpeedMod_21=NA
, FlatAttackSpeedMod_3=NA, FlatAttackSpeedMod_5=NA, FlatAttackSpeedMod_7=NA, FlatAttackSpeedMod_9=NA, FlatAttackSpeedMod_11=NA, FlatAttackSpeedMod_13=NA, FlatAttackSpeedMod_15=NA, FlatAttackSpeedMod_17=NA, FlatAttackSpeedMod_19=NA, FlatAttackSpeedMod_21=NA
, PercentAttackSpeedMod_3=NA, PercentAttackSpeedMod_5=NA, PercentAttackSpeedMod_7=NA, PercentAttackSpeedMod_9=NA, PercentAttackSpeedMod_11=NA, PercentAttackSpeedMod_13=NA, PercentAttackSpeedMod_15=NA, PercentAttackSpeedMod_17=NA, PercentAttackSpeedMod_19=NA, PercentAttackSpeedMod_21=NA
, PercentDodgeMod_3=NA, PercentDodgeMod_5=NA, PercentDodgeMod_7=NA, PercentDodgeMod_9=NA, PercentDodgeMod_11=NA, PercentDodgeMod_13=NA, PercentDodgeMod_15=NA, PercentDodgeMod_17=NA, PercentDodgeMod_19=NA, PercentDodgeMod_21=NA
, FlatCritChanceMod_3=NA, FlatCritChanceMod_5=NA, FlatCritChanceMod_7=NA, FlatCritChanceMod_9=NA, FlatCritChanceMod_11=NA, FlatCritChanceMod_13=NA, FlatCritChanceMod_15=NA, FlatCritChanceMod_17=NA, FlatCritChanceMod_19=NA, FlatCritChanceMod_21=NA
, PercentCritChanceMod_3=NA, PercentCritChanceMod_5=NA, PercentCritChanceMod_7=NA, PercentCritChanceMod_9=NA, PercentCritChanceMod_11=NA, PercentCritChanceMod_13=NA, PercentCritChanceMod_15=NA, PercentCritChanceMod_17=NA, PercentCritChanceMod_19=NA, PercentCritChanceMod_21=NA
, FlatCritDamageMod_3=NA, FlatCritDamageMod_5=NA, FlatCritDamageMod_7=NA, FlatCritDamageMod_9=NA, FlatCritDamageMod_11=NA, FlatCritDamageMod_13=NA, FlatCritDamageMod_15=NA, FlatCritDamageMod_17=NA, FlatCritDamageMod_19=NA, FlatCritDamageMod_21=NA
, PercentCritDamageMod_3=NA, PercentCritDamageMod_5=NA, PercentCritDamageMod_7=NA, PercentCritDamageMod_9=NA, PercentCritDamageMod_11=NA, PercentCritDamageMod_13=NA, PercentCritDamageMod_15=NA, PercentCritDamageMod_17=NA, PercentCritDamageMod_19=NA, PercentCritDamageMod_21=NA
, FlatBlockMod_3=NA, FlatBlockMod_5=NA, FlatBlockMod_7=NA, FlatBlockMod_9=NA, FlatBlockMod_11=NA, FlatBlockMod_13=NA, FlatBlockMod_15=NA, FlatBlockMod_17=NA, FlatBlockMod_19=NA, FlatBlockMod_21=NA
, PercentBlockMod_3=NA, PercentBlockMod_5=NA, PercentBlockMod_7=NA, PercentBlockMod_9=NA, PercentBlockMod_11=NA, PercentBlockMod_13=NA, PercentBlockMod_15=NA, PercentBlockMod_17=NA, PercentBlockMod_19=NA, PercentBlockMod_21=NA
, FlatSpellBlockMod_3=NA, FlatSpellBlockMod_5=NA, FlatSpellBlockMod_7=NA, FlatSpellBlockMod_9=NA, FlatSpellBlockMod_11=NA, FlatSpellBlockMod_13=NA, FlatSpellBlockMod_15=NA, FlatSpellBlockMod_17=NA, FlatSpellBlockMod_19=NA, FlatSpellBlockMod_21=NA
, PercentSpellBlockMod_3=NA, PercentSpellBlockMod_5=NA, PercentSpellBlockMod_7=NA, PercentSpellBlockMod_9=NA, PercentSpellBlockMod_11=NA, PercentSpellBlockMod_13=NA, PercentSpellBlockMod_15=NA, PercentSpellBlockMod_17=NA, PercentSpellBlockMod_19=NA, PercentSpellBlockMod_21=NA
, FlatEXPBonus_3=NA, FlatEXPBonus_5=NA, FlatEXPBonus_7=NA, FlatEXPBonus_9=NA, FlatEXPBonus_11=NA, FlatEXPBonus_13=NA, FlatEXPBonus_15=NA, FlatEXPBonus_17=NA, FlatEXPBonus_19=NA, FlatEXPBonus_21=NA
, FlatEnergyRegenMod_3=NA, FlatEnergyRegenMod_5=NA, FlatEnergyRegenMod_7=NA, FlatEnergyRegenMod_9=NA, FlatEnergyRegenMod_11=NA, FlatEnergyRegenMod_13=NA, FlatEnergyRegenMod_15=NA, FlatEnergyRegenMod_17=NA, FlatEnergyRegenMod_19=NA, FlatEnergyRegenMod_21=NA
, FlatEnergyPoolMod_3=NA, FlatEnergyPoolMod_5=NA, FlatEnergyPoolMod_7=NA, FlatEnergyPoolMod_9=NA, FlatEnergyPoolMod_11=NA, FlatEnergyPoolMod_13=NA, FlatEnergyPoolMod_15=NA, FlatEnergyPoolMod_17=NA, FlatEnergyPoolMod_19=NA, FlatEnergyPoolMod_21=NA
, PercentLifeStealMod_3=NA, PercentLifeStealMod_5=NA, PercentLifeStealMod_7=NA, PercentLifeStealMod_9=NA, PercentLifeStealMod_11=NA, PercentLifeStealMod_13=NA, PercentLifeStealMod_15=NA, PercentLifeStealMod_17=NA, PercentLifeStealMod_19=NA, PercentLifeStealMod_21=NA
, PercentSpellVampMod_3=NA, PercentSpellVampMod_5=NA, PercentSpellVampMod_7=NA, PercentSpellVampMod_9=NA, PercentSpellVampMod_11=NA, PercentSpellVampMod_13=NA, PercentSpellVampMod_15=NA, PercentSpellVampMod_17=NA, PercentSpellVampMod_19=NA, PercentSpellVampMod_21=NA
, currentGold_3=NA, currentGold_5=NA, currentGold_7=NA, currentGold_9=NA, currentGold_11=NA, currentGold_13=NA, currentGold_15=NA, currentGold_17=NA, currentGold_19=NA, currentGold_21=NA
, totalGold_3=NA, totalGold_5=NA, totalGold_7=NA, totalGold_9=NA, totalGold_11=NA, totalGold_13=NA, totalGold_15=NA, totalGold_17=NA, totalGold_19=NA, totalGold_21=NA
, level_3=NA, level_5=NA, level_7=NA, level_9=NA, level_11=NA, level_13=NA, level_15=NA, level_17=NA, level_19=NA, level_21=NA
, xp_3=NA, xp_5=NA, xp_7=NA, xp_9=NA, xp_11=NA, xp_13=NA, xp_15=NA, xp_17=NA, xp_19=NA, xp_21=NA
, minionsKilled_3=NA, minionsKilled_5=NA, minionsKilled_7=NA, minionsKilled_9=NA, minionsKilled_11=NA, minionsKilled_13=NA, minionsKilled_15=NA, minionsKilled_17=NA, minionsKilled_19=NA, minionsKilled_21=NA
, jungleMinionsKilled_3=NA, jungleMinionsKilled_5=NA, jungleMinionsKilled_7=NA, jungleMinionsKilled_9=NA, jungleMinionsKilled_11=NA, jungleMinionsKilled_13=NA, jungleMinionsKilled_15=NA, jungleMinionsKilled_17=NA, jungleMinionsKilled_19=NA, jungleMinionsKilled_21=NA
, dominionScore_3=NA, dominionScore_5=NA, dominionScore_7=NA, dominionScore_9=NA, dominionScore_11=NA, dominionScore_13=NA, dominionScore_15=NA, dominionScore_17=NA, dominionScore_19=NA, dominionScore_21=NA
, teamScore_3=NA, teamScore_5=NA, teamScore_7=NA, teamScore_9=NA, teamScore_11=NA, teamScore_13=NA, teamScore_15=NA, teamScore_17=NA, teamScore_19=NA, teamScore_21=NA)

j<-startRank 	# rank pointer also row number in the new table
b<-0 	# carry on the row number
# each gameId has a rank. Loop through each gameId
for (j in startRank:(startRank+batchSize-1))
	{		
		x<-1 	# participantId pointer. Can be from 1 to <=10
		for (x in 1:DT[DT$rank==j,max(participantId)])
		#for (x in 1:1)
			{
				# gameId level columns
				transposeTable[b+x,1]<-DT[DT$rank==j,max(gameId,na.rm=TRUE)] 	# gameId
				transposeTable[b+x,2]<-DT[DT$rank==j,max(version,na.rm=TRUE)]  	# version
				transposeTable[b+x,3]<-x 		# participantId
				transposeTable[b+x,4]<-j 		# rank
				transposeTable[b+x,5]<-DT[DT$rank==j&DT$participantId==x,max(win,na.rm=TRUE)] # win
				transposeTable[b+x,6]<-DT[DT$rank==j,max(gameMinutes,na.rm=TRUE)] # gameMinutes
				transposeTable[b+x,7]<-DT[DT$rank==j,max(gameMode,na.rm=TRUE)] # gameMode
				transposeTable[b+x,8]<-DT[DT$rank==j,max(gameType,na.rm=TRUE)] # gameType
				transposeTable[b+x,9]<-DT[DT$rank==j,max(seasonId,na.rm=TRUE)] # seasonId
				# participantId level columns
				transposeTable[b+x,10]<-DT[DT$rank==j&DT$participantId==x,max(championId,na.rm=TRUE)] 	# championId
				transposeTable[b+x,11]<-DT[DT$rank==j&DT$participantId==x,max(spell1Id,na.rm=TRUE)] 	# spell1Id
				transposeTable[b+x,12]<-DT[DT$rank==j&DT$participantId==x,max(spell2Id,na.rm=TRUE)] 	# spell2Id
				transposeTable[b+x,13]<-DT[DT$rank==j&DT$participantId==x,max(highestAchievedSeasonTier,na.rm=TRUE)] 	# highestAchievedSeasonTier
				transposeTable[b+x,14]<-DT[DT$rank==j&DT$participantId==x,max(role,na.rm=TRUE)] 	# role
				transposeTable[b+x,15]<-DT[DT$rank==j&DT$participantId==x,max(lane,na.rm=TRUE)]  	# lane
				transposeTable[b+x,16]<-DT[DT$rank==j&DT$participantId==x,max(masteryId1,na.rm=TRUE)]     #  masteryId1
				transposeTable[b+x,17]<-DT[DT$rank==j&DT$participantId==x,max(mrank1,na.rm=TRUE)]     #  mrank1
				transposeTable[b+x,18]<-DT[DT$rank==j&DT$participantId==x,max(masteryId2,na.rm=TRUE)]     #  masteryId2
				transposeTable[b+x,19]<-DT[DT$rank==j&DT$participantId==x,max(mrank2,na.rm=TRUE)]     #  mrank2
				transposeTable[b+x,20]<-DT[DT$rank==j&DT$participantId==x,max(masteryId3,na.rm=TRUE)]     #  masteryId3
				transposeTable[b+x,21]<-DT[DT$rank==j&DT$participantId==x,max(mrank3,na.rm=TRUE)]     #  mrank3
				transposeTable[b+x,22]<-DT[DT$rank==j&DT$participantId==x,max(masteryId4,na.rm=TRUE)]     #  masteryId4
				transposeTable[b+x,23]<-DT[DT$rank==j&DT$participantId==x,max(mrank4,na.rm=TRUE)]     #  mrank4
				transposeTable[b+x,24]<-DT[DT$rank==j&DT$participantId==x,max(masteryId5,na.rm=TRUE)]     #  masteryId5
				transposeTable[b+x,25]<-DT[DT$rank==j&DT$participantId==x,max(mrank5,na.rm=TRUE)]     #  mrank5
				transposeTable[b+x,26]<-DT[DT$rank==j&DT$participantId==x,max(masteryId6,na.rm=TRUE)]     #  masteryId6
				transposeTable[b+x,27]<-DT[DT$rank==j&DT$participantId==x,max(mrank6,na.rm=TRUE)]     #  mrank6
				transposeTable[b+x,28]<-DT[DT$rank==j&DT$participantId==x,max(masteryId7,na.rm=TRUE)]     #  masteryId7
				transposeTable[b+x,29]<-DT[DT$rank==j&DT$participantId==x,max(mrank7,na.rm=TRUE)]     #  mrank7
				transposeTable[b+x,30]<-DT[DT$rank==j&DT$participantId==x,max(masteryId8,na.rm=TRUE)]     #  masteryId8
				transposeTable[b+x,31]<-DT[DT$rank==j&DT$participantId==x,max(mrank8,na.rm=TRUE)]     #  mrank8
				transposeTable[b+x,32]<-DT[DT$rank==j&DT$participantId==x,max(masteryId9,na.rm=TRUE)]     #  masteryId9
				transposeTable[b+x,33]<-DT[DT$rank==j&DT$participantId==x,max(mrank9,na.rm=TRUE)]     #  mrank9
				transposeTable[b+x,34]<-DT[DT$rank==j&DT$participantId==x,max(masteryId10,na.rm=TRUE)]     #  masteryId10
				transposeTable[b+x,35]<-DT[DT$rank==j&DT$participantId==x,max(mrank10,na.rm=TRUE)]     #  mrank10
				transposeTable[b+x,36]<-DT[DT$rank==j&DT$participantId==x,max(masteryId11,na.rm=TRUE)]     #  masteryId11
				transposeTable[b+x,37]<-DT[DT$rank==j&DT$participantId==x,max(mrank11,na.rm=TRUE)]     #  mrank11
				transposeTable[b+x,38]<-DT[DT$rank==j&DT$participantId==x,max(masteryId12,na.rm=TRUE)]     #  masteryId12
				transposeTable[b+x,39]<-DT[DT$rank==j&DT$participantId==x,max(mrank12,na.rm=TRUE)]     #  mrank12
				transposeTable[b+x,40]<-DT[DT$rank==j&DT$participantId==x,max(masteryId13,na.rm=TRUE)]     #  masteryId13
				transposeTable[b+x,41]<-DT[DT$rank==j&DT$participantId==x,max(mrank13,na.rm=TRUE)]     #  mrank13
				transposeTable[b+x,42]<-DT[DT$rank==j&DT$participantId==x,max(masteryId14,na.rm=TRUE)]     #  masteryId14
				transposeTable[b+x,43]<-DT[DT$rank==j&DT$participantId==x,max(mrank14,na.rm=TRUE)]     #  mrank14
				transposeTable[b+x,44]<-DT[DT$rank==j&DT$participantId==x,max(masteryId15,na.rm=TRUE)]     #  masteryId15
				transposeTable[b+x,45]<-DT[DT$rank==j&DT$participantId==x,max(mrank15,na.rm=TRUE)]     #  mrank15
				transposeTable[b+x,46]<-DT[DT$rank==j&DT$participantId==x,max(masteryId16,na.rm=TRUE)]     #  masteryId16
				transposeTable[b+x,47]<-DT[DT$rank==j&DT$participantId==x,max(mrank16,na.rm=TRUE)]     #  mrank16
				transposeTable[b+x,48]<-DT[DT$rank==j&DT$participantId==x,max(masteryId17,na.rm=TRUE)]     #  masteryId17
				transposeTable[b+x,49]<-DT[DT$rank==j&DT$participantId==x,max(mrank17,na.rm=TRUE)]     #  mrank17
				transposeTable[b+x,50]<-DT[DT$rank==j&DT$participantId==x,max(masteryId18,na.rm=TRUE)]     #  masteryId18
				transposeTable[b+x,51]<-DT[DT$rank==j&DT$participantId==x,max(mrank18,na.rm=TRUE)]     #  mrank18
				transposeTable[b+x,52]<-DT[DT$rank==j&DT$participantId==x,max(masteryId19,na.rm=TRUE)]     #  masteryId19
				transposeTable[b+x,53]<-DT[DT$rank==j&DT$participantId==x,max(mrank19,na.rm=TRUE)]     #  mrank19
				transposeTable[b+x,54]<-DT[DT$rank==j&DT$participantId==x,max(masteryId20,na.rm=TRUE)]     #  masteryId20
				transposeTable[b+x,55]<-DT[DT$rank==j&DT$participantId==x,max(mrank20,na.rm=TRUE)]     #  mrank20
				transposeTable[b+x,56]<-DT[DT$rank==j&DT$participantId==x,max(runeId1,na.rm=TRUE)]     #  runeId1
				transposeTable[b+x,57]<-DT[DT$rank==j&DT$participantId==x,max(rrank1,na.rm=TRUE)]     #  rrank1
				transposeTable[b+x,58]<-DT[DT$rank==j&DT$participantId==x,max(runeId2,na.rm=TRUE)]     #  runeId2
				transposeTable[b+x,59]<-DT[DT$rank==j&DT$participantId==x,max(rrank2,na.rm=TRUE)]     #  rrank2
				transposeTable[b+x,60]<-DT[DT$rank==j&DT$participantId==x,max(runeId3,na.rm=TRUE)]     #  runeId3
				transposeTable[b+x,61]<-DT[DT$rank==j&DT$participantId==x,max(rrank3,na.rm=TRUE)]     #  rrank3
				transposeTable[b+x,62]<-DT[DT$rank==j&DT$participantId==x,max(runeId4,na.rm=TRUE)]     #  runeId4
				transposeTable[b+x,63]<-DT[DT$rank==j&DT$participantId==x,max(rrank4,na.rm=TRUE)]     #  rrank4
				transposeTable[b+x,64]<-DT[DT$rank==j&DT$participantId==x,max(runeId5,na.rm=TRUE)]     #  runeId5
				transposeTable[b+x,65]<-DT[DT$rank==j&DT$participantId==x,max(rrank5,na.rm=TRUE)]     #  rrank5
				transposeTable[b+x,66]<-DT[DT$rank==j&DT$participantId==x,max(runeId6,na.rm=TRUE)]     #  runeId6
				transposeTable[b+x,67]<-DT[DT$rank==j&DT$participantId==x,max(rrank6,na.rm=TRUE)]     #  rrank6
				transposeTable[b+x,68]<-DT[DT$rank==j&DT$participantId==x,max(runeId7,na.rm=TRUE)]     #  runeId7
				transposeTable[b+x,69]<-DT[DT$rank==j&DT$participantId==x,max(rrank7,na.rm=TRUE)]     #  rrank7
				transposeTable[b+x,70]<-DT[DT$rank==j&DT$participantId==x,max(runeId8,na.rm=TRUE)]     #  runeId8
				transposeTable[b+x,71]<-DT[DT$rank==j&DT$participantId==x,max(rrank8,na.rm=TRUE)]     #  rrank8
				transposeTable[b+x,72]<-DT[DT$rank==j&DT$participantId==x,max(runeId9,na.rm=TRUE)]     #  runeId9
				transposeTable[b+x,73]<-DT[DT$rank==j&DT$participantId==x,max(rrank9,na.rm=TRUE)]     #  rrank9
				transposeTable[b+x,74]<-DT[DT$rank==j&DT$participantId==x,max(runeId10,na.rm=TRUE)]     #  runeId10
				transposeTable[b+x,75]<-DT[DT$rank==j&DT$participantId==x,max(rrank10,na.rm=TRUE)]     #  rrank10


			#	batchTable<-batchTable[-79]	# drop variable participantId

				i<-76 	# column pointer - batchTable

				# populate each column
				for (i in 76:(ncol(batchTable)-1)) # the batchTable. Don't count the last column rank.
			#	for (i in 4:4)
				{
					k<-3 	# frame pointer
					a<-(i-76)*10+75	# column accumulator - transposeTable. Not all games last more than 21 frames
					
					# aggregated each 2 frames of each participantId in a gameId
					# we only look at <=20 frames
					for (k in seq(from=3,to=21,by=2))	# the frame should start from 2 as frame = 1 is the 0min
				
					#for (k in c(3:5:7))
						{
							colName<-colnames(batchTable)[i] # <- added 1 column in both batchTable and transposeTable. Need to adjust the numbers here
							if (!(i %in% c(89:92,158:165)))	# those columns aggregated in other ways other than sum					
								transposeTable[b+x,a+k%/%2]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","sum(as.numeric(",colName,"),na.rm=TRUE)]")))
							if (i %in% c(159:165))  # level needs to take the max
								transposeTable[b+x,a+k%/%2]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","max(as.numeric(",colName,"),na.rm=TRUE)]")))
							if (i %in% c(89:92,158)) # need to be avg
								transposeTable[b+x,a+k%/%2]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","mean(as.numeric(",colName,"),na.rm=TRUE)]")))
						#	if (i %in% c(128,129,131,133,135,137,139,141,143,144,146,148,150,152,154,156,157)) 	# need to be multiplied
						#		transposeTable[b+x,a+k%/%2]<-eval(parse(text=paste0("DT[DT$participantFrames>=",k-1,"&DT$participantFrames<=",k,"&DT$participantId==",x,"&DT$rank==",j,",","prod(as.numeric(",colName,"),na.rm=TRUE)]")))
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


# read a sql file as a string
read_sql<-function(path)
{
  if (file.exists(path))
    sql<-readChar(path,nchar= file.info(path)$size)
  else sql<-NA
  return(sql)
}

# make sure the script can automatically run through multiple tables
runMultiTables<-function()
	{
		con<-dbConnect(MySQL(),user='hanmei',password='3322439',db='lol',host='127.0.0.1')
		nameDateList<-c("150528","150529","150530","150531","150601","150602","150605","150606","150607","150608","150609"
					,"150610","150611","150612","150613","150614")
		exist<-dbGetQuery(con,"show tables from lol like 'participant_rollup_%'")
		
		if (nrow(exist)==1) 	# initialise the 1st transposed table
		{
			nameDate<-"150528"
			startRank<-1
			timelineToParticipant(startRank,1,nameDate)	 # get the 1st gameId and setup unique index
			sql<-read_sql("/src/lol/SQL/99-1-uniqueIndex_TransParticipant") 	# add unique index on gameIdParticipantId, set rank to be int
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
					sql<-read_sql("/src/lol/SQL/99-1-uniqueIndex_TransParticipant") 	# add unique index on gameIdParticipantId, set rank to be int
					sql<-gsub("nameDate",nameDate,sql)
					dbSendQuery(con,sql)
					timelineToParticipant(startRank+1,100,nameDate)
					
				}
		}
		
		dbDisconnect(con)
	
	}

runMultiTables()


