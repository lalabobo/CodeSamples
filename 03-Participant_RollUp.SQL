## create table each row contains a game per participantId with first 20min timeline and event info with 2min interval
## this table is used to answer: what is the common pattern of a player in a winning team
## need to join back to lol.game_team_par_join_150610 to get championId, team combination, masteries and runes if needed.

# 01- attach the correct version number to participants table
#alter table lol.game_team_par_join_150610
#add index gameDate (gameDate_GMT);

drop table if exists lol.150610_getVersion;
#create table lol.150610_getVersion as
#select a.* # all the stats of each participant in a game as seen at the end of a game, and masteries and runes
#a.gameId,a.participantId,a.gameDate_GMT,a.gameDuration,a.gameMode
#,b.version,b.patchDate,b.endDate
#		from lol.game_team_par_join_150610 as a
#		left join lol.patchdate as b
		# join on first two fields of version, and gameDate between patchDate and endDate
#		on left(gameVersion,(length(gameVersion)-locate(".",reverse(gameVersion)))-2)=
#		LEFT( version, (LENGTH(Version)-LOCATE(".", REVERSE(Version))))
#		and gameDate_GMT>=min_gameDate
#		and gameDate_GMT<=max_gameDate;

# add index to speed up join
#alter table lol.150610_getVersion
#add index gamdId (gameId),
#add index participantId (participantId);
# correct the data type
#alter table lol.timelineevents_150610 	
#modify position_x int,
#modify position_y int;


# 02 - create derived variables from timelineevents table
drop table if exists lol.timelineevents_150610_derive;
create table lol.timelineevents_150610_derive as 
select gameId,participantFrames,`type`,participantId,itemId
, case when `type`='BUILDING_KILL' then 1 else 0 end as Num_Building_Killed
, case when (`type`='BUILDING_KILL' or `type`='CHAMPION_KILL') and assistingParticipantIds!='NA' and assistingParticipantIds is not NULL 
			then (LENGTH(assistingParticipantIds) - LENGTH(REPLACE(assistingParticipantIds,',',''))+1) else 0 end as Num_Assisting_Player
, case when (`type`='BUILDING_KILL' or `type`='WARD_KILL' or `type`='CHAMPION_KILL' or `type`='ELITE_MONSTER_KILL') and killerId !=0  and killerId!='NA' then 1 else 0 end as KilledByPlayer
, case when (`type`='CHAMPION_KILL' and victimId!=0  and victimId!='NA') then 1 else 0 end as Num_Victim 
, case when `type`='WARD_PLACED' then 1 else 0 end as Num_Ward_Used
, case when `type`='SKILL_LEVEL_UP' then skillSlot else NULL end as skillSlot
, case when position_x='NA' then NULL else position_x end as position_x
, case when position_y='NA' then NULL else position_y end as position_y
, ts_add
, ID as timelineevents_ID 
from lol.timelineevents_150610;		

# add in index to speed up join
alter table lol.timelineevents_150610_derive add index gameId (gameId);

# 03 - grab the version for timelineevents table
drop table if exists lol.timelineevents_150610_derive_getVersion;
create table lol.timelineevents_150610_derive_getVersion
select  a.gameId,b.version,b.win,participantFrames,`type`,a.participantId,itemId
# table a
,gameMinutes,gameMode,gameType,seasonId,championId,spell1Id,spell2Id
	,highestAchievedSeasonTier,role,lane
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
,Num_Building_Killed,Num_Assisting_Player,KilledByPlayer
,Num_Victim,Num_Ward_Used,skillSlot,position_x,position_y,ts_add
,timelineevents_ID
from lol.timelineevents_150610_derive as a
left join 
	(select gameId,version,participantId,case when win='Fail' then 0 else 1 end as win 
	,gameMinutes,gameMode,gameType,seasonId,championId,spell1Id,spell2Id
	,highestAchievedSeasonTier,role,lane
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
	from lol.150610_getVersion) as b 	
on a.gameId=b.gameId and a.participantId=b.participantId
where version is not NULL; 	# some gameId are in timelineevents but not in lol.game_team_par_join_150610: 38 gameId


