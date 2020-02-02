//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native;

// Standard PlayInfo groups

var const localized string RulesGroup,
                           GameGroup,
                           ServerGroup,
                           ChatGroup,
                           BotsGroup,
                           MapVoteGroup,
                           KickVoteGroup;

// mc: Fill a PlayInfoData structure to allow easy access to
static function FillPlayInfo(PlayInfo PlayInfo)
{
	PlayInfo.AddClass(default.Class);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	return true;
}

//	rjp-- Can I remove a class from playinfo?
//	Called when PlayInfo.RemoveClass is called on this class
//	Only called if you have called PopClass() after calling FillPlayInfo() on this class
static event bool AllowClassRemoval()
{
	return true;
}

static event byte GetSecurityLevel(string PropName)
{
	return 0;
}

static event string GetDescriptionText(string PropName)
{
	return "";
}

defaultproperties
{
     RulesGroup="Rules"
     GameGroup="Game"
     ServerGroup="Server"
     ChatGroup="Chat"
     BotsGroup="Bots"
     MapVoteGroup="Map Voting"
     KickVoteGroup="Kick Voting"
     bHidden=True
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_None
     NetUpdateFrequency=10.000000
}
