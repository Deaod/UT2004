//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerCoreBreachEffect extends Emitter;

#exec OBJ LOAD FILE="..\Sounds\IndoorAmbience.uax"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Opacity=2.000000
         FadeOutStartTime=1.000000
         MaxParticles=20
         StartLocationOffset=(Z=10.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=180.000000,Max=180.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=5.000000,Max=5.000000))
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=130.000000,Max=180.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         Sounds(0)=(Sound=Sound'ONSVehicleSounds-S.Explosions.Explosion03',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=1.500000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_LinearGlobal
         SpawningSoundProbability=(Min=0.150000,Max=0.150000)
         InitialParticlesPerSecond=550.000000
         Texture=Texture'VMParticleTextures.PowerNodeEXP.powerNodeEXPblueTEX'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         InitialDelayRange=(Min=0.750000,Max=0.750000)
         StartVelocityRange=(X=(Min=-2500.000000,Max=2500.000000),Y=(Min=-2500.000000,Max=2500.000000),Z=(Min=-2500.000000,Max=2500.000000))
         VelocityLossRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=6.000000,Max=6.000000))
         VelocityScale(0)=(RelativeTime=1.000000,RelativeVelocity=(X=0.200000,Y=0.200000,Z=0.200000))
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter16'

     Begin Object Class=MeshEmitter Name=MeshEmitter16
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.CoreBreachFrontFLARE'
         UseParticleColor=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpawnOnlyInDirectionOfNormal=True
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         MeshNormal=(Z=0.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000),Y=(Min=6.000000,Max=6.000000),Z=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=1.000000
         Texture=None
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(1)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter16'

     Begin Object Class=MeshEmitter Name=MeshEmitter17
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.CoreBreachFrontDISC'
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         InitialParticlesPerSecond=1.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(2)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter17'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         FadeInEndTime=0.200000
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=68.000000)
         StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         InitialParticlesPerSecond=1.000000
         Texture=Texture'ONSstructureTextures.CoreBreachGroup.CoreBreachShockRINGedge'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(3)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.CoreBreachTopDISC'
         RenderTwoSided=True
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=16.000000)
         StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         InitialParticlesPerSecond=1.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(4)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter18'

     Begin Object Class=MeshEmitter Name=MeshEmitter19
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.CoreBreachTopRING'
         RenderTwoSided=True
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=12.000000)
         StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         Sounds(0)=(Sound=Sound'ONSVehicleSounds-S.Explosions.Explosion03',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=1.500000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_LinearGlobal
         SpawningSoundProbability=(Min=1.000000,Max=1.000000)
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_Regular
         Texture=None
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(5)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter19'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=80
         StartLocationRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=-250.000000,Max=250.000000))
         StartSpinRange=(X=(Min=0.231000,Max=0.853000))
         StartSizeRange=(X=(Min=350.000000,Max=350.000000))
         Sounds(0)=(Sound=Sound'ONSVehicleSounds-S.Explosions.Explosion03',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=1.500000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(1)=(Sound=Sound'ONSVehicleSounds-S.Explosions.Explosion06',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=1.500000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(2)=(Sound=Sound'ONSVehicleSounds-S.Explosions.Explosion08',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=1.500000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_LinearGlobal
         SpawningSoundProbability=(Min=0.300000,Max=0.300000)
         InitialParticlesPerSecond=15.000000
         Texture=Texture'ONSstructureTextures.CoreBreachGroup.exp7_framesBLUE'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(6)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter18'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Opacity=0.500000
         FadeOutStartTime=2.000000
         FadeInEndTime=0.100000
         MaxParticles=30
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=5.000000,RelativeSize=20.000000)
         StartSizeRange=(X=(Min=75.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=6.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         InitialDelayRange=(Min=7.000000,Max=7.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=220.000000,Max=220.000000))
     End Object
     Emitters(7)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter19'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.coreLightning'
         RenderTwoSided=True
         SpinParticles=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=-10.000000)
         StartSpinRange=(X=(Min=0.450000,Max=0.750000))
         StartSizeRange=(X=(Min=0.500000),Y=(Min=0.500000),Z=(Min=0.500000))
         Sounds(0)=(Sound=Sound'IndoorAmbience.electricity1',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=0.600000,Max=0.600000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_LinearGlobal
         SpawningSoundProbability=(Min=0.200000,Max=0.200000)
         InitialParticlesPerSecond=4.000000
         DrawStyle=PTDS_Regular
         LifetimeRange=(Min=0.250000,Max=0.650000)
         InitialDelayRange=(Min=7.000000,Max=10.000000)
     End Object
     Emitters(8)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.coreLightning1'
         RenderTwoSided=True
         SpinParticles=True
         UseRegularSizeScale=False
         MaxParticles=1
         StartSpinRange=(X=(Min=0.357000,Max=0.741000))
         StartSizeRange=(X=(Min=0.650000),Y=(Min=0.650000))
         Sounds(0)=(Sound=Sound'IndoorAmbience.electricity1',Radius=(Min=1024.000000,Max=1024.000000),Pitch=(Min=1.000000,Max=1.000000),Volume=(Min=0.600000,Max=0.600000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_LinearGlobal
         SpawningSoundProbability=(Min=0.200000,Max=0.200000)
         LifetimeRange=(Min=0.250000,Max=0.650000)
         InitialDelayRange=(Min=7.000000,Max=9.000000)
     End Object
     Emitters(9)=MeshEmitter'Onslaught.ONSPowerCoreBreachEffect.MeshEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         FadeOutStartTime=3.250000
         FadeInEndTime=0.250000
         MaxParticles=40
         StartLocationOffset=(X=-70.000000,Y=-70.000000)
         StartLocationRange=(X=(Min=150.000000,Max=150.000000),Y=(Min=150.000000,Max=150.000000))
         SizeScale(0)=(RelativeTime=3.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=50.000000,Max=70.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'VMParticleTextures.TankFiringP.TankDustKick'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         InitialDelayRange=(Min=7.000000,Max=7.000000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=200.000000,Max=250.000000))
     End Object
     Emitters(10)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         FadeOutStartTime=1.500000
         FadeInEndTime=0.250000
         MaxParticles=40
         StartLocationOffset=(X=-100.000000,Y=50.000000,Z=100.000000)
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=6.000000)
         StartSizeRange=(X=(Min=35.000000,Max=35.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'VMParticleTextures.TankFiringP.TankDustKick1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=7.000000,Max=7.000000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=180.000000,Max=230.000000))
     End Object
     Emitters(11)=SpriteEmitter'Onslaught.ONSPowerCoreBreachEffect.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
}
