// 1 - enabled, 0 - disabled
Ware_Minigames <-
[
	[1, "airblast"        ],
	[1, "avoid_props"     ],
	[1, "avoid_trains"    ],
	[1, "backstab"        ],
	[1, "bombs"           ],
	[1, "build_this"      ],
	[1, "break_barrel"    ],
	[1, "bullseye"        ],
	[1, "bumpers"         ],
	[1, "caber_king"      ],
	[1, "catch_cubes"     ],
	[1, "count_bombs"     ],
	[1, "disguise"        ],
	[1, "dont_touch"      ],
	[1, "flood"           ],
	[1, "ghost"           ],
	[1, "goomba"          ],
	[1, "headshot"        ],
	[1, "halloween_fight" ],
	[1, "hit_player"      ],
	[1, "hit_balls"       ],
	[1, "kamikaze"        ],
	[1, "math"            ],
	[1, "melee_arena"     ],
	[1, "most_bombs"      ],
	[1, "move"            ],
	[1, "parachute"       ],
	[1, "projectile_jump" ],
	[1, "rocket_rain"     ],
	[1, "sap"             ],
	[1, "sawrun"          ],
	[1, "say_word"        ],
	[1, "shoot_gifts"     ],
	[1, "shoot_target"    ],
	[1, "simon_says"      ],
	[1, "spycrab"         ],
	[1, "stand_near"      ],
	[1, "stay_ground"     ],
	[1, "street_fighter"  ],
	[1, "swim_up"         ],
	[1, "taunt_kill"      ],
	[1, "touch_sky"       ],
	[1, "type_color"      ],
	[1, "water_war"       ],
];

Ware_Location <- {};

Ware_GameSounds <-
[
	"boss",
	"break",
	"break_end",
	"failure",
	"failure_all",
	"gameover",
	"intro",
	"lets_get_started",
	"speedup",
	"victory"
];

Ware_MinigameMusic <-
[
	"actfast",
	"actioninsilence",
	"adventuretime",
	"bliss",
	"cheerful",
	"circus",
	"clumsy",
	"cozy",
	"dizzy",
	"falling",
	"farm",
	"funkymoves",
	"getmoving",
	"getready",
	"golden",
	"goodtimes",
	"heat",
	"keepitup",
	"knockout",
	"morning",
	"ohno",
	"pumpit",
	"question"
	"sillytime",
	"spotlightsonyou",
	"streetfighter",
	"survivor",
	"takeabreak",
	"thethinker",
	"train",
	"wildwest",
];

foreach (sound in Ware_GameSounds)
	PrecacheSound(format("tf2ware_ultimate/music_game/%s.mp3", sound));
foreach (sound in Ware_MinigameMusic)
	PrecacheSound(format("tf2ware_ultimate/music_minigame/%s.mp3", sound));