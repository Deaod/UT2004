//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSSmallVehicleExplosionEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=100.000000)
         ColorScale(0)=(Color=(B=16,G=16,R=16))
         ColorScale(1)=(RelativeTime=0.200000,Color=(A=192))
         ColorScale(2)=(RelativeTime=0.800000,Color=(A=96))
         ColorScale(3)=(RelativeTime=1.000000)
         AddLocationFromOtherEmitter=2
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=2.000000,Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.exp2_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.700000,Max=0.700000)
         StartVelocityRadialRange=(Min=-600.000000,Max=-600.000000)
         VelocityLossRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=3.000000,Max=3.000000))
         AddVelocityFromOtherEmitter=2
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSSmallVehicleExplosionEffect.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=4
         StartLocationShape=PTLS_Polar
         SphereRadiusRange=(Min=8.000000,Max=8.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=2.000000,Max=2.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.200000)
         InitialParticlesPerSecond=500.000000
         Texture=Texture'ExplosionTex.Framed.we1_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.600000)
         StartVelocityRadialRange=(Min=-500.000000,Max=-500.000000)
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSSmallVehicleExplosionEffect.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         StartLocationRange=(Z=(Max=50.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=16.000000,Max=48.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=50.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSSmallVehicleExplosionEffect.SpriteEmitter6'

     AutoDestroy=True
     bNoDelete=False
}
