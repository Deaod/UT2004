//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerCoreEnergy extends Actor
    abstract;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMStructures.CoreGroup.COREenergy'
     bStasis=True
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     bMovable=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
