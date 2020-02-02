class xBot extends Bot
    DependsOn(xUtil);

var() xUtil.PlayerRecord PawnSetupRecord;

function SetPawnClass(string inClass, string inCharacter)
{
    local class<xPawn> pClass;
    
    if ( inClass != "" )
	{
		pClass = class<xPawn>(DynamicLoadObject(inClass, class'Class'));
		if (pClass != None)
			PawnClass = pClass;
	}
	
    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(inCharacter);
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	if ( xPawn(aPawn) != None )
		xPawn(aPawn).Setup(PawnSetupRecord);
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'XGame.xPlayerReplicationInfo'
}
