//=============================================================================
// Projectile.
//
// A delayed-hit projectile that moves around for some time after it is created.
//=============================================================================
class Projectile extends Actor
	abstract
	native;

//-----------------------------------------------------------------------------
// Projectile variables.

// Motion information.
var		float   Speed;               // Initial speed of projectile.
var		float   MaxSpeed;            // Limit on speed of projectile (0 means no limit)
var		float	TossZ;
var		Actor	ZeroCollider;

var		bool	bSwitchToZeroCollision; // if collisionextent nonzero, and hit actor with bBlockNonZeroExtents=0, switch to zero extent collision
var		bool	bNoFX;					// used to prevent effects when projectiles are destroyed (see LimitationVolume)
var		bool	bReadyToSplash;
var     bool    bSpecialCalcView;       // Use the projectile's SpecialCalcView function instead of letting the playercontroller handle the camera

// Damage attributes.
var   float    Damage;
var	  float	   DamageRadius;
var   float	   MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var   class<DamageType>	   MyDamageType;

// Projectile sound effects
var   sound    SpawnSound;		// Sound made when projectile is spawned.
var   sound	   ImpactSound;		// Sound made when projectile hits something.

// explosion effects
var   class<Projector> ExplosionDecal;
var   float		ExploWallOut;	// distance to move explosions out from wall
var Controller	InstigatorController;

var Actor LastTouched;
var Actor HurtWall;
var float MaxEffectDistance;

var	bool bScriptPostRender;		// if true, PostRender2D() gets called

simulated function PostBeginPlay()
{
	local PlayerController PC;

    if ( Role == ROLE_Authority && Instigator != None && Instigator.Controller != None )
    {
    	if ( Instigator.Controller.ShotTarget != None && Instigator.Controller.ShotTarget.Controller != None )
			Instigator.Controller.ShotTarget.Controller.ReceiveProjectileWarning( Self );

		InstigatorController = Instigator.Controller;
    }

    if ( bDynamicLight && Level.NetMode != NM_DedicatedServer )
    {
		PC = Level.GetLocalPlayerController();
		if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 4000) )
		{
			LightType = LT_None;
			bDynamicLight = false;
		}
	}
	bReadyToSplash = true;
}

function bool SpecialCalcView(out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation, bool bBehindView);

simulated function bool CanSplash()
{
	return bReadyToSplash;
}

function Reset()
{
	Destroy();
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,MaxEffectDistance);
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function DelayedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
}

//==============
// Encroachment
function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;

	return false;
}

//==============
// Touching
simulated singular function Touch(Actor Other)
{
	local vector	HitLocation, HitNormal;

	if ( Other == None ) // Other just got destroyed in its touch?
		return;
	if ( Other.bProjTarget || Other.bBlockActors )
	{
		LastTouched = Other;
		if ( Velocity == vect(0,0,0) || Other.IsA('Mover') )
		{
			ProcessTouch(Other,Location);
			LastTouched = None;
			return;
		}

		if ( Other.TraceThisActor(HitLocation, HitNormal, Location, Location - 2*Velocity, GetCollisionExtent()) )
			HitLocation = Location;

		ProcessTouch(Other, HitLocation);
		LastTouched = None;
		if ( (Role < ROLE_Authority) && (Other.Role == ROLE_Authority) && (Pawn(Other) != None) )
			ClientSideTouch(Other, HitLocation);
	}
}

simulated function ClientSideTouch(Actor Other, Vector HitLocation)
{
	Other.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local PlayerController PC;

	if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer)  )
	{
		if ( ExplosionDecal.Default.CullDistance != 0 )
		{
			PC = Level.GetLocalPlayerController();
			if ( !PC.BeyondViewDistance(Location, ExplosionDecal.Default.CullDistance) )
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
			else if ( (Instigator != None) && (PC == Instigator.Controller) && !PC.BeyondViewDistance(Location, 2*ExplosionDecal.Default.CullDistance) )
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
		}
		else
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
	}
	HurtWall = None;
}

simulated function BlowUp(vector HitLocation)
{
	HurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;
}

simulated static function float GetRange()
{
	if (default.LifeSpan == 0.0)
		return 15000;
	else
		return (default.MaxSpeed * default.LifeSpan);
}

function bool IsStationary()
{
	return false;
}

// called if bScriptPostRender is true
simulated event PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY);

defaultproperties
{
     MaxSpeed=2000.000000
     TossZ=100.000000
     DamageRadius=220.000000
     MyDamageType=Class'Engine.DamageType'
     DrawType=DT_Mesh
     bAcceptsProjectors=False
     bNetTemporary=True
     bReplicateInstigator=True
     bNetInitialRotation=True
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=2.500000
     LifeSpan=14.000000
     Texture=Texture'Engine.S_Camera'
     bUnlit=True
     bGameRelevant=True
     bCanBeDamaged=True
     bDisturbFluidSurface=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
}
