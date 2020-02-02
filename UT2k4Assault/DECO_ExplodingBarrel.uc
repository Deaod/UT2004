//=============================================================================
// DECO_ExplodingBarrel
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class DECO_ExplodingBarrel extends Decoration;

#exec OBJ LOAD FILE=..\StaticMeshes\CP_MechStaticPack1.usx

var int			Backup_Health;
var VolumeTimer	VT;
var Controller	DelayedDamageInstigatorController;
var float		RadiusDamage;
var bool		bCheckForStackedBarrels;

function Landed(vector HitNormal);
function HitWall (vector HitNormal, actor Wall);
singular function PhysicsVolumeChange( PhysicsVolume NewVolume );
singular function BaseChange();

function PostBeginPlay()
{
	super.PostBeginPlay();
	Backup_Health = Health;
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> damageType)
{
	if ( !bDamageable || (Health<0) ) 
		return;

	if ( damagetype == None )
		DamageType = class'DamageType';

	if ( InstigatedBy != None )
		Instigator = InstigatedBy;
	else if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( Instigator != None )
		MakeNoise(1.0);

	Health -= NDamage;
	FragMomentum = Momentum;
	
	if ( Health < 0 ) 	
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		CheckNearbyBarrels();

		if ( EffectWhenDestroyed != None )
			Spawn( EffectWhenDestroyed, Owner,, Location );
		
		bHidden = true;
		SetCollision(false, false, false);
		VT = Spawn(class'VolumeTimer', Self);
		VT.SetTimer(0.2, false);
	}
}

/* Barrels stacked on top, are set off instantly. Sides and below are set off with a slight delay */
function CheckNearbyBarrels()
{
	bCheckForStackedBarrels = true;
	HurtRadius( 100, RadiusDamage, class'DamTypeExploBarrel', 256, Location );
}

// delayed explosion for barrel chain reaction explosions
function TimerPop( VolumeTimer T )
{
	VT.Destroy();
	bCheckForStackedBarrels = false;
	HurtRadius( 100, RadiusDamage, class'DamTypeExploBarrel', 256, Location );
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		/* Set off top barrels instantly, side and below are set off with a delay*/
		if ( bCheckForStackedBarrels && Victims.IsA('DECO_ExplodingBarrel') && Victims.Location.Z <= HitLocation.Z )
			continue;

		/* limit damage radius to right next barrel, so we can set them of one after the other */
		if ( Victims.IsA('DECO_ExplodingBarrel') && !IsNearbyBarrel(Victims) )
			continue;

		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( DelayedDamageInstigatorController );
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}

simulated final function bool IsNearbyBarrel(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;
	if ( abs(Dir.Z) > CollisionHeight*2.67 )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius*2.25 );
}

function Reset()
{
	super.Reset();

	NetUpdateTime = Level.TimeSeconds - 1;
	Health	= Backup_Health;
	bHidden = false;
	SetCollision(true, true, true);
}

function Bump( actor Other )
{
	if ( Mover(Other) != None && Mover(Other).bResetting )
		return;

	if ( VSize(Other.Velocity) > 500 )
	{
		Instigator = Pawn(Other);
		if ( Instigator != None && Instigator.Controller != None )
			SetDelayedDamageInstigatorController( Instigator.Controller );
		TakeDamage( VSize(Other.Velocity)*0.03, Instigator, Location, vect(0,0,0), class'Crushed');
	}
}

event EncroachedBy(Actor Other) 
{
	if ( Mover(Other) != None && Mover(Other).bResetting )
		return;

	Instigator = Pawn(Other);
	if ( Instigator != None && Instigator.Controller != None )
		SetDelayedDamageInstigatorController( Instigator.Controller );
	TakeDamage( 1000, Instigator, Location, vect(0,0,0), class'Crushed');
}

function bool EncroachingOn(Actor Other)
{
	if ( Mover(Other) != None && Mover(Other).bResetting )
		return false;

	Instigator = Pawn(Other);
	if ( Instigator != None && Instigator.Controller != None )
		SetDelayedDamageInstigatorController( Instigator.Controller );
	TakeDamage( 1000, Instigator, Location, vect(0,0,0), class'Crushed');
	return false;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RadiusDamage=256.000000
     EffectWhenDestroyed=Class'UT2k4Assault.FX_ExplodingBarrel'
     bDamageable=True
     Health=25
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Decos.ExplodingBarrel'
     bStatic=False
     NetUpdateFrequency=1.000000
     AmbientGlow=48
     CollisionHeight=32.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bUseCylinderCollision=True
     bBlockKarma=True
     bEdShouldSnap=True
}
