class ONSVehicleKillMessage extends LocalMessage;

var localized string KillString[8];
var name KillSound[8];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.KillString[Min(Switch,7)];
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
	P.PlayRewardAnnouncement(Default.KillSound[Min(Switch,7)],1,true);
}

defaultproperties
{
     KillString(0)="Road Kill!"
     KillString(1)="Hit and Run!"
     KillString(2)="Road Rage!"
     KillString(3)="Vehicular Manslaughter!"
     KillString(4)="Pancake!"
     KillString(5)="Eagle Eye!"
     KillString(6)="Top Gun!"
     KillString(7)="Fender Bender!"
     KillSound(0)="Road_Kill"
     KillSound(1)="Hit_and_run"
     KillSound(2)="Road_Rage"
     KillSound(3)="Vehicular_manslaughter"
     KillSound(4)="Pancake"
     KillSound(5)="EagleEye"
     KillSound(6)="Top_Gun"
     KillSound(7)="Fender_Bender"
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
