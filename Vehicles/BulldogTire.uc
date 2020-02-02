class BulldogTire extends KTire;

defaultproperties
{
     StaticMesh=StaticMesh'BulldogMeshes.Simple.S_RearWheel'
     DrawScale=0.400000
     CollisionRadius=34.000000
     CollisionHeight=34.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.800000
         KInertiaTensor(3)=1.800000
         KInertiaTensor(5)=1.800000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
     End Object
     KParams=KarmaParamsRBFull'Vehicles.BulldogTire.KParams0'

}
