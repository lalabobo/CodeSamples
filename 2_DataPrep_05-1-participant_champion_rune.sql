/* read in by 04-attachChamp_Rune.R
attach runes to participant_champion
# notice that percentage should be added up not multiply as it's how it is handled in game.
#drop table if exists lol.participant_champion_rune_nameDate_next;*/
create table lol.participant_champion_rune_nameDate_next as
select 
/* list the columns from table a*/
gameId,a.version,participantId,`rank`,win
,gameCount,gameMinutes,gameMode,gameType,mapId
,seasonId,championId,spell1Id,spell2Id,highestAchievedSeasonTier,role,lane
,masteryId1,mrank1,masteryId2,mrank2,masteryId3,mrank3
,masteryId4,mrank4,masteryId5,mrank5,masteryId6,mrank6
,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12
,masteryId13,mrank13,masteryId14,mrank14,masteryId15,mrank15
,masteryId16,mrank16,masteryId17,mrank17,masteryId18,mrank18
,masteryId19,mrank19,masteryId20,mrank20
/* do in a loop to join these to rune table and aggregate to item attributes*/
,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3
,runeId4,rrank4,runeId5,rrank5,runeId6,rrank6
,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9
,runeId10,rrank10

/* item purchahsed type*/
,tags_Active_4,tags_Active_7,tags_Active_10,tags_Active_13,tags_Active_16
,tags_Active_19,tags_Active_22,tags_Active_25,tags_Active_28,tags_Active_31
,tags_Armor_4,tags_Armor_7,tags_Armor_10,tags_Armor_13,tags_Armor_16
,tags_Armor_19,tags_Armor_22,tags_Armor_25,tags_Armor_28,tags_Armor_31
,tags_ArmorPenetration_4,tags_ArmorPenetration_7,tags_ArmorPenetration_10,tags_ArmorPenetration_13,tags_ArmorPenetration_16
,tags_ArmorPenetration_19,tags_ArmorPenetration_22,tags_ArmorPenetration_25,tags_ArmorPenetration_28,tags_ArmorPenetration_31
,tags_AttackSpeed_4,tags_AttackSpeed_7,tags_AttackSpeed_10,tags_AttackSpeed_13,tags_AttackSpeed_16
,tags_AttackSpeed_19,tags_AttackSpeed_22,tags_AttackSpeed_25,tags_AttackSpeed_28,tags_AttackSpeed_31
,tags_Aura_4,tags_Aura_7,tags_Aura_10,tags_Aura_13,tags_Aura_16
,tags_Aura_19,tags_Aura_22,tags_Aura_25,tags_Aura_28,tags_Aura_31
,tags_Boots_4,tags_Boots_7,tags_Boots_10,tags_Boots_13,tags_Boots_16
,tags_Boots_19,tags_Boots_22,tags_Boots_25,tags_Boots_28,tags_Boots_31
,tags_Consumable_4,tags_Consumable_7,tags_Consumable_10,tags_Consumable_13,tags_Consumable_16
,tags_Consumable_19,tags_Consumable_22,tags_Consumable_25,tags_Consumable_28,tags_Consumable_31
,tags_CooldownReduction_4,tags_CooldownReduction_7,tags_CooldownReduction_10,tags_CooldownReduction_13,tags_CooldownReduction_16
,tags_CooldownReduction_19,tags_CooldownReduction_22,tags_CooldownReduction_25,tags_CooldownReduction_28,tags_CooldownReduction_31
,tags_CriticalStrike_4,tags_CriticalStrike_7,tags_CriticalStrike_10,tags_CriticalStrike_13,tags_CriticalStrike_16
,tags_CriticalStrike_19,tags_CriticalStrike_22,tags_CriticalStrike_25,tags_CriticalStrike_28,tags_CriticalStrike_31
,tags_Damage_4,tags_Damage_7,tags_Damage_10,tags_Damage_13,tags_Damage_16
,tags_Damage_19,tags_Damage_22,tags_Damage_25,tags_Damage_28,tags_Damage_31
,tags_GoldPer_4,tags_GoldPer_7,tags_GoldPer_10,tags_GoldPer_13,tags_GoldPer_16
,tags_GoldPer_19,tags_GoldPer_22,tags_GoldPer_25,tags_GoldPer_28,tags_GoldPer_31
,tags_Health_4,tags_Health_7,tags_Health_10,tags_Health_13,tags_Health_16
,tags_Health_19,tags_Health_22,tags_Health_25,tags_Health_28,tags_Health_31
,tags_HealthRegen_4,tags_HealthRegen_7,tags_HealthRegen_10,tags_HealthRegen_13,tags_HealthRegen_16
,tags_HealthRegen_19,tags_HealthRegen_22,tags_HealthRegen_25,tags_HealthRegen_28,tags_HealthRegen_31
,tags_Jungle_4,tags_Jungle_7,tags_Jungle_10,tags_Jungle_13,tags_Jungle_16
,tags_Jungle_19,tags_Jungle_22,tags_Jungle_25,tags_Jungle_28,tags_Jungle_31
,tags_Lane_4,tags_Lane_7,tags_Lane_10,tags_Lane_13,tags_Lane_16
,tags_Lane_19,tags_Lane_22,tags_Lane_25,tags_Lane_28,tags_Lane_31
,tags_LifeSteal_4,tags_LifeSteal_7,tags_LifeSteal_10,tags_LifeSteal_13,tags_LifeSteal_16
,tags_LifeSteal_19,tags_LifeSteal_22,tags_LifeSteal_25,tags_LifeSteal_28,tags_LifeSteal_31
,tags_MagicPenetration_4,tags_MagicPenetration_7,tags_MagicPenetration_10,tags_MagicPenetration_13,tags_MagicPenetration_16
,tags_MagicPenetration_19,tags_MagicPenetration_22,tags_MagicPenetration_25,tags_MagicPenetration_28,tags_MagicPenetration_31
,tags_Mana_4,tags_Mana_7,tags_Mana_10,tags_Mana_13,tags_Mana_16
,tags_Mana_19,tags_Mana_22,tags_Mana_25,tags_Mana_28,tags_Mana_31
,tags_ManaRegen_4,tags_ManaRegen_7,tags_ManaRegen_10,tags_ManaRegen_13,tags_ManaRegen_16
,tags_ManaRegen_19,tags_ManaRegen_22,tags_ManaRegen_25,tags_ManaRegen_28,tags_ManaRegen_31
,tags_Movement_4,tags_Movement_7,tags_Movement_10,tags_Movement_13,tags_Movement_16
,tags_Movement_19,tags_Movement_22,tags_Movement_25,tags_Movement_28,tags_Movement_31
,tags_NonbootsMovement_4,tags_NonbootsMovement_7,tags_NonbootsMovement_10,tags_NonbootsMovement_13,tags_NonbootsMovement_16
,tags_NonbootsMovement_19,tags_NonbootsMovement_22,tags_NonbootsMovement_25,tags_NonbootsMovement_28,tags_NonbootsMovement_31
,tags_OnHit_4,tags_OnHit_7,tags_OnHit_10,tags_OnHit_13,tags_OnHit_16
,tags_OnHit_19,tags_OnHit_22,tags_OnHit_25,tags_OnHit_28,tags_OnHit_31
,tags_Slow_4,tags_Slow_7,tags_Slow_10,tags_Slow_13,tags_Slow_16
,tags_Slow_19,tags_Slow_22,tags_Slow_25,tags_Slow_28,tags_Slow_31
,tags_SpellBlock_4,tags_SpellBlock_7,tags_SpellBlock_10,tags_SpellBlock_13,tags_SpellBlock_16
,tags_SpellBlock_19,tags_SpellBlock_22,tags_SpellBlock_25,tags_SpellBlock_28,tags_SpellBlock_31
,tags_SpellDamage_4,tags_SpellDamage_7,tags_SpellDamage_10,tags_SpellDamage_13,tags_SpellDamage_16
,tags_SpellDamage_19,tags_SpellDamage_22,tags_SpellDamage_25,tags_SpellDamage_28,tags_SpellDamage_31
,tags_SpellVamp_4,tags_SpellVamp_7,tags_SpellVamp_10,tags_SpellVamp_13,tags_SpellVamp_16
,tags_SpellVamp_19,tags_SpellVamp_22,tags_SpellVamp_25,tags_SpellVamp_28,tags_SpellVamp_31
,tags_Stealth_4,tags_Stealth_7,tags_Stealth_10,tags_Stealth_13,tags_Stealth_16
,tags_Stealth_19,tags_Stealth_22,tags_Stealth_25,tags_Stealth_28,tags_Stealth_31
,tags_Tenacity_4,tags_Tenacity_7,tags_Tenacity_10,tags_Tenacity_13,tags_Tenacity_16
,tags_Tenacity_19,tags_Tenacity_22,tags_Tenacity_25,tags_Tenacity_28,tags_Tenacity_31
,tags_Trinket_4,tags_Trinket_7,tags_Trinket_10,tags_Trinket_13,tags_Trinket_16
,tags_Trinket_19,tags_Trinket_22,tags_Trinket_25,tags_Trinket_28,tags_Trinket_31
,tags_Vision_4,tags_Vision_7,tags_Vision_10,tags_Vision_13,tags_Vision_16
,tags_Vision_19,tags_Vision_22,tags_Vision_25,tags_Vision_28,tags_Vision_31


