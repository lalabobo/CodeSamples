# 10 - attach Num_AssistChamp
/*drop table if exists lol.timelineevents_item_nameDate_rollup_temp2;*/
create table lol.timelineevents_item_nameDate_rollup_temp2 (index gameIdParIdFrame (gameId,participantId,participantFrames)) as
select a.*,IFNULL(b.Num_AssistChamp,0) as Num_AssistChamp
from lol.timelineevents_item_nameDate_rollup_temp1 as a
left join
  (select gameId,participantFrames,assistingPlayerId,count(*) as Num_AssistChamp 
   from lol.timelineevents_nameDate_derive_temp
	where `type`='CHAMPION_KILL' and assistingPlayerId is not NULL
	group by gameId,assistingPlayerId,participantFrames) as b
on a.gameId = b.gameId and a.participantFrames = b.participantFrames and participantId = assistingPlayerId;
