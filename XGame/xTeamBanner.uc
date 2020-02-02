//=============================================================================
// xTeamBanner.
//=============================================================================
class xTeamBanner extends Decoration;

// todo: the white texture used for dom2 neutral state needs to be a shader so it can be 2-sided!!!

var() byte Team;
var GameReplicationInfo GRI;

simulated function PostBeginPlay()
{
    LoopAnim('AnimFlag');
    SetAnimFrame(FRand());

    Super.PostBeginPlay();
}

simulated function UpdateForTeam()
{
    if (Team == 0)
        Skins[0] = Shader'XGameShaders.RedBannerShader';
    else if ( Team > 1 )
		Skins[0] = Default.Skins[0]; //Shader'XGameShaders.TeamBannerShadder';
	else
        Skins[0] = Shader'XGameShaders.BlueBannerShader';

	if ( (GRI != None) && (Team < 2) && (GRI.TeamSymbols[Team] != None) )
		TexScaler(Combiner(Shader(Skins[0]).Diffuse).Material2).Material = GRI.TeamSymbols[Team];
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

simulated function Trigger( actor Other, pawn EventInstigator )
{
    local DominationPoint DPoint;

	DPoint = DominationPoint(Other);
    if ( DPoint != None )
    {
        // is the point disabled?
        if (!DPoint.bControllable)
			Team = 254;
        else if (DPoint.ControllingTeam == None)
 			Team = 255;
        else
			Team = DPoint.ControllingTeam.TeamIndex;
        UpdateForTeam();
    }
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=VertMesh'XGame_rc.TeamBannerMesh'
     Tag="'"
     DrawScale=1.700000
     Skins(0)=Shader'XGameShaders.TeamBannerShader'
     bUnlit=True
     CollisionRadius=48.000000
     CollisionHeight=90.000000
     bCollideActors=True
     bCollideWorld=True
     bNetNotify=True
}
