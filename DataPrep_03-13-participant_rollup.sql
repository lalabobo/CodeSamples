# 13 - join events to timeline /* cause NULL*/
/* version, win, gameMInutes, gameMode, gameType, mapId, seasonId, championId, spell1Id, spell2Id,
highestAchievedSeasonTier,role and lane have NULL and will be dealt in 03-1-TransParticipant.R */
/*drop table if exists lol.timeline_event_join_nameDate;*/
create table lol.timeline_event_join_nameDate as
select a.gameId, version, win,a.participantFrames
,gameCount,gameMinutes,gameMode,gameType,mapId,seasonId,championId,spell1Id,spell2Id
,highestAchievedSeasonTier,role,lane, a.participantId, IFNULL(itemId,0) as itemId  
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10

, IFNULL(Num_ItemPurchased,0) AS Num_ItemPurchased
, IFNULL(Num_ItemSold,0) AS Num_ItemSold
/*, IFNULL(Num_SkillLevelUp,0) as Num_SkillLevelUp*/
, IFNULL(Num_MonsterKilled,0) AS Num_MonsterKilled
, IFNULL(Num_Ward_Killed,0) AS Num_Ward_Killed
, IFNULL(Num_Ward_Place,0) AS Num_Ward_Place
, IFNULL(Num_KilledBld,0) AS Num_KilledBld
, IFNULL(Num_KilledChamp,0) AS Num_KilledChamp
, IFNULL(Num_Assisting_Player,0) AS Num_Assisting_Player
/*, IFNULL(Num_Building_Killed,0) as Num_Building_Killed
, IFNULL(KilledByPlayer,0) as KilledByPlayer, IFNULL(Num_Victim,0) as Num_Victim  */      
, IFNULL(skillSlot1,0) AS skillSlot1, IFNULL(skillSlot2,0) AS skillSlot2, IFNULL(skillSlot3,0) AS skillSlot3
, IFNULL(skillSlot4,0) AS skillSlot4, a.position_x, a.position_y
, b.position_x as champKilled_position_x,b.position_y as champKilled_position_y                                       
, ifnull(goldSpent,0) as goldSpent, ifnull(goldRecoup,0) as goldRecoup, ifnull(num_consumed,0) as num_consumed

, IFNULL(Num_AssistBld,0) AS Num_AssistBld
, IFNULL(Num_AssistChamp,0) AS Num_AssistChamp
, IFNULL(Num_Deaths,0) AS Num_Deaths

