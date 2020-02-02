// ====================================================================
//  Class: BonusPack.MutantGlow
//
//  Glowing particle effect for mutant
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

#exec OBJ LOAD FILE=EpicParticles.utx

class MutantGlow extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=GlowEm0
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=130,G=20,R=91,A=255))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=145,G=80,R=110))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=72,G=50,R=133))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         FadeOutStartTime=0.800000
         CoordinateSystem=PTCS_Relative
         MaxParticles=90
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         StartSizeRange=(X=(Min=5.000000,Max=12.000000),Y=(Min=5.000000,Max=5.000000))
         UseSkeletalLocationAs=PTSU_Location
         SkeletalScale=(X=0.400000,Y=0.400000,Z=0.370000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'EpicParticles.Flares.HotSpot'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'BonusPack.MutantGlow.GlowEm0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bOwnerNoSee=True
     bHardAttach=True
}
