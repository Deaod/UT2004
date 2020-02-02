//=============================================================================
// xDomPointA.
// For Double Domination (xDoubleDom) matches.
//=============================================================================
class xDomPointA extends xDomPoint
	placeable;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (Level.NetMode != NM_Client)
    {
        DomLetter = Spawn(class'XGame.xDomA',self,,Location+EffectOffset,Rotation);
        DomRing = Spawn(class'XGame.xDomRing',self,,Location+EffectOffset,Rotation);
    }

    SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
}

defaultproperties
{
     PointName="A"
     ControlEvent="xDOMMonitorA"
     PrimaryTeam=1
     ObjectiveName="Point A"
}
