//=============================================================================
// Weapon_SpaceFighter
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_SpaceFighter extends Weapon
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx

var Rotator PrevRotation;
var float	LastTimeSeconds;

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	if ( Instigator.Controller.Enemy == None )
		return 0;
	if ( GameObjective(Instigator.Controller.Focus) != None )
		return 0;

	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	if ( FRand() < 0.65 )
		return 1;
	return 0;
}
simulated final function float	CalcInertia(float DeltaTime, float FrictionFactor, float OldValue, float NewValue)
{
	local float	Friction;

	Friction = 1.f - FClamp( (0.02*FrictionFactor) ** DeltaTime, 0.f, 1.f);
	return	OldValue*Friction + NewValue;
}

simulated function PreDrawFPWeapon()
{
	local Rotator	DeltaRot, NewRot;
	local float		myDeltaTime;

	PlayerViewOffset = default.PlayerViewOffset;
	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(Self) );

	if ( PrevRotation == rot(0,0,0) )
		PrevRotation = Instigator.Rotation;

	myDeltaTime		= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds	= Level.TimeSeconds;
	DeltaRot		= Normalize(Instigator.Rotation - PrevRotation);
	NewRot.Yaw		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Yaw, PrevRotation.Yaw);
	NewRot.Pitch	= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Pitch, PrevRotation.Pitch);
	NewRot.Roll		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Roll, PrevRotation.Roll);
	PrevRotation	= NewRot;
	SetRotation( NewRot );
}

simulated function bool HasAmmo()
{
    return true;
}

function float SuggestAttackStyle()
{
    return 1.0;
}
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'UT2k4AssaultFull.FM_SpaceFighter_InstantHitLaser'
     FireModeClass(1)=Class'UT2k4AssaultFull.FM_SpaceFighter_AltFire'
     AIRating=0.680000
     CurrentRating=0.680000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=1
     SmallViewOffset=(Z=-20.000000)
     PlayerViewOffset=(Z=-20.000000)
     AttachmentClass=Class'UT2k4AssaultFull.WA_SpaceFighter'
     ItemName="SpaceFighter weapon"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP'
     AmbientGlow=64
}
