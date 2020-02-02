//=============================================================================
// Pickup items.
//
// Pickup is the base class of actors that when touched by an appropriate pawn,
// will create and place an Inventory actor in that pawn's inventory chain.  Each
// pickup class has an associated inventory class (its InventoryType).  Pickups are
// placed by level designers.  Pickups can only interact with pawns when in their
// default Pickup state.  Pickups verify that they can give inventory to a pawn by
// calling the GameInfo's PickupQuery() function.  After a pickup spawns an inventory
// item for a pawn, it then queries the GameInfo by calling the GameInfo's
// ShouldRespawn() function about whether it should remain active, enter its Sleep
// state and later become active again, or destroy itself.
//
// When navigation paths are built, each pickup has an InventorySpot (a subclass
// of NavigationPoint) placed on it and associated with it
// (the Pickup's MyMarker== the InventorySpot,
// and the InventorySpot's markedItem == the pickup).
//
//=============================================================================
class Pickup extends Actor
	abstract
	placeable
	native
	nativereplication;

//-----------------------------------------------------------------------------
// AI related info.

var  float		  MaxDesireability;		// Maximum desireability this item will ever have.
var	  InventorySpot MyMarker;
var	  NavigationPoint PickupCache;		// used for dropped pickups
var() class<Inventory> InventoryType;
var() bool		bInstantRespawn;	  // Can be tagged so this item respawns instantly.
var	  bool		bOnlyReplicateHidden;	// only replicate changes in bHidden (optimization for level pickups)
var(Display) bool bAmbientGlow;		  // Whether to glow or not.
var		bool	bDropped;
var		bool	bPredictRespawns;	  // high skill bots may predict respawns for this item
var() float     RespawnTime;          // Respawn after this time, 0 for instant.
var	 float RespawnEffectTime;

var() localized string PickupMessage; // Human readable description when picked up.
var() sound PickupSound;
var() string PickupForce;  // jdf
var() xPickUpBase PickUpBase;          // Pick-up base which spawned this pickup.

var Controller TeamOwner[4];		// AI controller currently going after this pickup (for team coordination)

native final function AddToNavigation();			// cache dropped inventory in navigation network
native final function RemoveFromNavigation();

static function StaticPrecache(LevelInfo L);

function Destroyed()
{
	if (MyMarker != None )
		MyMarker.markedItem = None;
	if (Inventory != None )
		Inventory.Destroy();
}

simulated function String GetHumanReadableName()
{
	if ( InventoryType == None )
		return GetItemName(string(class));
	if ( InventoryType.Default.ItemName == "" )
		return GetItemName(string(InventoryType));

	return InventoryType.Default.ItemName;
}

function bool IsSuperItem()
{
	return (PickupBase != None) && PickupBase.bDelayedSpawn;
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( Inventory != None )
		destroy();
	else
	{
		if (myMarker != None && myMarker.bSuperPickup)
			GotoState('Sleeping', 'DelayedSpawn');
		else
			GotoState('Pickup');
		Super.Reset();
	}
}

function RespawnEffect();

// Turns the pickup into a different type of pickup - specificly used by the WildcardCharger
function Pickup Transmogrify(class<Pickup> NewClass) // de
{
	local Pickup NewPickup;

	NewPickup = Spawn(NewClass);
	NewPickup.PickupBase = PickupBase;
	NewPickup.RespawnTime = RespawnTime;

	if (MyMarker != None )
	{
		MyMarker.markedItem = NewPickup;
		NewPickup.MyMarker = MyMarker;
		MyMarker = None;
	}
	Destroy();

	return NewPickup;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	return 0;
}

/* Pickups have an AI interface to allow AIControllers, such as bots, to assess the
 desireability of acquiring that pickup.  The BotDesireability() method returns a
 float typically between 0 and 1 describing how valuable the pickup is to the
 AIController.  This method is called when an AIController uses the
 FindPathToBestInventory() navigation intrinsic.
*/
function float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local float desire;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		AlreadyHas = Bot.FindInventoryType(InventoryType);
		if ( AlreadyHas != None )
		{
			if ( Inventory != None )
			{
				if( Inventory.Charge <= AlreadyHas.Charge )
					return -1;
			}
			else if ( InventoryType.Default.Charge <= AlreadyHas.Charge )
				return -1;
		}
	}
	return desire;
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));

	Copy.GiveTo( Other, self );

	return Copy;
}

