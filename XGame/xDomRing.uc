//=============================================================================
// xDomRing.
//=============================================================================
class xDomRing extends Decoration;

var() Material  RedTeamShader;
var() Material  BlueTeamShader;
var() Material  NeutralShader;

defaultproperties
{
     RedTeamShader=Shader'XGameTextures.SuperPickups.DOMRedS'
     BlueTeamShader=Shader'XGameTextures.SuperPickups.DOMBlueS'
     NeutralShader=Shader'XGameTextures.SuperPickups.DOMGreyS'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.DomRing'
     bStatic=False
     bStasis=False
     Physics=PHYS_Rotating
     DrawScale=0.250000
     Skins(0)=Shader'XGameTextures.SuperPickups.DOMGreyS'
     bNetNotify=True
     bFixedRotationDir=True
     RotationRate=(Yaw=-16000,Roll=48000)
}
