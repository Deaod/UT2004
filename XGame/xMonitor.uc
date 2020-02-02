//=============================================================================
// xMonitor - Team monitors for designating team areas.
//=============================================================================
class xMonitor extends Decoration
    abstract;

var() byte      Team;
var() Material  RedTeamShader;
var() Material  BlueTeamShader;
var GameReplicationInfo GRI;

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(RedTeamShader);
    Level.AddPrecacheMaterial(BlueTeamShader);

	super.UpdatePrecacheMaterials();
}

simulated function UpdateForTeam()
{
    if (Team == 0)
        Skins[2] = RedTeamShader;
    else
        Skins[2] = BlueTeamShader;

	if ( (GRI != None) && (Team < 2) && (GRI.TeamSymbols[Team] != None) )
		Combiner(Shader(Skins[2]).SelfIllumination).Material2 = GRI.TeamSymbols[Team];
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
     RedTeamShader=Shader'XGameTextures.SuperPickups.RedScreenS'
     BlueTeamShader=Shader'XGameTextures.SuperPickups.BlueScreenS'
     DrawType=DT_StaticMesh
     bStatic=False
     bNoDelete=True
     bStasis=False
     bWorldGeometry=True
     RemoteRole=ROLE_None
     DrawScale=2.500000
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     bBlockKarma=True
     bNetNotify=True
}
