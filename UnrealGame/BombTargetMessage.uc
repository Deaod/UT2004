class BombTargetMessage extends LocalMessage;

var Localized string TargetMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return default.TargetMessage;
}

defaultproperties
{
     TargetMessage="Incoming Pass"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=200,G=200,R=200,A=200)
     PosY=0.650000
}
