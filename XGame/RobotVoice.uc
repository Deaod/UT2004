//=============================================================================
// Robot Voice.
//=============================================================================
class RobotVoice extends xVoicePack;

#exec OBJ LOAD FILE=TauntPack.uax

defaultproperties
{
     NameSound(0)=Sound'TauntPack.R_redleader'
     NameSound(1)=Sound'TauntPack.R_blueleader'
     AckSound(0)=Sound'TauntPack.r_affirmative'
     AckSound(1)=Sound'TauntPack.r_got_it'
     AckSound(2)=Sound'TauntPack.r_im_on_it'
     AckSound(3)=Sound'TauntPack.r_roger'
     FFireSound(0)=Sound'TauntPack.r_im_on_your_team'
     FFireSound(1)=Sound'TauntPack.r_im_on_your_team_idiot'
     FFireSound(2)=Sound'TauntPack.r_same_team'
     TauntSound(0)=Sound'TauntPack.R_and_stay_down'
     TauntSound(1)=Sound'TauntPack.R_anyoneelsewantsome'
     TauntSound(2)=Sound'TauntPack.R_boom'
     TauntSound(3)=Sound'TauntPack.R_burnbaby'
     TauntSound(4)=Sound'TauntPack.R_diebitch'
     TauntSound(5)=Sound'TauntPack.R_eatthat'
     TauntSound(6)=Sound'TauntPack.R_fightlikenali'
     TauntSound(7)=Sound'TauntPack.R_isthatyourbest'
     TauntSound(8)=Sound'TauntPack.R_kissmyass'
     TauntSound(9)=Sound'TauntPack.R_loser'
     TauntSound(10)=Sound'TauntPack.R_myhouse'
     TauntSound(11)=Sound'TauntPack.R_next'
     TauntSound(12)=Sound'TauntPack.R_ohyeah'
     TauntSound(13)=Sound'TauntPack.R_ownage'
     TauntSound(14)=Sound'TauntPack.R_seeya'
     TauntSound(15)=Sound'TauntPack.R_that_had_to_hurt'
     TauntSound(16)=Sound'TauntPack.R_useless'
     TauntSound(17)=Sound'TauntPack.R_you_play_like_a_girl'
     TauntSound(18)=Sound'TauntPack.R_youbedead'
     TauntSound(19)=Sound'TauntPack.R_youlikethat'
     TauntSound(20)=Sound'TauntPack.R_youwhore'
     TauntSound(21)=Sound'TauntPack.r_die_human'
     TauntSound(22)=Sound'TauntPack.r_faster_stronger_better'
     TauntSound(23)=Sound'TauntPack.r_fear_me'
     TauntSound(24)=Sound'TauntPack.r_flesh_is_a_design_flaw'
     TauntSound(25)=Sound'TauntPack.r_my_victory_your_death'
     TauntSound(26)=Sound'TauntPack.r_not_unacceptable'
     TauntSound(27)=Sound'TauntPack.r_rogue_process_terminated'
     TauntSound(28)=Sound'TauntPack.r_witness_my_perfection'
     TauntSound(29)=Sound'TauntPack.r_you_die_too_easily'
     TauntSound(30)=Sound'TauntPack.r_you_make_easy_prey'
     TauntSound(31)=Sound'TauntPack.r_your_programming_is_inferior'
     TauntString(21)="Die Human"
     TauntString(22)="Faster Stronger Better"
     TauntString(23)="Fear Me"
     TauntString(24)="Flesh Is A Design Flaw"
     TauntString(25)="My Victory Your Death"
     TauntString(26)="Not Unacceptable"
     TauntString(27)="Rogue Process Terminated"
     TauntString(28)="Witness My Perfection"
     TauntString(29)="You Die Too Easily"
     TauntString(30)="You Make Easy Prey"
     TauntString(31)="Your Programming Is Inferior"
     numTaunts=32
     OrderSound(0)=Sound'TauntPack.r_defend_the_base'
     OrderSound(1)=Sound'TauntPack.R_holdthisposition'
     OrderSound(2)=Sound'TauntPack.r_attack_their_base'
     OrderSound(3)=Sound'TauntPack.r_cover_me'
     OrderSound(4)=Sound'TauntPack.R_searchanddestroy'
     OrderSound(10)=Sound'TauntPack.R_take_their_flag'
     OrderSound(11)=Sound'TauntPack.r_defend_the_flag'
     OrderSound(12)=Sound'TauntPack.R_attackalpha'
     OrderSound(13)=Sound'TauntPack.R_attackbravo'
     OrderSound(14)=Sound'TauntPack.R_gettheball'
     OtherSound(0)=Sound'TauntPack.r_base_is_undefended'
     OtherSound(1)=Sound'TauntPack.r_get_our_flag_back'
     OtherSound(2)=Sound'TauntPack.R_igottheflag'
     OtherSound(3)=Sound'TauntPack.r_ive_got_your_back'
     OtherSound(4)=Sound'TauntPack.r_im_hit'
     OtherSound(5)=Sound'TauntPack.r_man_down'
     OtherSound(6)=Sound'TauntPack.r_im_all_alone_here'
     OtherSound(7)=Sound'TauntPack.r_negative'
     OtherSound(8)=Sound'TauntPack.r_got_it'
     OtherSound(9)=Sound'TauntPack.r_in_position'
     OtherSound(10)=Sound'TauntPack.r_im_going_in'
     OtherSound(11)=Sound'TauntPack.r_area_secure'
     OtherSound(12)=Sound'TauntPack.r_enemy_flag_carrier_is_here'
     OtherSound(13)=Sound'TauntPack.r_i_need_backup'
     OtherSound(14)=Sound'TauntPack.r_incoming'
     OtherSound(15)=Sound'TauntPack.r_ball_carrier_is_here'
     OtherSound(16)=Sound'TauntPack.r_point_alpha_secure'
     OtherSound(17)=Sound'TauntPack.r_point_bravo_secure'
     OtherSound(18)=Sound'TauntPack.R_attackalpha'
     OtherSound(19)=Sound'TauntPack.R_attackbravo'
     OtherSound(20)=Sound'TauntPack.r_the_base_is_under_attack'
     OtherSound(21)=Sound'TauntPack.r_were_being_overrun'
     OtherSound(22)=Sound'TauntPack.r_under_heavy_attack'
     OtherSound(23)=Sound'TauntPack.r_defend_point_alpha'
     OtherSound(24)=Sound'TauntPack.r_defend_point_bravo'
     OtherSound(25)=Sound'TauntPack.R_gettheball'
     OtherSound(26)=Sound'TauntPack.r_im_on_defense'
     OtherSound(27)=Sound'TauntPack.r_im_on_offense'
     OtherSound(28)=Sound'TauntPack.r_take_point_alpha'
     OtherSound(29)=Sound'TauntPack.r_take_point_bravo'
     OtherSound(30)=Sound'TauntPack.R_medic'
     OtherSound(31)=Sound'TauntPack.R_nice'
     OtherSound(32)=Sound'TauntPack.r_rerouting_critical_systems'
     OtherSound(33)=Sound'TauntPack.r_you_adapt_well'
     OtherString(32)="Rerouting Critical Systems"
     OtherString(33)="You Adapt Well"
     DeathPhrases(0)=Sound'TauntPack.R_medic'
     DeathPhrases(1)=Sound'TauntPack.R_nice'
     DeathPhrases(2)=Sound'TauntPack.r_rerouting_critical_systems'
     DeathPhrases(3)=Sound'TauntPack.r_you_adapt_well'
     NumDeathPhrases=4
     VoicePackName="Robot"
}
