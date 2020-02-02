//=============================================================================
// ACTION_PlayExplosionSound
//=============================================================================
// Standardize explosion sounds...
// Various explosion sounds are combined to create a unique and loud sound
//=============================================================================
// Created by Laurent Delayen
// © 2004, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ACTION_PlayExplosionSound extends LatentScriptedAction;

var(Action) name	SoundEmitterActorTag;	// source emitting the sound (none = self)
var(Action) float	SoundVolumeScale;		// volume scale
var(Action) float	SoundRadiusScale;		// radius scale
var(Action) float	SoundPitchScale;		// pitch scale

var	Actor	SoundEmitter;
var Sound	ExplosionSound[11];
var byte	bPlayed[11];

event PostBeginPlay( ScriptedSequence SS )
{
	super.PostBeginPlay( SS );
	if ( SoundEmitterActorTag == 'None' || SoundEmitterActorTag == '' )
		SoundEmitter = SS;
	else
		ForEach SS.AllActors(class'Actor', SoundEmitter, SoundEmitterActorTag)
			break;
}

function bool InitActionFor(ScriptedController C)
{
	if ( SoundEmitter != None )
	{
		PlayUniqueRandomExplosion();
		PlayUniqueRandomExplosion();
		
		C.CurrentAction = self;
		C.SetTimer(0.33, false);
		return true;
	}
	return false;
}

event ActionCompleted()
{
	PlayUniqueRandomExplosion();
}

function bool CompleteWhenTriggered()
{
	return true;
}

function bool CompleteWhenTimer()
{
	return true;
}

function string GetActionString()
{
	return ActionString @ SoundEmitterActorTag;
}

function PlayUniqueRandomExplosion()
{
	local int Num;
	
	Num = Rand(42) % 11;
	if ( bPlayed[Num] > 0 )	
	{	
		PlayUniqueRandomExplosion(); // try again if already played this sound...
		return;
	}

	SoundEmitter.PlaySound(ExplosionSound[Num],, 4.0*SoundVolumeScale,, 1600*SoundRadiusScale, SoundPitchScale);
	bPlayed[Num] = 1;
}

event Reset()
{
	local int i;

	super.Reset();
	for (i=0; i<11; i++)
		bPlayed[i] = 0;
}

defaultproperties
{
     SoundVolumeScale=1.000000
     SoundRadiusScale=1.000000
     SoundPitchScale=1.000000
     ExplosionSound(0)=Sound'ONSVehicleSounds-S.Explosions.Explosion01'
     ExplosionSound(1)=Sound'ONSVehicleSounds-S.Explosions.Explosion02'
     ExplosionSound(2)=Sound'ONSVehicleSounds-S.Explosions.Explosion03'
     ExplosionSound(3)=Sound'ONSVehicleSounds-S.Explosions.Explosion04'
     ExplosionSound(4)=Sound'ONSVehicleSounds-S.Explosions.Explosion05'
     ExplosionSound(5)=Sound'ONSVehicleSounds-S.Explosions.Explosion06'
     ExplosionSound(6)=Sound'ONSVehicleSounds-S.Explosions.Explosion07'
     ExplosionSound(7)=Sound'ONSVehicleSounds-S.Explosions.Explosion08'
     ExplosionSound(8)=Sound'ONSVehicleSounds-S.Explosions.Explosion09'
     ExplosionSound(9)=Sound'ONSVehicleSounds-S.Explosions.Explosion10'
     ExplosionSound(10)=Sound'ONSVehicleSounds-S.Explosions.Explosion11'
     ActionString="Play explosion sound"
}