/* moved the columns at the end forward*/
,currentGold_4,currentGold_7,currentGold_10,currentGold_13,currentGold_16
,currentGold_19,currentGold_22,currentGold_25,currentGold_28,currentGold_31
,totalGold_4,totalGold_7,totalGold_10,totalGold_13,totalGold_16
,totalGold_19,totalGold_22,totalGold_25,totalGold_28,totalGold_31
,level_4,level_7,level_10,level_13,level_16
,level_19,level_22,level_25,level_28,level_31
,xp_4,xp_7,xp_10,xp_13,xp_16
,xp_19,xp_22,xp_25,xp_28,xp_31
,minionsKilled_4,minionsKilled_7,minionsKilled_10,minionsKilled_13,minionsKilled_16
,minionsKilled_19,minionsKilled_22,minionsKilled_25,minionsKilled_28,minionsKilled_31
,jungleMinionsKilled_4,jungleMinionsKilled_7,jungleMinionsKilled_10,jungleMinionsKilled_13,jungleMinionsKilled_16
,jungleMinionsKilled_19,jungleMinionsKilled_22,jungleMinionsKilled_25,jungleMinionsKilled_28,jungleMinionsKilled_31


,case when runeId1 is null or runeId1=0 then 0 else 1 end as hasRune /* if a player has runes in the game*/
/* ,Name as Rune_Name*/
,tier as runeIdNum_tier /* used to be  Rune_tier_num*/
,type as runeIdNum_type   /* used to be Rune_type_1*/
,Tags as runeIdNum_tags    /* used to be  Rune_tags_1*/

/* champion variables*/
, Champ_Name, Champ_Attack, Champ_Defense, Champ_Magic, Champ_Difficulty, Champ_Tags
, Champ_parType, Champ_HP, Champ_HPperLevel, Champ_MP, Champ_MPperLevel, Champ_MoveSpeed
, Champ_Armor, Champ_ArmorPerLevel, Champ_SpellBlock, Champ_SpellBlockPerLevel
, Champ_AttackRange, Champ_HPregen, Champ_HPregenPerLevel, Champ_MPregen, Champ_MPregenPerLevel
, Champ_Crit, Champ_CritPerLevel, Champ_AttackDamage, Champ_AttackDamagePerLevel
, Champ_AttackSpeedOffset, Champ_AttackSpeedPerLevel

