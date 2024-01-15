#=begin
module Quest
  
    SUB = [ #0-No  #1-Management Variable #2-Type    #3-Request Location        #4-Requester  #5-Reward   #6-Recommended LV
             [1,   51,         "Delivery",   "Sagittarius Town Adventurer's Guild", "Mariana", "\edbi[a,98]", "--", 
             "Nebapuru Experiment", #7-Title
             #8-Details
             "\e}\e}I need items dropped by \edb[e,1] monsters for\nan upcoming experiment. I'd like you to procure\nabout three of them. Could you do that for me?\n\n\edbi[i,171]　\e}Needed 3/ In Possession \eqin[i,171]\e{",
             #9-Completion Condition Hash
             {"171 i"=>3}, 
             #10-Reward Hash
             {"98 a"=>1}
             ],
             
             [2,   52,         "Suppression",   "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "200\eg、\edbi[i,4]×２", "3～", 
             "Goblin Slayer", #7-Title
             #8-Details
             "\e}\e}Attackers who assault adventurers and merchants\nto steal their goods or kidnap women are the despicable\n\eimp\edb[e,5]. Please subdue six of them.\n\edb[e,5] primarily inhabit the surroundings of Sagittarius\nand the southern area of Rizel Forest.\n\n\edb[e,5] Suppression　\e}Remaining \eqkm[5]\e{",
             #9-Completion Condition Hash
             {5=>6}, 
             #10-Reward Hash
             {"g"=>200, "4 i"=>2}
             ],
             
             [3,   53,      "Suppression", "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,106]", "4～", 
             "Rabbit Hunt", 
             "\e}\e}Please subdue five of the rabbit-like demons\n\eimp\edb[e,6] that inhabit the southern Robe area and\nRizel Forest etc.\n\n\edb[e,6] Suppression　\e}Remaining \eqkm[6]\e{",
             {6=>5},
             {"106 a"=>1}
             ],
             
             [4,   54,      "Delivery", "Sagittarius Town Adventurer's Guild", "Tool Shop", "\edbi[w,2]", "--", 
             "Healing Potion Ingredients", 
             "\e}\e}The tool shop has requested \edbi[i,27] and \edbi[i,32].\nSo please collect five of each \edbi[i,27] and\n\edbi[i,32]. Both can be collected in Rizel Forest.\n\n\edbi[i,27]　\e}Needed 5/ In Possession \eqin[i,27]\e{\n\edbi[i,32]　\e}Needed 5/ In Possession \eqin[i,32]\e{",
             {"27 i"=>5, "32 i"=>5},
             {"2 w"=>1}
             ],
             
             [5,   55,      "Suppression", "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "200\eg、\edbi[i,4]×３", "5～", 
             "Pest Control", 
             "\e}\e}Please subdue five each of the pests \eimp\edb[e,7] and\n\edb[e,8]\ec[0] that inhabit Rizel Forest.\n\edb[e,7] can be found throughout the forest, while\n\edb[e,8] resides in the southern area.\n\n\edb[e,7] Suppression　\e}Remaining \eqkm[7]\e{\n\edb[e,8] Suppression　\e}Remaining \eqkm[8]\e{",
             {7=>5, 8=>5},
             {"g"=>200, "4 i"=>3}
             ],
                        
  #--------Only after clearing the ruins No.6-----------------------------------------------------------------------------------
  
             [6,   56,         "Urgent",   "Sagittarius Town Adventurer's Guild", "Guild Receptionist \emob[qp2]", "2000\eg", "11～", 
             "Defeat the Giant Slime!", #7-Title
             #8-Details
             "\e}\e}We've received reports of a high-level giant slime\nappearing near the northern area water sites of Rizel Forest.\nPlease exterminate it. There's information that if a\n\eimp female adventurer confronts it alone and loses, she will be violated\ec[0].\nTake extra caution if you go alone. Reports suggest\nthat this creature is resistant to physical attacks.",
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
             "\e}\e}\emob[f3] says she lost her strap somewhere\nin Sagittarius town. Let's search the town and\nfind the bear strap she lost.",
             #9-Completion Condition Hash
             {}, 
             #10-Reward Hash
             {"116 i"=>1}
             ],
             
             [8,   58,      "Delivery", "Sagittarius Town In front of the Restaurant", "\emob[a1_f1]", "\edbi[a,22]", "--", 
             "In Search of Ingredients?", 
             "\e}\e}The restaurant wants to use \edbi[i,75], which grows in forests,\nfor their dishes. Apparently, \edbi[i,75] becomes very\ntasty after detoxifying… Let's collect \edbi[i,75] from\nRizel Forest and give it to \emob[a1_f1].\n\n\edbi[i,75]　\e}Needed 5/ In Possession \eqin[i,75]\e{",
             {"75 i"=>5},
             {"22 a"=>1}
             ],
             
  #--------After one night in Robe-----------------------------------------------------------------------------------
  
             [9,   59,      "Delivery", "Forest Village Robe Chief's House 1st Floor", "\emob[f8]", "500\eg", "--", 
             "Fuzzy", 
             "\e}\e}The \emob[f8] at the chief's house seems to be obsessed\nwith hair-type monsters. Let's collect three \edbi[i,173],\nwhich are dropped by hair creatures, and give them to her.\n\n\edbi[i,173]　\e}Needed 3/ In Possession \eqin[i,173]\e{",
             {"173 i"=>3},
             {"g"=>500}
             ],
  
             [10,   60,      "Urgent", "Forest Village Robe Tavern/Inn 1st Floor", "\emob[m2]", "1000\eg、\edbi[i,93]", "7～", 
             "Bee Swarm", 
             "\e}\e}A huge swarm of \edb[e,8] has appeared at the\npond in the southern area of Rizel Forest. Moreover,\nthese are a bit higher level than others in the forest,\ncreating potential unknown damages if left unchecked. It's\nlikely to be a continuous battle, so prepare\nthoroughly and head to the southern area pond.",
             #9-Completion Condition Hash
             {},
             #10-Reward Hash
             {"g"=>1000, "93 i"=>1}
             ],
             
  #--------After arrival in Ragras, also No.17-----------------------------------------------------------------------------------
  
             [11,   61,      "Delivery", "Commercial Town Ragras Adventurer's Guild", "Street Vendor Food Shop", "800\eg、\edbi[i,113]×２", "--", 
             "Monster Meat", 
             "\e}\e}The food shop has requested the delivery of hair-monster's \edbi[i,181] and boar-monster's \edbi[i,180],\nthree each. Boars are found in both north and south caves,\nwhile hairs are around Ragras.\n\n\edbi[i,180]　\e}Needed 3/ In Possession \eqin[i,180]\e{\n\edbi[i,181]　\e}Needed 3/ In Possession \eqin[i,181]\e{",
             {"180 i"=>3, "181 i"=>3},
             {"g"=>800, "113 i"=>2}
             ],
  
             [12,   62,      "Suppression", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,24]、\edbi[a,171]", "10～", 
             "More Goblin Slayers", 
             "\e}\e}There are \edb[e,5] that have high intelligence and\nuse sword skills and \esk[2]. They live in the southern cave.\nPlease subjugate five each of \eimp\edb[e,18]\ \edb[e,19]\ec[0].\n\n\edb[e,18] Suppression　\e}Remaining \eqkm[18]\e{\n\edb[e,19] Suppression　\e}Remaining \eqkm[19]\e{",
             {18=>5, 19=>5},
             {"24 a"=>1, "171 a"=>1},
             {"v"=>[[52,6,0]], "t"=>"You can accept this quest after completing Quest No.02"}
             ],
  
             [13,   63,      "Suppression", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[w,5]", "9～", 
             "Poison Ant Breeding Season", 
             "\e}\e}The poisonous \edb[e,16] started their breeding season.\nTo prevent further proliferation, please subjugate eight\nof them. This creature resides in the Grayer Cave near\nRagras and the south cave of Ragras.\n\n\edb[e,16] Suppression　\e}Remaining \eqkm[16]\e{",
             {16=>8},
             {"5 w"=>1}
             ],
  
  #--------After the morning following the bandit Suppression-----------------------------------------------------------------------------------
  
             [14,   64,      "Delivery", "Commercial Town Ragras Adventurer's Guild", "Street Vendor Material Shop", "1200\eg\nMonster materials will be added to the Ragras material shop's inventory", "--", 
             "Monster Material Drops", 
             "\e}\e}The material shop wants to handle monster materials.\nSo they need three each of \edbi[i,171] and \edbi[i,174],\nand two of \edbi[i,176].\n\n\edbi[i,171]　\e}Needed 3/ In Possession \eqin[i,171]\e{\n\edbi[i,174]　\e}Needed 3/ In Possession \eqin[i,174]\e{\n\edbi[i,176]　\e}Needed 2/ In Possession \eqin[i,176]\e{",
             {"171 i"=>3, "174 i"=>3, "176 i"=>2},
             {"g"=>1200}
             ],
  
             [15,   65,      "Suppression", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,84]、\edbi[a,106]", "13～", 
             "Snake Hunt", 
             "\e}\e}Timor Mountain is an important route for traffic between Dalia.\nHowever, the mountain path is dangerous due to numerous\nsnake monsters 'edb[e,23]' living there. For\nthe sake of those who travel between the two countries,\nplease subjugate six \eimp\edb[e,23].\n\n\edb[e,23] Suppression　\e}Remaining \eqkm[23]\e{",
             {23=>6},
             {"84 a"=>1, "106 a"=>1}
             ],
  
             [16,   66,      "Suppression", "Commercial Town Ragras Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,113]×２、\edbi[a,257]", "14～", 
             "Snowmen", 
             "\e}\e}\eimpThe area near the summit of Timor Mountain\ec[0] is always\ncovered in snow, and there are monsters that look\nlike snowmen. Please subjugate five \eimp\edb[e,27]\ec[0].\n\n\edb[e,27] Suppression　\e}Remaining \eqkm[27]\e{",
             {27=>5},
             {"113 i"=>2, "257 a"=>1}
             ],
  
             [17,   67,      "Errand", "Commercial Town Ragras Red-Roofed Private House", "\emob[f7]", "\edbi[w,24]、\edbi[a,287]", "14～", 
             "Desire to Be Busty!", 
             "\e}\e}\emob[f7] wants to get her hands on freshly milked\nmilk from the ranch because she's eager to have bigger\nbreasts. It seems there's a ranch by the lake west of\nRagras, so let's ask the ranch owner.\n\eimp If you go with the busty married woman\ec[0],\nsomething special might happen…?",
             {},
             {"287 a"=>1, "24 w"=>1},
             {"h"=>2}
             ],
  
             [18,   68,      "Investigation", "Commercial Town Ragras Mayor's House 2nd Floor", "\emob[p11b]", "\edbi[i,52]", "12～", 
             "What Lurks in the Underground Waterway", 
             "\e}\e}There's something wrong with Ragras' underground\nwaterway. The water quality has deteriorated significantly\nrecently. The purification device prevents any serious\nproblems, but if left unchecked, it could harm the residents.\n\eimp Go through the white building located in the northwest of the town\ec[0]\nand down to the waterway to investigate the cause.",
             {},
             {"52 i"=>1}
             ],
  
             [19,   69,      "Errand", "Timor Mountain Cave Entrance", "\emob[p1_f]", "\edbi[i,2]×２、\n\edbi[i,8]", "--", 
             "Lower the Rope Ladder", 
             "\e}\e}\emob[p1_f] en route over the mountain fears goblins and can't enter\nthe cave leading to the cliff. Without passing through the cave,\nthe mountain cannot be crossed… So he asked us to\ngo through the cave on his behalf and drop the rope ladder\non the other side. Let's complete the mountain path\nby lowering the rope ladder from the cliff on his behalf.",
             {},
             {"2 i"=>2, "8 i"=>1}
             ],
  
  #--------After arrival at the temple-----------------------------------------------------------------------------------
  
             [20,   70,      "Other", "Frizenia Temple 4th Floor Small Room", "\esb[34]", "\edbi[w,6]", "--", 
             "Monster Girl Talk", 
             "\e}\e}Met a \edb[e,28] named Anemone in a small\nroom on the fourth floor of the Frizenia Temple.\nInitially wary, Lunaria gradually warmed up to her\nas they spoke and realized despite being a monster,\nshe bore no malice. Considering becoming friends,\nvisit her again when the opportunity arises.",
             {},
             {"6 w"=>1},
             {"l"=>[38,41]}
             ],
  
  #--------After arrival in Senessio-----------------------------------------------------------------------------------
  
             [21,   71,      "Suppression", "Port Town Senessio Café with Ocean View", "\emob[p2_f]", "\edbi[i,54]", "--", 
             "Octopus Wiener", 
             "\e}\e}A \emob[p2_f] at the port café has requested that we\nsubdue \edb[e,34] around \eimpSenessio\ec[0]. Apparently, it makes\nher hungry watching them and is quite bothersome…\n\n\edb[e,34] Suppression　\e}Remaining \eqkm[34]\e{",
             {34=>5},
             {"54 i"=>1}
             ],
             
  #--------After meeting Tsukihana-----------------------------------------------------------------------------------
  
             [22,   72,      "Delivery", "Kujou Village Warehouse", "\emob[f7]", "2000\eg", "--", 
             "Naughty Underwear", 
             "\e}\e}A woman from the village has asked us to collect\nthree \edbi[i,188], which female-shaped demons (monsters)\ndrop. She plans to study them to create a technique to\nseduce men. Female ghosts often appear\n\eimparound the village, Nawate, and the Sealing Cave\ec[0].\n\n\edbi[i,188]　\e}Needed 3/ In Possession \eqin[i,188]\e{",
             {"188 i"=>3},
             {"g"=>2000}
             ],
             
             [23,   73,      "Suppression", "Town of Nawate Adventurers' Association", "Guild Receptionist \emob[qp2]", "\edbi[i,123]、\edbi[i,124]\n\edbi[i,125]、\edbi[i,126]\e{", "20～", 
             "Foreign Goblin Slayer", 
             "\e}\e}The 'edb[e,41]' yokai, who turns pillows to\nconfuse sleeping people, have been spotted\n\eimparound and inside the Sealing Cave\ec[0].\nPlease subjugate five \eimp\edb[e,41].\n\n\edb[e,41] Suppression　\e}Remaining \eqkm[41]\e{",
             {41=>5},
             {"123 i"=>1, "124 i"=>1, "125 i"=>1, "126 i"=>1}
             ],
           
             [24, 74, "Suppression", "Nawate Town Adventurers' Guild", "Guild Receptionist \emob[qp2]", "\edbi[i,64]×2\n1000\eg", "20～",
             "Demonic Youkai",
             "In Tokiwa, there exist demonic youkai that seduce men, kidnap, and consume them. Please subjugate four of each of these youkai \eimp\edb[e,42] and\n\edb[e,43]\e}\e}(Jorougumo)\e}\e}. Both inhabit the Sealed Cave from the midway point onwards.\n\n\edb[e,42] Suppression　\e}Remaining \eqkm[42] bodies\e{\n\edb[e,43] Suppression　\e}Remaining \eqkm[43] bodies\e{",
             {42=>4, 43=>4},
             {"64 i"=>2, "g"=>1000}
             ],
  
             [25, 75, "Delivery", "Nawate Town Adventurers' Guild", "Shrine Maiden \esb[14]", "\edbi[w,7], 1000\eg", "--",
             "Youkai Ecology",
             "To understand the ecology of youkai, please deliver three each of \edb[e,37] dropped \edbi[i,187] and\n\edb[e,44] dropped \edbi[i,189]. \edb[e,37] mainly inhabits the \eimpvillage surroundings\ec[0],\n\edb[e,44] dwells in the \eimpSealed Cave\ec[0].\n\n\edbi[i,187]　\e}Required Number 3/ Possessed Number \eqin[i,187]\e{\n\edbi[i,189]　\e}Required Number 3/ Possessed Number \eqin[i,189]\e{",
             {"187 i"=>3, "189 i"=>3},
             {"7 w"=>1, "g"=>1000}
             ],
  
             [26, 76, "Delivery", "Nawate Town Adventurers' Guild", "\emob[m13]", "\edbi[i,262]×2\n\edbi[i,20]×4", "--",
             "Medicine Compounding",
             "The clinic's doctor has requested the delivery of five \edbi[i,29] and three \edbi[i,35]. Both can be collected in the Sealed Cave.\n\n\edbi[i,29]　\e}Required Number 5/ Possessed Number \eqin[i,29]\e{\n\edbi[i,35]　\e}Required Number 3/ Possessed Number \eqin[i,35]\e{",
             {"29 i"=>5, "35 i"=>3},
             {"262 i"=>2, "20 i"=>4}
             ],
  
             [27, 77, "Delivery", "Nawate Town Adventurers' Guild", "\eshop[we4]", "2000\eg", "--",
             "Spiritual Stone",
             "\eshop[we4] wants to request a new weapon from the blacksmith, so please deliver four \edbi[i,47]. \edbi[i,47] is an ore that can only be collected in Tokiwa.\n\n\edbi[i,47]　\e}Required Number 4/ Possessed Number \eqin[i,47]\e{",
             {"47 i"=>4},
             {"g"=>2000}
             ],
  
             [28, 78, "Delivery", "Nawate Town Row Houses", "\emob[f2]", "\edbi[i,283]×2", "--",
             "Weaving Thread",
             "A woman living in the row houses is in trouble because she has run out of weaving thread. She said that \edbi[i,184] would be a good substitute, so let's deliver five \edbi[i,184].\n\n\edbi[i,184]　\e}Required Number 5/ Possessed Number \eqin[i,184]\e{",
             {"184 i"=>5},
             {"283 i"=>2}
             ],
  
  #--------↓Post-evil dragon Suppression-----------------------------------------------------------------------------------
  
             [29, 79, "Errand", "In front of Nawate Town Public Bath", "\eshop[hu1]", "\edbi[a,288], \edbi[a,258]", "--",
             "Grand Reopening",
             "According to Mr. \eshop[hu1] from the public bath, they are short on stones for a renovation, so let's go to the underground passage to Tokiwa and mine \edbi[i,205]. It seems \edbi[i,205] can be mined from the place where water is falling from both sides near the exit of Tokiwa.",
             {},
             {"288 a"=>1,"258 a"=>1}
             ],
  
  #--------↓Post-Sakai Arrival-----------------------------------------------------------------------------------
  
             [30, 80, "Suppression", "Sakai Port Town Pier", "\emob[f9]", "\edbi[i,97]", "24～",
             "Peaceful Demise",
             "In the port of Sakai, I met a sorrowful nun. She wants to give a peaceful rest to the youkai called \edb[e,47]. To grant her wish, let's subjugate eight \edb[e,47] wandering in the \eimpKujo Labyrinth.\n\n\edb[e,47] Suppression　\e}Remaining \eqkm[47] bodies\e{",
             {47=>8},
             {"97 i"=>1}
             ],
  
             [31, 81, "Errand", "Furisenia Temple 4th Floor Small Room", "\esb[34]", "\edbi[i,56]", "--",
             "Tokiwa's Food",
             "When I visited Anemone after a long time, she envied that I had been to Tokiwa. It seems she has a longing for Tokiwa, so she wants to at least taste the atmosphere of Tokiwa through its food. Let's buy rice balls and dumplings from the tea house near the northern ferry and give them to her.\ec[0]",
             {},
             {"56 i"=>1},
             {"l"=>[38,41], "s"=>[127], "t"=>"This quest can be accepted after completing Quest No. 20"}
             ],
  
  #--------↓After receiving the pass-----------------------------------------------------------------------------------
  
             [32, 82, "Errand", "Sagittarius Castle Throne Room", "Millay", "\edbi[i,57]", "--",
             "Hot Spring's Essence",
             "Millay is taking a break from the investigation of the mysterious man. She has been investigating without much rest and seems tired... To relieve her fatigue, let's buy the essence of a hot spring, which is said to have recovery effects, at the public bath in Nawate.",
             {},
             {"57 i"=>1},
             {"l"=>[27,29], "v"=>[[79,6,0]], "t"=>"This quest can be accepted after completing Quest No. 29"}
             ],
  
             [33, 83, "Suppression", "Timor Mountain Dalia-side Downhill Path", "\emob[s1]", "\edbi[i,64]\n\edbi[a,264]", "25～",
             "New Imp Slayer",
             "The \edb[e,5] of Timor Mountain are a challenge for everyone. Among them, it is believed that a higher-ranking species, the \eimp\edb[e,53], is leading them. We have been asked to subjugate six \edb[e,53]. They are often spotted in the \eimpcaves on the Dalia-side downhill path.\n\n\edb[e,53] Suppression　\e}Remaining \eqkm[53] bodies\e{",
             {53=>6},
             {"64 i"=>1, "264 a"=>1},
             {"v"=>[[62,6,0]], "t"=>"This quest can be accepted after completing Quest No. 12"}
             ],
  
             [34, 84, "Hunt", "Ragras Commercial Town Adventurers' Guild", "Guild Receptionist \emob[qp2]", "5000\eg", "28～",
             "That Pig, Beware its Ferocity...",
             "An urgent request. A ferocious monster, the \eimp\edb[e,60], has appeared in Grea Cave. Already, several adventurers have been defeated, and one \eimpfemale adventurer was continuously violated by \edb[e,60] until it was satisfied. Please be aware of the danger and subjugate the \edb[e,60] residing in Grea Cave. It is said to be near the western water area immediately after entering from the Ragras side.",
             {},
             {"g"=>5000},
             {"l"=>[37,40], "h"=>1}
             ],
  
             [35, 85, "Suppression", "Border Checkpoint", "\emob[p6_m]", "\edbi[i,118]×2\n\edbi[i,70]×2", "26～",
             "If One Must Be Poisoned",
             "At the border checkpoint, I met \emob[p6_m] who said he is weak against poison attacks. Let's help him reduce the number of \edb[e,54] in the Hydra Marsh before crossing it by subjugating five \edb[e,54].\n\n\edb[e,54] Suppression　\e}Remaining \eqkm[54] bodies\e{",
             {54=>5},
             {"118 i"=>2, "70 i"=>2},
             {}
             ],
  
  #--------↓Arrival in Cactus-----------------------------------------------------------------------------------
  
             [36, 86, "Other", "Furisenia Temple 4th Floor Small Room", "\esb[34]", "???", "33～",
             "Humans and Monsters",
             "Anemone, a monster, says she would like to \eimptravel together one day. However, I can't take her, a monster, around, and because she herself does not enjoy fighting, she deems it best not to leave the temple. Her next request is to taste the apple manju from Ragras. Let's go to \eimpRagras\ec[0] and buy some \eimpapple manju\ec[0] from a street stall to give to her.",
             {},
             {},
             {"l"=>[38,41], "s"=>[128], "t"=>"This quest can be accepted after completing Quest No. 31"}
             ],
  
             [37, 87, "Suppression", "Cactus Royal Capital Adventurers' Guild", "Guild Receptionist \emob[qp2]", "1000\eg、\edbi[a,289]", "28～",
             "Ghostbusting",
             "In \eimpFolia Ruins\ec[0], there are monsters that have left unfinished business in this world and cannot pass on peacefully. This request is to subjugate one such ghostly monster, \edb[e,55]. Please subjugate five \edb[e,55].\n\n\edb[e,55] Suppression　\e}Remaining \eqkm[55] bodies\e{",
             {55=>5},
             {"g"=>1000, "289 a"=>1},
             {}
             ],
  
             [38, 88, "Suppression", "Cactus Royal Capital Adventurers' Guild", "Guild Receptionist \emob[qp2]", "1000\eg、\edbi[a,290]", "28～",
             "Knight of the Shadows",
             "There are monsters that lurk and merge with shadows. Please subjugate six shadow monsters, the \eimp\edb[e,12]. They mainly inhabit the \eimpFolia Ruins.\n\n\edb[e,12] Suppression　\e}Remaining \eqkm[12] bodies\e{",
             {12=>6},
             {"g"=>1000, "290 a"=>1},
             {}
             ],
  
             [39, 89, "Delivery", "Cactus Royal Capital Adventurers' Guild", "Tool Shop", "2000\eg", "26～",
             "Mysterious Plants",
             "Plants that grow by absorbing mana from the atmosphere have mysterious magical powers. Among them, the plant \eimp\edbi[i,30], which is used in healing medications, is required. Please deliver four \edbi[i,30]. In this area, they can be collected in the \eimpHydra Marsh.\n\n\edbi[i,30]　\e}Required Number 4/ Possessed Number \eqin[i,30]\e{",
             {"30 i"=>4},
             {"g"=>2000},
             {}
             ],
  
             [40, 90, "Delivery", "Cactus Royal Capital Adventurers' Guild", "\emob[m2]", "\edbi[i,64]", "26～",
             "I Want to Sleep While Numb",
             "A peculiar person―ahem, a person with unique tastes wants to sleep while feeling numb. Thus, please deliver \eimp\edbi[i,79] and \edbi[i,80]\ec[0], three of each.\n\n\edbi[i,79]　\e}Required Number 3/ Possessed Number \eqin[i,79]\e{\n\edbi[i,80]　\e}Required Number 3/ Possessed Number \eqin[i,80]\e{",
             {"79 i"=>3, "80 i"=>3},
             {"64 i"=>1},
             {}
             ],
  
             [41, 91, "Hunt", "Cactus Royal Capital Adventurers' Guild", "Guild Receptionist \emob[qp2]", "4000\eg\n\edbi[a,333]、\edbi[a,334]", "30～",
             "Tentacle Squirming",
             "Monsters with tentacles, \eimp\edb[e,61], have appeared in the Hydra Marsh. \edb[e,61] uses its numerous tentacles to capture and violate \eimpfemale adventurers, so please be extra cautious, especially the ladies, while subjugating them. The location is the \eimpsecond area on the royal capital side of the marsh, just beyond the stepping stones to the west.\ec[0]",
             {},
             {"g"=>4000, "333 a"=>1, "334 a"=>1},
             {"l"=>[37,40], "h"=>1}
             ],
  
             [42, 92, "Errand", "Cactus Capital Wealthy District Brown-roofed House", "\esb[19]", "\edbi[i,98]\n\edbi[a,259]、\edbi[a,260]", "--",
             "A Letter to Mother",
             "In the royal capital of the Dalia Kingdom, I met \esb[32]'s mother, my colleague's mother. It seems that Eriora, of Dalia's nobility, became a court magician in Sagittarius against her father's wishes. Persuade her to write \eimpa letter destined for her mother and let's get it from her. \esb[32] is likely on the \eimpfirst floor of the magician's wing in Sagittarius Castle.\ec[0]",
             {},
             {"98 i"=>1, "259 a"=>1, "260 a"=>1},
             {"s"=>[132],"l"=>[38,50], "t"=>"This quest can be accepted if you have spoken to the court magician Eriora of Sagittarius at least once"}
             ],
           
