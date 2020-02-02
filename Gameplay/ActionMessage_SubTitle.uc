// ====================================================================
//  Class:  GamePlay.ActionMessage_SubTitle
//  Parent: GamePlay.ActionMessage
//
//  <Enter a description here>
// ====================================================================

class ActionMessage_SubTitle extends ActionMessage;

var localized float Delays[32];

static function float GetLifeTime(int Switch)
{
	if (default.Delays[switch]==0.0)
	    return default.LifeTime;
    else
    	return default.Delays[Switch];
}

defaultproperties
{
     Delays(0)=4.000000
     Delays(1)=4.000000
     Delays(2)=8.000000
     Delays(3)=8.000000
     Delays(4)=8.000000
     Delays(5)=8.000000
     Delays(6)=8.000000
     Delays(7)=8.000000
     Delays(8)=8.000000
     Delays(9)=8.000000
     Delays(10)=8.000000
     Delays(11)=8.000000
     Delays(12)=8.000000
     Delays(13)=8.000000
     Delays(14)=8.000000
     Delays(15)=8.000000
     Delays(16)=8.000000
     Delays(17)=8.000000
     Delays(18)=8.000000
     Delays(19)=8.000000
     Delays(20)=8.000000
     Delays(21)=8.000000
     Messages(0)="How do I look?"
     Messages(1)="Not as good as me baby..."
     Messages(2)="Well fans here we are for another edition of the bloodiest sport in the Galaxy. A tournament where the winners become gods and the losers pay the ultimate price!"
     Messages(3)="THERE THEY ARE! Once they were rivals, but now they're one of the fiercest teams around."
     Messages(4)="That's right. Nothing beats experience and each one of these three brings loads of it to the table."
     Messages(5)="Look at Malcolm! Now there's a guy who can really keep his cool in a fire-fight."
     Messages(6)="That Brock. He's as dangerous to the ladies OUT-side the ring as he is to his foes IN-side!"
     Messages(7)="I love watching Lauren. She's such a little....bundle of energy."
     Messages(8)="Yeah right.....you like watching Lauren for her energy."
     Messages(9)="This time he's MINE!!"
     Messages(10)="AAGGGHHHHRRRR"
     Messages(11)="You d'man Gorge! You rock! Yeah baby, com'on, now, you d'man dude!"
     Messages(12)="MAAAALLLCOOOOOMMM!"
     Messages(13)="Oh, man, did you see that?"
     Messages(14)="I tell you Jim, that Gorge, he just has no respect for his fans."
     Messages(15)="Well, I think he is still pissed about that new scar on his face, courtesy of Malcolm in their last match."
     Messages(16)="Yea, I think he is looking for a little PAYBACK."
     Messages(17)="Yep, it should be a good one tonight."
     Messages(18)="Since Malcolm's team are the reigning champs, they get to choose tonight's arena."
     Messages(19)="Looks like it's gonna be... Kalendra Icefields."
     Messages(20)="Awww Yeah, I love this arena, Malcolm does really well here."
     Messages(21)="Tonight's match oughta be a real blood-bath."
}