/* item base+rune -------------------------------------*/
/* in the trial, Percent~_num already has 1 in it. In the office one, we will need to add 1 in the percent calculation*/
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_4+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatHPPoolMod_4
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_4=0 then 1 else PercentHPPoolMod_4 end) as PercentHPPoolMod_4
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_7+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatHPPoolMod_7
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_7=0 then 1 else PercentHPPoolMod_7 end) as PercentHPPoolMod_7
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_10+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatHPPoolMod_10
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_10=0 then 1 else PercentHPPoolMod_10 end) as PercentHPPoolMod_10
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_13+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatHPPoolMod_13
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_13=0 then 1 else PercentHPPoolMod_13 end) as PercentHPPoolMod_13
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_16+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatHPPoolMod_16
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_16=0 then 1 else PercentHPPoolMod_16 end) as PercentHPPoolMod_16
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_19+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatHPPoolMod_19
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_19=0 then 1 else PercentHPPoolMod_19 end) as PercentHPPoolMod_19
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_22+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatHPPoolMod_22
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_22=0 then 1 else PercentHPPoolMod_22 end) as PercentHPPoolMod_22
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_25+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatHPPoolMod_25
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_25=0 then 1 else PercentHPPoolMod_25 end) as PercentHPPoolMod_25
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_28+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatHPPoolMod_28
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_28=0 then 1 else PercentHPPoolMod_28 end) as PercentHPPoolMod_28
,(ifNull(FlatHPPoolMod,0)*ifNull(rrankNum,0)+FlatHPPoolMod_31+ifNull(rFlatHPModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatHPPoolMod_31
	,ifNull(PercentHPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentHPPoolMod_31=0 then 1 else PercentHPPoolMod_31 end) as PercentHPPoolMod_31



,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_4+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatMPPoolMod_4
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_4=0 then 1 else PercentMPPoolMod_4 end) as PercentMPPoolMod_4
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_7+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatMPPoolMod_7
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_7=0 then 1 else PercentMPPoolMod_7 end) as PercentMPPoolMod_7
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_10+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatMPPoolMod_10
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_10=0 then 1 else PercentMPPoolMod_10 end) as PercentMPPoolMod_10
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_13+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatMPPoolMod_13
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_13=0 then 1 else PercentMPPoolMod_13 end) as PercentMPPoolMod_13
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_16+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatMPPoolMod_16
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_16=0 then 1 else PercentMPPoolMod_16 end) as PercentMPPoolMod_16
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_19+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatMPPoolMod_19
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_19=0 then 1 else PercentMPPoolMod_19 end) as PercentMPPoolMod_19
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_22+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatMPPoolMod_22
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_22=0 then 1 else PercentMPPoolMod_22 end) as PercentMPPoolMod_22
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_25+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatMPPoolMod_25
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_25=0 then 1 else PercentMPPoolMod_25 end) as PercentMPPoolMod_25
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_28+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatMPPoolMod_28
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_28=0 then 1 else PercentMPPoolMod_28 end) as PercentMPPoolMod_28
,(ifNull(FlatMPPoolMod,0)*ifNull(rrankNum,0)+FlatMPPoolMod_31+ifNull(rFlatMPModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatMPPoolMod_31
	,ifNull(PercentMPPoolMod,0)*ifNull(rrankNum,0)+(case when PercentMPPoolMod_31=0 then 1 else PercentMPPoolMod_31 end) as PercentMPPoolMod_31

,(FlatHPRegenMod_4+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatHPRegenMod_4
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_4=0 then 1 else PercentHPRegenMod_4 end) as PercentHPRegenMod_4
,(FlatHPRegenMod_7+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatHPRegenMod_7
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_7=0 then 1 else PercentHPRegenMod_7 end) as PercentHPRegenMod_7
,(FlatHPRegenMod_10+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatHPRegenMod_10
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_10=0 then 1 else PercentHPRegenMod_10 end) as PercentHPRegenMod_10
,(FlatHPRegenMod_13+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatHPRegenMod_13
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_13=0 then 1 else PercentHPRegenMod_13 end) as PercentHPRegenMod_13
,(FlatHPRegenMod_16+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatHPRegenMod_16
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_16=0 then 1 else PercentHPRegenMod_16 end) as PercentHPRegenMod_16
,(FlatHPRegenMod_19+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatHPRegenMod_19
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_19=0 then 1 else PercentHPRegenMod_19 end) as PercentHPRegenMod_19
,(FlatHPRegenMod_22+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatHPRegenMod_22
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_22=0 then 1 else PercentHPRegenMod_22 end) as PercentHPRegenMod_22
,(FlatHPRegenMod_25+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatHPRegenMod_25
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_25=0 then 1 else PercentHPRegenMod_25 end) as PercentHPRegenMod_25
,(FlatHPRegenMod_28+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatHPRegenMod_28
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_28=0 then 1 else PercentHPRegenMod_28 end) as PercentHPRegenMod_28
,(FlatHPRegenMod_31+ifNull(FlatHPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatHPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatHPRegenMod_31
	,ifNull(PercentHPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentHPRegenMod_31=0 then 1 else PercentHPRegenMod_31 end) as PercentHPRegenMod_31

,(FlatMPRegenMod_4+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatMPRegenMod_4
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_4=0 then 1 else PercentMPRegenMod_4 end) AS PercentMPRegenMod_4 
,(FlatMPRegenMod_7+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatMPRegenMod_7
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_7=0 then 1 else PercentMPRegenMod_7 end) AS PercentMPRegenMod_7
,(FlatMPRegenMod_10+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatMPRegenMod_10
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_10=0 then 1 else PercentMPRegenMod_10 end) AS PercentMPRegenMod_10
,(FlatMPRegenMod_13+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatMPRegenMod_13
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_13=0 then 1 else PercentMPRegenMod_13 end) AS PercentMPRegenMod_13
,(FlatMPRegenMod_16+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatMPRegenMod_16
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_16=0 then 1 else PercentMPRegenMod_16 end) AS PercentMPRegenMod_16
,(FlatMPRegenMod_19+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatMPRegenMod_19
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_19=0 then 1 else PercentMPRegenMod_19 end) AS PercentMPRegenMod_19
,(FlatMPRegenMod_22+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatMPRegenMod_22
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_22=0 then 1 else PercentMPRegenMod_22 end) AS PercentMPRegenMod_22
,(FlatMPRegenMod_25+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatMPRegenMod_25
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_25=0 then 1 else PercentMPRegenMod_25 end) AS PercentMPRegenMod_25
,(FlatMPRegenMod_28+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatMPRegenMod_28
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_28=0 then 1 else PercentMPRegenMod_28 end) AS PercentMPRegenMod_28
,(FlatMPRegenMod_31+ifNull(FlatMPRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMPRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatMPRegenMod_31
	,ifNull(PercentMPRegenMod,0)*ifNull(rrankNum,0)+(case when PercentMPRegenMod_31=0 then 1 else PercentMPRegenMod_31 end) AS PercentMPRegenMod_31

,(FlatArmorMod_4+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatArmorMod_4
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_4=0 then 1 else PercentArmorMod_4 end) as PercentArmorMod_4
,(FlatArmorMod_7+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatArmorMod_7
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_7=0 then 1 else PercentArmorMod_7 end) as PercentArmorMod_7
,(FlatArmorMod_10+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatArmorMod_10
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_10=0 then 1 else PercentArmorMod_10 end) as PercentArmorMod_10
,(FlatArmorMod_13+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatArmorMod_13
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_13=0 then 1 else PercentArmorMod_13 end) as PercentArmorMod_13
,(FlatArmorMod_16+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatArmorMod_16
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_16=0 then 1 else PercentArmorMod_16 end) as PercentArmorMod_16
,(FlatArmorMod_19+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatArmorMod_19
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_19=0 then 1 else PercentArmorMod_19 end) as PercentArmorMod_19
,(FlatArmorMod_22+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatArmorMod_22
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_22=0 then 1 else PercentArmorMod_22 end) as PercentArmorMod_22
,(FlatArmorMod_25+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatArmorMod_25
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_25=0 then 1 else PercentArmorMod_25 end) as PercentArmorMod_25
,(FlatArmorMod_28+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatArmorMod_28
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_28=0 then 1 else PercentArmorMod_28 end) as PercentArmorMod_28
,(FlatArmorMod_31+ifNull(FlatArmorMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatArmorMod_31
	,ifNull(PercentArmorMod,0)*ifNull(rrankNum,0)+(case when PercentArmorMod_31=0 then 1 else PercentArmorMod_31 end) as PercentArmorMod_31


,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rFlatArmorPenetrationMod_4
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rPercentArmorPenetrationMod_4
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rFlatArmorPenetrationMod_7
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rPercentArmorPenetrationMod_7
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rFlatArmorPenetrationMod_10
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rPercentArmorPenetrationMod_10
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1))as rFlatArmorPenetrationMod_13
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rPercentArmorPenetrationMod_13
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rFlatArmorPenetrationMod_16
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rPercentArmorPenetrationMod_16
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1))as rFlatArmorPenetrationMod_19
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rPercentArmorPenetrationMod_19
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rFlatArmorPenetrationMod_22
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rPercentArmorPenetrationMod_22
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rFlatArmorPenetrationMod_25
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rPercentArmorPenetrationMod_25
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rFlatArmorPenetrationMod_28
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rPercentArmorPenetrationMod_28
,(ifNull(rFlatArmorPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rFlatArmorPenetrationMod_31
	,ifNull(rPercentArmorPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentArmorPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rPercentArmorPenetrationMod_31

,(FlatPhysicalDamageMod_4+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatPhysicalDamageMod_4
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_4=0 then 1 else PercentPhysicalDamageMod_4 end) as PercentPhysicalDamageMod_4
,(FlatPhysicalDamageMod_7+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatPhysicalDamageMod_7
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_7=0 then 1 else PercentPhysicalDamageMod_7 end) as PercentPhysicalDamageMod_7
,(FlatPhysicalDamageMod_10+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatPhysicalDamageMod_10
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_10=0 then 1 else PercentPhysicalDamageMod_10 end) as PercentPhysicalDamageMod_10
,(FlatPhysicalDamageMod_13+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatPhysicalDamageMod_13
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_13=0 then 1 else PercentPhysicalDamageMod_13 end) as PercentPhysicalDamageMod_13
,(FlatPhysicalDamageMod_16+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatPhysicalDamageMod_16
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_16=0 then 1 else PercentPhysicalDamageMod_16 end) as PercentPhysicalDamageMod_16
,(FlatPhysicalDamageMod_19+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatPhysicalDamageMod_19
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_19=0 then 1 else PercentPhysicalDamageMod_19 end) as PercentPhysicalDamageMod_19
,(FlatPhysicalDamageMod_22+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatPhysicalDamageMod_22
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_22=0 then 1 else PercentPhysicalDamageMod_22 end) as PercentPhysicalDamageMod_22
,(FlatPhysicalDamageMod_25+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatPhysicalDamageMod_25
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_25=0 then 1 else PercentPhysicalDamageMod_25 end) as PercentPhysicalDamageMod_25
,(FlatPhysicalDamageMod_28+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatPhysicalDamageMod_28
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_28=0 then 1 else PercentPhysicalDamageMod_28 end) as PercentPhysicalDamageMod_28
,(FlatPhysicalDamageMod_31+ifNull(FlatPhysicalDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatPhysicalDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatPhysicalDamageMod_31
	,ifNull(PercentPhysicalDamageMod,0)*ifNull(rrankNum,0)+(case when PercentPhysicalDamageMod_31=0 then 1 else PercentPhysicalDamageMod_31 end) as PercentPhysicalDamageMod_31

,(FlatMagicDamageMod_4+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatMagicDamageMod_4
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_4=0 then 1 else PercentMagicDamageMod_4 end) as PercentMagicDamageMod_4
,(FlatMagicDamageMod_7+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatMagicDamageMod_7
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_7=0 then 1 else PercentMagicDamageMod_7 end) as PercentMagicDamageMod_7
,(FlatMagicDamageMod_10+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatMagicDamageMod_10
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_10=0 then 1 else PercentMagicDamageMod_10 end) as PercentMagicDamageMod_10
,(FlatMagicDamageMod_13+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatMagicDamageMod_13
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_13=0 then 1 else PercentMagicDamageMod_13 end) as PercentMagicDamageMod_13
,(FlatMagicDamageMod_16+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatMagicDamageMod_16
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_16=0 then 1 else PercentMagicDamageMod_16 end) as PercentMagicDamageMod_16
,(FlatMagicDamageMod_19+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatMagicDamageMod_19
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_19=0 then 1 else PercentMagicDamageMod_19 end) as PercentMagicDamageMod_19
,(FlatMagicDamageMod_22+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatMagicDamageMod_22
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_22=0 then 1 else PercentMagicDamageMod_22 end) as PercentMagicDamageMod_22
,(FlatMagicDamageMod_25+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatMagicDamageMod_25
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_25=0 then 1 else PercentMagicDamageMod_25 end) as PercentMagicDamageMod_25
,(FlatMagicDamageMod_28+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatMagicDamageMod_28
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_28=0 then 1 else PercentMagicDamageMod_28 end) as PercentMagicDamageMod_28
,(FlatMagicDamageMod_31+ifNull(FlatMagicDamageMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatMagicDamageMod_31
	,ifNull(PercentMagicDamageMod,0)*ifNull(rrankNum,0)+(case when PercentMagicDamageMod_31=0 then 1 else PercentMagicDamageMod_31 end) as PercentMagicDamageMod_31

,(FlatMovementSpeedMod_4+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatMovementSpeedMod_4
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1))+(case when PercentMovementSpeedMod_4=0 then 1 else PercentMovementSpeedMod_4 end) as PercentMovementSpeedMod_4
,(FlatMovementSpeedMod_7+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatMovementSpeedMod_7
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1))+(case when PercentMovementSpeedMod_7=0 then 1 else PercentMovementSpeedMod_7 end) as PercentMovementSpeedMod_7
,(FlatMovementSpeedMod_10+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatMovementSpeedMod_10
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1))+(case when PercentMovementSpeedMod_10=0 then 1 else PercentMovementSpeedMod_10 end) as PercentMovementSpeedMod_10
,(FlatMovementSpeedMod_13+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatMovementSpeedMod_13
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1))+(case when PercentMovementSpeedMod_13=0 then 1 else PercentMovementSpeedMod_13 end) as PercentMovementSpeedMod_13
,(FlatMovementSpeedMod_16+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatMovementSpeedMod_16
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1))+(case when PercentMovementSpeedMod_16=0 then 1 else PercentMovementSpeedMod_16 end) as PercentMovementSpeedMod_16
,(FlatMovementSpeedMod_19+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatMovementSpeedMod_19
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1))+(case when PercentMovementSpeedMod_19=0 then 1 else PercentMovementSpeedMod_19 end) as PercentMovementSpeedMod_19
,(FlatMovementSpeedMod_22+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatMovementSpeedMod_22
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1))+(case when PercentMovementSpeedMod_22=0 then 1 else PercentMovementSpeedMod_22 end) as PercentMovementSpeedMod_22
,(FlatMovementSpeedMod_25+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatMovementSpeedMod_25
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1))+(case when PercentMovementSpeedMod_25=0 then 1 else PercentMovementSpeedMod_25 end) as PercentMovementSpeedMod_25
,(FlatMovementSpeedMod_28+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatMovementSpeedMod_28
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1))+(case when PercentMovementSpeedMod_28=0 then 1 else PercentMovementSpeedMod_28 end) as PercentMovementSpeedMod_28
,(FlatMovementSpeedMod_31+ifNull(FlatMovementSpeedMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatMovementSpeedMod_31
	,ifNull(PercentMovementSpeedMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMovementSpeedModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1))+(case when PercentMovementSpeedMod_31=0 then 1 else PercentMovementSpeedMod_31 end) as PercentMovementSpeedMod_31
#  round((1 / (1.6 * (1 + $offset)) * (1 + $bonus + $pl * ($level - 1) / 100)),3)
#,Champ_AttackSpeedOffset
#,Champ_AttackSpeedPerLevel
,FlatAttackSpeedMod_4+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_4
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_4=0 then 1 else PercentAttackSpeedMod_4 end) as PercentAttackSpeedMod_4
,FlatAttackSpeedMod_7+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_7
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_7=0 then 1 else PercentAttackSpeedMod_7 end) as PercentAttackSpeedMod_7
,FlatAttackSpeedMod_10+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_10
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_10=0 then 1 else PercentAttackSpeedMod_10 end) as PercentAttackSpeedMod_10
,FlatAttackSpeedMod_13+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_13
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_13=0 then 1 else PercentAttackSpeedMod_13 end) as PercentAttackSpeedMod_13
,FlatAttackSpeedMod_16+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_16
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_16=0 then 1 else PercentAttackSpeedMod_16 end) as PercentAttackSpeedMod_16
,FlatAttackSpeedMod_19+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_19
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_19=0 then 1 else PercentAttackSpeedMod_19 end) as PercentAttackSpeedMod_19
,FlatAttackSpeedMod_22+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_22
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_22=0 then 1 else PercentAttackSpeedMod_22 end) as PercentAttackSpeedMod_22
,FlatAttackSpeedMod_25+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_25
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_25=0 then 1 else PercentAttackSpeedMod_25 end) as PercentAttackSpeedMod_25
,FlatAttackSpeedMod_28+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_28
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_28=0 then 1 else PercentAttackSpeedMod_28 end) as PercentAttackSpeedMod_28
,FlatAttackSpeedMod_31+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0) as FlatAttackSpeedMod_31
,ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_31=0 then 1 else PercentAttackSpeedMod_31 end) as PercentAttackSpeedMod_31
	  	# PercentAttackSpeedMod_n already has 1 in it
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_4+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_4=0 then 1 else PercentAttackSpeedMod_4 end)+Champ_AttackSpeedPerLevel*(level_4-1)/100)),3) as FlatAttackSpeedMod_4
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_7+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_7=0 then 1 else PercentAttackSpeedMod_7 end)+Champ_AttackSpeedPerLevel*(level_7-1)/100)),3) as FlatAttackSpeedMod_7
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_10+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_10=0 then 1 else PercentAttackSpeedMod_10 end)+Champ_AttackSpeedPerLevel*(level_10-1)/100)),3) as FlatAttackSpeedMod_10
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_13+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_13=0 then 1 else PercentAttackSpeedMod_13 end)+Champ_AttackSpeedPerLevel*(level_13-1)/100)),3) as FlatAttackSpeedMod_13
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_16+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_16=0 then 1 else PercentAttackSpeedMod_16 end)+Champ_AttackSpeedPerLevel*(level_16-1)/100)),3) as FlatAttackSpeedMod_16
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_19+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_19=0 then 1 else PercentAttackSpeedMod_19 end)+Champ_AttackSpeedPerLevel*(level_19-1)/100)),3) as FlatAttackSpeedMod_19
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_22+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_22=0 then 1 else PercentAttackSpeedMod_22 end)+Champ_AttackSpeedPerLevel*(level_22-1)/100)),3) as FlatAttackSpeedMod_22
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_25+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_25=0 then 1 else PercentAttackSpeedMod_25 end)+Champ_AttackSpeedPerLevel*(level_25-1)/100)),3) as FlatAttackSpeedMod_25
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_28+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_28=0 then 1 else PercentAttackSpeedMod_28 end)+Champ_AttackSpeedPerLevel*(level_28-1)/100)),3) as FlatAttackSpeedMod_28
#,round((1/(1.6*(1+Champ_AttackSpeedOffset+FlatAttackSpeedMod_31+ifNull(FlatAttackSpeedMod,0)*ifNull(rrankNum,0))+(ifNull(PercentAttackSpeedMod,0)+(case when PercentAttackSpeedMod_31=0 then 1 else PercentAttackSpeedMod_31 end)+Champ_AttackSpeedPerLevel*(level_31-1)/100)),3) as FlatAttackSpeedMod_31