# 04 - roll up items table so one item in a version only takes one row 
/*drop table if exists lol.items_rollup;
create table lol.items_rollup
select max(Name) as Name,ID,version,max(`group`) as `group`,max(Description) as Description
	,max(PlainText) as PlainText,max(`from`) as `from`
, case when tags='Active' then 1 else 0 end as tags_Active                    
,case when tags='Armor' then 1 else 0 end as tags_Armor            
,case when tags='ArmorPenetration' then 1 else 0 end as tags_ArmorPenetration 
,case when tags='AttackSpeed' then 1 else 0 end as tags_AttackSpeed      
,case when tags='Aura' then 1 else 0 end as tags_Aura             
,case when tags='Boots' then 1 else 0 end as tags_Boots            
,case when tags='Consumable' then 1 else 0 end as tags_Consumable       
,case when tags='CooldownReduction' then 1 else 0 end as tags_CooldownReduction
,case when tags='CriticalStrike' then 1 else 0 end as tags_CriticalStrike   
,case when tags='Damage' then 1 else 0 end as tags_Damage           
,case when tags='GoldPer' then 1 else 0 end as tags_GoldPer          
,case when tags='Health' then 1 else 0 end as tags_Health           
,case when tags='HealthRegen' then 1 else 0 end as tags_HealthRegen      
,case when tags='Jungle' then 1 else 0 end as tags_Jungle           
,case when tags='Lane' then 1 else 0 end as tags_Lane             
,case when tags='LifeSteal' then 1 else 0 end as tags_LifeSteal        
,case when tags='MagicPenetration' then 1 else 0 end as tags_MagicPenetration 
,case when tags='Mana' then 1 else 0 end as tags_Mana             
,case when tags='ManaRegen' then 1 else 0 end as tags_ManaRegen        
,case when tags='Movement' then 1 else 0 end as tags_Movement         
,case when tags='NonbootsMovement' then 1 else 0 end as tags_NonbootsMovement 
,case when tags='OnHit' then 1 else 0 end as tags_OnHit            
,case when tags='Slow' then 1 else 0 end as tags_Slow             
,case when tags='SpellBlock' then 1 else 0 end as tags_SpellBlock       
,case when tags='SpellDamage' then 1 else 0 end as tags_SpellDamage      
,case when tags='SpellVamp' then 1 else 0 end as tags_SpellVamp        
,case when tags='Stealth' then 1 else 0 end as tags_Stealth          
,case when tags='Tenacity' then 1 else 0 end as tags_Tenacity         
,case when tags='Trinket' then 1 else 0 end as tags_Trinket          
,case when tags='Vision' then 1 else 0 end as tags_Vision                  

	, max(`Into`) as `into`,max(GoldPurchasable) as GoldPurchasable
	,max(GoldBase) as GoldBase,max(goldSell) as goldSell,max(goldTotal) as goldTotal
	,max(map1) as map1,max(map8) as map8,max(map10) as map10,max(map12) as map12,max(depth) as depth
	,max(consumed) as consumed,max(stacks) as stacks,max(consumeOnFull) as consumeOnFull
	,max(specialRecipe) as specialRecipe,max(inStore) as inStore
	,max(requiredChampion) as requiredChampion,max(Effect1Amount) as Effect1Amount
	,max(Effect2Amount) as Effect2Amount,max(Effect3Amount) as Effect3Amount
	,max(Effect4Amount) as Effect4Amount,max(Effect5Amount) as Effect5Amount
	,max(Effect6Amount) as Effect6Amount,max(Effect7Amount) as Effect7Amount
	,max(Effect8Amount) as Effect8Amount,max(FlatHPPoolMod) as FlatHPPoolMod,max(FlatMPPoolMod) as FlatMPPoolMod
	,max(PercentHPPoolMod) as PercentHPPoolMod,max(PercentMPPoolMod) as PercentMPPoolMod
	,max(FlatHPRegenMod) as FlatHPRegenMod,max(PercentHPRegenMod) as PercentHPRegenMod
	,max(FlatMPRegenMod) as FlatMPRegenMod,max(PercentMPRegenMod) as PercentMPRegenMod
	,max(FlatArmorMod) as FlatArmorMod,max(PercentArmorMod) as PercentArmorMod
	,max(FlatPhysicalDamageMod) as FlatPhysicalDamageMod,max(PercentPhysicalDamageMod) as PercentPhysicalDamageMod
	,max(FlatMagicDamageMod) as FlatMagicDamageMod
	,max(PercentMagicDamageMod) as PercentMagicDamageMod,max(FlatMovementSpeedMod) as FlatMovementSpeedMod
	,max(PercentMovementSpeedMod) as PercentMovementSpeedMod
	,max(FlatAttackSpeedMod) as FlatAttackSpeedMod,max(PercentAttackSpeedMod) as PercentAttackSpeedMod
	,max(PercentDodgeMod) as PercentDodgeMod,max(FlatCritChanceMod) as FlatCritChanceMod
	,max(PercentCritChanceMod) as PercentCritChanceMod,max(FlatCritDamageMod) as FlatCritDamageMod
	,max(PercentCritDamageMod) as PercentCritDamageMod,max(FlatBlockMod) as FlatBlockMod
	,max(PercentBlockMod) as PercentBlockMod,max(FlatSpellBlockMod) as FlatSpellBlockMod
	,max(PercentSpellBlockMod) as PercentSpellBlockMod,max(FlatEXPBonus) as FlatEXPBonus
	,max(FlatEnergyRegenMod) as FlatEnergyRegenMod,max(FlatEnergyPoolMod) as FlatEnergyPoolMod
	,max(PercentLifeStealMod) as PercentLifeStealMod,max(PercentSpellVampMod) as PercentSpellVampMod
	from lol.items group by ID,version;

# add index to speed up join
alter table lol.items_rollup
add index IDVersion (ID,version);*/
alter table lol.timelineevents_150610_derive_getVersion
modify itemId int,
modify version varchar(10),
add index itemIdVersion (itemId,version);

