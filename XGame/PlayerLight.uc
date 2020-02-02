//=============================================================================
// PlayerLight.
//=============================================================================
class PlayerLight extends ScaledSprite;

var() float ExtinguishTime;

singular function BaseChange();

defaultproperties
{
     ExtinguishTime=1.500000
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_None
     DrawScale=0.150000
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
