class Message_ASKillMessages extends LocalMessage;

const MaxMSGs=8;
var localized string KillString[MaxMSGs];
var name KillSound[MaxMSGs];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return default.KillString[Min(Switch,MaxMSGs-1)];
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( default.KillSound[Min(Switch,MaxMSGs-1)] != '' )
		P.PlayRewardAnnouncement(default.KillSound[Min(Switch,MaxMSGs-1)],1,true);
}

defaultproperties
{
     KillString(0)="Top Gun!"
     KillString(1)="Wrecker!"
     KillString(2)="Vehicle spawn blocking! 5 secs warning"
     KillString(3)="Vehicle spawn blocking! 4 secs warning"
     KillString(4)="Vehicle spawn blocking! 3 secs warning"
     KillString(5)="Vehicle spawn blocking! 2 secs warning"
     KillString(6)="Vehicle spawn blocking! 1 sec warning"
     KillString(7)="Leaving battle field!"
     KillSound(0)="Top_Gun"
     KillSound(1)="Wrecker"
     bIsConsoleMessage=False
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
