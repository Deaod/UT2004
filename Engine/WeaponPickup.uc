class WeaponPickup extends Pickup
	notplaceable
	abstract;

var   bool	  bWeaponStay;
var() bool	  bThrown; // true if deliberatly thrown, not dropped from kill
var() int     AmmoAmount[2];

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
	MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

function SetWeaponStay()
{
	bWeaponStay = ( bWeaponStay && Level.Game.bWeaponStay );
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastWeaponPickupTime = H.LastPickupTime;
}

function StartSleeping()
{
    if (bDropped)
        Destroy();
    else if (!bWeaponStay)
	    GotoState('Sleeping');
}

function bool AllowRepeatPickup()
{
    return (!bWeaponStay || (bDropped && !bThrown));
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local Weapon AlreadyHas;

	AlreadyHas = Weapon(Other.FindInventoryType(InventoryType)); 
	if ( (AlreadyHas != None)
		&& (bWeaponStay || (AlreadyHas.AmmoAmount(0) > 0)) )
		return 0;
	if ( AIController(Other.Controller).PriorityObjective()
		&& ((Other.Weapon.AIRating > 0.5) || (PathWeight > 400)) )
		return 0.2/PathWeight;
	return class<Weapon>(InventoryType).Default.AIRating/PathWeight;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local class<Pickup> AmmoPickupClass;
	local float desire;

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType)); 
	if ( AlreadyHas != None )
	{
		if ( Bot.Controller.bHuntPlayer )
			return 0;
			
		// can't pick it up if weapon stay is on
		if ( !AllowRepeatPickup() )
			return 0;
		if ( (RespawnTime < 10) 
			&& ( bHidden || AlreadyHas.AmmoMaxed(0)) )
			return 0;

		if ( AlreadyHas.AmmoMaxed(0) )
			return 0.25 * desire;

		// bot wants this weapon for the ammo it holds
		if( AlreadyHas.AmmoAmount(0) > 0 )
		{
			AmmoPickupClass = AlreadyHas.AmmoPickupClass(0);
			
			if ( AmmoPickupClass == None )
				return 0.05;
			else
				return FMax( 0.25 * desire, 
						AmmoPickupClass.Default.MaxDesireability
						* FMin(1, 0.15 * AlreadyHas.MaxAmmo(0)/AlreadyHas.AmmoAmount(0)) );
		} 
		else
			return 0.05;
	}
	if ( Bot.Controller.bHuntPlayer && (MaxDesireability * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;
	
	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

function float GetRespawnTime()
{
	if ( (Level.NetMode != NM_Standalone) || (Level.Game.GameDifficulty > 3) )
		return ReSpawnTime;
	return RespawnTime * (0.33 + 0.22 * Level.Game.GameDifficulty); 
}

function InitDroppedPickupFor(Inventory Inv)
{
    local Weapon W;
    W = Weapon(Inv);
    if (W != None)
    {
        AmmoAmount[0] = W.AmmoAmount(0);
        AmmoAmount[1] = W.AmmoAmount(1);
    }
    Super.InitDroppedPickupFor(None);
}

function Reset()
{
    AmmoAmount[0] = 0;
    AmmoAmount[1] = 0;
    Super.Reset();
}

state FallingPickup
{
	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure thrower doesn't run over own weapon
		if ( bThrown && (Physics == PHYS_Falling) && (Velocity.Z > 0) && ((Velocity dot Other.Velocity) > 0) && ((Velocity dot (Location - Other.Location)) > 0) )
			return false;
		
		return super.ValidTouch(Other);
	}
}

defaultproperties
{
     bWeaponStay=True
     MaxDesireability=0.500000
     bAmbientGlow=True
     bPredictRespawns=True
     RespawnTime=30.000000
     PickupMessage="You got a weapon"
     CullDistance=6500.000000
     Physics=PHYS_Rotating
     Texture=Texture'Engine.S_Weapon'
     AmbientGlow=128
     CollisionRadius=36.000000
     CollisionHeight=30.000000
     RotationRate=(Yaw=32768)
}
