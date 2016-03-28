# 08 - aggregate timelineevent to one record per frame       
/* drop table if exists lol.timelineevents_item_nameDate_rollup;*/
 create table lol.timelineevents_item_nameDate_rollup (index gameIdParIdFrame (gameId,participantFrames,participantId)) as 
 select gameId,max(version) as version,max(win) as win,participantFrames
 		,participantId,GROUP_CONCAT(itemId) as itemId
		/*,type*/
,max(gameCount) as gameCount,max(gameMinutes) as gameMinutes,max(gameMode) as gameMode,max(gameType) as gameType
,max(mapId) as mapId,max(seasonId) as seasonId,max(championId) as championId,max(spell1Id) as spell1Id
,max(spell2Id) as spell2Id,max(highestAchievedSeasonTier) as highestAchievedSeasonTier,max(role) as role,max(lane) as lane
,max(masteryId1) as masteryId1,max(mrank1) as mrank1,max(masteryId2) as masteryId2,max(mrank2) as mrank2
,max(masteryId3) as masteryId3,max(mrank3) as mrank3,max(masteryId4) as masteryId4,max(mrank4) as mrank4
,max(masteryId5) as masteryId5,max(mrank5) as mrank5,max(masteryId6) as masteryId6,max(mrank6) as mrank6
,max(masteryId7) as masteryId7,max(mrank7) as mrank7,max(masteryId8) as masteryId8,max(mrank8) as mrank8
,max(masteryId9) as masteryId9,max(mrank9) as mrank9,max(masteryId10) as masteryId10,max(mrank10) as mrank10
,max(masteryId11) as masteryId11,max(mrank11) as mrank11,max(masteryId12) as masteryId12,max(mrank12) as mrank12
,max(masteryId13) as masteryId13,max(mrank13) as mrank13,max(masteryId14) as masteryId14,max(mrank14) as mrank14
,max(masteryId15) as masteryId15,max(mrank15) as mrank15,max(masteryId16) as masteryId16,max(mrank16) as mrank16
,max(masteryId17) as masteryId17,max(mrank17) as mrank17,max(masteryId18) as masteryId18,max(mrank18) as mrank18
,max(masteryId19) as masteryId19,max(mrank19) as mrank19,max(masteryId20) as masteryId20,max(mrank20) as mrank20
,max(runeId1) as runeId1,max(rrank1) as rrank1,max(runeId2) as runeId2,max(rrank2) as rrank2
,max(runeId3) as runeId3,max(rrank3) as rrank3,max(runeId4) as runeId4,max(rrank4) as rrank4
,max(runeId5) as runeId5,max(rrank5) as rrank5,max(runeId6) as runeId6,max(rrank6) as rrank6
,max(runeId7) as runeId7,max(rrank7) as rrank7,max(runeId8) as runeId8,max(rrank8) as rrank8
,max(runeId9) as runeId9,max(rrank9) as rrank9,max(runeId10) as runeId10,max(rrank10) as rrank10

/*, assistingPlayerId, victimId*/
,sum(IfNULL(Num_Assisting_Player,0)) as Num_Assisting_Player
/*,sum(Num_MonsterKilled) as Num_MonsterKilled
,sum(Num_Ward_Killed) as Num_Ward_Killed
,sum(Num_Ward_Place) as Num_Ward_Place */
,sum(IfNull(skillSlot1,0)) as skillSlot1
,sum(IfNull(skillSlot2,0)) as skillSlot2
,sum(ifNull(skillSlot3,0)) as skillSlot3
,sum(ifNull(skillSlot4,0)) as skillSlot4
,avg(ifNull(position_x,0)) as position_x
,avg(ifNull(position_y,0)) as position_y
,sum(ifNull(Num_ItemPurchased,0)) as Num_ItemPurchased
,sum(ifnull(Num_ItemSold,0)) as Num_ItemSold
,sum(ifNull(Num_KilledBld,0)) as Num_KilledBld
,sum(ifNull(Num_KilledChamp,0)) as Num_KilledChamp

/*,ts_add， item stats,Name as itemName,description as itemDescription,`group` as itemGroup*/
,case when `type` = 'ITEM_PURCHASED' then sum(goldbase) else 0 end as goldSpent	/* negative for spending*/
,case when `type` = 'ITEM_SOLD' then sum(goldsell) else 0 end as goldRecoup	/*positive for recouping*/ 
,case when `type` = 'ITEM_PURCHASED' then count(consumed) else 0 end as num_consumed

