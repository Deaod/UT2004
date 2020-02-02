class STR_red_blood_puff extends Emitter;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( class'GameInfo'.Static.UseLowGore() )
		Emitters[0].Texture =  texture'XGameShadersB.Blood.AlienBloodJet';
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=STR_red_blood_puff
         FadeOut=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         UseVelocityScale=True
         AddVelocityFromOwner=True
         Acceleration=(Z=-60.000000)
         FadeOutFactor=(W=2.000000,X=2.000000,Y=2.000000,Z=2.000000)
         FadeOutStartTime=-2.000000
         MaxParticles=40
         DetailMode=DM_SuperHigh
         StartLocationRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=-4.000000,Max=4.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.600000)
         SpinsPerSecondRange=(X=(Min=0.150000,Max=0.400000))
         SizeScale(0)=(RelativeSize=1.200000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         UseSkeletalLocationAs=PTSU_Location
         InitialParticlesPerSecond=240.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XGameShadersB.Blood.BloodJetc'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SubdivisionStart=3
         StartVelocityRange=(X=(Min=30.000000,Max=-30.000000),Y=(Min=-60.000000,Max=-80.000000),Z=(Min=30.000000,Max=-30.000000))
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
     End Object
     Emitters(0)=SpriteEmitter'StreamlineFX.STR_red_blood_puff.STR_red_blood_puff'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