,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rFlatDodgeMod_4
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_4=0 then 1 else PercentDodgeMod_4 end) as PercentDodgeMod_4
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rFlatDodgeMod_7
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_7=0 then 1 else PercentDodgeMod_7 end) as PercentDodgeMod_7
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rFlatDodgeMod_10
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_10=0 then 1 else PercentDodgeMod_10 end) as PercentDodgeMod_10
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rFlatDodgeMod_13
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_13=0 then 1 else PercentDodgeMod_13 end) as PercentDodgeMod_13
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rFlatDodgeMod_16
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_16=0 then 1 else PercentDodgeMod_16 end) as PercentDodgeMod_16
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rFlatDodgeMod_19
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_19=0 then 1 else PercentDodgeMod_19 end) as PercentDodgeMod_19
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rFlatDodgeMod_22
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_22=0 then 1 else PercentDodgeMod_22 end) as PercentDodgeMod_22
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rFlatDodgeMod_25
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_25=0 then 1 else PercentDodgeMod_25 end) as PercentDodgeMod_25
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rFlatDodgeMod_28
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_28=0 then 1 else PercentDodgeMod_28 end) as PercentDodgeMod_28
,(ifNull(rFlatDodgeMod,0)*ifNull(rrankNum,0)+ifNull(rFlatDodgeModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rFlatDodgeMod_31
	,ifNull(PercentDodgeMod,0)*ifNull(rrankNum,0)+(case when PercentDodgeMod_31=0 then 1 else PercentDodgeMod_31 end) as PercentDodgeMod_31
# crit chance is capped at 100%
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_4+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatCritChanceMod_4
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_4=0 then 1 else PercentCritChanceMod_4 end) as PercentCritChanceMod_4
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_7+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatCritChanceMod_7
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_7=0 then 1 else PercentCritChanceMod_7 end) as PercentCritChanceMod_7
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_10+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatCritChanceMod_10
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_10=0 then 1 else PercentCritChanceMod_10 end) as PercentCritChanceMod_10
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_13+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatCritChanceMod_13
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_13=0 then 1 else PercentCritChanceMod_13 end) as PercentCritChanceMod_13
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_16+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatCritChanceMod_16
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_16=0 then 1 else PercentCritChanceMod_16 end) as PercentCritChanceMod_16
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_19+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatCritChanceMod_19
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_19=0 then 1 else PercentCritChanceMod_19 end) as PercentCritChanceMod_19
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_22+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatCritChanceMod_22
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_22=0 then 1 else PercentCritChanceMod_22 end) as PercentCritChanceMod_22
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_25+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatCritChanceMod_25
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_25=0 then 1 else PercentCritChanceMod_25 end) as PercentCritChanceMod_25
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_28+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatCritChanceMod_28
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_28=0 then 1 else PercentCritChanceMod_28 end) as PercentCritChanceMod_28
,(ifNull(FlatCritChanceMod,0)*ifNull(rrankNum,0)+FlatCritChanceMod_31+ifNull(rFlatCritChanceModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatCritChanceMod_31
	,ifNull(PercentCritChanceMod,0)*ifNull(rrankNum,0)+(case when PercentCritChanceMod_31=0 then 1 else PercentCritChanceMod_31 end) as PercentCritChanceMod_31


,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_4+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatCritDamageMod_4
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_4=0 then 1 else PercentCritDamageMod_4 end) as PercentCritDamageMod_4
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_7+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatCritDamageMod_7
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_7=0 then 1 else PercentCritDamageMod_7 end) as PercentCritDamageMod_7
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_10+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatCritDamageMod_10
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_10=0 then 1 else PercentCritDamageMod_10 end) as PercentCritDamageMod_10
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_13+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatCritDamageMod_13
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_13=0 then 1 else PercentCritDamageMod_13 end) as PercentCritDamageMod_13
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_16+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatCritDamageMod_16
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_16=0 then 1 else PercentCritDamageMod_16 end) as PercentCritDamageMod_16
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_19+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatCritDamageMod_19
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_19=0 then 1 else PercentCritDamageMod_19 end) as PercentCritDamageMod_19
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_22+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatCritDamageMod_22
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_22=0 then 1 else PercentCritDamageMod_22 end) as PercentCritDamageMod_22
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_25+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatCritDamageMod_25
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_25=0 then 1 else PercentCritDamageMod_25 end) as PercentCritDamageMod_25
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_28+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatCritDamageMod_28
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_28=0 then 1 else PercentCritDamageMod_28 end) as PercentCritDamageMod_28
,(ifNull(FlatCritDamageMod,0)*ifNull(rrankNum,0)+FlatCritDamageMod_31+ifNull(rFlatCritDamageModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatCritDamageMod_31
	,ifNull(PercentCritDamageMod,0)*ifNull(rrankNum,0)+(case when PercentCritDamageMod_31=0 then 1 else PercentCritDamageMod_31 end) as PercentCritDamageMod_31


,(FlatBlockMod_4+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_4
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_4=0 then 1 else PercentBlockMod_4 end) as PercentBlockMod_4
,(FlatBlockMod_7+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_7
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_7=0 then 1 else PercentBlockMod_7 end) as PercentBlockMod_7
,(FlatBlockMod_10+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_10
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_10=0 then 1 else PercentBlockMod_10 end) as PercentBlockMod_10
,(FlatBlockMod_13+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_13
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_13=0 then 1 else PercentBlockMod_13 end) as PercentBlockMod_13
,(FlatBlockMod_16+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_16
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_16=0 then 1 else PercentBlockMod_16 end) as PercentBlockMod_16
,(FlatBlockMod_19+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_19
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_19=0 then 1 else PercentBlockMod_19 end) as PercentBlockMod_19
,(FlatBlockMod_22+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_22
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_22=0 then 1 else PercentBlockMod_22 end) as PercentBlockMod_22
,(FlatBlockMod_25+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_25
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_25=0 then 1 else PercentBlockMod_25 end) as PercentBlockMod_25
,(FlatBlockMod_28+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_28
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_28=0 then 1 else PercentBlockMod_28 end) as PercentBlockMod_28
,(FlatBlockMod_31+ifNull(FlatBlockMod,0)*ifNull(rrankNum,0)) as FlatBlockMod_31
	,ifNull(PercentBlockMod,0)*ifNull(rrankNum,0)+(case when PercentBlockMod_31=0 then 1 else PercentBlockMod_31 end) as PercentBlockMod_31

,(FlatSpellBlockMod_4+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as FlatSpellBlockMod_4
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_4=0 then 1 else PercentSpellBlockMod_4 end) as PercentSpellBlockMod_4
,(FlatSpellBlockMod_7+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as FlatSpellBlockMod_7
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_7=0 then 1 else PercentSpellBlockMod_7 end) as PercentSpellBlockMod_7
,(FlatSpellBlockMod_10+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as FlatSpellBlockMod_10
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_10=0 then 1 else PercentSpellBlockMod_10 end) as PercentSpellBlockMod_10
,(FlatSpellBlockMod_13+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as FlatSpellBlockMod_13
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_13=0 then 1 else PercentSpellBlockMod_13 end) as PercentSpellBlockMod_13
,(FlatSpellBlockMod_16+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as FlatSpellBlockMod_16
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_16=0 then 1 else PercentSpellBlockMod_16 end) as PercentSpellBlockMod_16
,(FlatSpellBlockMod_19+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as FlatSpellBlockMod_19
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_19=0 then 1 else PercentSpellBlockMod_19 end) as PercentSpellBlockMod_19
,(FlatSpellBlockMod_22+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as FlatSpellBlockMod_22
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_22=0 then 1 else PercentSpellBlockMod_22 end) as PercentSpellBlockMod_22
,(FlatSpellBlockMod_25+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as FlatSpellBlockMod_25
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_25=0 then 1 else PercentSpellBlockMod_25 end) as PercentSpellBlockMod_25
,(FlatSpellBlockMod_28+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as FlatSpellBlockMod_28
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_28=0 then 1 else PercentSpellBlockMod_28 end) as PercentSpellBlockMod_28
,(FlatSpellBlockMod_31+ifNull(FlatSpellBlockMod,0)*ifNull(rrankNum,0)+ifNull(rFlatSpellBlockModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as FlatSpellBlockMod_31
	,ifNull(PercentSpellBlockMod,0)*ifNull(rrankNum,0)+(case when PercentSpellBlockMod_31=0 then 1 else PercentSpellBlockMod_31 end) as PercentSpellBlockMod_31

,FlatEXPBonus_4+ifNull(FlatEXPBonus,0) as FlatEXPBonus_4
,FlatEXPBonus_7+ifNull(FlatEXPBonus,0) as FlatEXPBonus_7
,FlatEXPBonus_10+ifNull(FlatEXPBonus,0) as FlatEXPBonus_10
,FlatEXPBonus_13+ifNull(FlatEXPBonus,0) as FlatEXPBonus_13
,FlatEXPBonus_16+ifNull(FlatEXPBonus,0) as FlatEXPBonus_16
,FlatEXPBonus_19+ifNull(FlatEXPBonus,0) as FlatEXPBonus_19
,FlatEXPBonus_22+ifNull(FlatEXPBonus,0) as FlatEXPBonus_22
,FlatEXPBonus_25+ifNull(FlatEXPBonus,0) as FlatEXPBonus_25
,FlatEXPBonus_28+ifNull(FlatEXPBonus,0) as FlatEXPBonus_28
,FlatEXPBonus_31+ifNull(FlatEXPBonus,0) as FlatEXPBonus_31

,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1) as rPercentCooldownMod_4
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1) as rPercentCooldownMod_7
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1) as rPercentCooldownMod_10
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1) as rPercentCooldownMod_13
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1) as rPercentCooldownMod_16
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1) as rPercentCooldownMod_19
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1) as rPercentCooldownMod_22
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1) as rPercentCooldownMod_25
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1) as rPercentCooldownMod_28
,ifNull(rPercentCooldownMod,0)*ifNull(rrankNum,0)+ifNull(rPercentCooldownModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1) as rPercentCooldownMod_31