function StartSleeping()
{
    if (bDropped)
        Destroy();
    else
	    GotoState('Sleeping');
}

function AnnouncePickup( Pawn Receiver )
{
	Receiver.HandlePickup(self);
	PlaySound( PickupSound,SLOT_Interact );
}

//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
	if( Level.Game.ShouldRespawn(self) )
		StartSleeping();
	else
		Destroy();
}

// HUD Messages

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	GotoState('FallingPickup');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
    bDropped = true;
    LifeSpan = 16;
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
}

function bool ReadyToPickup(float MaxWait)
{
	return false;
}

event Landed(Vector HitNormal)
{
    GotoState('Pickup','Begin');
}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		local Inventory Copy;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
            SetRespawn();
            if ( Copy != None )
				Copy.PickupFunction(Pawn(Other));
		}
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
			Touch(P);
	}

	function Timer()
	{
		if ( bDropped )
			GotoState('FadeOut');
	}

	function BeginState()
	{
		UntriggerEvent(Event, self, None);
		if ( bDropped )
        {
			AddToNavigation();
		    SetTimer(8, false);
        }
	}

	function EndState()
	{
		if ( bDropped )
			RemoveFromNavigation();
	}

Begin:
	CheckTouching();
}

state FallingPickup extends Pickup
{
	function CheckTouching()
	{
	}

	function Timer()
	{
		GotoState('FadeOut');
	}

	function BeginState()
	{
	    SetTimer(8, false);
	}
}

State FadeOut extends Pickup
{
	function Tick(float DeltaTime)
	{
		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
	}

	function BeginState()
	{
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;
	}

	function EndState()
	{
		LifeSpan = 0.0;
		SetDrawScale(Default.DrawScale);
		if ( Physics == PHYS_Rotating )
			SetPhysics(PHYS_None);
	}
}

//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.
function float GetRespawnTime()
{
	return RespawnTime;
}

State WaitingForMatch
{
	ignores Touch;

	function MatchStarting()
	{
		GotoState( 'Sleeping', 'DelayedSpawn' );
	}

	function BeginState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
	}
}

State Sleeping
{
	ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return ( bPredictRespawns && (LatentFloat < MaxWait) );
	}

	function StartSleeping() {}

	function BeginState()
	{
		local int i;

		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
		for ( i=0; i<4; i++ )
			TeamOwner[i] = None;
	}

	function EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = false;
	}

DelayedSpawn:
	if ( Level.NetMode == NM_Standalone )
		Sleep(FMin(30, Level.Game.GameDifficulty * 8));
	else
		Sleep(30);
	Goto('Respawn');
Begin:
	Sleep( GetReSpawnTime() - RespawnEffectTime );
Respawn:
	RespawnEffect();
	Sleep(RespawnEffectTime);
    if (PickUpBase != None)
		PickUpBase.TurnOn();
    GotoState('Pickup');
}

State Disabled
{
	function bool ReadyToPickup(float MaxWait)
	{
		return false;
	}

	function Reset() {}
	function StartSleeping() {}

	simulated function BeginState()
	{
		MaxDesireability = 0;
		bHidden = true;
		ResetStaticFilterState();
		SetCollision(false,false,false);
	}
}

defaultproperties
{
     MaxDesireability=0.100000
     bOnlyReplicateHidden=True
     RespawnEffectTime=0.500000
     PickupMessage="Snagged an item."
     DrawType=DT_Mesh
     CullDistance=8000.000000
     bOrientOnSlope=True
     bIgnoreEncroachers=True
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     bIgnoreVehicles=True
     NetUpdateFrequency=0.100000
     NetPriority=1.400000
     Texture=Texture'Engine.S_Inventory'
     bShouldBaseAtStartup=True
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
     bFixedRotationDir=True
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
}
