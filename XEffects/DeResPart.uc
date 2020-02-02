#exec OBJ LOAD FILE=EpicParticles.utx

class DeResPart extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         Acceleration=(Z=-50.000000)
         ColorScale(0)=(Color=(B=6,G=255,R=6))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=190,G=190))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=190,G=190))
         ColorMultiplierRange=(Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=0.700000
         MaxParticles=200
         StartLocationRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.700000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=2.000000,Max=3.000000))
         UseSkeletalLocationAs=PTSU_SpawnOffset
         SkeletalScale=(X=0.380000,Y=0.380000,Z=0.380000)
         Texture=Texture'EpicParticles.Flares.BurnFlare1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.900000,Max=0.900000)
     End Object
     Emitters(0)=SpriteEmitter'XEffects.DeResPart.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
     bNetTemporary=True
     bHardAttach=True
}
