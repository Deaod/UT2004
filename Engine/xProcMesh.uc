//=============================================================================
// xProcMesh - Procedural mesh actor
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class xProcMesh extends Actor
	placeable
    exportstructs
	native;

struct ProcMeshVertex // struct reordering breaks this
{
	var Vector	Position;
	var Vector  Normal;
	var Color   Color;
	var float   U,V;
};

var const array<ProcMeshVertex>	Vertices;
var const array<int> SectionOffsets;

var() float	Dampening; // should be less than < 1.0f
var() Range DampeningRange;
var() Range MovementClamp;
var() Range ForceClamp;
var() float ForceAttenuation;
var() float Tension;
var() float RestTension;
var() bool  CheckCollision;
var() float Noise;
var() Range NoiseForce;
var() Range NoiseTimer;
var transient float NoiseCounter;
var() enum EProcMeshType
{
	MT_Water,
	MT_Deform,
} ProcType;
var(Force) bool bForceAffected;
var() bool  bRigidEdges;

var const transient pointer pProcData; // todo: take this out and serialize most things

var() class<Effects>    HitEffect;
var() class<Effects>    BigHitEffect;
var() float             BigMomentumThreshold;
var() float             BigTouchThreshold;
var() float             ShootStrength;
var() float             TouchStrength;
var() float             InfluenceRadius;


// support fluid funcs
// Ripple water at a particlar location.
// Ignores 'z' componenet of position.
native final function ProcPling(vector Position, float Strength, float Radius, out vector EffectLocation, out vector EffectNormal);

// Default behaviour when shot is to apply an impulse and kick the KActor.
simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
    local vector EffectNormal;
    local vector EffectLocation;

	ProcPling(hitLocation, ShootStrength, 0, EffectLocation, EffectNormal);
	if(VSize(Momentum) > BigMomentumThreshold && BigHitEffect != None )
		spawn(BigHitEffect, self, , EffectLocation, rotator(EffectNormal));
	else if ( HitEffect != None )
		spawn(HitEffect, self, , EffectLocation,rotator(EffectNormal));
}

simulated function Touch(Actor Other)
{
	local vector touchLocation;
    local vector EffectNormal;
    local vector EffectLocation;
    local float touchValue;

	Super.Touch(Other);

	if ( (Other == None) || !Other.bDisturbFluidSurface )
		return;
		
	touchLocation = Other.Location;

    touchValue = VSize(Velocity);

	ProcPling(touchLocation, TouchStrength, Other.CollisionRadius, EffectLocation, EffectNormal);

	if(touchValue > BigTouchThreshold && BigHitEffect != None )
		spawn(BigHitEffect, self, , EffectLocation, rotator(EffectNormal));
	else if ( HitEffect != None )
		spawn(HitEffect, self, , EffectLocation,rotator(EffectNormal));
}

defaultproperties
{
     Dampening=0.500000
     DampeningRange=(Min=-4.000000,Max=4.000000)
     MovementClamp=(Min=-50.000000,Max=50.000000)
     ForceClamp=(Min=-20.000000,Max=20.000000)
     ForceAttenuation=1.000000
     Tension=0.400000
     RestTension=0.400000
     CheckCollision=True
     Noise=0.100000
     NoiseForce=(Min=-1.000000,Max=1.000000)
     NoiseTimer=(Min=2.000000,Max=3.000000)
     DrawType=DT_Particle
     bLightingVisibility=False
     bNoDelete=True
     Texture=Texture'Engine.S_Emitter'
     CollisionRadius=80.000000
     CollisionHeight=80.000000
     bCollideActors=True
     bProjTarget=True
     bUseCylinderCollision=True
}
