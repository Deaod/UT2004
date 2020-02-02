//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSVehicleIonExplosionEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\ExplosionTex.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=600
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Min=-32.000000,Max=32.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=20.000000,Max=60.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'AW-2004Particles.Energy.ElecPanelsP'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=300
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-120.000000,Max=120.000000),Z=(Min=-32.000000,Max=32.000000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=50.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'AW-2004Particles.Energy.ElecPanelsP'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.100000,Max=0.100000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         CoordinateSystem=PTCS_Relative
         StartLocationRange=(Z=(Min=-40.000000,Max=-20.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=5.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         InitialParticlesPerSecond=10.000000
         Texture=Texture'AW-2004Particles.Energy.AirBlastP'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(2)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-30.000000,Max=30.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=150.000000,Max=200.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.600000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
     End Object
     Emitters(3)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=6
         StartLocationOffset=(Z=100.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-30.000000,Max=80.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.600000)
         InitialDelayRange=(Min=1.600000,Max=1.600000)
     End Object
     Emitters(4)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.850000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.750000,RelativeSize=4.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.PurpleSwell'
         LifetimeRange=(Min=1.250000,Max=1.250000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(5)=SpriteEmitter'Onslaught.ONSVehicleIonExplosionEffect.SpriteEmitter6'

     AutoDestroy=True
     bNoDelete=False
     AmbientGlow=254
}
