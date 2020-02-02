//=============================================================================
// FX_WeaponLocker
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_WeaponLocker extends Emitter;

#exec OBJ LOAD FILE=..\Textures\AS_FX_TX.UTX
#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.UTX

function TurnOff(Float T)
{
	bHidden = true;
	SetTimer(30, false);
}

function Timer()
{
	bHidden = false;
}

simulated function NotifyLocalPlayerDead(PlayerController PC)
{
	bHidden = false;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter60
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=64,G=255,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.670000
         MaxParticles=3
         StartLocationOffset=(Z=30.000000)
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.040000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=20.000000,Max=25.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AS_FX_TX.Flares.Laser_Flare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'XWeapons.FX_WeaponLocker.SpriteEmitter60'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter61
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=128,G=255,R=224))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.330000
         MaxParticles=1
         StartLocationOffset=(Z=30.000000)
         SpinsPerSecondRange=(X=(Min=0.005000,Max=0.030000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=16.000000,Max=18.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'XWeapons.FX_WeaponLocker.SpriteEmitter61'

     CullDistance=7000.000000
     bNoDelete=False
}
