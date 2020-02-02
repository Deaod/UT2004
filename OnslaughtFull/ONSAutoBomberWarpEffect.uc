class ONSAutoBomberWarpEffect extends Emitter;

#exec OBJ LOAD FILE=..\StaticMeshes\VMStructures.usx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.700000
         FadeInEndTime=0.100000
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.100000,Max=0.800000))
         StartSizeRange=(X=(Min=250.000000,Max=1000.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'VMParticleTextures.LeviathanParticleEffects.rainbowSpikes'
         LifetimeRange=(Min=0.050000,Max=0.015000)
     End Object
     Emitters(0)=SpriteEmitter'OnslaughtFull.ONSAutoBomberWarpEffect.SpriteEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMStructures.CoreBreachGroup.CoreBreachFrontDISC'
         RenderTwoSided=True
         UseParticleColor=True
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeTime=1.500000,RelativeSize=20.000000)
         StartSizeRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
         InitialParticlesPerSecond=80.000000
         LifetimeRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(1)=MeshEmitter'OnslaughtFull.ONSAutoBomberWarpEffect.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         MaxParticles=25
         StartSpinRange=(X=(Min=0.132000,Max=0.850000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=150.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'VMParticleTextures.LeviathanParticleEffects.darkEnergy'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.350000,Max=0.350000)
         StartVelocityRange=(X=(Min=250.000000,Max=-250.000000),Y=(Min=250.000000,Max=-250.000000),Z=(Min=250.000000,Max=-250.000000))
     End Object
     Emitters(2)=SpriteEmitter'OnslaughtFull.ONSAutoBomberWarpEffect.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         MaxParticles=1
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'VMParticleTextures.LeviathanParticleEffects.LEVsingBLIP'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(3)=SpriteEmitter'OnslaughtFull.ONSAutoBomberWarpEffect.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
}
