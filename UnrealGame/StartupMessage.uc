class StartupMessage extends CriticalEventPlus;

var localized string Stage[8], NotReady, SinglePlayer;
var sound	Riff;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( Switch < 7 )
	{
		P.Level.FillPrecacheMaterialsArray(false);
		P.Level.FillPrecacheStaticMeshesArray(false);
		P.PrecacheAnnouncements();
	}
	// don't play sound if quickstart=true, so no 'play' voiceover at start of tutorials
	if ( Switch == 5 && P != none && P.Level != none && P.Level.Game != none && (!P.Level.Game.IsA('Deathmatch') || (!DeathMatch(P.Level.Game).bQuickstart && !DeathMatch(P.Level.Game).bSkipPlaySound)) )
		P.PlayStatusAnnouncement('Play',1,true);
	else if ( (Switch > 1) && (Switch < 5) )
		P.PlayBeepSound();
	else if ( Switch == 7 )
		P.ClientPlaySound(Default.Riff);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int i, PlayerCount;
	local GameReplicationInfo GRI;

	if ( (RelatedPRI_1 != None) && (RelatedPRI_1.Level.NetMode == NM_Standalone) )
	{
		if ( (DeathMatch(RelatedPRI_1.Level.Game) != None) && DeathMatch(RelatedPRI_1.Level.Game).bQuickstart )
			return "";
		if ( Switch < 2 )
			return Default.SinglePlayer;
	}
	else if ( Switch == 0 && RelatedPRI_1 != None )
	{
		GRI = RelatedPRI_1.Level.GRI;
		if (GRI == None)
			return Default.Stage[0];
		for (i = 0; i < GRI.PRIArray.Length; i++)
		{
			if ( GRI.PRIArray[i] != None && !GRI.PRIArray[i].bOnlySpectator
			     && (!GRI.PRIArray[i].bIsSpectator || GRI.PRIArray[i].bWaitingPlayer) )
				PlayerCount++;
		}
		if (GRI.MinNetPlayers - PlayerCount > 0)
			return Default.Stage[0]@"("$(GRI.MinNetPlayers - PlayerCount)$")";
	}
	else if ( switch == 1 )
	{
		if ( (RelatedPRI_1 == None) || !RelatedPRI_1.bWaitingPlayer )
			return Default.Stage[0];
		else if ( RelatedPRI_1.bReadyToPlay )
			return Default.Stage[1];
		else
			return Default.NotReady;
	}
	return Default.Stage[Switch];
}

defaultproperties
{
     Stage(0)="Waiting for other players."
     Stage(1)="Waiting for ready signals. You are READY."
     Stage(2)="The match is about to begin...3"
     Stage(3)="The match is about to begin...2"
     Stage(4)="The match is about to begin...1"
     Stage(5)="The match has begun!"
     Stage(6)="The match has begun!"
     Stage(7)="OVER TIME!"
     NotReady="You are NOT READY. Press Fire!"
     SinglePlayer="Press FIRE to start!"
     Riff=Sound'GameSounds.Fanfares.UT2K3Fanfare11'
     bIsConsoleMessage=False
     DrawColor=(G=64,R=32)
}
