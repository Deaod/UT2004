//=============================================================================
// xPickUpBase.
// This is the base class of all pickup-spawners.  When placing pickups in
// levels, place pickup bases instead since these will spawn the actual
// pickups.
//=============================================================================
class xPickUpBase extends Actor
    abstract
    placeable
    native;

var(PickUpBase) class<PickUp>   PowerUp;        // pick-up class to spawn with this base
var(PickUpBase) float           SpawnHeight;    // height above this base at which the power up will spawn
var(PickUpBase) class<Emitter>  SpiralEmitter;  // emitter which spawns particles when myPickup is available
var(PickUpBase) float			ExtraPathCost;	// assigned to the inventory spot
var PickUp                      myPickUp;       // reference to the pick up spawned with this base
var Emitter                     myEmitter;      // reference to the emitter spawned with this base
var	InventorySpot               myMarker;       // inventory spot marker associated with this pick-up base
var(PickUpBase) bool			bDelayedSpawn;

/* The UnrealEd console command "NewPickupBases" will apply the following properties to this pickup base
 * Used to apply UT2004's new pickup base staticmeshes because we can't just universally change StaticMesh
 * as that would cause them to be unlit in all old maps
 */
var StaticMesh NewStaticMesh;
var vector NewPrePivot;
var float NewDrawScale;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( PowerUp != None )
    {
		if( Level.NetMode != NM_Client )
		{
			SpawnPickup();
			if ( bDelayedSpawn && (myPickup != None) )
			{
				if ( myPickup.IsInState('Pickup') )
					myPickup.GotoState( 'WaitingForMatch' );
				if ( myPickup.myMarker != None )
					myPickup.myMarker.bSuperPickup = true;
			}
		}
		if ( Level.NetMode != NM_DedicatedServer )
			PowerUp.static.StaticPrecache(Level);
	}

	if( !bHidden && (Level.NetMode != NM_DedicatedServer) )
	{
		myEmitter = Spawn(SpiralEmitter,,,Location + vect(0,0,40));
		SetDrawScale(Default.DrawScale);
	}
}


function bool CheckForErrors()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,10), Location,false);
	if ( HitActor == None )
	{
		log(self$" FLOATING");
		return true;
	}
	return Super.CheckForErrors();
}

function byte GetInventoryGroup()
{
	return 0;
}

function TurnOn();

function SpawnPickup()
{
    if( PowerUp == None )
        return;

    myPickUp = Spawn(PowerUp,,,Location + SpawnHeight * vect(0,0,1), rot(0,0,0));

    if (myPickUp != None)
    {
        myPickUp.PickUpBase = self;
        myPickup.Event = event;
    }

	if (myMarker != None)
	{
		myMarker.markedItem = myPickUp;
		myMarker.ExtraCost = ExtraPathCost;
        if (myPickUp != None)
		    myPickup.MyMarker = MyMarker;
	}
	else log("No marker for "$self);
}

defaultproperties
{
     SpawnHeight=50.000000
     DrawType=DT_Mesh
     CullDistance=7000.000000
     bStatic=True
     RemoteRole=ROLE_None
     AmbientGlow=64
     CollisionRadius=35.000000
     CollisionHeight=35.000000
     bProjTarget=True
}
