class NewIonEffect extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000)
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=255,G=128,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=40
         StartLocationOffset=(Z=-64.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshSpawning=PTMS_Linear
         MeshScaleRange=(Z=(Min=2.000000,Max=2.000000))
         RevolutionsPerSecondRange=(Z=(Min=-0.200000,Max=0.200000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=16.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=25.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-1.000000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.500000)
         VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=3000.000000,Y=3000.000000,Z=1000.000000))
         VelocityScale(3)=(RelativeTime=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseRevolution=True
         UseRevolutionScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=60,G=60,R=60,A=100))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=180,G=180,R=180,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=150
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=128.000000,Max=128.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshScaleRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         RevolutionsPerSecondRange=(Z=(Min=0.100000,Max=0.100000))
         RevolutionScale(0)=(RelativeRevolution=(Z=10.000000))
         RevolutionScale(1)=(RelativeTime=1.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=16.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=50.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.Smokepuff'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-0.800000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.500000)
         VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=3000.000000,Y=3000.000000,Z=1000.000000))
         VelocityScale(3)=(RelativeTime=1.000000,RelativeVelocity=(X=300.000000,Y=300.000000,Z=100.000000))
     End Object
     Emitters(1)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Forward
         UseColorScale=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseRevolution=True
         UseRevolutionScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.330000)
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=136,G=237,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInEndTime=0.100000
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=64.000000,Max=128.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshScaleRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000))
         RevolutionsPerSecondRange=(Z=(Min=-0.200000,Max=0.200000))
         RevolutionScale(0)=(RelativeRevolution=(Z=1.000000))
         RevolutionScale(1)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.800000,RelativeSize=16.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=25.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'EpicParticles.Smoke.Smokepuff2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
         InitialDelayRange=(Min=0.050000,Max=0.050000)
         StartVelocityRange=(Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=-1.000000,Max=-1.000000)
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(1)=(RelativeTime=0.500000)
         VelocityScale(2)=(RelativeTime=0.700000,RelativeVelocity=(X=2000.000000,Y=2000.000000,Z=500.000000))
         VelocityScale(3)=(RelativeTime=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'ParticleMeshes.Complex.IonSphere'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=180,G=180,R=180,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=1.000000
         FadeInEndTime=0.100000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=18.000000)
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.400000,Max=0.400000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_Darken
         Texture=None
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.750000,Max=0.750000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(3)=MeshEmitter'XEffects.NewIonEffect.MeshEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=30,R=80))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=180,G=50,R=180))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=180,G=50,R=140))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=2
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.800000,RelativeSize=10.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.250000,Max=1.250000)
         InitialDelayRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(4)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=80,R=200))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=40,R=200))
         FadeOutStartTime=0.900000
         FadeInEndTime=0.100000
         MaxParticles=2
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=15.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Flares.BurnFlare1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(5)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=242,G=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=209,G=5,R=194))
         FadeOutStartTime=0.600000
         FadeInEndTime=0.200000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=256.000000,Max=256.000000)
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=40.000000,Max=40.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRadialRange=(Min=200.000000,Max=200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(6)=SpriteEmitter'XEffects.NewIonEffect.SpriteEmitter6'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'ParticleMeshes.Complex.IonSphere'
         RenderTwoSided=True
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.700000,Max=0.700000))
         FadeOutStartTime=0.750000
         MaxParticles=1
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=25.000000)
         StartSizeRange=(Z=(Min=0.200000,Max=0.200000))
         InitialParticlesPerSecond=50000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=1.200000,Max=1.200000)
     End Object
     Emitters(7)=MeshEmitter'XEffects.NewIonEffect.MeshEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