, IFNULL(tags_Active,0) AS tags_Active, IFNULL(tags_Armor,0) AS tags_Armor, IFNULL(tags_ArmorPenetration,0) AS tags_ArmorPenetration
, IFNULL(tags_AttackSpeed,0) AS tags_AttackSpeed      
, IFNULL(tags_Aura,0) AS tags_Aura, IFNULL(tags_Boots,0) AS tags_Boots, IFNULL(tags_Consumable,0) AS tags_Consumable
, IFNULL(tags_CooldownReduction,0) AS tags_CooldownReduction
, IFNULL(tags_CriticalStrike,0) AS tags_CriticalStrike, IFNULL(tags_Damage,0) AS tags_Damage, IFNULL(tags_GoldPer,0) AS tags_GoldPer
, IFNULL(tags_Health,0) AS tags_Health           
, IFNULL(tags_HealthRegen,0) AS tags_HealthRegen, IFNULL(tags_Jungle,0) AS tags_Jungle, IFNULL(tags_Lane,0) AS tags_Lane
, IFNULL(tags_LifeSteal,0) AS tags_LifeSteal        
, IFNULL(tags_MagicPenetration,0) AS tags_MagicPenetration, IFNULL(tags_Mana,0) AS tags_Mana, IFNULL(tags_ManaRegen,0) AS tags_ManaRegen
, IFNULL(tags_Movement,0) AS tags_Movement         
, IFNULL(tags_NonbootsMovement,0) AS tags_NonbootsMovement, IFNULL(tags_OnHit,0) AS tags_OnHit, IFNULL(tags_Slow,0) AS tags_Slow
, IFNULL(tags_SpellBlock,0) AS tags_SpellBlock       
, IFNULL(tags_SpellDamage,0) AS tags_SpellDamage, IFNULL(tags_SpellVamp,0) AS tags_SpellVamp, IFNULL(tags_Stealth,0) AS tags_Stealth
, IFNULL(tags_Tenacity,0) AS tags_Tenacity         
, IFNULL(tags_Trinket,0) AS tags_Trinket, IFNULL(tags_Vision,0) AS tags_Vision 
, IFNULL(FlatHPPoolMod,0) AS FlatHPPoolMod, IFNULL(FlatMPPoolMod,0) AS FlatMPPoolMod
, IFNULL(PercentHPPoolMod,0) AS PercentHPPoolMod
, IFNULL(PercentMPPoolMod,0) AS PercentMPPoolMod, IFNULL(FlatHPRegenMod,0) AS FlatHPRegenMod           
, IFNULL(PercentHPRegenMod,0) AS PercentHPRegenMod, IFNULL(FlatMPRegenMod,0) AS FlatMPRegenMod, IFNULL(PercentMPRegenMod,0) AS PercentMPRegenMod
, IFNULL(FlatArmorMod,0) AS FlatArmorMod, IFNULL(PercentArmorMod,0) AS PercentArmorMod          
, IFNULL(FlatPhysicalDamageMod,0) AS FlatPhysicalDamageMod, IFNULL(PercentPhysicalDamageMod,0) AS PercentPhysicalDamageMod
, IFNULL(FlatMagicDamageMod,0) AS FlatMagicDamageMod, IFNULL(PercentMagicDamageMod,0) AS PercentMagicDamageMod    
, IFNULL(FlatMovementSpeedMod,0) AS FlatMovementSpeedMod, IFNULL(PercentMovementSpeedMod,0) AS PercentMovementSpeedMod
, IFNULL(FlatAttackSpeedMod,0) AS FlatAttackSpeedMod, IFNULL(PercentAttackSpeedMod,0) AS PercentAttackSpeedMod    
, IFNULL(PercentDodgeMod,0) AS PercentDodgeMod, IFNULL(FlatCritChanceMod,0) AS FlatCritChanceMod
, IFNULL(PercentCritChanceMod,0) AS PercentCritChanceMod, IFNULL(FlatCritDamageMod,0) AS FlatCritDamageMod        
, IFNULL(PercentCritDamageMod,0) AS PercentCritDamageMod, IFNULL(FlatBlockMod,0) AS FlatBlockMod
, IFNULL(PercentBlockMod,0) AS PercentBlockMod, IFNULL(FlatSpellBlockMod,0) AS FlatSpellBlockMod        
, IFNULL(PercentSpellBlockMod,0) AS PercentSpellBlockMod, IFNULL(FlatEXPBonus,0) AS FlatEXPBonus
, IFNULL(FlatEnergyRegenMod,0) AS FlatEnergyRegenMod, IFNULL(FlatEnergyPoolMod,0) AS FlatEnergyPoolMod        
, IFNULL(PercentLifeStealMod,0) AS PercentLifeStealMod, IFNULL(PercentSpellVampMod,0) AS PercentSpellVampMod 
/* table a*/
, currentGold, totalGold, level, xp, minionsKilled, jungleMinionsKilled
, IFNULL(dominionScore,0) as dominionScore, IFNULL(teamScore,0) as teamScore  
from (select * from lol.timelines_nameDate where gameId in 
		(select distinct gameId from lol.timelineevents_item_nameDate_rollup)) as a
left join lol.timelineevents_item_nameDate_rollup_temp4 as b 
on a.gameId=b.gameId
and a.participantId=b.participantId
and a.participantFrames=b.participantFrames;