# 05 - join the item stats to timelineevents table 
drop table if exists lol.timelineevents_item_150610;
create table lol.timelineevents_item_150610 as
select gameId,a.version,a.win,participantFrames,`type`,participantId,itemId
# table a
,gameMinutes,gameMode,gameType,seasonId,championId,spell1Id,spell2Id
,highestAchievedSeasonTier,role,lane
,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
	
,Num_Building_Killed,Num_Assisting_Player,KilledByPlayer
,Num_Victim,Num_Ward_Used,skillSlot,position_x,position_y,ts_add
# item stats
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
from lol.timelineevents_150610_derive_getVersion as a
left join lol.items_rollup as b 	# roll up the items table due to multiple tags per item
on a.itemId=b.ID and a.version=b.version;

# add index to speed up aggregation
alter table lol.timelineevents_item_150610
modify participantId int,
add index gameIdParIdFrame (gameId,participantId,participantFrames);

# 06 - aggregate timelineevent to one record per frame 
 drop table if exists lol.timelineevents_item_150610_rollup;
 create table lol.timelineevents_item_150610_rollup as 
 select gameId,max(version) as version,max(win) as win,participantFrames
, sum(case when `type`='ITEM_PURCHASED' then 1 else 0 end) as Num_ItemPurchased
, sum(case when `type`='ITEM_SOLD' then 1 else 0 end) as Num_ItemSold
, sum(case when `type`='SKILL_LEVEL_UP' then 1 else 0 end) as Num_SkillLevelUp
#, sum(case when `type`='WARD_PLACED' then 1 else 0 end) as Num_Ward_Place
#, sum(case when `type`='BUILDING_KILL' then 1 else 0 end) as Num_BldKilled
, sum(case when `type`='CHAMPION_KILL' then 1 else 0 end) as Num_ChampKilled
, sum(case when `type`='ELITE_MONSTER_KILL' then 1 else 0 end) as Num_MonsterKilled
#,type
,participantId,GROUP_CONCAT(itemId) as itemId
,max(gameMinutes) as gameMinutes,max(gameMode) as gameMode,max(gameType) as gameType
,max(seasonId) as seasonId,max(championId) as championId,max(spell1Id) as spell1Id,max(spell2Id) as spell2Id
,max(highestAchievedSeasonTier) as highestAchievedSeasonTier,max(role) as role,max(lane) as lane
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

