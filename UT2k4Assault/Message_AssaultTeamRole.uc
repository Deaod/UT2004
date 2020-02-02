//==============================================================================
// Message_AssaultTeamRole
//==============================================================================
//	Created by Laurent Delayen
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class Message_AssaultTeamRole extends LocalMessage;


var localized string	Message_PostLogin_Attacker, Message_PostLogin_Defender;
var name				TeamSounds[2];

var Color	BlueColor, RedColor;


static function ClientReceive( 
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	local GameObjective GO;
	local bool			bNotify;

	super.ClientReceive( P,Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

	if ( P.myHUD != None && P.myHUD.IsA('HUD_Assault') )
	{
		HUD_Assault(P.myHUD).CurrentObjective = None;	// force update
		GO		= HUD_Assault(P.myHUD).GetCurrentObjective();
		bNotify = HUD_Assault(P.myHUD).CanSpawnNotify();
	}

	if ( bNotify )
	{
		switch ( Switch )
		{
			case 0 : P.QueueAnnouncement( default.TeamSounds[0], 2, AP_InstantPlay ); break;
			case 1 : P.QueueAnnouncement( default.TeamSounds[1], 2, AP_InstantPlay ); break;
		}

		AnnounceCurrentObjective( P, GO, Switch == 0 );
	}		
	else
		AnnounceCurrentObjective( P, None, Switch == 0 );
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	switch ( Switch )
	{
		case 0 : return default.Message_PostLogin_Attacker;
		case 1 : return default.Message_PostLogin_Defender;
	}
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
	if ( (RelatedPRI_1 != None) && (RelatedPRI_1.Team != None) )
	{
		if ( RelatedPRI_1.Team.TeamIndex == 0 )
			return default.RedColor;
		else
			return default.BlueColor;
	}
	else
		return default.DrawColor;
}

static function AnnounceCurrentObjective( PlayerController PC, GameObjective GO, bool bAttacking )
{
	local Sound	Announcer;

	if ( GO != None && GO.IsActive() && !GO.bOptionalObjective )
	{
		if ( bAttacking )
			Announcer = GO.Announcer_ObjectiveInfo;
		else
			Announcer = GO.Announcer_DefendObjective;
	}

	if ( Announcer != None )
		PC.QueueAnnouncement( Announcer.Name, 1, AP_NoDuplicates, 200 );
	else
		PC.QueueAnnouncement( '', 1, AP_NoDuplicates, 201 );	// Simple objective highlight
}

defaultproperties
{
     Message_PostLogin_Attacker="You are Attacking!!"
     Message_PostLogin_Defender="You are Defending!!"
     TeamSounds(0)="You_are_attacking"
     TeamSounds(1)="You_are_defending"
     BlueColor=(B=255,A=255)
     RedColor=(R=255,A=255)
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     StackMode=SM_Down
     PosY=0.330000
}
