# 05 - grab the version for timelineevents table
/* drop table if exists lol.timelineevents_nameDate_derive_getVersion;*/
create table lol.timelineevents_nameDate_derive_getVersion as  /* requires 03-99-4-index.sql*/
select  a.gameId,b.version,b.win,participantFrames,`type`,a.participantId,itemId
/* table a*/
,gameCount,gameMinutes,gameMode,gameType,mapId,seasonId,championId,spell1Id,spell2Id
,highestAchievedSeasonTier,role,lane
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
/* additional columns from table a*/
,ts_add,timelineevents_ID
, assistingParticipantIds
, Num_Assisting_Player
, victimId
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
from lol.timelineevents_nameDate_derive as a
left join 
	(select gameId,version,participantId,case when win='Fail' then 0 else 1 end as win 
	,gameCount,gameMinutes,gameMode,gameType,mapId,seasonId,championId,spell1Id,spell2Id
	,highestAchievedSeasonTier,role,lane
	,masteryId1,mrank1
	,masteryId2,mrank2,masteryId3,mrank3,masteryId4,mrank4,masteryId5,mrank5
	,masteryId6,mrank6,masteryId7,mrank7,masteryId8,mrank8,masteryId9,mrank9
	,masteryId10,mrank10,masteryId11,mrank11,masteryId12,mrank12,masteryId13,mrank13
	,masteryId14,mrank14,masteryId15,mrank15,masteryId16,mrank16,masteryId17,mrank17
	,masteryId18,mrank18,masteryId19,mrank19,masteryId20,mrank20
	,runeId1,rrank1,runeId2,rrank2,runeId3,rrank3,runeId4,rrank4,runeId5,rrank5
	,runeId6,rrank6,runeId7,rrank7,runeId8,rrank8,runeId9,rrank9,runeId10,rrank10
	from lol.150528_getVersion) as b 	 /* <- has to be 150528 because all available timeline data are from gameId parsed on 2015-05-28*/
on a.gameId=b.gameId and a.participantId=b.participantId
