# 14 - add rank column to the table
/*drop table if exists lol.timeline_event_join_nameDate_ranked;*/
create table lol.timeline_event_join_nameDate_ranked (
gameId bigint
,version varchar(10)
,win tinyint
,participantFrames tinyint
,gameCount smallint
,gameMinutes float
,gameMode  varchar(20)
,gameType  varchar(20)
,mapId tinyint
,seasonId  tinyint
,championId  smallint
,spell1Id  tinyint
,spell2Id  tinyint
,highestAchievedSeasonTier  varchar(20)
,role  varchar(20)
,lane  varchar(20)
,participantId tinyint
,itemId  varchar(50)
,masteryId1  smallint
,mrank1  tinyint
,masteryId2  smallint
,mrank2  tinyint
,masteryId3  smallint
,mrank3  tinyint
,masteryId4  smallint
,mrank4  tinyint
,masteryId5  smallint
,mrank5  tinyint
,masteryId6  smallint
,mrank6  tinyint
,masteryId7  smallint
,mrank7  tinyint
,masteryId8  smallint
,mrank8  tinyint
,masteryId9  smallint
,mrank9  tinyint
,masteryId10 smallint
,mrank10 tinyint
,masteryId11 smallint
,mrank11 tinyint
,masteryId12 smallint
,mrank12 tinyint
,masteryId13 smallint
,mrank13 tinyint
,masteryId14 smallint
,mrank14 tinyint
,masteryId15 smallint
,mrank15 tinyint
,masteryId16 smallint
,mrank16 tinyint
,masteryId17 smallint
,mrank17 tinyint
,masteryId18 smallint
,mrank18 tinyint
,masteryId19 smallint
,mrank19 tinyint
,masteryId20 smallint
,mrank20 tinyint
,runeId1 smallint
,rrank1  tinyint
,runeId2 smallint
,rrank2  tinyint
,runeId3 smallint
,rrank3  tinyint
,runeId4 smallint
,rrank4  tinyint
,runeId5 smallint
,rrank5  tinyint
,runeId6 smallint
,rrank6  tinyint
,runeId7 smallint
,rrank7  tinyint
,runeId8 smallint
,rrank8  tinyint
,runeId9 smallint
,rrank9  tinyint
,runeId10  smallint
,rrank10 tinyint
,Num_ItemPurchased smallint
,Num_ItemSold  smallint
,Num_MonsterKilled tinyint
,Num_Ward_Killed smallint
,Num_Ward_Place  smallint
,Num_KilledBld tinyint
,Num_KilledChamp tinyint
,Num_Assisting_Player smallint
,skillSlot1  tinyint
,skillSlot2  tinyint
,skillSlot3  tinyint
,skillSlot4  tinyint
,position_x  smallint
,position_y  smallint
,champKilled_position_x smallint
,champKilled_position_y smallint
,goldSpent smallint
,goldRecoup  smallint
,num_consumed  smallint
,Num_AssistBld tinyint
,Num_AssistChamp tinyint
,Num_Deaths  tinyint
,tags_Active tinyint
,tags_Armor  tinyint
,tags_ArmorPenetration  tinyint
,tags_AttackSpeed  tinyint
,tags_Aura tinyint
,tags_Boots  tinyint
,tags_Consumable tinyint
,tags_CooldownReduction tinyint
,tags_CriticalStrike  tinyint
,tags_Damage tinyint
,tags_GoldPer  tinyint
,tags_Health tinyint
,tags_HealthRegen  tinyint
,tags_Jungle tinyint
,tags_Lane tinyint
,tags_LifeSteal  tinyint
,tags_MagicPenetration  tinyint
,tags_Mana tinyint
,tags_ManaRegen  tinyint
,tags_Movement tinyint
,tags_NonbootsMovement  tinyint
,tags_OnHit  tinyint
,tags_Slow tinyint
,tags_SpellBlock tinyint
,tags_SpellDamage  tinyint
,tags_SpellVamp  tinyint
,tags_Stealth  tinyint
,tags_Tenacity tinyint
,tags_Trinket  tinyint
,tags_Vision tinyint
,FlatHPPoolMod float
,FlatMPPoolMod float
,PercentHPPoolMod    float
,PercentMPPoolMod    float
,FlatHPRegenMod float
,PercentHPRegenMod   float
,FlatMPRegenMod float
,PercentMPRegenMod   float
,FlatArmorMod  float
,PercentArmorMod float
,FlatPhysicalDamageMod float
,PercentPhysicalDamageMod   float
,FlatMagicDamageMod  float
,PercentMagicDamageMod float
,FlatMovementSpeedMod  float
,PercentMovementSpeedMod    float
,FlatAttackSpeedMod  float
,PercentAttackSpeedMod float
,PercentDodgeMod float
,FlatCritChanceMod   float
,PercentCritChanceMod  float
,FlatCritDamageMod   float
,PercentCritDamageMod  float
,FlatBlockMod  float
,PercentBlockMod float
,FlatSpellBlockMod   float
,PercentSpellBlockMod  float
,FlatEXPBonus  float
,FlatEnergyRegenMod  float
,FlatEnergyPoolMod   float
,PercentLifeStealMod float
,PercentSpellVampMod float
,currentGold smallint
,totalGold smallint
,level tinyint
,xp  smallint
,minionsKilled smallint
,jungleMinionsKilled  smallint
,rank  smallint
) as
select gameId                    
,version                   
,win                       
,participantFrames         
,gameCount                 
,gameMinutes               
,gameMode                  
,gameType                  
,mapId                     
,seasonId                  
,championId                
,spell1Id                  
,spell2Id                  
,highestAchievedSeasonTier 
,role                      
,lane                      
,participantId             
,itemId                    
,masteryId1                
,mrank1                    
,masteryId2                
,mrank2                    
,masteryId3                
,mrank3                    
,masteryId4                
,mrank4                    
,masteryId5                
,mrank5                    
,masteryId6                
,mrank6                    
,masteryId7                
,mrank7                    
,masteryId8                
,mrank8                    
,masteryId9                
,mrank9                    
,masteryId10               
,mrank10                   
,masteryId11               
,mrank11                   
,masteryId12               
,mrank12                   
,masteryId13               
,mrank13                   
,masteryId14               
,mrank14                   
,masteryId15               
,mrank15                   
,masteryId16               
,mrank16                   
,masteryId17               
,mrank17                   
,masteryId18               
,mrank18                   
,masteryId19               
,mrank19                   
,masteryId20               
,mrank20                   
,runeId1                   
,rrank1                    
,runeId2                   
,rrank2                    
,runeId3                   
,rrank3                    
,runeId4                   
,rrank4                    
,runeId5                   
,rrank5                    
,runeId6                   
,rrank6                    
,runeId7                   
,rrank7                    
,runeId8                   
,rrank8                    
,runeId9                   
,rrank9                    
,runeId10                  
,rrank10                   
,Num_ItemPurchased         
,Num_ItemSold              
,Num_MonsterKilled         
,Num_Ward_Killed           
,Num_Ward_Place            
,Num_KilledBld             
,Num_KilledChamp           
,Num_Assisting_Player      
,skillSlot1                
,skillSlot2                
,skillSlot3                
,skillSlot4                
,position_x                
,position_y                
,champKilled_position_x    
,champKilled_position_y    
,goldSpent                 
,goldRecoup                
,num_consumed              
,Num_AssistBld             
,Num_AssistChamp           
,Num_Deaths                
,tags_Active               
,tags_Armor                
,tags_ArmorPenetration     
,tags_AttackSpeed          
,tags_Aura                 
,tags_Boots                
,tags_Consumable           
,tags_CooldownReduction    
,tags_CriticalStrike       
,tags_Damage               
,tags_GoldPer              
,tags_Health               
,tags_HealthRegen          
,tags_Jungle               
,tags_Lane                 
,tags_LifeSteal            
,tags_MagicPenetration     
,tags_Mana                 
,tags_ManaRegen            
,tags_Movement             
,tags_NonbootsMovement     
,tags_OnHit                
,tags_Slow                 
,tags_SpellBlock           
,tags_SpellDamage          
,tags_SpellVamp            
,tags_Stealth              
,tags_Tenacity             
,tags_Trinket              
,tags_Vision               
,FlatHPPoolMod             
,FlatMPPoolMod             
,PercentHPPoolMod          
,PercentMPPoolMod          
,FlatHPRegenMod            
,PercentHPRegenMod         
,FlatMPRegenMod            
,PercentMPRegenMod         
,FlatArmorMod              
,PercentArmorMod           
,FlatPhysicalDamageMod     
,PercentPhysicalDamageMod  
,FlatMagicDamageMod        
,PercentMagicDamageMod     
,FlatMovementSpeedMod      
,PercentMovementSpeedMod   
,FlatAttackSpeedMod        
,PercentAttackSpeedMod     
,PercentDodgeMod           
,FlatCritChanceMod         
,PercentCritChanceMod      
,FlatCritDamageMod         
,PercentCritDamageMod      
,FlatBlockMod              
,PercentBlockMod           
,FlatSpellBlockMod         
,PercentSpellBlockMod      
,FlatEXPBonus              
,FlatEnergyRegenMod        
,FlatEnergyPoolMod         
,PercentLifeStealMod       
,PercentSpellVampMod       
,currentGold               
,totalGold                 
,level                     
,xp                        
,minionsKilled             
,jungleMinionsKilled       
,case when @prev_value=gameId then @rank   /* for the same gameId, take the same rank; otherwise, incremet rank by 1*/
      when @prev_value:=gameId then @rank:=@rank+1 end as `rank`

from lol.timeline_event_join_nameDate as a,(select @rank:= 0, @prev_value := NULL ) as b /* @rank := 0 is equivalent to 
Declare @rank int;
set @rank = 0;
select @rank */
order by gameId; 