,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rFlatTimeDeadMod_4
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rPercentTimeDeadMod_4
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rFlatTimeDeadMod_7
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rPercentTimeDeadMod_7
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rFlatTimeDeadMod_10
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rPercentTimeDeadMod_10
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rFlatTimeDeadMod_13
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rPercentTimeDeadMod_13
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rFlatTimeDeadMod_16
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rPercentTimeDeadMod_16
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rFlatTimeDeadMod_19
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rPercentTimeDeadMod_19
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rFlatTimeDeadMod_22
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rPercentTimeDeadMod_22
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rFlatTimeDeadMod_25
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rPercentTimeDeadMod_25
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rFlatTimeDeadMod_28
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rPercentTimeDeadMod_28
,(ifNull(rFlatTimeDeadMod,0)*ifNull(rrankNum,0)+ifNull(rFlatTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rFlatTimeDeadMod_31
	,ifNull(rPercentTimeDeadMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentTimeDeadModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rPercentTimeDeadMod_31

,ifNull(rFlatGoldPer10Mod,0)*ifNull(rrankNum,0) as rFlatGoldPer10Mod_total

,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rFlatMagicPenetrationMod_4
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1)) as rPercentMagicPenetrationMod_4
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rFlatMagicPenetrationMod_7
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1)) as rPercentMagicPenetrationMod_7
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rFlatMagicPenetrationMod_10
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1)) as rPercentMagicPenetrationMod_10
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rFlatMagicPenetrationMod_13
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1)) as rPercentMagicPenetrationMod_13
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rFlatMagicPenetrationMod_16
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1)) as rPercentMagicPenetrationMod_16
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rFlatMagicPenetrationMod_19
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1)) as rPercentMagicPenetrationMod_19
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rFlatMagicPenetrationMod_22
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1)) as rPercentMagicPenetrationMod_22
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rFlatMagicPenetrationMod_25
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1)) as rPercentMagicPenetrationMod_25
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rFlatMagicPenetrationMod_28
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1)) as rPercentMagicPenetrationMod_28
,(ifNull(rFlatMagicPenetrationMod,0)*ifNull(rrankNum,0)+ifNull(rFlatMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rFlatMagicPenetrationMod_31
	,ifNull(rPercentMagicPenetrationMod,0)*ifNull(rrankNum,0)+(1+ifNull(rPercentMagicPenetrationModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1)) as rPercentMagicPenetrationMod_31

,FlatEnergyRegenMod_4+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1) as FlatEnergyRegenMod_4
,FlatEnergyRegenMod_7+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1) as FlatEnergyRegenMod_7
,FlatEnergyRegenMod_10+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1) as FlatEnergyRegenMod_10
,FlatEnergyRegenMod_13+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1) as FlatEnergyRegenMod_13
,FlatEnergyRegenMod_16+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1) as FlatEnergyRegenMod_16
,FlatEnergyRegenMod_19+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1) as FlatEnergyRegenMod_19
,FlatEnergyRegenMod_22+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1) as FlatEnergyRegenMod_22
,FlatEnergyRegenMod_25+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1) as FlatEnergyRegenMod_25
,FlatEnergyRegenMod_28+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1) as FlatEnergyRegenMod_28
,FlatEnergyRegenMod_31+ifNull(FlatEnergyRegenMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyRegenModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1) as FlatEnergyRegenMod_31

