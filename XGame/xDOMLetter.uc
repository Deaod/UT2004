//=============================================================================
// xDomLetter.
//=============================================================================
class xDomLetter extends Decoration
    abstract;

#exec OBJ LOAD FILE=XGameTextures.utx

var() Material  RedTeamShader;
var() Material  BlueTeamShader;
var() Material  NeutralShader;

defaultproperties
{
     RedTeamShader=Shader'XGameTextures.SuperPickups.DOMabRs'
     BlueTeamShader=Shader'XGameTextures.SuperPickups.DOMabBs'
     NeutralShader=Shader'XGameTextures.SuperPickups.DOMabGs'
     Skins(0)=Shader'XGameTextures.SuperPickups.DOMabGs'
     bNetNotify=True
}
