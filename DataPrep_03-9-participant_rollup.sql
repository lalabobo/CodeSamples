# 09 -  attach Num_AssistBld
/*drop table if exists lol.timelineevents_item_nameDate_rollup_temp1;*/
create table lol.timelineevents_item_nameDate_rollup_temp1 (index gameIdParIdFrame (gameId,participantId,participantFrames)) as
select a.*,IFNULL(b.Num_AssistBld,0) as Num_AssistBld
from lol.timelineevents_item_nameDate_rollup as a
left join
	(select gameId,participantFrames,assistingPlayerId,count(*) as Num_AssistBld 
	 from lol.timelineevents_nameDate_derive_temp
		where `type`='BUILDING_KILL'
		group by gameId,assistingPlayerId,participantFrames) as b
on a.gameId = b.gameId and a.participantFrames = b.participantFrames and participantId = assistingPlayerId;
