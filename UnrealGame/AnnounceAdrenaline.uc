class AnnounceAdrenaline extends Info;

var sound AnnounceSound;
var name Announcement;

function Timer()
{
	if ( PlayerController(Owner) != None )
	{
		if ( Announcement != '' )
			PlayerController(Owner).PlayRewardAnnouncement(Announcement,1);
		else if ( AnnounceSound != None )
			PlayerController(Owner).PlayAnnouncement(AnnounceSound,1);
	}
	Destroy();
}

defaultproperties
{
     LifeSpan=30.000000
}
