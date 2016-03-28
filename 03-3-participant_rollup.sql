# 03 - decompose string in column assistingParticipantIds
/* extract those that have assisting players,  and decompose the string into single participantId  
	This will later be attached in 06, only to capture who assist and die*/
/*drop table if exists lol.timelineevents_nameDate_derive_temp;*/
create table lol.timelineevents_nameDate_derive_temp (index gameIdFrames (gameId,participantFrames)) as 
select gameId,participantFrames,`type`,itemId
, assistingParticipantIds
, skillSlot
, participantId
, Num_Assisting_Player
, victimId
, Num_MonsterKilled
, Num_Ward_Killed
, Num_Ward_Place
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
,ts_add,timelineevents_ID
, SUBSTRING_INDEX(SUBSTRING_INDEX(assistingParticipantIds, ',', n.digit+1), ',', -1) as assistingPlayerId
from lol.timelineevents_nameDate_derive
  INNER JOIN  /* this increase the row number as one kill can have multiple assisting players*/
  (SELECT 0 digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) n
  ON LENGTH(REPLACE(assistingParticipantIds, ',' , '')) <= LENGTH(assistingParticipantIds)-n.digit  # notice that this exlucde assistingParticipantIds is NULL
  where assistingParticipantIds is not NULL and assistingParticipantIds!='NA' and assistingParticipantIds!=''
/* where gameId = 1819484402  # for testing*/
ORDER BY
  gameId,participantFrames,assistingParticipantIds;
