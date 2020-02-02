#exec OBJ LOAD FILE=..\staticmeshes\EffectMeshes.usx
#exec OBJ LOAD FILE=..\textures\VehicleFX.utx

class BulldogDust extends Emitter;

var () int		MaxSpritePPS;
var () int		MaxMeshPPS;

simulated function UpdateDust(KTire t, float DustSlipRate, float DustSlipThresh)
{
	local float SpritePPS, MeshPPS;

	//Log("Material:"$t.GroundMaterial$" OnGround:"$t.bTireOnGround);

	// If wheel is on ground, and slipping above threshold..
	if(t.bTireOnGround && t.GroundSlipVel > DustSlipThresh)
	{
		SpritePPS = FMin(DustSlipRate * (t.GroundSlipVel - DustSlipThresh), MaxSpritePPS);

		Emitters[0].ParticlesPerSecond = SpritePPS;
		Emitters[0].InitialParticlesPerSecond = SpritePPS;
		Emitters[0].AllParticlesDead = false;

		MeshPPS = FMin(DustSlipRate * (t.GroundSlipVel - DustSlipThresh), MaxMeshPPS);

		Emitters[1].ParticlesPerSecond = MeshPPS;
		Emitters[1].InitialParticlesPerSecond = MeshPPS;
		Emitters[1].AllParticlesDead = false;		
	}
	else // ..otherwise, switch off.
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;

		Emitters[1].ParticlesPerSecond = 0;
		Emitters[1].InitialParticlesPerSecond = 0;
	}
}

defaultproperties
{
     MaxSpritePPS=35
     MaxMeshPPS=35
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=15.000000)
         ColorScale(0)=(Color=(B=30,G=90,R=110))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=34,G=44,R=66,A=128))
         ColorScale(2)=(RelativeTime=0.900000,Color=(B=36,G=49,R=64,A=128))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=20,G=50,R=80))
         MaxParticles=100
         StartLocationRange=(Y=(Min=-24.000000,Max=24.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.025000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'VehicleFX.Particles.DustyCloud2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'Vehicles.BulldogDust.SpriteEmitter1'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'EffectMeshes.Particles.DirtChunk_01aw'
         UseParticleColor=True
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AlphaTest=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Acceleration=(Z=-600.000000)
         DampingFactorRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=109,G=184,R=220))
         FadeOutStartTime=2.000000
         MaxParticles=100
         StartLocationRange=(Y=(Min=-24.000000,Max=24.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.010000),Y=(Max=0.010000),Z=(Max=0.010000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.025000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=0.300000),Y=(Min=0.300000),Z=(Min=0.300000))
         DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=120.000000,Max=120.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=60.000000,Max=120.000000))
     End Object
     Emitters(1)=MeshEmitter'Vehicles.BulldogDust.MeshEmitter1'

     bNoDelete=False
     bHardAttach=True
}
