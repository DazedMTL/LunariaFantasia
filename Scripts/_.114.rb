#=begin
module Quest
  
    SUB = [ #0-No  #1-Management Variable #2-Type    #3-Request Location        #4-Requester  #5-Reward   #6-Recommended LV
             [1,   51,         "Delivery",   "Sagittarius Town Adventurer's Guild", "Mariana", "\edbi[a,98]", "--", 
             "Nebapuru Experiment", #7-Title
             #8-Details
             "I need items dropped by \edb[e,1] monsters for\nan upcoming experiment. I'd like you to procure\nabout three of them. Could you do that for me?\n\n\edbi[i,171]　Needed 3/ In Possession \eqin[i,171]",
             #9-Completion Condition Hash
             {"171 i"=>3}, 
             #10-Reward Hash
             {"98 a"=>1}
             ],
             
             [2,   52,         "Extermination",   "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "200\eg、\edbi[i,4]×２", "3～", 
             "Goblin Slayer", #7-Title
             #8-Details
             "Attackers who assault adventurers and merchants\nto steal their goods or kidnap women are the despicable\n\eimp\edb[e,5]. Please subdue six of them.\n\edb[e,5] primarily inhabit the surroundings of Sagittarius\nand the southern area of Rizel Forest.\n\n\edb[e,5] Extermination　Remaining \eqkm[5]",
             #9-Completion Condition Hash
             {5=>6}, 
             #10-Reward Hash
             {"g"=>200, "4 i"=>2}
             ],
             
             [3,   53,      "Extermination", "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,106]", "4～", 
             "Rabbit Hunt", 
             "Please subdue five of the rabbit-like demons\n\eimp\edb[e,6] that inhabit the southern Robe area and\nRizel Forest etc.\n\n\edb[e,6] Extermination　Remaining \eqkm[6]",
             {6=>5},
             {"106 a"=>1}
             ],
             
             [4,   54,      "Delivery", "Sagittarius Town Adventurer's Guild", "Tool Shop", "\edbi[w,2]", "--", 
             "Healing Potion Ingredients", 
             "The tool shop has requested \edbi[i,27] and \edbi[i,32].\nSo please collect five of each \edbi[i,27] and\n\edbi[i,32]. Both can be collected in Rizel Forest.\n\n\edbi[i,27]　Needed 5/ In Possession \eqin[i,27]\n\edbi[i,32]　Needed 5/ In Possession \eqin[i,32]",
             {"27 i"=>5, "32 i"=>5},
             {"2 w"=>1}
             ],
             
             [5,   55,      "Extermination", "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "200\eg、\edbi[i,4]×３", "5～", 
             "Pest Control", 
             "Please subdue five each of the pests \eimp\edb[e,7] and\n\edb[e,8]\ec[0] that inhabit Rizel Forest.\n\edb[e,7] can be found throughout the forest, while\n\edb[e,8] resides in the southern area.\n\n\edb[e,7] Extermination　Remaining \eqkm[7]\n\edb[e,8] Extermination　Remaining \eqkm[8]",
             {7=>5, 8=>5},
             {"g"=>200, "4 i"=>3}
             ],
                        
  #--------Only after clearing the ruins No.6-----------------------------------------------------------------------------------
  
             [6,   56,         "Boss Hunt",   "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "2000\eg", "11～", 
             "Defeat the Giant Slime!", #7-Title
             #8-Details
             "We've received reports of a high-level giant slime\nappearing near the northern area water sites of Rizel Forest.\nPlease exterminate it. There's information that if a\n\eimp female adventurer confronts it alone and loses, she will be violated\ec[0].\nTake extra caution if you go alone. Reports suggest\nthat this creature is resistant to physical attacks.",
             #9-Completion Condition Hash
             {}, 
             #10-Reward Array
             {"g"=>2000},
             #11-Request Conditions and Other Hash. Optional
             {"l"=>[37,40], "h"=>1}
             ],
             
             [7,   57,         "Search",   "Sagittarius Town Near Home", "\emob[f3]", "\edbi[i,116]", "--", 
             "Lost Item", #7-Title
             #8-Details
             "\emob[f3] says she lost her strap somewhere\nin Sagittarius town. Let's search the town and\nfind the bear strap she lost.",
             #9-Completion Condition Hash
             {}, 
             #10-Reward Hash
             {"116 i"=>1}
             ],
             
             [8,   58,      "Delivery", "Sagittarius Town In front of the Restaurant", "\emob[a1_f1]", "\edbi[a,22]", "--", 
             "In Search of Ingredients?", 
             "The restaurant wants to use \edbi[i,75], which grows in forests,\nfor their dishes. Apparently, \edbi[i,75] becomes very\ntasty after detoxifying… Let's collect \edbi[i,75] from\nRizel Forest and give it to \emob[a1_f1].\n\n\edbi[i,75]　Needed 5/ In Possession \eqin[i,75]",
             {"75 i"=>5},
             {"22 a"=>1}
             ],
             
  #--------After one night in Robe-----------------------------------------------------------------------------------
  
             [9,   59,      "Delivery", "Forest Village Robe Chief's House 1st Floor", "\emob[f8]", "500\eg", "--", 
             "Fuzzy", 
             "The \emob[f8] at the chief's house seems to be obsessed\nwith hair-type monsters. Let's collect three \edbi[i,173],\nwhich are dropped by hair creatures, and give them to her.\n\n\edbi[i,173]　Needed 3/ In Possession \eqin[i,173]",
             {"173 i"=>3},
             {"g"=>500}
             ],
  
             [10,   60,      "Boss Hunt", "Forest Village Robe Tavern/Inn 1st Floor", "\emob[m2]", "1000\eg、\edbi[i,93]", "7～", 
             "Bee Swarm", 
             "A huge swarm of \edb[e,8] has appeared at the\npond in the southern area of Rizel Forest. Moreover,\nthese are a bit higher level than others in the forest,\ncreating potential unknown damages if left unchecked. It's\nlikely to be a continuous battle, so prepare\nthoroughly and head to the southern area pond.",
             #9-Completion Condition Hash
             {},
             #10-Reward Hash
             {"g"=>1000, "93 i"=>1}
             ],
             
  #--------After arrival in Ragras, also No.17-----------------------------------------------------------------------------------
  
             [11,   61,      "Delivery", "Commercial Town Ragras Adventurer's Guild", "Street Vendor Food Shop", "800\eg、\edbi[i,113]×２", "--", 
             "Monster Meat", 
             "The food shop has requested the delivery of \nhair-monster's \edbi[i,181] and boar-monster's \edbi[i,180],\nthree each. Boars are found in both north and south caves,\nwhile hairs are around Ragras.\n\n\edbi[i,180]　Needed 3/ In Possession \eqin[i,180]\n\edbi[i,181]　Needed 3/ In Possession \eqin[i,181]",
             {"180 i"=>3, "181 i"=>3},
             {"g"=>800, "113 i"=>2}
             ],
  
             [12,   62,      "Extermination", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,24]、\edbi[a,171]", "10～", 
             "More Goblin Slayers", 
             "There are \edb[e,5] that have high intelligence and\nuse sword skills and \esk[2]. They live in the southern cave.\nPlease subjugate five each of \eimp\edb[e,18]\ \edb[e,19]\ec[0].\n\n\edb[e,18] Extermination　Remaining \eqkm[18]\n\edb[e,19] Extermination　Remaining \eqkm[19]",
             {18=>5, 19=>5},
             {"24 a"=>1, "171 a"=>1},
             {"v"=>[[52,6,0]], "t"=>"You can accept this quest after completing Quest No.02"}
             ],
  
             [13,   63,      "Extermination", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[w,5]", "9～", 
             "Poison Ant Breeding Season", 
             "The poisonous \edb[e,16] started their breeding season.\nTo prevent further proliferation, please subjugate eight\nof them. This creature resides in the Grayer Cave near\nRagras and the south cave of Ragras.\n\n\edb[e,16] Extermination　Remaining \eqkm[16]",
             {16=>8},
             {"5 w"=>1}
             ],
  
  #--------After the morning following the bandit Extermination-----------------------------------------------------------------------------------
  
             [14,   64,      "Delivery", "Commercial Town Ragras Adventurer's Guild", "Street Vendor Material Shop", "1200\eg Monster materials will be added to \nthe Ragras material shop's inventory", "--", 
             "Monster Material Drops", 
             "The material shop wants to handle monster materials.\nSo they need three each of \edbi[i,171] and \edbi[i,174],\nand two of \edbi[i,176].\n\n\edbi[i,171]　Needed 3/ In Possession \eqin[i,171]\n\edbi[i,174]　Needed 3/ In Possession \eqin[i,174]\n\edbi[i,176]　Needed 2/ In Possession \eqin[i,176]",
             {"171 i"=>3, "174 i"=>3, "176 i"=>2},
             {"g"=>1200}
             ],
  
             [15,   65,      "Extermination", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,84]、\edbi[a,106]", "13～", 
             "Snake Hunt", 
             "Timor Mountain is an important route for traffic between Dalia.\nHowever, the mountain path is dangerous due to numerous\nsnake monsters 'edb[e,23]' living there. For\nthe sake of those who travel between the two countries,\nplease subjugate six \eimp\edb[e,23].\n\n\edb[e,23] Extermination　Remaining \eqkm[23]",
             {23=>6},
             {"84 a"=>1, "106 a"=>1}
             ],
  
             [16,   66,      "Extermination", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,113]×２、\edbi[a,257]", "14～", 
             "Snowmen", 
             "\eimpThe area near the summit of Timor Mountain\ec[0] is always\ncovered in snow, and there are monsters that look\nlike snowmen. Please subjugate five \eimp\edb[e,27]\ec[0].\n\n\edb[e,27] Extermination　Remaining \eqkm[27]",
             {27=>5},
             {"113 i"=>2, "257 a"=>1}
             ],
  
             [17,   67,      "Errand", "Commercial Town Ragras Red-Roofed Private House", "\emob[f7]", "\edbi[w,24]、\edbi[a,287]", "14～", 
             "Desire to Be Busty!", 
             "\emob[f7] wants to get her hands on freshly milked\nmilk from the ranch because she's eager to have bigger\nbreasts. It seems there's a ranch by the lake west of\nRagras, so let's ask the ranch owner.\n\eimp If you go with the busty married woman\ec[0],\nsomething special might happen…?",
             {},
             {"287 a"=>1, "24 w"=>1},
             {"h"=>2}
             ],
  
             [18,   68,      "Investigation", "Commercial Town Ragras Mayor's House 2nd Floor", "\emob[p11b]", "\edbi[i,52]", "12～", 
             "What Lurks in the Underground Waterway", 
             "There's something wrong with Ragras' underground\nwaterway. The water quality has deteriorated significantly\nrecently. The purification device prevents any serious\nproblems, but if left unchecked, it could harm the residents.\n\eimp Go through the white building located in the northwest of the town\ec[0]\nand down to the waterway to investigate the cause.",
             {},
             {"52 i"=>1}
             ],
  
             [19,   69,      "Errand", "Timor Mountain Cave Entrance", "\emob[p1_f]", "\edbi[i,2]×２、\n\edbi[i,8]", "--", 
             "Lower the Rope Ladder", 
             "\emob[p1_f] en route over the mountain fears goblins and can't enter\nthe cave leading to the cliff. Without passing through the cave,\nthe mountain cannot be crossed… So he asked us to\ngo through the cave on his behalf and drop the rope ladder\non the other side. Let's complete the mountain path\nby lowering the rope ladder from the cliff on his behalf.",
             {},
             {"2 i"=>2, "8 i"=>1}
             ],
  
  #--------After arrival at the temple-----------------------------------------------------------------------------------
  
             [20,   70,      "Other", "Frizenia Temple 4th Floor Small Room", "\esb[34]", "\edbi[w,6]", "--", 
             "Monster Girl Talk", 
             "Met a \edb[e,28] named Anemone in a small\nroom on the fourth floor of the Frizenia Temple.\nInitially wary, Lunaria gradually warmed up to her\nas they spoke and realized despite being a monster,\nshe bore no malice. Considering becoming friends,\nvisit her again when the opportunity arises.",
             {},
             {"6 w"=>1},
             {"l"=>[38,41]}
             ],
  
  #--------After arrival in Senessio-----------------------------------------------------------------------------------
  
             [21,   71,      "Extermination", "Port Town Senessio Café with Ocean View", "\emob[p2_f]", "\edbi[i,54]", "--", 
             "Octopus Wiener", 
             "A \emob[p2_f] at the port cafe has requested that we\nsubdue \edb[e,34] around \eimpSenessio\ec[0]. Apparently, it makes\nher hungry watching them and is quite bothersome…\n\n\edb[e,34] Extermination　Remaining \eqkm[34]",
             {34=>5},
             {"54 i"=>1}
             ],
             
  #--------After meeting Tsukihana-----------------------------------------------------------------------------------
  
             [22,   72,      "Delivery", "Kujou Village Warehouse", "\emob[f7]", "2000\eg", "--", 
             "Naughty Underwear", 
             "A woman from the village has asked us to collect\nthree \edbi[i,188], which female-shaped demons (monsters)\ndrop. She plans to study them to create a technique to\nseduce men. Female ghosts often appear\n\eimparound the village, Nawate, and the Sealing Cave\ec[0].\n\n\edbi[i,188]　Needed 3/ In Possession \eqin[i,188]",
             {"188 i"=>3},
             {"g"=>2000}
             ],
             
             [23,   73,      "Extermination", "Town of Nawate Adventurers' Association", "Guild Receptionist \emob[qp2]", "\edbi[i,123]、\edbi[i,124]\n\edbi[i,125]、\edbi[i,126]", "20～", 
             "Foreign Goblin Slayer", 
             "The 'edb[e,41]' yokai, who turns pillows to\nconfuse sleeping people, have been spotted\n\eimparound and inside the Sealing Cave\ec[0].\nPlease subjugate five \eimp\edb[e,41].\n\n\edb[e,41] Extermination　Remaining \eqkm[41]",
             {41=>5},
             {"123 i"=>1, "124 i"=>1, "125 i"=>1, "126 i"=>1}
             ],
           
             [24, 74, "Extermination", "Nawate Town Adventurers' Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,64]×2\n1000\eg", "20～",
             "Demonic Youkai",
             "In Tokiwa, there exist demonic youkai that seduce men, kidnap, and consume them. Please subjugate four of each of these youkai \eimp\edb[e,42] and\n\edb[e,43](Jorougumo). Both inhabit the Sealed Cave from the midway point onwards.\n\n\edb[e,42] Extermination　Remaining \eqkm[42] bodies\n\edb[e,43] Extermination　Remaining \eqkm[43] bodies",
             {42=>4, 43=>4},
             {"64 i"=>2, "g"=>1000}
             ],
  
             [25, 75, "Delivery", "Nawate Town Adventurers' Guild", "Shrine Maiden \esb[14]", "\edbi[w,7], 1000\eg", "--",
             "Youkai Ecology",
             "To understand the ecology of youkai, please deliver three each of \edb[e,37] dropped \edbi[i,187] and\n\edb[e,44] dropped \edbi[i,189]. \edb[e,37] mainly inhabits the \eimpvillage surroundings\ec[0],\n\edb[e,44] dwells in the \eimpSealed Cave\ec[0].\n\n\edbi[i,187]　Required Number 3/ Possessed Number \eqin[i,187]\n\edbi[i,189]　Required Number 3/ Possessed Number \eqin[i,189]",

             {"187 i"=>3, "189 i"=>3},
              {
                "7 w"=>1, "g"=>1000
              }
              ],
              
              [26, 76, "Delivery", "Nawate Town Adventurers' Guild", "\emob[m13]", "\edbi[i,262]×2\n\edbi[i,20]×4", "--",
              "Medicine Mixing",
              "The doctor at the clinic requests you to deliver 5 of \edbi[i,29],\nand 3 of \edbi[i,35].\nBoth can be collected in the Sealing Cave.\n\n\edbi[i,29]  Required Amount 5/ Owned Amount \eqin[i,29]\n\edbi[i,35]  Required Amount 3/ Owned Amount \eqin[i,35]",
              {
                "29 i"=>5, "35 i"=>3
              },
              {
                "262 i"=>2, "20 i"=>4
              }
              ],
              
              [27, 77, "Delivery", "Nawate Town Adventurers' Guild", "\eshop[we4]", "2000\eg", "--",
              "Spirit Stone",
              "\eshop[we4] would like to request 4 of \edbi[i,47] for a new weapon order for the blacksmith.\n\edbi[i,47] is an ore that can only be collected in Tokiwa.\n\n\edbi[i,47]  Required Amount 4/ Owned Amount \eqin[i,47]",
              {
                "47 i"=>4
              },
              {
                "g"=>2000
              }
              ],
              
              [28, 78, "Delivery", "Nawate Town Tenement Houses", "\emob[f2]", "\edbi[i,283]×2", "--",
              "Weaving Thread",
              "A woman living in the tenement houses is in trouble because she has\nrun out of weaving thread. She says that \edbi[i,184] would be a good substitute,\nso let's deliver 5 of \edbi[i,184].\n\n\edbi[i,184]  Required Amount 5/ Owned Amount \eqin[i,184]",
              {
                "184 i"=>5
              },
              {
                "283 i"=>2
              }
              ],
              
              #--------↓After defeating the Evil Dragon-----------------------------------------------------------------------------------
              
              [29, 79, "Errand", "In front of Nawate Town Bathhouse", "\eshop[hu1]", "\edbi[a,288], \edbi[a,258]", "--",
              "Grand Reopening",
              "According to Mr. \eshop[hu1] from the bathhouse, they lack stones for the bathhouse renovation.\nLet's go to the underground passage in Tokiwa and mine for \edbi[i,205].\nIt seems that \edbi[i,205] can be mined from places where water is falling\non both sides near the exit in Tokiwa.",
              {},
              {
                "288 a"=>1,"258 a"=>1
              }
              ],
              
              #--------↓After arriving at Sakai-----------------------------------------------------------------------------------
              
              [30, 80, "Extermination", "Sakai Port Wharf", "\emob[f9]", "\edbi[i,97]", "24～",
              "Peaceful Demise",
              "At the port of Sakai, I met a melancholic nun.\nShe wants to give a peaceful sleep to the youkai called \edb[e,47].\nTo fulfill her wish, let's subjugate 8 \edb[e,47] wandering\nthe Kujo Labyrinth.\n\n\edb[e,47] Extermination  Remaining \eqkm[47] bodies",
              {
                47=>8
              },
              {
                "97 i"=>1
              }
              ],
              
              [31, 81, "Errand", "Furizenia Temple 4th Floor Small Room", "\esb[34]", "\edbi[i,56]", "--",
              "Tokiwa's Food",
              "When I went to see \esbt[34] after a long time, \nshe seemed to envy me for going to Tokiwa.\nApparently, she admires Tokiwa and wants to at least taste the \natmosphere of Tokiwa through its food.\nSo from the tea house near the northern ferry point,\nlet's buy rice balls and sweet dumplings for her.\ec[0]",
              {},
              {
                "56 i"=>1
              },
              {
                "l"=>[38,41], "s"=>[127], "t"=>"You can accept this quest after clearing Quest No. 20"
              }
              ],
              
              #--------↓After receiving the pass-----------------------------------------------------------------------------------
              
              [32, 82, "Errand", "Sagittarius Castle Throne Room", "\ekp[3]", "\edbi[i,57]", "--",
              "Hot Spring Essence",
              "\ekpt[3] is having a break amidst the investigation of the mysterious man.\nShe seems tired because she's been investigating without much rest.\nTo relieve her fatigue, let's buy hot spring essence, which is said to have fatigue recovery effects,\nfrom the bathhouse in Nawate.",
              {},
              {
                "57 i"=>1
              },
              {
                "l"=>[27,29], "v"=>[[79,6,0]], "t"=>"You can accept this quest after clearing Quest No. 29"
              }
              ],
              
              [33, 83, "Extermination", "Timor Mountain Dalia Direction Descent Path", "\emob[s1]", "\edbi[i,64]\n\edbi[a,264]", "25～",
              "New Oni Slayer",
              "Everyone is having trouble with the \edb[e,5] on Timor Mountain.\nAmong them, it is requested to subjugate 6 of the higher species thought to be leading them, the \edb[e,53].\nIt seems that \edb[e,53] frequently appears in the caves along the descent path\non the Dalia side of the mountain.\n\n\edb[e,53] Extermination  Remaining \eqkm[53] bodies",
             {53=>6},
             {"64 i"=>1, "264 a"=>1},
             {"v"=>[[62,6,0]], "t"=>"This quest can be accepted after completing Quest No. 12"}
             ],
  
             [34, 84, "Boss Hunt", "Ragras Commercial Town Adventurers' Guild", "Guild Receptionist \emob[qp2]", "5000\eg", "28～",
             "That Pig, Beware its Ferocity...",
             "An urgent request. A ferocious monster, the \eimp\edb[e,60], \nhas appeared in Grea Cave. Already, several adventurers \nhave been defeated, and one \eimpfemale adventurer was \ncontinuously violated by \edb[e,60] until it was satisfied. \nPlease be aware of the danger and subjugate \nthe \edb[e,60] residing in Grea Cave. \nIt is said to be near the western \nwater area immediately after entering from \nthe Ragras side.",
             {},
             {"g"=>5000},
             {"l"=>[37,40], "h"=>1}
             ],
  
             [35,   85,      "Extermination", "Border Checkpoint", "\emob[p6_m]", "\edbi[i,118]×2\n\edbi[i,70]×2", "26~", 
             "If Poisoned, Make It Quick", 
             "At the border checkpoint, I encountered a \emob[p6_m] who\nis weak against poison attacks. Before crossing the wetlands,\nhe wants to reduce the number of \edb[e,54] as much as possible.\nLet's subdue 5 \edb[e,54] for him in the Hydra Wetlands.\n\n\edb[e,54] Extermination  Remaining \eqkm[54]",
             {54=>5},
             {"118 i"=>2, "70 i"=>2},
             {}
             ],
             
  #--------↓Cactus Arrival-----------------------------------------------------------------------------------
             
             [36,   86,      "Other", "Frisenia Temple 4F Small Room", "\esb[34]", "???", "33~", 
             "Humans and Monsters", 
             "A \esbt[34] who says she wants to travel with me.\nHowever, as she is a monster, she can't easily accompany\nme outside, and since she dislikes fighting, she hesitates\nto leave the temple. Her next request was to try the\nLagrus specialty, apple manju. Let's go to Lagrus\nimmediately and buy some apple manju at the street stall.",
             {},
             {},
             {"l"=>[38,41], "s"=>[128], "t"=>"This quest can be undertaken after clearing\nQuest No.31"}
             ],
             
             [37,   87,      "Extermination", "Royal Capital Cactus Adventurers' Guild", "Guild Reception \emob[qp2]", "1000\eg, \edbi[a,289]", "28~", 
             "Ghost Extermination", 
             "At the Folia Ruins, the souls of monsters unable\nto pass on to the next world appear. This time, we are\nrequesting the Extermination of such ghostly monsters,\n\edb[e,55]. Please subdue 5 \edb[e,55].\n\n\edb[e,55] Extermination  Remaining \eqkm[55]",
             {55=>5},
             {"g"=>1000, "289 a"=>1},
             {}
             ],
             
             [38,   88,      "Extermination", "Royal Capital Cactus Adventurers' Guild", "Guild Reception \emob[qp2]", "1000\eg, \edbi[a,290]", "28~", 
             "Shadow Knight", 
             "There exist monsters that lurk in shadows and become one\nwith them. Please subdue the shadowy monsters, \edb[e,12],\n6 bodies. They primarily inhabit the Folia Ruins.\n\n\edb[e,12] Extermination  Remaining \eqkm[12]",
             {12=>6},
             {"g"=>1000, "290 a"=>1},
             {}
             ],
             
             [39,   89,      "Delivery", "Royal Capital Cactus Adventurers' Guild", "Tool Shop", "2000\eg", "26~", 
             "Mysterious Plant", 
             "Plants that grow by absorbing mana from the air\nharness mystical magical power. Among them, the plant\nused in healing potions called \edbi[i,30] must be delivered,\n4 pieces. You can gather them in the Hydra Wetlands nearby.\n\n\edbi[i,30]  Required amount 4/ Amount owned \eqin[i,30]",
             {"30 i"=>4},
             {"g"=>2000},
             {}
             ],
             
             [40,   90,      "Delivery", "Royal Capital Cactus Adventurers' Guild", "\emob[m2]", "\edbi[i,64]", "26~", 
             "Sleep While Being Numb", 
             "A request from a peculiar person—no, a person with\nunique tastes who wants to fall asleep while feeling numb.\nTherefore, please deliver \edbi[i,79] and \edbi[i,80],\n3 of each.\n\n\edbi[i,79]  Required amount 3/ Amount owned \eqin[i,79]\n\edbi[i,80]  Required amount 3/ Amount owned \eqin[i,80]",
             {"79 i"=>3, "80 i"=>3},
             {"64 i"=>1},
             {}
             ],
             
             [41,   91,      "Major Extermination", "Royal Capital Cactus Adventurers' Guild", "Guild Reception \emob[qp2]", "4000\eg\n\edbi[a,333], \edbi[a,334]", "30~", 
             "Wriggling Tentacles", 
             "Multiple \edb[e,61] with tentacles have appeared\nin the Hydra Wetlands. \edb[e,61] captures\nfemale adventurers with its countless tentacles. Please be\nvery cautious, especially if you are a woman, as you carry\nout this Extermination. The location is through the western stepping stones in the\nsecond area after entering the wetlands from the royal capital side.",
             {},
             {"g"=>4000, "333 a"=>1, "334 a"=>1},
             {"l"=>[37,40], "h"=>1}
             ],
             
             [42,   92,      "Errand", "Royal Capital Cactus Wealthy District, Brown-roofed House", "\esb[19]", "\edbi[i,98]\n\edbi[a,259], \edbi[a,260]", "--", 
             "Letter to Mother", 
             "I unexpectedly ran into the mother of my coworker \esb[32] in\nthe Royal Capital of the Dalia Kingdom. It turns out that\n\esbt[32], though born into Dalia nobility, defied her\nfather's opposition and became a court magician in the\nneighboring country of Sagittarius. Let's persuade her to\nwrite a letter to her mother.\n\esb[32] must be in the magicians' wing on the\nfirst floor of Sagittarius Castle.",
             {},
             {"98 i"=>1, "259 a"=>1, "260 a"=>1},
             {"s"=>[132],"l"=>[38,50], "t"=>"You can undertake this quest as long as you have\nspoken to the Sagittarius court magician \esbt[32] at least once"}
             ],
             
  #--------↓After the Queen's Triumph-------------------------------------------------------------------------
             # 43 is after the confrontation with Kamala
             [43,   93,      "Extermination", "Royal Capital Cactus Adventurers' Guild", "Guild Reception \emob[qp2]", "\edbi[a,265]×2", "36~", 
             "Skeleton Warrior", 
             "It's said that warriors died in the desert or mine\nwander as skeletons. To prevent them from taking the living\nwith them, please subdue 6 \edb[e,73] that appear\nin the desert or the mine.\n\n\edb[e,73] Extermination  Remaining \eqkm[73]",
             {73=>6},
             {"265 a"=>2},
             {}
             ],
             
             [44,   94,      "Search", "Mountain Village Bioosa House (bottom)", "\esb[4]", "\edbi[i,9]×3", "32~", 
             "Please Help My Son!", 
             "A young boy \esb[3] from Bioosa went to the\nFolia Ruins and has not returned. His life may be in\ndanger, so let's rush to the ruins to look for the boy.",
             {},
             {"9 i"=>3},
             {"h"=>1}
             ],
             
  #--------↓After the Confrontation with Kamala-------------------------------------------------------------------------------
             
             [45,   95,      "Delivery", "Royal Capital Cactus Adventurers' Guild", "Researcher", "\edbi[i,40]×2", "36~", 
             "Suspicious Research", 
             "A researcher from the castle is looking for\nexperimental materials. Please deliver 4 pieces each of\n\edbi[i,191], \edbi[i,192],\nand \edbi[i,193].\n\n\edbi[i,191]  Required amount 4/ Amount owned \eqin[i,191]\n\edbi[i,192]  Required amount 4/ Amount owned \eqin[i,192]\n\edbi[i,193]  Required amount 4/ Amount owned \eqin[i,193]",
             {"191 i"=>4, "192 i"=>4, "193 i"=>4},
             {"40 i"=>2},
             {}
             ],
             
             [46,   96,      "Extermination", "Royal Capital Cactus Adventurers' Guild", "Women with Boyfriends", "\edbi[i,287]×5", "36~", 
             "Women's Wishes", 
             "There have been numerous reports of boyfriends being\ntempted by succubi. Men bewitched by succubi become\nboneless and neglect their lovers or wives...\nAs such, there have been numerous grievances from women.\nPlease subdue 12 \edb[e,71] that appear in the Dark\nMine or the Desert.\n\n\edb[e,71] Extermination  Remaining \eqkmk[SC]",
             {"SC"=>12},
             {"287 i"=>5},
             {}
             ],
             
             [47,   97,      "Major Extermination", "Royal Capital Cactus Adventurers' Guild", "Guild Reception \emob[qp2]", "\edbi[a,261]×2", "40~", 
             "Goblin Slayer - Fierce Battle Edition", 
             "We are requesting the Extermination of a swarm of\n\edb[e,5] that have taken up residence in the desert cave.\nSince there are also mages among the large numbers,\nplease thoroughly prepare for the battle. Many adventurers\nhave already faced defeat attempting to subdue them, and\nnumerous female adventurers have been captured,\nso rescuing them is also a part of this request.",
             {},
             {"261 a"=>2},
             {"v"=>[[83,6,0]], "t"=>"You can undertake this quest after clearing\nQuest No.33"}
             ],
             
  #---------↓After Chapter Eight Begins------------------------------------------------------------------------------
  
             [48,   98,      "Delivery", "Desert Oasis", "\emob[pe_f]", "1000\eg\n\edbi[i,40]×4", "--", 
             "Tortoise Shell", 
             "I ran into the merchant I saved from thieves in Lagrus\nby chance at the oasis. Apparently, she is collecting\n\edbi[i,185] that \edb[e,79] and others drop.\nShe needs about five, so let's deliver them to her once we\nhave enough.\n\n\edbi[i,185]  Required amount 5/ Amount owned \eqin[i,185]",
             {"185 i"=>5},
             {"40 i"=>4, "g"=>1000},
             {}
             ],
             
             
             [49,   99,      "Delivery", "Resort Garadi Beach", "\emob[f7s]", "\edbi[i,64]×2", "--", 
             "Boost Your Charm!",
             "A woman at the beach in Garadi has asked me to make a\n\edbi[i,325] because she cannot obtain the materials\nherself. She claims that after eating it, she can make any\nmen at the beach head over heels...? Let's gather the\ningredients, cook them, and deliver the dish to her.\n\n\edbi[i,325]  Required amount 1/ Amount owned \eqin[i,325]",
             {"325 i"=>1},
             {"64 i"=>2},
             {}
             ],
             
             [50,   100,      "Extermination", "Resort Garadi East Cliff", "\emob[ex]", "\edbi[a,114]", "44~", 
             "Mermaid's Grudge",
             "A man gazing at the sea from the cliffs of Garadi.\nAfter being rejected by his girlfriend, he (seemingly)\nblames the \edb[e,84] for causing it. To settle his grudge,\nlet's subdue 6 \edb[e,84] inhabiting\nthe Tower of All Demons from floor 4 upwards.\n\n\edb[e,84] Extermination  Remaining \eqkm[84]",
           {84=>6},
           {"114 a"=>1},
           {}
           ],
           
