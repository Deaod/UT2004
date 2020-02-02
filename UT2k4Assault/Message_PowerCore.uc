class Message_PowerCore extends LocalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local ASObj_EnergyCore_Spawn EC;

	EC = ASObj_EnergyCore_Spawn(OptionalObject);
	if ( EC == None )
	{
		switch( Switch )
		{
			case 0 : return RelatedPRI_1.PlayerName $ class'GameObject_EnergyCore'.default.PlayerDroppedMessage;
			case 1 : return class'GameObject_EnergyCore'.default.DroppedMessage;
			case 2 : return class'GameObject_EnergyCore'.default.EnergyCorePickedUp;
			case 3 : return RelatedPRI_1.PlayerName $ class'GameObject_EnergyCore'.default.PlayerPickedUpEnergyCore;
			case 4 : return class'GameObject_EnergyCore'.default.PlayerCoreReset;
		}
	}
	else
	{
		switch( Switch )
		{
			case 0 : return RelatedPRI_1.PlayerName $ EC.PlayerDroppedMessage;
			case 1 : return EC.DroppedMessage;
			case 2 : return EC.EnergyCorePickedUp;
			case 3 : return RelatedPRI_1.PlayerName $ EC.PlayerPickedUpEnergyCore;
			case 4 : return EC.PlayerCoreReset;
		}
	}
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local ASObj_EnergyCore_Spawn EC;

	super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	EC = ASObj_EnergyCore_Spawn(OptionalObject);
	if ( EC == None )
	{
		Switch( Switch )
		{
			case 0 :
			case 1 : P.QueueAnnouncement( class'GameObject_EnergyCore'.default.Announcer_EnergyCore_Dropped, 1); break;
			case 2 :
			case 3 : P.QueueAnnouncement( class'GameObject_EnergyCore'.default.Announcer_EnergyCore_PickedUp, 1); break;
			case 4 : P.QueueAnnouncement( class'GameObject_EnergyCore'.default.Announcer_EnergyCore_Reset, 1); break;
		}
	}
	else
	{
		Switch( Switch )
		{
			case 0 :
			case 1 : P.QueueAnnouncement( EC.Announcer_EnergyCore_Dropped.Name, 1); break;
			case 2 :
			case 3 : P.QueueAnnouncement( EC.Announcer_EnergyCore_PickedUp.Name, 1); break;
			case 4 : P.QueueAnnouncement( EC.Announcer_EnergyCore_Reset.Name, 1); break;
		}
	}
}

defaultproperties
{
     bIsConsoleMessage=False
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
