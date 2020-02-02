//=============================================================================
// xDomB.
//=============================================================================
class xDomB extends xDOMLetter;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.DomBMesh'
     bStatic=False
     bStasis=False
     Physics=PHYS_Rotating
     DrawScale=0.250000
     bFixedRotationDir=True
     RotationRate=(Yaw=24000)
}
