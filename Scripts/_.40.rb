module Person
  # 制御文字使用時のキャラ名の表記色
  Color = { 0 =>  0, #
            1 =>  2, #アクター１
            2 =>  3, #アクター２
            3 =>  5, #アクター３
            4 =>  0, #アクター４
            5 =>  12, #アクター５
            6 =>  0, #アクター６
            7 =>  0, #アクター７
            8 =>  0, #アクター８
            9 =>  0, #アクター９
            10 =>  0, #アクター１０
            11 =>  0, #アクター１１
            12 =>  0, #アクター１２
            13 =>  0, #アクター１３
            14 =>  0, #アクター１４
            15 =>  0, #アクター１５
            16 =>  0, #アクター１６
            17 =>  0, #アクター１７
            18 =>  0, #アクター１８
            19 =>  0, #アクター１９
            20 =>  0, #アクター２０
            21 =>  0, #アクター２１
            22 =>  0, #アクター２２
            23 =>  0, #アクター２３
            24 =>  0, #アクター２４
            25 =>  0, #アクター２４
            }


  Name = { 0 => ["", 0,""], #キーパーソンキャラ用↓
           1 => ["マリアナ", 24,"Mariana"], # 宮廷魔術師・研究者
           2 => ["ディアナ", 27, "Diana"], # 魔法王国女王陛下
           3 => ["ミレイ", 17, "Millay"], # 宮廷魔術師団団長
           4 => ["シャーリー", 21, "Shirley"], # 宮廷魔術師・学院同級生
           5 => ["エスティア", 21, "Estia"], # 宮廷魔術師・学院同級生
           6 => ["エレノア", 21, "Eleanor"], # ルナリアの母親
           7 => ["メリス", 21, "Meris"], # 旅のロリ爆乳シスター
           8 => ["ドレイク", 21, ""], # サジタリーズ騎士団団長　将軍
           9 => ["サルビア", 21, "Salvia"], # 魔術学院 召喚科の講師
           10 => ["", 21, ""],
           11 => ["リリ", 21, "Lili"], #宮廷魔術師・先輩
           12 => ["ツキハ", 25, "Tsukiha"], #トキワの里長
           13 => ["フィリカ", 25, "Filica"], #ダリアの女王
           14 => ["シグン", 21, "Sigun"], #サジタリーズ初代国王
           15 => ["シア", 21, ""], #サジタリーズ初代国王第一王妃・幼馴染
           16 => ["ましろ", 21, ""], #トキワの伝説の巫女
           21 => ["ライト", 23, "Wright"], #ソニアの夫
           22 => ["ゴード", 23, ""], #ダリアの大富豪
           23 => ["デルタ", 23, "Delta"], #ダリアの大臣　デルタ・アベラーゼ
           25 => ["ヒメ", 21, ""], #ダリアの大富豪のメイド姉妹・妹
           26 => ["ナミ", 21, ""], #ダリアの大富豪のメイド姉妹・姉
           31 => ["レノ", 31, "Renno"],
           32 => ["アスモリオス", 31, "Asmolios"],
           41 => ["ゼパール", 31, "Zepar"],
           42 => ["マガツオロチ", 31, "Magatsuorochi"],
           43 => ["ゼパールの魂", 31, ""],
           44 => ["玉藻前", 31, "Tamamo"],
           51 => ["ベルゼリアン", 31, "Beelzelian"],
           61 => ["ラスフレイア", 21, ""], #世界創世神話に出てくる創造の女神
           62 => ["マルグレーナ", 21, ""], #世界創世神話に出てくる破壊の女神
          }

  Sub =  { 0 => ["", 0, ""],  #名前のあるサブキャラ用↓　
           1 => ["ポルコ", 23, ""], #ロベの青年
           2 => ["カマラ", 23, ""], #ゼパール教の教祖
           3 => ["シュウト", 21, ""], #ビオーサのショタ
           4 => ["カペラ", 21, ""], #↑ビオーサのショタの母親
           5 => ["カンゾウ", 23, ""], # ダリア地方の宿経営者
           6 => ["アークス", 8, ""], #　学院時代の同期の闇魔術師
           7 => ["トウキチ", 8, ""], #サカイの名主
           8 => ["ゴコウ", 8, ""],#サカイの名主の息子
           9 => ["", 21, ""],
           10 => ["", 21, ""],
           11 => ["サラ", 21, ""], #ロベ駐在の魔術師
           12 => ["", 21, ""],
           13 => ["", 21, ""],
           14 => ["ハルナ", 21, "Haruna"], #ツキハの側近巫女
           15 => ["", 21, ""],
           16 => ["ローザ", 21, "Rosa"], #フィリカ付きのメイド
           17 => ["エリス", 21, "Eris"], #ピオニーナイツ隊長　エリオラの姉
           18 => ["フェリシア", 21, "Felicia"], #ピオニーナイツ副隊長　エッチ好き
           19 => ["エリューシア", 21, "Ellusia"],# エリオラの母
           20 => ["エリィ", 21, ""], # エリューシアの愛称
           21 => ["ベイク", 8, ""], #ネメシアの盗人
           22 => ["ゴブリン", 8, ""],
           23 => ["ヤマコA", 8, ""],
           24 => ["ヤマコB", 8, ""],
           25 => ["邪龍", 21, ""],
           26 => ["オーク", 8, ""],
           27 => ["ヤマコ", 8, ""],
           28 => ["鬼", 8, ""],
           29 => ["", 21, ""],
           30 => ["", 21, ""],
           31 => ["ベルベット", 21, "Velvet"], #サジタリーズ女性大臣 ベルベット・ウォード
           32 => ["エリオラ", 21, "Eriora"], #氷結さん　自称ルナリアのライバル
           33 => ["べリア", 21, "Vieria"], #娼館のオーナー
           34 => ["アネモネ", 21, ""], #スノーレディ
           35 => ["ラナン", 21, "Ranun"], #スノークイーン
           36 => ["ゲオル", 21, ""], #ダリアの悪徳商人
           37 => ["カール", 21, ""], #廃坑前の兵士
           38 => ["マキ", 21, "Maki"], #スノーレディ　アネモネの友人
           39 => ["バニーウィッチ", 21, ""], #バニーウィッチ
           40 => ["ルゴール", 21, ""], # エリオラの父　ダリア王国騎士団団長 階級は将軍
           41 => ["サクラ", 21, "Sakura"], #
           42 => ["ユリ", 21, "Yuri"],
           43 => ["コハナ", 21, "Kohana"],
           44 => ["ハクト", 21, ""], # ツキハの息子 名前だけ
           45 => ["", 21, ""],
           46 => ["", 21, ""],
           47 => ["", 21, ""],
           48 => ["", 21, ""],
           49 => ["", 21, ""],
           50 => ["", 21, ""],
           51 => ["？？？", 21, ""],
          }

  Shop = { "in1" => ["Innkeeper Old Man", 0],   #Shop Clerk
           "in2" => ["Innkeeper Sister", 0], #
           "in3" => ["Innkeeper Madame", 0], #
           "in4" => ["Travel Inn Owner", 0], #
           "in5" => ["Travel Inn Madame", 0], #
           "in6" => ["Travel Inn Wife", 0], #
           "in7" => ["Shabby Inn Man", 0], #
           "in8" => ["Innkeeper Grandma", 0], #
           "in9" => ["Innkeeper Manager", 0], #
           "in0" => ["Inn", 0], #
           "we1" => ["Weapon Shop Old Man", 0], #
           "we2" => ["Weapon Shop Sister", 0], #
           "we3" => ["Weapon Shop Aunt", 0], #
           "we4" => ["Weapon Shop Owner", 0], #
           "we" => ["Weapon Shop", 0], #
           "ar1" => ["Armor Shop Old Man", 0], #
           "ar2" => ["Armor Shop Sister", 0], #
           "ar3" => ["Armor Shop Aunt", 0], #
           "ar" => ["Armor Shop", 0], #
           "ac1" => ["Accessory Shop Old Man", 0], #
           "ac2" => ["Accessory Shop Sister", 0], #
           "ac3" => ["Accessory Shop Aunt", 0], #
           "ac" => ["Accessory Shop", 0], #
           "it1" => ["Tool Shop Old Man", 0], #
           "it2" => ["Tool Shop Sister", 0],
           "it3" => ["Tool Shop Aunt", 0],
           "it" => ["Tool Shop", 0],
           "re1" => ["Alchemy Shop Old Man", 0], #
           "re2" => ["Alchemy Shop Sister", 0],
           "re3" => ["Alchemy Shop Aunt", 0],
           "re" => ["Alchemy Shop", 0],
           "ru1" => ["Rune Shop Old Man", 0], #
           "ru2" => ["Rune Shop Sister", 0],
           "ru3" => ["Rune Shop Aunt", 0],
           "ru" => ["Rune Shop", 0],
           "pu1" => ["Tavern Old Man", 0], #
           "pu2" => ["Tavern Sister", 0],
           "pu3" => ["Tavern Aunt", 0],
           "pu4" => ["Bunny Girl", 0],
           "pu5" => ["Tavern Uncle", 8],
           "pu" => ["Master", 0],
           "hu1" => ["Receptionist", 0],
           "ex" => ["Store Owner", 0],
           "ex1" => ["Salesperson", 0],
          }

  Mob = {  "rw_f1" => ["Female Court Magician", 0],   #Background character
           "rw_f2" => ["Female Senior Magician", 0], #
           "rw_f3" => ["Knowledgeable Magician", 0], #
           "rw_m1" => ["Male Court Magician", 0], #
           "rw_m2" => ["Male Senior Magician", 0], #
           "rw_m3" => ["Magician", 0], #
           "rw_m4" => ["Vice-Leader of the Magician's Group", 0], #
           
           "rp"    => ["Minister", 0], #
           "rp_m1" => ["Male Minister", 0], #
           "rp_m2" => ["Elder Minister", 0], #
           "rp_f1" => ["Female Minister", 0], #
           
           "rs1" => ["Kingdom Soldier", 0], #
           "rs2" => ["Supply Clerk", 0], #
           "rk1" => ["Kingdom Knight", 0], #
           "rk2" => ["Senior Knight", 0], #
           "rk1s" => ["Kingdom Knight on Leave", 0], #
           "rk2s" => ["Senior Knight on Leave", 0], #
           "rk1_f" => ["Female Kingdom Knight", 0], #
           "rk2_f" => ["Female Senior Knight", 0], #
           "rk1s_f" => ["Female Kingdom Knight on Leave", 0], #
           "rk2s_f" => ["Female Senior Knight on Leave", 0], #
           "rk3" => ["Leader of the Knights", 8], #
           "rk4" => ["Vice-Leader of the Knights", 0], #
           "rk5" => ["Captain", 0], #
           "rk_f" => ["Piony Knights", 0], #
           "rks_f" => ["Piony Knights on Leave", 0], #
           "s1"  => ["Security Guard", 0], #
           "bs1" => ["Soldier of Sagittarius", 0], #
           "bs1_l" => ["Leader of the Sagittarius Soldiers", 0], #
           "bs2" => ["Soldier of Dalia", 0], #
           "bs2_l" => ["Leader of the Dalia Soldiers", 0], #
           
           "m0" => ["Man", 0], #
           "m1" => ["Male", 0], #
           "m1s" => ["Man in Swimsuit", 0], #
           "m2" => ["Uncle", 0], #
           "m2s" => ["Uncle in Swimsuit", 0], #
           "m3" => ["Boy", 0], #
           "m4" => ["Father", 0], #
           "m5" => ["Grandfather", 0], #
           "m6" => ["Husband", 0], #
           "m7" => ["Big Brother", 0], #
           "m8" => ["Young Man", 0], #
           "m9" => ["Monk", 0], #
           "m9b" => ["Abbot", 0], #
           "m9c" => ["Young Monk", 0], #
           "m10" => ["Shop Owner", 0], #
           "m11" => ["DFC Member", 0], #
           "m12" => ["Constable", 0], #
           "m13" => ["Town Doctor", 0], #
           "m14" => ["Servant", 0], #
           "m15" => ["Vagrant", 0], #
           "m16" => ["Thug", 0], #
           "m17" => ["Rogue", 0], #
           "m18" => ["Suspicious Man", 0], #
           "m19" => ["Nobleman", 0], #
           "m19b" => ["Nobleman's Son", 0], #
           "m19c" => ["Nobleman's Elder", 0], #
           "m20" => ["Husband", 0], #
           "m21" => ["Veteran Summoner", 0], #
           "m22" => ["Bathhouse Guest", 0], #
           "m23" => ["Fat Man", 0], #
           "m24" => ["Talkative Carpenter", 0], #
           "m25" => ["Craftsman-like Man", 0], #
           "m26" => ["Man with a Magic Camera", 0], #
           "m27" => ["Dual Sword Swordsman", 0], #
           "m31" => ["Pervy Old Man", 0], #
           "m32" => ["Peeping Old Man", 0], #
           "m32b" => ["Peeping Man", 0], #
           "m33" => ["Pervy Grandpa", 0], #
           "m34" => ["Wealthy Middle-aged Man", 0], #
           "m35" => ["Drunkard", 0], #
           "m36" => ["Nouveau Riche Merchant", 0], #
           "m37" => ["Suspicious Peddler", 0], #
           "m38" => ["Handsome Helper", 0], #
           "m38b" => ["Middle-aged Helper", 0], #
           "m39" => ["Ranch Owner", 8], #
           "m40" => ["Brothel Client", 8], #
           "m41" => ["VIP Client", 8], #
           
           "f0" => ["Woman", 0], #
           "f1" => ["Female", 0], #
           "f1s" => ["Woman in Swimsuit", 0], #
           "f2" => ["Aunt", 0], #
           "f3" => ["Girl", 0], #
           "f4" => ["Mother", 0], #
           "f5" => ["Grandmother", 0], #
           "f6" => ["Wife", 0], #
           "f7" => ["Big Sister", 0], #
           "f7s" => ["Big Sister in Swimsuit", 0], #
           "f8" => ["Village Maiden", 0], #
           "f9" => ["Nun", 0], #
           "f10" => ["Shop Owner's Wife", 0], #
           "f11" => ["Teleportation Magician", 0], #
           "f14" => ["Maid", 0], #
           "f15" => ["Prostitute", 0], #
           "f19" => ["Noblewoman", 0], #
           "f19b" => ["Nobleman's Daughter", 0], #
           "f20" => ["Married Woman", 0], #
           
           "p1" => ["Swordsman", 0], #
           "p1_m" => ["Male Swordsman", 0], #
           "p1_f" => ["Female Swordsman", 0], #
           "p2" => ["Magician", 0], #
           "p2_m" => ["Male Magician", 0], #
           "p2_f" => ["Female Magician", 0], #
           "p3" => ["Martial Artist", 0], #
           "p3_m" => ["Male Martial Artist", 0], #
           "p3_f" => ["Female Martial Artist", 0], #
           "p4" => ["Healing Magician", 0], #
           "p4b" => ["Summoning Magician", 0], #
           "p5" => ["Scholar", 0], #
           "p6" => ["Warrior", 0], #
           "p6_m" => ["Male Warrior", 0], #
           "p6_f" => ["Female Warrior", 0], #
           "p6_w" => ["Married Female Warrior", 0], #
           "p6_o" => ["Old Warrior", 0], #
           "p7" => ["Samurai", 0], #
           "p7_m" => ["Bushido Warrior", 0], #
           "p7_f" => ["Female Samurai", 0], #
           "p8" => ["Researcher", 0], #
           "p9" => ["Librarian", 0], #
           "p10_m" => ["Priest", 0], #
           "p10_f" => ["Sister", 0], #
           "p11" => ["Village Chief", 0], #
           "p11_f" => ["Village Chief's Wife", 0], #
           "p11b" => ["Town Mayor", 0], #
           "p11b_w" => ["Town Mayor's Wife", 0], #
           "p11c" => ["Headman", 0], #
           "p11c_w" => ["Headman's Wife", 0], #
           "p11d" => ["Acting Headman", 0], #
           "p11d_m" => ["Acting Headman's Mother", 0], #
           "p11_o" => ["Former Village Chief", 0], #
           "p12" => ["Shrine Maiden", 0], #
           "p13" => ["Dancer", 0], #
           "p13b" => ["Minstrel", 0], #
           "p14" => ["Receptionist", 0], #
           "p14b" => ["Sales Clerk", 0], #
           "p14c" => ["Staff Member", 0], #
           "p14d" => ["Assistant", 0], #
           "p14e" => ["Attendant", 0], #
           "p14f" => ["Host", 0], #
           "p15" => ["Crew Member", 0], #
           "p15b" => ["Fisherman", 0], #
           "p16" => ["Captain", 0], #
           "p17" => ["Boatman", 0], #
           "p18" => ["Bodyguard", 0], #
           "p19" => ["Lookout", 0], #
           "p20" => ["Teahouse", 0], #
           "p20_m" => ["Izakaya Owner", 0], #
           "p20_f" => ["Izakaya Daughter", 0], #
           "p21" => ["Magician", 0], #
           "p21_f" => ["Female Magician", 0], #
           "p22" => ["Swimsuit Cafe Manager", 0], #
           
           "a1_m1" => ["Waiter", 0], #
           "a1_f1" => ["Waitress", 0], #
           "a1_f1s" => ["Waitress in Swimsuit", 0], #
           "a2_m1" => ["Butler", 0], #
           "a2_f1" => ["Maid", 0], #
           "a3" => ["Owner", 0], #
           "a4" => ["Shop Clerk", 0], #
           "a4b" => ["Employee", 0], #
           "a5" => ["Chef", 0], #
           
           "el_f" => ["Female Elf", 0], #
           "el_m" => ["Male Elf", 0], #
           
           "ex_f" => ["Female Adventurer", 0], #
           "pe_f" => ["Female Peddler", 0], #
           
           "ex" => ["Adventurer", 0], #
           "pe" => ["Peddler", 0], #
           "mc" => ["Follower of Zepar's Teachings", 0], #
           "ms" => ["Memorial Sister", 0], #
           
           "en1" => ["Thief", 0], #
           "en2" => ["Thief Boss", 0], #
           
           "qp1" => ["", 0], #
           "qp2" => ["Lilika", 0], #Guild receptionist sister
           "qp2b"=> ["Ruluka", 0], #Guild receptionist younger sister
           "qp3" => ["Merinda", 0], #Not set
           "qp4" => ["Fiona", 0], #Not set
           "qp5" => ["Dolton", 0], #Not set
           "qp6" => ["Arup", 0], #Not set
           "qp7" => ["", 0], #
           
           "mon" => ["Monster", 0], #Monster
           "mon_wa" => ["Yokai", 0], #Yokai
           "snow" => ["Snow Lady", 0], #
           "s_queen" => ["Snow Queen", 0], #
           "suc" => ["Succubus", 0], #
           
           "mob" => ["Crowd", 0], #
           
          }

  BWH =  { 
           "n1_t"   => 162,#データ設定項目・アクター１ルナリアの身長
           "n1_b"   => 98, #３サイズ・アクター１のバスト
           "n1_w"   => 59, #ウエスト
           "n1_h"   => 93, #ヒップ
           "n1_c"   => "I", #カップサイズ
           "n2_t"   => 164,#アクター２ソニアの身長
           "n2_b"   => 105, #バスト
           "n2_w"   => 62, #ウエスト
           "n2_h"   => 98, #ヒップ
           "n2_c"   => "K", #カップサイズ
           "n3_t"   => 150,#アクター３マナの身長
           "n3_b"   => 86, #バスト
           "n3_w"   => 51, #ウエスト
           "n3_h"   => 83, #ヒップ
           "n3_c"   => "H", #カップサイズ
           "n5_t"   => 163,#アクター５アネモネの身長
           "n5_b"   => 100, #バスト
           "n5_w"   => 58, #ウエスト
           "n5_h"   => 95, #ヒップ
           "n5_c"   => "J", #カップサイズ
           "n1b_t"   => 162,#淫魔ルナリアデータ
           "n1b_b"   => 104, #
           "n1b_w"   => 61, #
           "n1b_h"   => 96, #
           "n1b_c"   => "K", #
           "kp1_t"  => 160,#キーパーソン１マリアナの身長
           "kp1_b"  => 100,
           "kp1_w"  => 59,
           "kp1_h"  => 93,
           "kp1_c"  => "J",
           "kp1b_t"  => 160,#淫魔マリアナの身長
           "kp1b_b"  => 102,
           "kp1b_w"  => 60,
           "kp1b_h"  => 94,
           "kp1b_c"  => "K",
           "kp2_t"  => 161,#キーパーソン２ディアナの身長
           "kp2_b"  => 110,
           "kp2_w"  => 62,
           "kp2_h"  => 95,
           "kp2_c"  => "M",
           "kp3_t"  => 166,#キーパーソン３ミレイの身長
           "kp3_b"  => 103,
           "kp3_w"  => 61,
           "kp3_h"  => 94,
           "kp3_c"  => "K",
           "kp4_t"  => 159,#キーパーソン４シャーリーの身長
           "kp4_b"  => 84,
           "kp4_w"  => 57,
           "kp4_h"  => 91,
           "kp4_c"  => "D",
           "kp5_t"  => 162,#キーパーソン５エスティアの身長
           "kp5_b"  => 99,
           "kp5_w"  => 62,
           "kp5_h"  => 95,
           "kp5_c"  => "I",
           "kp6_t"  => 166,#キーパーソン６エレノアの身長
           "kp6_b"  => 108,
           "kp6_w"  => 64,
           "kp6_h"  => 99,
           "kp6_c"  => "L",
           "kp7_t"  => 152,#キーパーソン７メリスの身長
           "kp7_b"  => 97,
           "kp7_w"  => 57,
           "kp7_h"  => 89,
           "kp7_c"  => "J",
           "kp9_t"  => 166,#キーパーソン９サルビアの身長
           "kp9_b"  => 103,
           "kp9_w"  => 64,
           "kp9_h"  => 97,
           "kp9_c"  => "J",
           "kp11_t"  => 164,#キーパーソン１１リリの身長
           "kp11_b"  => 91,
           "kp11_w"  => 60,
           "kp11_h"  => 94,
           "kp11_c"  => "F",
           "kp12_t"  => 158,#キーパーソン１２ツキハの身長
           "kp12_b"  => 105,
           "kp12_w"  => 66,
           "kp12_h"  => 96,
           "kp12_c"  => "K",
           "kp13_t"  => 162,#キーパーソン１３フィリカの身長
           "kp13_b"  => 102,
           "kp13_w"  => 57,
           "kp13_h"  => 91,
           "kp13_c"  => "K",
           "kp31_t"  => 164,#キーパーソン３１レノの身長
           "kp31_b"  => 103,
           "kp31_w"  => 59,
           "kp31_h"  => 95,
           "kp31_c"  => "K",
           "kp32_t"  => 166,#キーパーソン３２アスモリオスの身長
           "kp32_b"  => 109,
           "kp32_w"  => 60,
           "kp32_h"  => 97,
           "kp32_c"  => "L",
           
           "kp8_t"  => 181,#キーパーソン８ドレイクの身長
           "kp14_t"  => 174,#キーパーソン１４シグンの身長
           "kp21_t"  => 185,#キーパーソン２１ライトの身長
           "kp22_t"  => 175,#キーパーソン２２ゴードの身長
           "kp23_t"  => 163,#キーパーソン２３デルタの身長
           "kp41_t"  => 200,#キーパーソン４１ゼパールの身長
           "kp42_t"  => 188,#キーパーソン４２マガツオロチの身長
           "kp42b_t"  => "?",#キーパーソン４２マガツオロチ(真)の身長
           "kp51_t"  => 190,#キーパーソン５１ベルゼリアンの身長
           "kp51b_t"  => "?",#キーパーソン５１ベルゼリアン(真)の身長
           "sb2_t"  => 181,#サブキャラ２カマラの身長
           "sb6_t"  => 170,#サブキャラ６アークスの身長
           
           "sb14_t"  => 161,#サブキャラ１４ハルナの身長
           "sb14_b"  => 94,
           "sb14_w"  => 60,
           "sb14_h"  => 88,
           "sb14_c"  => "G",
           "sb16_t"  => 157,#サブキャラ１６ローザの身長
           "sb16_b"  => 92,
           "sb16_w"  => 58,
           "sb16_h"  => 86,
           "sb16_c"  => "G",
           "sb17_t"  => 167,#サブキャラ１７エリスの身長
           "sb17_b"  => 96,
           "sb17_w"  => 56,
           "sb17_h"  => 92,
           "sb17_c"  => "I",
           "sb18_t"  => 158,#サブキャラ１８フェリシアの身長
           "sb18_b"  => 100,
           "sb18_w"  => 57,
           "sb18_h"  => 95,
           "sb18_c"  => "J",
           "sb19_t"  => 162,#サブキャラ１９エリューシアの身長
           "sb19_b"  => 105,
           "sb19_w"  => 63,
           "sb19_h"  => 98,
           "sb19_c"  => "K",
           "sb31_t"  => 160,#サブキャラ３１ベルベットの身長
           "sb31_b"  => 99,
           "sb31_w"  => 63,
           "sb31_h"  => 96,
           "sb31_c"  => "I",
           "sb32_t"  => 164,#サブキャラ３２エリオラの身長
           "sb32_b"  => 93,
           "sb32_w"  => 58,
           "sb32_h"  => 92,
           "sb32_c"  => "G",
           "sb33_t"  => 162,#サブキャラ３３べリアの身長
           "sb33_b"  => 102,
           "sb33_w"  => 62,
           "sb33_h"  => 98,
           "sb33_c"  => "J",
           "sb41_t"  => 158,#サブキャラ４１サクラの身長
           "sb41_b"  => 85,
           "sb41_w"  => 57,
           "sb41_h"  => 88,
           "sb41_c"  => "E",
           "sb42_t"  => 162,#サブキャラ４２ユリの身長
           "sb42_b"  => 103,
           "sb42_w"  => 62,
           "sb42_h"  => 94,
           "sb42_c"  => "K",
           "sb43_t"  => 152,#サブキャラ４３コハナの身長
           "sb43_b"  => 79,
           "sb43_w"  => 54,
           "sb43_h"  => 80,
           "sb43_c"  => "C",
           
           "sb38_t"  => 159,#サブキャラ３８マキの身長
           "sb38_b"  => 95,
           "sb38_w"  => 59,
           "sb38_h"  => 91,
           "sb38_c"  => "H",
           
           "sb35_t"  => 166,#サブキャラ３５ラナンの身長
           "sb35_b"  => 106,
           "sb35_w"  => 63,
           "sb35_h"  => 99,
           "sb35_c"  => "K",
           
           "kp44_t"  => 158,#キーパーソン４４玉藻前の身長
           "kp44_b"  => 97,
           "kp44_w"  => 60,
           "kp44_h"  => 95,
           "kp44_c"  => "I",
           
          }


