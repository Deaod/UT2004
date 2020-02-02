class IdleKickWarningMessage extends LocalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	UnrealPlayer(OptionalObject).LastKickWarningTime = UnrealPlayer(OptionalObject).Level.TimeSeconds;
    return class'GameMessage'.Default.KickWarning;
}

defaultproperties
{
     bIsPartiallyUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=64)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
