class LandMineExplosion extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'ArboreaLanscape.Cliffs.littlerock01'
         UseCollision=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UniformVelocityScale=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(Z=-950.000000)
         DampingFactorRange=(X=(Min=-0.500000,Max=-0.250000),Y=(Min=-0.500000,Max=-0.250000),Z=(Min=-0.500000,Max=-0.250000))
         MaxParticles=30
         StartMassRange=(Min=100.000000,Max=500.000000)
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=-0.050000,Max=0.025000),Y=(Min=0.050000,Max=0.025000),Z=(Min=0.050000,Max=0.025000))
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=500.000000,Max=800.000000))
     End Object
     Emitters(0)=MeshEmitter'XEffects.LandMineExplosion.MeshEmitter18'

     Begin Object Class=MeshEmitter Name=MeshEmitter19
         StaticMesh=StaticMesh'ArboreaLanscape.Cliffs.littlerock01'
         ResetAfterChange=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UniformVelocityScale=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(Z=-950.000000)
         MaxParticles=25
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.025000,Max=0.050000),Y=(Min=0.025000,Max=0.050000),Z=(Min=0.025000,Max=0.050000))
         InitialParticlesPerSecond=1100.000000
         LifetimeRange=(Min=2.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=500.000000,Max=800.000000))
     End Object
     Emitters(1)=MeshEmitter'XEffects.LandMineExplosion.MeshEmitter19'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter27
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(Z=-950.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.rockchunks02'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=800.000000,Max=1000.000000))
     End Object
     Emitters(2)=SpriteEmitter'XEffects.LandMineExplosion.SpriteEmitter27'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(Z=-750.000000)
         ColorScale(0)=(Color=(B=34,G=141,R=238))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=43,G=68,R=77))
         ColorScale(2)=(RelativeTime=0.900000,Color=(B=51,G=51,R=51))
         ColorMultiplierRange=(X=(Min=0.750000,Max=0.750000),Y=(Min=0.750000,Max=0.750000),Z=(Min=0.750000,Max=0.750000))
         FadeOutFactor=(W=0.250000,X=0.100000,Y=0.100000,Z=0.100000)
         FadeOutStartTime=0.750000
         MaxParticles=25
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'EmitterTextures.MultiFrame.smokelight_a'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=400.000000,Max=900.000000))
         RelativeWarmupTime=1.000000
     End Object
     Emitters(3)=SpriteEmitter'XEffects.LandMineExplosion.SpriteEmitter28'

     AutoDestroy=True
     bLightChanged=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     bUnlit=False
     ForceType=FT_Constant
     ForceRadius=1000.000000
     ForceScale=10.000000
}