end
          
#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 制御文字の事前変換　※再定義
  #    実際の描画を始める前に、原則として文字列に変わるものだけを置き換える。
  #    文字「\」はエスケープ文字（\e）に変換。
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)              { "\e" }
    result.gsub!(/\e\e/)            { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i)   { $game_variables[$1.to_i] }
    result.gsub!(/\eQT\[(\d+)\]/i)  { Quest.title($1.to_i) }
    #result.gsub!(/\eQTT\[(\d+)\]/i) { Quest.true_title($1.to_i) }
    result.gsub!(/\eQKM\[(\d+)\]/i) { $game_party.kill_list($1.to_i)}
    result.gsub!(/\eQKMK\[(\w+)\]/i) { $game_party.kill_list($1)}
    result.gsub!(/\eQIN\[(\w+)\,(\d+)\]/i) { $game_party.quest_item_number($1, $2.to_i)}
    result.gsub!(/\eQR\[(\d+)\]/i)  { Quest.reword_text($1.to_i) }
    result.gsub!(/\eN\[(\d+)\]/i)   { "\e>" + "\eC\[#{Person::Color[$1.to_i]}\]" + actor_name($1.to_i) + "\eC\[0\]" }
    result.gsub!(/\eNT\[(\d+)\]/i)  { actor_name($1.to_i) }
    result.gsub!(/\eKP\[(\d+)\]/i)  { "\e>" + "\eC\[#{Person::Name[$1.to_i][1]}\]" + Person::Name[$1.to_i][0] + "\eC\[0\]" }
    result.gsub!(/\eKPT\[(\d+)\]/i) { Person::Name[$1.to_i][0] }
    result.gsub!(/\eSB\[(\d+)\]/i)  { "\e>" + "\eC\[#{Person::Sub[$1.to_i][1]}\]" + Person::Sub[$1.to_i][0] + "\eC\[0\]" }
    result.gsub!(/\eSBT\[(\d+)\]/i) { Person::Sub[$1.to_i][0] }
    result.gsub!(/\eSHOP\[(\w+)\]/i){ "\e>" + "\eC\[#{Person::Shop[$1][1]}\]" + Person::Shop[$1][0] + "\eC\[0\]" }
    result.gsub!(/\eSHOPT\[(\w+)\]/i){ Person::Shop[$1][0] }
    result.gsub!(/\eMOB\[(\w+)\]/i) { "\e>" + "\eC\[#{Person::Mob[$1][1]}\]" + Person::Mob[$1][0] + "\eC\[0\]" }
    result.gsub!(/\eMOBT\[(\w+)\]/i){ Person::Mob[$1][0] }
    result.gsub!(/\eBWH\[(\w+)\]/i) { Person::BWH[$1]}
    result.gsub!(/\eSM/i)           { Vocab::summon }
    result.gsub!(/\eP\[(\d+)\]/i)   { party_member_name($1.to_i) }
    result.gsub!(/\eGN/i)           { FAKEREAL::GOLD_NAME }
    result.gsub!(/\eG/i)            { Vocab::currency_unit }
    result
  end
end
