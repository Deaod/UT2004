class xRealCTFBase extends CTFBase
	abstract;

var GameReplicationInfo GRI;
var() vector BaseOffset;

simulated function UpdateForTeam()
{
	if ( (GRI != None) && (DefenderTeamIndex < 2) && (GRI.TeamSymbols[DefenderTeamIndex] != None) )
	    TexScaler(Combiner(Shader(FinalBlend(Skins[0]).Material).Diffuse).Material2).Material = GRI.TeamSymbols[DefenderTeamIndex];
}

simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
	UpdateForTeam();
}	

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
    
    if ( Level.NetMode != NM_DedicatedServer )
        LoopAnim('flag',0.8);
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);
}

defaultproperties
{
     BaseOffset=(X=2.000000,Z=-18.000000)
     TakenSound=Sound'GameSounds.CTFAlarm'
     bHidden=False
     Mesh=VertMesh'XGame_rc.FlagMesh'
     DrawScale=1.200000
     CollisionHeight=80.000000
     bNetNotify=True
}
