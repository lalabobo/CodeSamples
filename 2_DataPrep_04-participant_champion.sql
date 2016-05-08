/* attach champions table to participant_rollup*/
create table lol.participant_champion_nameDate 
select a.*
, champKey
, b.Name as Champ_Name
, b.Attack as Champ_Attack
, b.Defense as Champ_Defense
, b.Magic as Champ_Magic
, b.Difficulty as Champ_Difficulty
, b.Tags as Champ_Tags
, b.parType as Champ_parType
, b.HP as Champ_HP
, b.HPperLevel as Champ_HPperLevel
, b.MP as Champ_MP
, b.MPperLevel as Champ_MPperLevel
, b.MoveSpeed as Champ_MoveSpeed
, b.Armor as Champ_Armor
, b.ArmorPerLevel as Champ_ArmorPerLevel
, b.SpellBlock as Champ_SpellBlock
, b.SpellBlockPerLevel as Champ_SpellBlockPerLevel
, b.AttackRange as Champ_AttackRange
, b.HPregen as Champ_HPregen
, b.HPregenPerLevel as Champ_HPregenPerLevel
, b.MPregen as Champ_MPregen
, b.MPregenPerLevel as Champ_MPregenPerLevel
, b.Crit as Champ_Crit
, b.CritPerLevel as Champ_CritPerLevel
, b.AttackDamage as Champ_AttackDamage
, b.AttackDamagePerLevel as Champ_AttackDamagePerLevel
, b.AttackSpeedOffset as Champ_AttackSpeedOffset
, b.AttackSpeedPerLevel as Champ_AttackSpeedPerLevel
from lol.participant_rollup_nameDate as a
left join lol.champions as b
on a.version=b.version and a.championId=champKey
