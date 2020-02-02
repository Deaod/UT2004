//=============================================================================
// FX_Turret_IonCannon_BeamExplosion
//=============================================================================
//	Created by Laurent Delayen
//	© 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_Turret_IonCannon_BeamExplosion extends Emitter
	notplaceable;

#exec OBJ LOAD FILE=AW-2004Particles.utx


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=250,G=128,R=200))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=250,G=128,R=200))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=300.000000,Max=500.000000)
         RevolutionsPerSecondRange=(Z=(Min=2.000000,Max=2.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(X=0.020000,Y=0.020000,Z=0.020000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=1.600000,Max=1.600000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRadialRange=(Min=1200.000000,Max=1200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
     End Object
     Emitters(0)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.AirBlastP'
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(1)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         MaxParticles=1
         SizeScale(1)=(RelativeTime=0.750000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.500000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.PurpleSwell'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(2)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=40
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=100.000000,Max=100.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         InitialParticlesPerSecond=300.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=1.500000,Max=1.500000)
         StartVelocityRadialRange=(Min=-750.000000,Max=-750.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=500.000000,Max=500.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=1.700000,Max=1.700000)
         StartVelocityRadialRange=(Min=-750.000000,Max=-750.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(4)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=60
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1000.000000,Max=1000.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'ExplosionTex.Framed.exp2_framesP'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000,Max=0.500000)
         InitialDelayRange=(Min=1.900000,Max=1.900000)
         StartVelocityRadialRange=(Min=-750.000000,Max=-750.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(5)=SpriteEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.SpriteEmitter13'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Min=1.000000),Z=(Min=1.000000))
         SizeScale(0)=(RelativeSize=4.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=25.000000)
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=0.750000,Max=0.750000)
         InitialDelayRange=(Min=1.700000,Max=1.700000)
     End Object
     Emitters(6)=MeshEmitter'UT2k4AssaultFull.FX_Turret_IonCannon_BeamExplosion.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     AmbientGlow=254
     bDirectional=True
}