,FlatEnergyPoolMod_4+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_4-1) as FlatEnergyPoolMod_4
,FlatEnergyPoolMod_7+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_7-1) as FlatEnergyPoolMod_7
,FlatEnergyPoolMod_10+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_10-1) as FlatEnergyPoolMod_10
,FlatEnergyPoolMod_13+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_13-1) as FlatEnergyPoolMod_13
,FlatEnergyPoolMod_16+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_16-1) as FlatEnergyPoolMod_16
,FlatEnergyPoolMod_19+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_19-1) as FlatEnergyPoolMod_19
,FlatEnergyPoolMod_22+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_22-1) as FlatEnergyPoolMod_22
,FlatEnergyPoolMod_25+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_25-1) as FlatEnergyPoolMod_25
,FlatEnergyPoolMod_28+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_28-1) as FlatEnergyPoolMod_28
,FlatEnergyPoolMod_31+ifNull(FlatEnergyPoolMod,0)*ifNull(rrankNum,0)+ifNull(rFlatEnergyModPerLevel,0)*ifNull(rrankNum,0)*(level_31-1) as FlatEnergyPoolMod_31

,PercentLifeStealMod_4+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_4
,PercentLifeStealMod_7+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_7
,PercentLifeStealMod_10+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_10
,PercentLifeStealMod_13+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_13
,PercentLifeStealMod_16+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_16
,PercentLifeStealMod_19+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_19
,PercentLifeStealMod_22+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_22
,PercentLifeStealMod_25+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_25
,PercentLifeStealMod_28+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_28
,PercentLifeStealMod_31+(ifNull(PercentLifeStealMod,0)*ifNull(rrankNum,0)) as PercentLifeStealMod_31

,PercentSpellVampMod_4+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_4
,PercentSpellVampMod_7+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_7
,PercentSpellVampMod_10+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_10
,PercentSpellVampMod_13+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_13
,PercentSpellVampMod_16+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_16
,PercentSpellVampMod_19+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_19
,PercentSpellVampMod_22+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_22
,PercentSpellVampMod_25+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_25
,PercentSpellVampMod_28+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_28
,PercentSpellVampMod_31+(ifNull(PercentSpellVampMod,0)*ifNull(rrankNum,0)) as PercentSpellVampMod_31

#===============================================================================
from lol.participant_champion_nameDate as a
left join 
lol.rune_aggregated as b
on runeIdNum=ID and a.version=b.version;