#---------配列番号通りここまで------------------------------------------------------------------------------
           
           #[99,   99,      "種類", "場所", "人名", "報酬", "--", 
           #"題名", 
           #"詳細",
           #{},
           #{},
           #{"s"=>[1,2,3],"v"=>[[51,3,-1]],"t"=>"", "l"=>[22,25], "h"=>1}
           #11-受注条件およびその他ハッシュ。なくてもOK
           #sはスイッチ番号配列。vは配列内変数配列[変数番号,変数の値,-1で未満・0で同値・1で より上・それ以外で以上]。
           #tは条件を満たす前に表示するテキスト
           #lは期限の有無。進行度基準。進行度が配列[0]の数字になると期限間近となり、配列[1]の数字になると期限切れとなる
           #hはHイベントの有無。1がルナリアのH有り、2がソニアのH有り、3がマナのH有り、4が主人公と誰かのハーレムH有り。それ以外はサブキャラ等のH有りの予定
           #],
           
  ]
#文字数　２３文字　７行
# 変数　0 => 受注不可,　1 => 受注可能(内容不明),　2 => 受注可能,　3 => 受注中
#       4 => 失敗(討伐などで一度敗北),
#       5 => 目的達成（討伐後やアイテム入手後等）,　6 => クエストクリア(報告)
=begin
  # クエストタイトル取得
  def self.title(n)
    if SUB[n - 1][11] && SUB[n - 1][11]["h"]
      "クエストNo.#{format("%02d",SUB[n - 1][0])}" + "「#{SUB[n - 1][7]}」" + " \eI[#{self.heart_change(SUB[n - 1][11]["h"])}] "
    else
      "クエストNo.#{format("%02d",SUB[n - 1][0])}" + "「#{SUB[n - 1][7]}」"
    end
  end
  
  def self.heart_change(num)
    case num
    when 1 ; QuestConfig::LU_H
    when 2 ; QuestConfig::SO_H
    when 3 ; QuestConfig::MA_H
    when 4 ; QuestConfig::HA_H
    else   ; QuestConfig::EX_H
    end
  end

  # クエスト管理変数取得
  def self.variables(n)
    SUB[n - 1][1]
  end

  # クエスト報酬取得
  def self.reword(n)
    SUB[n - 1][10]
  end
  
  # 討伐と納品のクエストクリア判定
  def self.cc(n)
    item = SUB[n - 1]
    if item[2] == "討伐"
      key = item[9].keys
      key.all?{|id| $game_party.kill_list(id) == 0 }
    elsif item[2] == "納品"
      key = item[9].keys
      key.all?{|c| quest_item_number?(c, item[9][c])}
    else
      false
    end
  end
  
  # 終了　総合
  def self.q_end(n)
    item = SUB[n - 1]
    if item[2] == "討伐"
      kill_end(item)
    elsif item[2] == "納品"
      deliver_end(item)
    end
  end
  
  # 納品　町民用
  def self.deliver_end(item)
    item[9].each{|k, v| $game_party.lose_item($game_party.quest_item(k, k.to_i), v)}
  end
  
  # クエスト開始　町民・討伐用
  def self.q_start(n)
    item = SUB[n - 1]
    $game_party.kill_list_fullset(item[9]) if item[2] == "討伐"
  end
  
  # 討伐終了　町民用
  def self.kill_end(item)
    item[9].each_key{|k| $game_party.kill_end(k)}
  end
  
  # アイテム所持判定
  def self.quest_item_number?(c, num)
    return $game_party.item_number($data_items[c.to_i]) >= num if c.include?("i")
    return $game_party.item_number($data_weapons[c.to_i]) >= num if c.include?("w")
    return $game_party.item_number($data_armors[c.to_i]) >= num if c.include?("a")
  end
  
  # クエスト報酬 テキスト表示用を取得
  def self.reword_text(n)
    SUB[n - 1][5]
  end
  
  # クエスト(トゥルー)タイトル取得
  def self.true_title(n)
    SUB_TRUE[n - 1][7]
  end

  # クエスト(トゥルー)管理変数取得
  def self.true_variables(n)
    SUB_TRUE[n - 1][1]
  end

  SE       = ["Audio/SE/Chime2", 80, 100]  #
  
  CLEAR_SE       = ["Audio/SE/Applause1", 80, 100]  #
  
  NO_RESET       = [20,31,36,42]  # 周回リセットしないクエスト
  
  NO_RESET_TRUE  = []  # 周回リセットしないトゥルークエスト
  
