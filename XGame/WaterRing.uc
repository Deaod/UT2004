class WaterRing extends Emitter;

function PostBeginPlay()
{
	local float F;
	Super.PostBeginPlay();

	if ( Instigator != None )
	{
		F = (70 + 30*FRand()) * sqrt(Instigator.CollisionRadius/25);
		Emitters[0].StartSizeRange.X.Min = F;
		Emitters[0].StartSizeRange.X.Max = F;
		Emitters[0].StartSizeRange.Y.Min = F;
		Emitters[0].StartSizeRange.Y.Max = F;
		Emitters[0].StartSizeRange.Z.Min = F;
		Emitters[0].StartSizeRange.Z.Max = F;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=234,R=168))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=128,G=128,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=2
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=70.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'XGame.Water.xCausticRing2'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'XGame.WaterRing.SpriteEmitter9'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
}
