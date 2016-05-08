# 03 - decompose string in column assistingParticipantIds
/* extract those that have assisting players. It's likely that the column contains a string of participantId when 
there are 1+ participants assisting. Need to decompose the string into single participantId  
This table will later be attached in 06, only to capture who assist and die*/
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
, SUBSTRING_INDEX(SUBSTRING_INDEX(assistingParticipantIds, ',', n.digit+1), ',', -1) as assistingPlayerId  /* SUBSTRING_INDEX(str, delim, count), grab the substr after the nth delim counting from the left.
e.g., SUBSTRING('1,2,3',',',2) = 3. If the count is negative, means counting from right. e.g., SUBSTRING('1,2,3',',',-1) = 2*/ 
from lol.timelineevents_nameDate_derive
  INNER JOIN  /* this increase the row number as one kill can have multiple assisting players*/
  (SELECT 0 digit UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) n  /* create a column called 'digit' with 4 values: 0, 1, 2, 3. The number is equivalent to number or position index of comma. Starting from 0 for cases where only one participant assisted*/
  ON LENGTH(REPLACE(assistingParticipantIds, ',' , '')) <= LENGTH(assitingParticipantIds)-n.digit  /* by doing so, for assistingParticipantIds = '1,2,3', we will have three rows: the string with comma index at 0, comma index at 1 and comma index at 2*/
  /* this exlucde assistingParticipantIds is NULL*/
  where assistingParticipantIds is not NULL and assistingParticipantIds!='NA' and assistingParticipantIds!='' /* situations of assistingParticipantIds is empty or NULL*/
  /* and gameId = 1150180720  # for testing*/
  ORDER BY  gameId,participantFrames,assistingParticipantIds;
