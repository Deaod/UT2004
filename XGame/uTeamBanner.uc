class uTeamBanner extends Decoration;

var GameReplicationInfo GRI;
var int Team;

simulated function UpdateForTeam()
{
	if ( (GRI != None) && (Team < 2) && (GRI.TeamSymbols[Team] != None) )
        TexScaler(Combiner(Shader(FinalBlend(Skins[0]).Material).Diffuse).Material2).Material = GRI.TeamSymbols[Team];
}

simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
	UpdateForTeam();
}	
	
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();	
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     RemoteRole=ROLE_None
     Mesh=VertMesh'XGame_rc.banner'
}
