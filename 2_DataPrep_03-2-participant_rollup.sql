# 02 - create derived variables from timelineevents table
create table lol.timelineevents_nameDate_derive as 
select gameId,participantFrames,`type`,assistingParticipantIds,skillSlot,itemId
, case when `type`='BUILDING_KILL' and killerId is not NULL and killerId!='NA' then killerId 
	   when (`type`='CHAMPION_KILL' and victimId!=0  and victimId!='NA') then killerId
	   when participantId = 'NA' or participantId is NULL or participantId='' then 0  /* for ward_placed etc, the participantId is NA or NULL */
	   else participantId end as participantId
/* assistingParticipantIds can have NULL, NA, '' and numbers */
, case when `type`='BUILDING_KILL' and assistingParticipantIds is not Null and assistingParticipantIds!='NA' and assistingParticipantIds !=''
		then (LENGTH(assistingParticipantIds) - LENGTH(REPLACE(assistingParticipantIds,',',''))+1) 
	   when (`type`='CHAMPION_KILL' and assistingParticipantIds is not Null and assistingParticipantIds!='NA' and assistingParticipantIds!='') 
		then (LENGTH(assistingParticipantIds) - LENGTH(REPLACE(assistingParticipantIds,',',''))+1) 
	   else 0 end as Num_Assisting_Player  # 0 if no assisting player
, case when (`type`='CHAMPION_KILL' and victimId!=0  and victimId!='NA') 
	then victimId else 0 end as victimId  # replace Null and NA with 0
, case when `type`= 'ELITE_MONSTER_KILL' and killerId is not Null and killerId!='NA' 
	then 1 else 0 end as Num_MonsterKilled   /* no participantId. need to aggregated by gameId and frame */
, case when `type`= 'WARD_KILL' and killerId is not Null and killerId!='NA' 
	then 1 else 0 end as Num_Ward_Killed   /* no participantId. need to aggregated by gameId and frame */
, case when `type` =  "WARD_PLACED"
	then 1 else 0 end as Num_Ward_Place   /* no participantId. need to aggregated by gameId and frame */
, case when `type` = 'SKILL_LEVEL_UP' and participantId is not NULL and participantId!='NA' and skillSlot = '1'
	then 1 else 0 end as skillSlot1
, case when `type` = 'SKILL_LEVEL_UP' and participantId is not NULL and participantId!='NA' and skillSlot = '2'
	then 1 else 0 end as skillSlot2
, case when `type` = 'SKILL_LEVEL_UP' and participantId is not NULL and participantId!='NA' and skillSlot = '3'
	then 1 else 0 end as skillSlot3
, case when `type` = 'SKILL_LEVEL_UP' and participantId is not NULL and participantId!='NA' and skillSlot = '4'
	then 1 else 0 end as skillSlot4

, case when `type`='ITEM_PURCHASED' then 1 else 0 end as Num_ItemPurchased
, case when `type`='ITEM_SOLD' then 1 else 0 end as Num_ItemSold
, case when `type`='BUILDING_KILL' then 1 else 0 end as Num_KilledBld
, case when `type`='CHAMPION_KILL' then 1 else 0 end as Num_KilledChamp
, case when position_x='NA' then NULL else position_x end as position_x
, case when position_y='NA' then NULL else position_y end as position_y
, ts_add
, ID as timelineevents_ID 
, 0 as assistingPlayerId  # default value
from lol.timelineevents_nameDate;	