/*# item stats
#,goldBase,goldTotal,goldSell*/
, sum(tags_Active) as tags_Active, sum(tags_Armor) as tags_Armor, sum(tags_ArmorPenetration) as tags_ArmorPenetration
, sum(tags_AttackSpeed) as  tags_AttackSpeed     
, sum(tags_Aura) as tags_Aura, sum(tags_Boots) as tags_Boots, sum(tags_Consumable) as tags_Consumable, sum(tags_CooldownReduction) as tags_CooldownReduction
, sum(tags_CriticalStrike) as tags_CriticalStrike, sum(tags_Damage) as tags_Damage, sum(tags_GoldPer) as tags_GoldPer, sum(tags_Health) as tags_Health       
, sum(tags_HealthRegen) as tags_HealthRegen, sum(tags_Jungle) as tags_Jungle, sum(tags_Lane) as tags_Lane, sum(tags_LifeSteal) as tags_LifeSteal      
, sum(tags_MagicPenetration) as tags_MagicPenetration, sum(tags_Mana) as tags_Mana, sum(tags_ManaRegen) as tags_ManaRegen, sum(tags_Movement) as tags_Movement         
, sum(tags_NonbootsMovement) as tags_NonbootsMovement, sum(tags_OnHit) as tags_OnHit, sum(tags_Slow) as tags_Slow, sum(tags_SpellBlock) as tags_SpellBlock       
, sum(tags_SpellDamage) as tags_SpellDamage, sum(tags_SpellVamp) as tags_SpellVamp, sum(tags_Stealth) as tags_Stealth, sum(tags_Tenacity) as tags_Tenacity        
, sum(tags_Trinket) as tags_Trinket, sum(tags_Vision) as tags_Vision
/*,PlainText as itemPlainText,consumed,specialRecipe*/
, sum(IFNULL(FlatHPPoolMod,0)) as FlatHPPoolMod, sum(IFNULL(FlatMPPoolMod,0)) as FlatMPPoolMod
, sum(IFNULL(PercentHPPoolMod,0)) as PercentHPPoolMod, sum(IFNULL(PercentMPPoolMod,0)) as PercentMPPoolMod
, sum(IFNULL(FlatHPRegenMod,0)) as FlatHPRegenMod 	# the value is per sec up to 5 sec or 15 sec
, sum(IFNULL(PercentHPRegenMod,0)) as PercentHPRegenMod
, sum(IFNULL(FlatMPRegenMod,0)) as FlatMPRegenMod, sum(IFNULL(PercentMPRegenMod,0)) as PercentMPRegenMod
, sum(IFNULL(FlatArmorMod,0)) as FlatArmorMod, sum(IFNULL(PercentArmorMod,0)) as PercentArmorMod
, sum(IFNULL(FlatPhysicalDamageMod,0)) as FlatPhysicalDamageMod, sum(IFNULL(PercentPhysicalDamageMod,0)) as PercentPhysicalDamageMod
, sum(IFNULL(FlatMagicDamageMod,0)) as FlatMagicDamageMod, sum(IFNULL(PercentMagicDamageMod,0)) as PercentMagicDamageMod
, sum(IFNULL(FlatMovementSpeedMod,0)) as FlatMovementSpeedMod,  sum(IFNULL(PercentMovementSpeedMod,0)) as PercentMovementSpeedMod
, sum(IFNULL(FlatAttackSpeedMod,0)) as FlatAttackSpeedMod, sum(IFNULL(PercentAttackSpeedMod,0)) as PercentAttackSpeedMod
, sum(IFNULL(PercentDodgeMod,0)) as PercentDodgeMod
, case when sum(IFNULL(FlatCritChanceMod,0))>=1 then 1 else sum(IFNULL(FlatCritChanceMod,0)) end as FlatCritChanceMod
, sum(IFNULL(PercentCritChanceMod,0)) as PercentCritChanceMod, sum(IFNULL(FlatCritDamageMod,0)) as FlatCritDamageMod
, sum(IFNULL(PercentCritDamageMod,0)) as PercentCritDamageMod, sum(IFNULL(FlatBlockMod,0)) as FlatBlockMod
, sum(IFNULL(PercentBlockMod,0)) as PercentBlockMod, sum(IFNULL(FlatSpellBlockMod,0)) as FlatSpellBlockMod 	# value reduced in AP
, sum(IFNULL(PercentSpellBlockMod,0)) as PercentSpellBlockMod, sum(IFNULL(FlatEXPBonus,0)) as FlatEXPBonus
, sum(IFNULL(FlatEnergyRegenMod,0)) as FlatEnergyRegenMod, sum(IFNULL(FlatEnergyPoolMod,0)) as FlatEnergyPoolMod
, sum(IFNULL(PercentLifeStealMod,0)) as PercentLifeStealMod, sum(IFNULL(PercentSpellVampMod,0)) as PercentSpellVampMod
from lol.timelineevents_item_nameDate
group by gameId,participantId,participantFrames;
