# 07 - join the item stats to timelineevents table 
/* drop table if exists lol.timelineevents_item_nameDate;*/
create table lol.timelineevents_item_nameDate as
select gameId,a.version,a.win,participantFrames,`type`,participantId,itemId
/* table a*/
,gameCount,gameMinutes,gameMode,gameType,mapId,seasonId,championId,spell1Id,spell2Id
,highestAchievedSeasonTier,role,lane
	,masteryId1,mrank1,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
/*,Num_Building_Killed,KilledByPlayer
,Num_Victim,Num_Ward_Killed,skillSlot,position_x,position_y
,assistingParticipantIds,ts_add,timelineevents_ID, assistingPlayerId*/
, Num_Assisting_Player
, victimId
/*, Num_MonsterKilled
, Num_Ward_Killed
, Num_Ward_Place*/
, skillSlot1
, skillSlot2
, skillSlot3
, skillSlot4
, position_x
, position_y
, Num_ItemPurchased
, Num_ItemSold
, Num_KilledBld
, Num_KilledChamp
/* item stats*/
,Name as itemName,description as itemDescription,`group` as itemGroup
,goldBase,goldTotal,goldSell,PlainText as itemPlainText
,consumed,specialRecipe

, tags_Active, tags_Armor, tags_ArmorPenetration, tags_AttackSpeed      
, tags_Aura, tags_Boots, tags_Consumable, tags_CooldownReduction
, tags_CriticalStrike, tags_Damage, tags_GoldPer, tags_Health           
, tags_HealthRegen, tags_Jungle, tags_Lane, tags_LifeSteal        
, tags_MagicPenetration, tags_Mana, tags_ManaRegen, tags_Movement         
, tags_NonbootsMovement, tags_OnHit, tags_Slow, tags_SpellBlock       
, tags_SpellDamage, tags_SpellVamp, tags_Stealth, tags_Tenacity         
, tags_Trinket, tags_Vision           

, FlatHPPoolMod, FlatMPPoolMod , PercentHPPoolMod , PercentMPPoolMod, FlatHPRegenMod
, PercentHPRegenMod, FlatMPRegenMod, PercentMPRegenMod, FlatArmorMod, PercentArmorMod 
, FlatPhysicalDamageMod, PercentPhysicalDamageMod, FlatMagicDamageMod, PercentMagicDamageMod
, FlatMovementSpeedMod, PercentMovementSpeedMod, FlatAttackSpeedMod, PercentAttackSpeedMod
, PercentDodgeMod, FlatCritChanceMod, PercentCritChanceMod, FlatCritDamageMod
, PercentCritDamageMod, FlatBlockMod, PercentBlockMod, FlatSpellBlockMod
, PercentSpellBlockMod, FlatEXPBonus, FlatEnergyRegenMod, FlatEnergyPoolMod
, PercentLifeStealMod, PercentSpellVampMod     
from lol.timelineevents_nameDate_derive_getVersion as a
left join lol.items_rollup as b 	# roll up the items table due to multiple tags per item
on a.itemId=b.ID and a.version=b.version;