,sum(Num_Building_Killed) as Num_Building_Killed,sum(Num_Assisting_Player) as Num_Assisting_Player
,sum(KilledByPlayer) as KilledByPlayer,sum(Num_Victim) as Num_Victim
,sum(Num_Ward_Used) as Num_Ward_Used
,sum(case when skillSlot='1' then 1 else 0 end) as skillSlot1
,sum(case when skillSlot='2' then 1 else 0 end) as skillSlot2
,sum(case when skillSlot='3' then 1 else 0 end) as skillSlot3
,sum(case when skillSlot='4' then 1 else 0 end) as skillSlot4
,avg(position_x) as position_x,avg(position_y) as position_y
#,ts_add
# item stats,Name as itemName,description as itemDescription,`group` as itemGroup
,case when `type` = 'ITEM_PURCHASED' then sum(goldbase) else 0 end as goldSpent	# negative for spending
,case when `type` = 'ITEM_SOLD' then sum(goldsell) else 0 end as goldRecoup	# positive for recouping 
,case when `type` = 'ITEM_PURCHASED' then count(consumed) else 0 end as num_consumed
#,goldBase,goldTotal,goldSell
, sum(tags_Active) as tags_Active, sum(tags_Armor) as tags_Armor, sum(tags_ArmorPenetration) as tags_ArmorPenetration
, sum(tags_AttackSpeed) as  tags_AttackSpeed     
, sum(tags_Aura) as tags_Aura, sum(tags_Boots) as tags_Boots, sum(tags_Consumable) as tags_Consumable, sum(tags_CooldownReduction) as tags_CooldownReduction
, sum(tags_CriticalStrike) as tags_CriticalStrike, sum(tags_Damage) as tags_Damage, sum(tags_GoldPer) as tags_GoldPer, sum(tags_Health) as tags_Health       
, sum(tags_HealthRegen) as tags_HealthRegen, sum(tags_Jungle) as tags_Jungle, sum(tags_Lane) as tags_Lane, sum(tags_LifeSteal) as tags_LifeSteal      
, sum(tags_MagicPenetration) as tags_MagicPenetration, sum(tags_Mana) as tags_Mana, sum(tags_ManaRegen) as tags_ManaRegen, sum(tags_Movement) as tags_Movement         
, sum(tags_NonbootsMovement) as tags_NonbootsMovement, sum(tags_OnHit) as tags_OnHit, sum(tags_Slow) as tags_Slow, sum(tags_SpellBlock) as tags_SpellBlock       
, sum(tags_SpellDamage) as tags_SpellDamage, sum(tags_SpellVamp) as tags_SpellVamp, sum(tags_Stealth) as tags_Stealth, sum(tags_Tenacity) as tags_Tenacity        
, sum(tags_Trinket) as tags_Trinket, sum(tags_Vision) as tags_Vision
#,PlainText as itemPlainText
#,consumed,specialRecipe
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
from lol.timelineevents_item_150610
group by gameId,participantId,participantFrames;

# added index to speed up join
#alter table lol.timelines_150610
#add index gameIdParIdFrame (gameId,participantId,participantFrames);
alter table lol.timelineevents_item_150610_rollup
add index gameIdParIdFrame (gameId,participantId,participantFrames);

# 07 - join events to timeline
drop table if exists lol.timeline_event_join_150528;
create table lol.timeline_event_join_150528 as
select a.gameId, version, win,a.participantFrames
,gameMinutes,gameMode,gameType,seasonId,championId,spell1Id,spell2Id
,highestAchievedSeasonTier,role,lane, a.participantId, itemId  
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10