#--------↓After the Queen's Triumph-------------------------------------------------------------------------
           # 43 is after the Kamala confrontation
           [43,   93,      "Suppression", "Royal Capital Cactus Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,265]×２", "36～", 
           "Skeletal Warriors", 
           "I have heard that warriors who died in deserts or mines wander as skeletons. Please subjugate \eimp\edb[e,73]\ec[0] appearing in deserts and mines so they do not make the living join them. You need to defeat 6 of them.\n\edb[e,73]Suppression \e}Remaining \eqkm[73] units\e{",
           {73=>6},
           {"265 a"=>2},
           {}
           ],
           
           [44,   94,      "Search", "Mountain Village Biorsa, Lower House", "\esb[4]", "\edbi[i,9]×３", "32～", 
           "Please Help My Son!", 
           "A boy from Biorsa \esb[3] has not returned after going to the \eimpFolia Ruins\ec[0]. His life is in danger, so we must hurry to the ruins to search for the boy.",
           {},
           {"9 i"=>3},
           {"h"=>1}
           ],
           
#--------↓After confronting Kamala-------------------------------------------------------------------------------
           
           [45,   95,      "Delivery", "Royal Capital Cactus Adventurer's Guild", "Researcher", "\edbi[i,40]×２", "36～", 
           "Suspicious Research", 
           "A researcher from the castle is looking for materials for an experiment, hence please deliver 4 each of \edbi[i,191], \edbi[i,192], and \edbi[i,193].\n\n\edbi[i,191]　\e} Required amount 4/ Owned amount \eqin[i,191]\e{\n\edbi[i,192]　\e} Required amount 4/ Owned amount \eqin[i,192]\e{\n\edbi[i,193]　\e} Required amount 4/ Owned amount \eqin[i,193]\e{",
           {"191 i"=>4, "192 i"=>4, "193 i"=>4},
           {"40 i"=>2},
           {}
           ],
           
           [46,   96,      "Suppression", "Royal Capital Cactus Adventurer's Guild", "Women with Boyfriends", "\edbi[i,287]×５", "36～", 
           "A Wish from Women", 
           "There are successive reports of boyfriends being seduced by succubi. Men charmed by succubi become spineless and neglect their lovers or wives. A multitude of women are voicing their resentment, so please subjugate \eimp12 units of \edb[e,71] found in the Dark Mines and the Desert.\n\edb[e,71]Suppression \e}Remaining \eqkmk[SC] units\e{",
           {"SC"=>12},
           {"287 i"=>5},
           {}
           ],
           
           [47,   97,      "Hunt", "Royal Capital Cactus Adventurer's Guild", "Guild Receptionist \emob[qp2]", "\edbi[a,261]×２", "40～", 
           "Imp Slayer・Fierce Battle Edition", 
           "Please subjugate the swarms of \edb[e,5] that dwell in the desert caves. The enemies are numerous including mages, so prepare thoroughly before challenging them. Additionally, numerous adventurers have already attempted to subdue them but were outnumbered, and many female adventurers have been captured, so please rescue them as well.",
           {},
           {"261 a"=>2},
           {"v"=>[[83,6,0]], "t"=>"This quest can be accepted after clearing Quest No.33"}
           ],
           
