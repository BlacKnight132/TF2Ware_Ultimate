Ware_Minigames <-
[
	"airblast"        
	"avoid_props"     
	"avoid_trains"    
	"backstab"        
	"bombs"           
	"build_this"      
	"break_barrel"    
	"bullseye"        
	"bumpers"         
	"caber_king"      
	"catch_cubes"     
	"change_class"    
	"count_bombs"     
	"disguise"        
	"dont_touch"      
	"flood"           
	"ghost"           
	"goomba"          
	"headshot"        
	"halloween_fight" 
	"hit_player"      
	"hit_balls"       
	"hot_potato"      
	"jarate"          
	"kamikaze"        
	"land_platform"   
	"laugh"           
	"math"            
	"melee_arena"     
	"merasmus"        
	"most_bombs"      
	"move"            
	"parachute"       
	"pickup_plate"    
	"piggyback"       
	"pirate"          
	"pop_jack",       
	"projectile_jump" 
	"rocket_rain"     
	"sap"             
	"sawrun"          
	"say_word"        
	"shark"           
	"shoot_gifts"     
	"shoot_target"    
	"simon_says"      
	"spycrab"         
	"stand_near"      
	"stay_ground"     
	"street_fighter"  
	"stun"            
	"swim_up"         
	"taunt_kill"      
	"touch_sky"       
	"type_color"      
	"water_war"       
]

Ware_Bossgames <-
[
	"cuddly_heavies",
]

Ware_GameSounds <-
[
	"boss"
	"break"
	"break_end"
	"failure"
	"failure_all"
	"gameover"
	"intro"
	"lets_get_started"
	"speedup"
	"victory"
]

Ware_MinigameMusic <-
[
	"actfast" 
	"actioninsilence" 
	"adventuretime" 
	"bigjazzfinish" 
	"bliss" 
	"brassy" 
	"catchme" 
	"cheerful" 
	"circus" 
	"clumsy" 
	"cozy" 
	"dizzy" 
	"drumdance" 
	"falling" 
	"farm" 
	"fastbros" 
	"funkymoves" 
	"getmoving" 
	"getready" 
	"golden" 
	"goodtimes" 
	"heat" 
	"keepitup" 
	"knockout" 
	"letsgetquirky" 
	"makemegroove" 
	"morning" 
	"nearend" 
	"ohno" 
	"piper" 
	"pumpit" 
	"question"
	"rockingout",
	"settingthescene" 
	"sillytime" 
	"slowfox" 
	"spotlightsonyou" 
	"streetfighter" 
	"surfin" 
	"survivor" 
	"sweetdays" 
	"takeabreak" 
	"thethinker" 
	"train" 
	"undergroundbros" 
	"wildwest" 
]

Ware_BossgameMusic <-
[
	"casino"
	"cuddly"
	"effort"
	"staredown"
]

foreach (sound in Ware_GameSounds)
	PrecacheSound(format("tf2ware_ultimate/music_game/%s.mp3", sound));
foreach (sound in Ware_MinigameMusic)
	PrecacheSound(format("tf2ware_ultimate/music_minigame/%s.mp3", sound));
foreach (sound in Ware_BossgameMusic)
	PrecacheSound(format("tf2ware_ultimate/music_bossgame/%s.mp3", sound));