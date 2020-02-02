//=============================================================================
// xDomPointB.
// For Double Domination (xDoubleDom) matches.
//=============================================================================
class xDomPointB extends xDomPoint
	placeable;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (Level.NetMode != NM_Client)
    {
        DomLetter = Spawn(class'XGame.xDomB',self,,Location+EffectOffset,Rotation);
        DomRing = Spawn(class'XGame.xDomRing',self,,Location+EffectOffset,Rotation);    
    }
        
    SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
}

defaultproperties
{
     PointName="B"
     ControlEvent="xDOMMonitorB"
     DomCombiner(0)=Combiner'XGameShaders.DomShaders.DomBCombiner'
     DomShader=Shader'XGameShaders.DomShaders.PulseBShader'
     ObjectiveName="Point B"
     Skins(1)=Combiner'XGameShaders.DomShaders.DomPointBCombiner'
}