#---------↓Chapter 8 Begins------------------------------------------------------------------------------

           [48,   98,      "Delivery", "Desert Oasis", "\emob[pe_f]", "1000\eg\n\edbi[i,40]×４", "--", 
           "Turtle Shell", 
           "Met accidentally at the oasis with a merchant whom I saved from thieves in Lagras. It seems she is collecting \eimp\edbi[i,185]\ec[0] dropped by \eimp\edb[e,79]. She needs about 5, so let's bring them to her once we've gathered enough.\n\n\edbi[i,185]　\e} Required amount 5/ Owned amount \eqin[i,185]\e{",
           {"185 i"=>5},
           {"40 i"=>4, "g"=>1000},
           {}
           ],
           
           
           [49,   99,      "Delivery", "Resort Area Galadi Beach", "\emob[f7s]", "\edbi[i,64]×２", "--", 
           "Boosting Charm!",
           "A woman at Galadi Beach asked for a \edbi[i,325] because she can't get the ingredients on her own. She says that with this, she can swoon the beachgoers...? Let's gather the ingredients, cook it at the shop, and deliver it to her.\n\n\edbi[i,325]　\e} Required amount 1/ Owned amount \eqin[i,325]\e{",
           {"325 i"=>1},
           {"64 i"=>2},
           {}
           ],
           
           [50,   100,      "Suppression", "Resort Area Galadi East Cliff", "\emob[ex]", "\edbi[a,114]", "44～", 
           "Grudge Against the Mermaid", 
           "A man looking out to sea from the cliff top in Galadi. He was dumped by his girlfriend and blames the creature \edb[e,84] for causing it. To clear his grudge, let us go and subjugate \eimp6 units of \edb[e,84]\ec[0] that inhabit the \eimpFourth-floor and above of the Demon's Tower.\n\n\edb[e,84]Suppression　\e}Remaining \eqkm[84] units\e{",
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
    if item[2] == "Hunt"
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
    if item[2] == "Hunt"
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
    $game_party.kill_list_fullset(item[9]) if item[2] == "Suppression"
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
