class STR_dripping_red_blood extends Emitter;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( class'GameInfo'.Static.UseLowGore() )
		Emitters[0].Texture =  texture'XGameShadersB.Blood.AlienBloodJet';
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=STR_dripping_red_blood
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
         Acceleration=(Z=-70.000000)
         FadeOutFactor=(W=2.500000,X=2.500000,Y=2.500000,Z=2.500000)
         FadeOutStartTime=-0.500000
         FadeInFactor=(W=3.000000,X=3.000000,Y=3.000000,Z=3.000000)
         MaxParticles=400
         DetailMode=DM_SuperHigh
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=-4.000000,Max=4.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.700000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=0.800000)
         StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         UseSkeletalLocationAs=PTSU_Location
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'XGameShadersB.Blood.BloodJetc'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SubdivisionStart=3
         StartVelocityRange=(Y=(Min=-40.000000,Max=-30.000000))
         AddVelocityMultiplierRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
     End Object
     Emitters(0)=SpriteEmitter'StreamlineFX.STR_dripping_red_blood.STR_dripping_red_blood'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
