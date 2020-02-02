class WaterVolume extends PhysicsVolume;

var string EntrySoundName, ExitSoundName, EntryActorName, PawnEntryActorName;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( (EntrySound == None) && (EntrySoundName != "") )
		EntrySound = Sound(DynamicLoadObject(EntrySoundName,class'Sound'));
	if ( (ExitSound == None) && (ExitSoundName != "") )
		ExitSound = Sound(DynamicLoadObject(ExitSoundName,class'Sound'));
	if ( (EntryActor == None) && (EntryActorName != "") )
		EntryActor = class<Actor>(DynamicLoadObject(EntryActorName,class'Class'));
	if ( (PawnEntryActor == None) && (PawnEntryActorName != "") )
		PawnEntryActor = class<Actor>(DynamicLoadObject(PawnEntryActorName,class'Class'));
}

defaultproperties
{
     EntrySoundName="PlayerSounds.FootstepWater1"
     ExitSoundName="GeneralImpacts.ImpactSplash2"
     EntryActorName="xGame.WaterSplash"
     PawnEntryActorName="xGame.WaterRing"
     FluidFriction=2.400000
     bWaterVolume=True
     bDistanceFog=True
     DistanceFogColor=(B=128,G=64,R=32,A=64)
     DistanceFogStart=8.000000
     DistanceFogEnd=2000.000000
     KExtraLinearDamping=2.500000
     KExtraAngularDamping=0.400000
     LocationName="under water"
}
