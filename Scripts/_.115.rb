module Quest
  
    SUB_TRUE = [ #0-No  #1-Management variable #2-Type  #3-Order location                         #4-Client         #5-Reward              #6-Recommended LV
            [SUB.size + 1,   101,         "Extermination", "Sagittarius Castle Lower Town  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "4000\eg,\edbi[i,6]", "48～", 
            "Dark Forces", #7-Title
            #8-Details
            "We have received reports that the \edb[e,1] and \edb[e,5] around the lower town have been enveloped by dark forces\nand have become ferocious. It is dangerous to leave them\nbe, so please exterminate 5 of each \edb[e,92] and\n\edb[e,91].\n\n\edb[e,92] Extermination Remaining \eqkm[92] bodies\n\edb[e,91] Extermination Remaining \eqkm[91] bodies",
            #9-Completion condition hash
            {92=>5, 91=>5}, 
            #10-Reward hash
            {"g"=>4000, "6 i"=>1},
            ],
            
            [SUB.size + 2,   102,      "Extermination", "Sagittarius Castle Lower Town  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,20]×2\n\edbi[i,46]×2", "48～", 
            "The Black Beast", 
            "The \edb[e,17] in Glear Cave have transformed into \edb[e,93] due to the power of darkness.\nGlear Cave is a crucial route connecting Sagittarius and Lagras. We cannot allow dangerous\nmonsters to overrun it, so please exterminate 5 of the \edb[e,93].\n\n\edb[e,93] Extermination Remaining \eqkm[93] bodies",
            {93=>5}, 
            {"20 i"=>2, "46 i"=>2},
            ],
            
            [SUB.size + 3,   103,      "Delivery", "Sagittarius Castle Lower Town  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,286]", "--", 
            "A New Mineral", 
            "Since the surge in monster ferocity, the kinds of materials obtainable around the lower town\nhave changed. For this request, please deliver 4 units of the mineral \edbi[i,336]\ncollectable in Glear Cave.\n\n\edbi[i,336]  Required 4 / In possession \eqin[i,336]",
            {"336 i"=>4},
            {"286 i"=>1},
            ],
            
            [SUB.size + 4,   104,      "Other", "Sagittarius Castle Lower Town  East Area・Magic Academy Main Gate", "Summoning Instructor Salvia", "New technique release for class \esm", "52～", 
            "Master and Pupil Showdown!", 
            "After reuniting with my summoning teacher, Salvia, from my academy days, I learned that the academy\nhas been temporarily closed due to recent commotions and that she has been idle. Since the opportunity\nhas arisen, let's spar and show her what I've learned on my journey.",
            {},
            {},
            ],
            
            [SUB.size + 5,   105,      "Delivery", "Forest Village Robe  Village Chief's House", "\esb[11]", "\edbi[a,294],\edbi[i,24]", "--", 
            "A New Staff", 
            "In order to combat the ferocious monsters, Sara has requested a \edbi[w,11], a staff that enhances\nher natural affinity for light magic. \edbi[w,11] can be acquired at the Sagittarius\nweapon and synthesis shop.\n\n\edbi[w,11]  Required 1 / In possession \eqin[w,11]",
            {"11 w"=>1},
            {"294 a"=>1, "24 i"=>1},
            ],
            
            [SUB.size + 6,   106,      "Boss Hunt", "Forest Village Robe  Tavern and Inn Ground Floor", "\emob[m2]", "\edbi[i,256]", "56～", 
            "Queen Bee Invasion", 
            "A queen bee \eimp\edb[e,138]\ec[0] has appeared in the southern area of the Rizel Forest. For now, she remains\nwithin her territory, so no damage has been reported, but there's no telling when her mood may change\nand she attacks the village. Therefore, she needs to be taken out while there's still a chance. Her location\nis where the previous \edb[e,8] infestation happened, at a pond in the \eimp southern area.\ec[0]",
            #9-Completion condition hash
            {},
            #10-Reward hash
            {"256 i"=>1},
            {"v"=>[[60,6,2]], "t"=>"This quest can be taken after clearing Quest No.10"}
            ],
            
            [SUB.size + 7,   107,      "Delivery", "Commercial Town Lagras  Adventurer's Guild", "Aspiring Gentleman", "10000\eg", "54～", 
            "Aiming for Gentility", 
            "We have a request from someone aspiring to be a gentleman. Around \eimpSenesio\ec[0],\nnew monsters called \eimp\edb[e,102]\ec[0] have started appearing, dropping an item called \eimp\edbi[i,306]\ec[0].\nPlease deliver 3 of these \edbi[i,306].\n\n\edbi[i,306]  Required 3 / In possession \eqin[i,306]",
            {"306 i"=>3},
            {"g"=>10000},
            ],
            
            [SUB.size + 8,   108,      "Extermination", "Commercial Town Lagras  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,352]", "58～", 
            "Electric Lizard", 
            "In Timor Mountain and its surroundings, a new kind of lizard called \edb[e,104],\ncharged with electricity, has been sighted. Please take out 4 \edb[e,104].\n\n\edb[e,104] Extermination  Remaining \eqkm[104] bodies",
            {104=>4},
            {"352 a"=>1},
            ],
            
            [SUB.size + 9,   109,      "Boss Hunt", "Commercial Town Lagras  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "5000\eg,\edbi[i,195]", "55～", 
            "Mother Ant", 
            "A superior species to \edb[e,7], the \eimp\edb[e,139]\ec[0] has been spotted \nin Glear Cave. Mother ants continuously produce offspring, leading to an \noverpopulation of \edb[e,7] in the cave.\nTo prevent this, please exterminate the \edb[e,139]. \nThe location is on the western side of the middle\nslope with the \eimp teleportation circle.\ec[0]",
            {},
            {"g"=>5000, "195 i"=>1},
            ],
            
            [SUB.size + 10,   110,      "Delivery", "Port City Senesio  In front of the Weapon Shop", "\eshop[we2]", "\edbi[i,48] sword", "--", 
            "Precious Ore", 
            "The daughter of the weapon shop wants to inspire her father's creativity by obtaining an ore called\n\edbi[i,48] that can only be found in Tokiwa. \edbi[i,48] is obtainable only at the end\nof Tokiwa's Sealed Cave, so let's head to the cave to obtain it.\n\n\edbi[i,48]  Required 3 / In possession \eqin[i,48]",
            {"48 i"=>3},
            {"48 w"=>1},
            ],
            
            [SUB.size + 11,   111,      "Extermination", "Nawate Town  Adventurer's Association", "Former Maiden \emob[p12]", "\edbi[a,349]", "58～", 
            "(Former) Maiden's Resentment", 
            "A vengeful shrine maiden who cannot forgive the \edb[e,95] that deflowered her has issued this request.\nTo alleviate her hate, please slaughter the \edb[e,95]. Twelve should be enough to clear her heart.\nYou can find many \edb[e,95] beyond the eastern mountains from the southern ferry.\n\edb[e,95] Extermination  Remaining \eqkm[95] bodies",
            {95=>12},
            {"349 a"=>1},
            ],
            
            [SUB.size + 12,   112,      "Extermination", "Nawate Town  Adventurer's Association", "Guild Receptionist \emob[qp2]", "6000\eg,\edbi[a,292]", "58～", 
            "How Long...?", 
            "The townspeople are unable to sleep due to the \edb[e,96] flying around the town chanting\n'how long... how long...' It's quite unsettling. For the residents' peace of mind, please exterminate\n6 \edb[e,96].\n\n\edb[e,96] Extermination  Remaining \eqkm[96] bodies",
            {96=>6},
            {"g"=>6000, "292 a"=>1},
            ],
            
            [SUB.size + 13,   113,      "Investigation", "Nine Valleys Village  Tsukiha's Mansion Back Room", "Tsukiha", "\edbi[i,346]", "62～", 
            "The Great Youkai! Nine-tailed Fox", 
            "Ever since the revival of the evil dragon, contact with the shrine maidens guarding the massacre stone\nhas been lost. Worried, Tsukiha has asked me to check on them. Let's visit the massacre stone and verify\nthere's no trouble. It's located around the mountains, east from the southern ferry.\n",
            {},
            {"346 i"=>1},
            ],
            
            [SUB.size + 14,   114,      "Errand", "Port Town Sakai  Middle Tier・White-walled House", "Sisters' Parents", "\edbi[w,50]", "--", 
            "To My Daughters", 
            "In Port Town Sakai, I met parents worried about their daughters who left home. According to rumors,\nthe sisters are serving a rich family in Daria. Having received a letter from the parents to their daughters,\nlet's deliver it to the sisters who are said to be working at a wealthy house in the royal city Cactus.",
            {},
            {"50 w"=>1},
            ],
            
            [SUB.size + 15,   115,      "Other", "Frizenia Temple  4th Floor", "\esb[38]", "\en[5] skill", "68～", 
            "Ice Sorceress Queen", 
            "I have met \emobt[snow] of \esbt[38], a friend of Anemone's. She told me\nthat the Ice Sorceress Queen, \emobt[s_queen], has something to discuss with Anemone and Lunaria.\nWhat it could be, I do not know, but in case anything happens, let's prepare properly and speak with\n\esbt[38] waiting at the staircase leading to the top floor of Frizenia Temple’s fourth floor.",
            {},
            {},
            {"s"=>[129], "t"=>"This quest can be taken after clearing Quest No.36"}
            ],
            
            [SUB.size + 16,   116,      "Delivery", "Royal City Cactus  Adventurer's Guild", "Man in Love with Bunny-eared Witches", "\edbi[i,338]×5", "70～", 
            "The Beautiful Bunny-eared Witch", 
            "A man seems to be smitten with the \edb[e,106] and desires their bunny ears. Therefore, he requests that you\ncollect 4 pieces of the \edbi[i,305] they drop. At present, they are said to reside in the\nGaladi area and the Tower of Babel.\n\n\edbi[i,305]  Required 4 / In possession \eqin[i,305]",
            {"305 i"=>4},
            {"338 i"=>5},
            ],
            
            [SUB.size + 17,   117,      "Extermination", "Royal City Cactus  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "25000\eg", "70～", 
            "Underworld Hound Lurking in the Abandoned Mine", 
            "Recently, a haunting howl can be heard from the abandoned mine. Investigation has revealed\nthat a wolf-like monster \edb[e,110] has taken residence in the mine. For the sake of ecosystem\npreservation, please exterminate 6 \edb[e,110].\n\n\edb[e,110] Extermination  Remaining \eqkm[110] bodies",
            {110=>6},
            {"g"=>25000},
            ],
            
            [SUB.size + 18,   118,      "Boss Hunt", "Royal City Cactus  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,302]", "75～", 
            "Mascot Brigade", 
            "An allied army of Hare and Octo has appeared in Hydra Marsh. Despite their cute appearance,\neach is quite a strong individual, and average adventurers can't stand against them. Prepare thoroughly\nfor \eimpconsecutive battles\ec[0] before heading there. The location is past the \eimp royal side\ec[0] of\nthe marsh from the second area towards the west, crossing the stepping stones.\n",
            {},
            {"302 a"=>1},
            ],
            
            [SUB.size + 19,   119,      "Other", "Resort Galadi Beach", "\emob[m26]", "\edbi[a,357],\edbi[a,121]", "75～", 
            "A Wonderful Subject", 
            "I met a pervert whose hobby is taking photos of women in swimsuits. He claims that instead of shooting\njust one subject, it's best to shoot a group of close friends. Let's indulge his request and have Sonia, Mana,\nand myself wear swimsuits for him to photograph us.",
            {},
            {"357 a"=>1, "121 a"=>1},
            ],
            
            [SUB.size + 20,   120,      "Boss Hunt", "Resort Galadi West・In front of a Building", "\emob[m27]", "\edbi[i,347]", "75～", 
            "Monster of Riddles", 
            "A dual-wielding swordsman from Leon Tais Desert has requested that we defeat a monster known as\n\edb[e,140]. If we manage to take it down, he has promised to hand over a book on the\nultimate dual-wielding techniques. \edb[e,140] seems to appear in the \eimp graveyard of bones\ec[0]\nlocated southwest in the second area of the desert from Galadi.\n",
            {},
            {"347 i"=>1},
            ],
            
            [SUB.size + 21,   121,      "Delivery", "Sagittarius Castle Lower Town  Adventurer's Guild", "Salvia", "\edbi[a,119]\n\edbi[a,120]", "--", 
            "Sexy Lingerie", 
            "Could you collect some \edbi[i,308], dropped by high-level female monsters? What I'll use it for?\nOf course, to have our \esm comrades wear it. It might also be interesting to make Velvet wear it\eht.\nThat being said, please deliver 7 pieces of \edbi[i,308].\n\n\edbi[i,308]  Required 7 / In possession \eqin[i,308]",
            {"308 i"=>7},
            {"119 a"=>1, "120 a"=>1},
            {"v"=>[[104,6,2]], "t"=>"This quest can be taken after clearing Quest No.54"}
            ],
            
            [SUB.size + 22,   122,      "Extermination", "Sagittarius Castle Lower Town  Adventurer's Guild", "Guild Receptionist \emob[qp2]", "30000\eg", "75～", 
            "Grim Reaper Hunt", 
            "Someone plagued by nightly appearances of the grim reaper in their dreams and unable to sleep\nrequested this. They say that ever since the floating continent appeared in the sky, the grim reapers\nhave started invading their dreams… Presumably, they are on the floating continent, so please\nexterminate 5 \edb[e,127].\n\n\edb[e,127] Extermination  Remaining \eqkm[127] bodies",
            {127=>5},
            {"g"=>30000},
            ],
            
            [SUB.size + 23,   123,      "Delivery", "Sagittarius Castle Lower Town  Adventurer's Guild", "Gourmet Man", "\edbi[a,365]", "--", 
            "The Ultimate Cuisine", 
            "According to a certain gourmet, grilling an \edbi[i,199] and seasoning it with salt and pepper\nmakes the \edbi[i,326] the ultimate dish...\nHe wants you to prepare 3 plates of \edbi[i,326]. Please have the \edbi[i,199] cooked\nat a restaurant and deliver them.\n\n\edbi[i,326]  Required 3 / In possession \eqin[i,326]",
            {"326 i"=>3},
            {"365 a"=>1},
            ],
           
            [SUB.size + 24,   124,      "Delivery", "Sagittarius Castle Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,301]\nNew products have been added to the assortment of the town's weapons, armor, runes, and refining shops", "--", 
            "Top-Quality Equipment", 
            "On the floating continent in the sky... it is said that the\n\edbi[i,49] mythical metal exists. If you can obtain multiple\n\edbi[i,49], you would be able to create the highest quality\nweapons and armor. Please deliver\eimp\edbi[i,49] eight pieces\ec[0].\n\n\edbi[i,49]　Required: 8 / In possession: \eqin[i,49]",
            {"49 i"=>8},
            {"301 a"=>1},
            ],
 
            [SUB.size + 25,   125,      "Extermination", "Sagittarius Castle Knights' Quarters 2nd Floor", "Knight Commander Drake", "\edbi[i,259]", "76～", 
            "Dragon Slayer", 
            "The Knight Commander has asked to defeat any 5 dragons,\nregardless of type, that reside on the floating continent.\nSubjugating dragon species is the aspiration of every knight.\nLet's subjugate 5 dragons on behalf of the Knight Commander,\nwho cannot go to the floating continent.\n\nDragon species Extermination　Remaining: \eqkmk[D] left",
            {"D"=>5},
            {"259 i"=>1},
            ],
           
  ]
# 変数　0 => 受注不可,　1 => 受注可能(内容不明),　2 => 受注可能,　3 => 受注中
#       4 => 失敗(討伐などで一度敗北),
#       5 => 目的達成（討伐後やアイテム入手後等）,　6 => クエストクリア(報告)
end
