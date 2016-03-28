# 11 - attach Num_Deaths	
/* drop table if exists lol.timelineevents_item_nameDate_rollup_temp3; */
create table lol.timelineevents_item_nameDate_rollup_temp3 (index gameIdParIdFrame (gameId,participantId,participantFrames)) as
select a.*,IFNULL(b.Num_Deaths,0) as Num_Deaths	
from lol.timelineevents_item_nameDate_rollup_temp2 as a
left join  
  (select gameId, participantFrames,victimId,count(*) as Num_Deaths 
   from lol.timelineevents_nameDate_derive_temp
	where `type`='CHAMPION_KILL' and victimId is not NULL
	group by gameId,victimId,participantFrames) as b
on a.gameId = b.gameId and a.participantFrames = b.participantFrames and participantId = victimId;
