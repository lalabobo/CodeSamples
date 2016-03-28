# 12 - attach Num_MonsterKilled, Num_Ward_Killed, Num_Ward_Place
/*drop table exists lol.timelineevents_item_nameDate_rollup_temp4;*/
create table lol.timelineevents_item_nameDate_rollup_temp4 (index gameIdFrame (gameId,participantFrames)) as
select a.*,Num_MonsterKilled,Num_Ward_Killed, Num_Ward_Place
from lol.timelineevents_item_nameDate_rollup_temp3 as a
left join  
  (select gameId, participantFrames,Num_MonsterKilled,Num_Ward_Killed, Num_Ward_Place
    from lol.timelineevents_nameDate_derive_agg) as b
on a.gameId = b.gameId and a.participantFrames = b.participantFrames; 