,IFNULL(Num_ItemPurchased,0) as Num_ItemPurchased, IFNULL(Num_ItemSold,0) as Num_ItemSold   
, IFNULL(Num_SkillLevelUp,0) as Num_SkillLevelUp
#, Num_Ward_Place
#, Num_BldKilled
, IFNULL(Num_ChampKilled,0) as Num_ChampKilled, IFNULL(Num_MonsterKilled,0) as Num_MonsterKilled
                 
, IFNULL(Num_Building_Killed,0) as Num_Building_Killed, IFNULL(Num_Assisting_Player,0) as Num_Assisting_Player
, IFNULL(KilledByPlayer,0) as KilledByPlayer, IFNULL(Num_Victim,0) as Num_Victim
, IFNULL(Num_Ward_Used,0) as Num_Ward_Used           
, skillSlot1, skillSlot2, skillSlot3, skillSlot4, a.position_x, a.position_y
, b.position_x as champKilled_position_x,b.position_y as champKilled_position_y                                       
, goldSpent, goldRecoup, num_consumed
, tags_Active, tags_Armor, tags_ArmorPenetration, tags_AttackSpeed      
, tags_Aura, tags_Boots, tags_Consumable, tags_CooldownReduction
, tags_CriticalStrike, tags_Damage, tags_GoldPer, tags_Health           
, tags_HealthRegen, tags_Jungle, tags_Lane, tags_LifeSteal        
, tags_MagicPenetration, tags_Mana, tags_ManaRegen, tags_Movement         
, tags_NonbootsMovement, tags_OnHit, tags_Slow, tags_SpellBlock       
, tags_SpellDamage, tags_SpellVamp, tags_Stealth, tags_Tenacity         
, tags_Trinket, tags_Vision 
, FlatHPPoolMod, FlatMPPoolMod, PercentHPPoolMod, PercentMPPoolMod, FlatHPRegenMod           
, PercentHPRegenMod, FlatMPRegenMod, PercentMPRegenMod, FlatArmorMod, PercentArmorMod          
, FlatPhysicalDamageMod, PercentPhysicalDamageMod, FlatMagicDamageMod, PercentMagicDamageMod    
, FlatMovementSpeedMod, PercentMovementSpeedMod, FlatAttackSpeedMod, PercentAttackSpeedMod    
, PercentDodgeMod, FlatCritChanceMod, PercentCritChanceMod, FlatCritDamageMod        
, PercentCritDamageMod, FlatBlockMod, PercentBlockMod, FlatSpellBlockMod        
, PercentSpellBlockMod, FlatEXPBonus, FlatEnergyRegenMod, FlatEnergyPoolMod        
, PercentLifeStealMod, PercentSpellVampMod 
# table a
, currentGold, totalGold, level, xp, minionsKilled, jungleMinionsKilled
, IFNULL(dominionScore,0) as dominionScore, IFNULL(teamScore,0) as teamScore         
from (select * from lol.timelines_150528 where gameId in (select distinct gameId from lol.timelineevents_item_150528_rollup)) as a
left join lol.timelineevents_item_150528_rollup as b
on a.gameId=b.gameId
and a.participantId=b.participantId
and a.participantFrames=b.participantFrames;



alter table lol.timeline_event_join_150528
#add index gameId (gameId),
modify minionsKilled int,
modify jungleMinionsKilled int,
modify currentGold int,
modify totalGold int,
modify level int,
modify xp int,
modify dominionScore int,
modify teamScore int;


# 08 - add rank column to the table
drop table if exists lol.timeline_event_join_150528_ranked;
create table lol.timeline_event_join_150528_ranked as
select a.*,
case when @prev_value=gameId then @rank
	 when @prev_value:=gameId then @rank:=@rank+1 end as rank

from lol.timeline_event_join_150528 as a,(select @rank:= 0, @prev_value := NULL ) as b
order by gameId; 



# clean up===============================================================================
# 02
drop table lol.timelineevents_150610_derive;
# 03
drop table lol.timelineevents_150610_derive_getVersion;
# 05
drop table lol.timelineevents_item_150610;
# 06
drop table lol.timelineevents_item_150610_rollup;
# 07
drop table lol.timeline_event_join_150528;



