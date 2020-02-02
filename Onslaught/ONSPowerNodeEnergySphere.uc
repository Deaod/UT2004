//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerNodeEnergySphere extends Actor;

var()   float           InducerRotationSpeed;
var     rotator         InducerRotation;
var     ONSPowerNode    PowerNode;
var     array<Material> RedConstructingSkins;
var     array<Material> BlueConstructingSkins;
var     array<Material> RedActiveSkins;
var     array<Material> BlueActiveSkins;

simulated function UpdatePrecacheMaterials()
{
	local int i;

	for ( i=0; i<RedConstructingSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedConstructingSkins[i]);

	for ( i=0; i<BlueConstructingSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueConstructingSkins[i]);

	for ( i=0; i<RedActiveSkins.Length; i++ )
		Level.AddPrecacheMaterial(RedActiveSkins[i]);

	for ( i=0; i<BlueActiveSkins.Length; i++ )
		Level.AddPrecacheMaterial(BlueActiveSkins[i]);

    Super.UpdatePrecacheMaterials();
}

function PostBeginPlay()
{
    PowerNode = ONSPowerNode(Owner);
    SetBoneLocation('EnergyDome', vect(-15,0,0));
}

function SetInitialState()
{
	Super.SetInitialState();

	if (Level.NetMode == NM_DedicatedServer)
		disable('Tick');
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,	Vector momentum, class<DamageType> damageType)
{
	if (PowerNode != None)
		PowerNode.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}


simulated function bool TeamLink(int TeamNum)
{
	return ( (PowerNode != None) && PowerNode.TeamLink(TeamNum) );
}

simulated event Tick(float DT)
{
    local PlayerController P;
    local Rotator FacePlayerRotation, YawRot;

    if ((PowerNode != None) && (PowerNode.CoreStage != 4))
    {
        InducerRotation.Yaw += InducerRotationSpeed * 65535 * DT;
        InducerRotation.Yaw = InducerRotation.Yaw & 65535;
        SetBoneRotation('EnergyInducers', InducerRotation, 0);

        P = Level.GetLocalPlayerController();
        if ((P != None) && (P.Pawn != None))
        {
            FacePlayerRotation = Rotator((P.Pawn.Location - Location) << Rotation);
            FacePlayerRotation *= -1;
            YawRot.Yaw = FacePlayerRotation.Yaw;
            SetBoneRotation('EnergyDome', YawRot, 0);
        }
    }
}

defaultproperties
{
     InducerRotationSpeed=0.500000
     RedConstructingSkins(0)=FinalBlend'ONSstructureTextures.CoreConstructionRed'
     RedConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     RedConstructingSkins(2)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     RedConstructingSkins(3)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     BlueConstructingSkins(0)=FinalBlend'ONSstructureTextures.CoreConstructionBlue'
     BlueConstructingSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     BlueConstructingSkins(2)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     BlueConstructingSkins(3)=FinalBlend'ONSstructureTextures.CoreGroup.InvisibleFinal'
     RedActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     RedActiveSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREredFinal'
     RedActiveSkins(2)=FinalBlend'ONSstructureTextures.CoreBreachGroup.powerNodeBeamREDfb'
     RedActiveSkins(3)=FinalBlend'ONSstructureTextures.CoreBreachGroup.PowerNodeREDfb'
     BlueActiveSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     BlueActiveSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREblueFinal'
     BlueActiveSkins(2)=FinalBlend'ONSstructureTextures.CoreBreachGroup.PowerNodeBeamBLUEfb'
     BlueActiveSkins(3)=FinalBlend'ONSstructureTextures.CoreBreachGroup.PowerNodeBlueFB'
     DrawType=DT_Mesh
     bHidden=True
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'ONSWeapons-A.PowerNode'
     CollisionRadius=90.000000
     CollisionHeight=75.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bProjTarget=True
     bUseCylinderCollision=True
}
