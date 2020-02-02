//=============================================================================
// xDOMMonitor - Domination monitor (two screens).
//=============================================================================
class xDOMMonitor extends xMonitor
    abstract;

var() Material RedShader;
var() Material BlueShader;
var() Material ActiveShader;
var() Material InactiveShader;
var() Material ActiveTeamShader;
var() Material InactiveTeamShader;
var byte NewTeam;

simulated function UpdateForTeam()
{
	if ( NewTeam == 254 )
	{
        Skins[2] = InactiveTeamShader;
        Skins[3] = InactiveShader;
	}
	else if ( NewTeam == 0 )
	{
		Skins[2] = RedTeamShader;
		Skins[3] = RedShader;
	}
	else if ( NewTeam == 1 )
	{
		Skins[2] = BlueTeamShader;
		Skins[3] = BlueShader;
	}
	else
	{
		Skins[2] = ActiveTeamShader;
		Skins[3] = ActiveShader;
	}
	
	if ( (GRI != None) && (NewTeam < 2) && !Level.IsSoftwareRendering() )
		Combiner(Shader(Skins[2]).SelfIllumination).Material2 = GRI.TeamSymbols[NewTeam];
}

simulated function Trigger( actor Other, pawn EventInstigator )
{
    local xDomPoint DPoint;

	DPoint = xDomPoint(Other);
    if ( DPoint != None )
    {        
        // is the point disabled?
        if (!DPoint.bControllable)
			NewTeam = 254;
        else if (DPoint.ControllingTeam == None)
 			NewTeam = 255;               
        else
			NewTeam = DPoint.ControllingTeam.TeamIndex;
        UpdateForTeam();
    }
}

defaultproperties
{
     ActiveTeamShader=Shader'XGameTextures.SuperPickups.GreyScreenS'
     InactiveTeamShader=Shader'XGameTextures.SuperPickups.BlackScreenS'
     NewTeam=255
     Team=255
     StaticMesh=StaticMesh'XGame_StaticMeshes.GameObjects.DOMMonitor'
     DrawScale=0.500000
}