end
=end

  # クエスト配列の取得。n でクエストNoを指定。
  # 便宜上、高潔ルートのクエストは１０１をNo１とする
  # 例外としてギルドでのクエスト受注・報告のquest_set(n)のみ
  # 高潔ルートはquest_true_set(n)を使用し、nは１０１ではなく１からとする
  def self.q_ary(n)
    if n > 100
      SUB_TRUE[n - 101]
    else
      SUB[n - 1]
    end
  end
  
  # クエストタイトル取得
  def self.title(n)
    if q_ary(n)[11] && q_ary(n)[11]["h"]
      "Quest No.#{format("%02d",q_ary(n)[0])}" + "「#{q_ary(n)[7]}」" + " \eI[#{self.heart_change(q_ary(n)[11]["h"])}] "
    else
      "Quest No.#{format("%02d",q_ary(n)[0])}" + "「#{q_ary(n)[7]}」"
    end
  end
  
  def self.heart_change(num)
    case num
    when 1 ; QuestConfig::LU_H
    when 2 ; QuestConfig::SO_H
    when 3 ; QuestConfig::MA_H
    when 4 ; QuestConfig::HA_H
    else   ; QuestConfig::EX_H
    end
  end

  # クエスト管理変数番号取得
  def self.variables(n)
    q_ary(n)[1]
  end

  # クエスト報酬取得
  def self.reword(n)
    q_ary(n)[10]
  end
  
  # 討伐と納品のクエストクリア判定
  def self.cc(n)
    item = q_ary(n)
    if item[2] == "Extermination"
      key = item[9].keys
      key.all?{|id| $game_party.kill_list(id) == 0 }
    elsif item[2] == "Delivery"
      key = item[9].keys
      key.all?{|c| quest_item_number?(c, item[9][c])}
    else
      false
    end
  end
  
  # 終了　総合
  def self.q_end(n)
    item = q_ary(n)
    if item[2] == "Extermination"
      kill_end(item)
    elsif item[2] == "Delivery"
      deliver_end(item)
    end
  end
  
  # 納品　町民用
  def self.deliver_end(item)
    item[9].each{|k, v| $game_party.lose_item($game_party.quest_item(k, k.to_i), v)}
  end
  
  # クエスト開始　町民・討伐用
  def self.q_start(n)
    item = q_ary(n)
    $game_party.kill_list_fullset(item[9]) if item[2] == "Extermination"
  end
  
  # 討伐終了　町民用
  def self.kill_end(item)
    item[9].each_key{|k| $game_party.kill_end(k)}
  end
  
  # アイテム所持判定
  def self.quest_item_number?(c, num)
    return $game_party.item_number($data_items[c.to_i]) >= num if c.include?("i")
    return $game_party.item_number($data_weapons[c.to_i]) >= num if c.include?("w")
    return $game_party.item_number($data_armors[c.to_i]) >= num if c.include?("a")
  end
  
  # クエスト報酬 テキスト表示用を取得
  def self.reword_text(n)
    q_ary(n)[5]
  end
  
  # クエストクリア済判定
  def self.cleared(n)
    $game_variables[variables(n)] >= 6
  end
  
=begin  
  # クエスト(トゥルー)タイトル取得
  def self.true_title(n)
    SUB_TRUE[n - 1][7]
  end

  # クエスト(トゥルー)管理変数取得
  def self.true_variables(n)
    SUB_TRUE[n - 1][1]
  end
=end
  SE       = ["Audio/SE/Chime2", 80, 100]  #
  
  CLEAR_SE       = ["Audio/SE/Applause1", 80, 100]  #
  
  NO_RESET       = [20,31,36,42]  # 周回リセットしないクエスト
  
  NO_RESET_TRUE  = [15]  # 周回リセットしないトゥルークエスト ※こちらも101ではなく1から
  
end
