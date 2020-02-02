class WeaponAttachment extends InventoryAttachment
	native
	nativereplication;

var		byte	FlashCount;			// when incremented, draw muzzle flash for current frame
var		byte	FiringMode;			// replicated to identify what type of firing/reload animations to play
var		byte	SpawnHitCount;		// when incremented, spawn hit effect at mHitLocation
var		bool	bAutoFire;			// When set to true.. begin auto fire sequence (used to play looping anims)
var		float	FiringSpeed;		// used by human animations to determine the appropriate speed to play firing animations
var		vector  mHitLocation;		// used for spawning hit effects client side
var		bool	bMatchWeapons;		// for team beacons (link gun potential links)
var		color	BeaconColor;		// if bMatchWeapons, what color team beacon should be

var class<Actor> SplashEffect;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
		FlashCount, FiringMode, bAutoFire;

	reliable if ( bNetDirty && (Role==ROLE_Authority) )
		mHitLocation, SpawnHitCount;
}

/*
ThirdPersonEffects called by Pawn's C++ tick if FlashCount incremented
becomes true
OR called locally for local player
*/
simulated event ThirdPersonEffects()
{
	// spawn 3rd person effects

	// have pawn play firing anim
	if ( Instigator != None )
	{
		if ( FiringMode == 1 )
			Instigator.PlayFiring(1.0,'1');
		else
			Instigator.PlayFiring(1.0,'0');
	}
}

simulated function CheckForSplash()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	
	if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (SplashEffect != None) && !Instigator.PhysicsVolume.bWaterVolume )
	{
		// check for splash
		bTraceWater = true;
		HitActor = Trace(HitLocation,HitNormal,mHitLocation,Instigator.Location,true);
		bTraceWater = false;
		if ( (FluidSurfaceInfo(HitActor) != None) || ((PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume) )
			Spawn(SplashEffect,,,HitLocation,rot(16384,0,0));
	}
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal);

defaultproperties
{
     FiringSpeed=1.000000
     BeaconColor=(G=255,A=255)
     CullDistance=4000.000000
     bActorShadows=True
     bReplicateInstigator=True
     NetUpdateFrequency=8.000000
}
