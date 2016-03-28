# 04 - aggregated columns that don't have participantId by gameId and frames. attach them later
/*drop table if exists lol.timelineevents_150610_derive_agg;*/
create table lol.timelineevents_nameDate_derive_agg (index gameIdFrames (gameId,participantFrames)) as
select gameId,participantFrames,sum(Num_MonsterKilled) as Num_MonsterKilled
,sum(Num_Ward_Killed) as Num_Ward_Killed,sum(Num_Ward_Place) as Num_Ward_Place
from lol.timelineevents_nameDate_derive
group by gameId,participantFrames;
