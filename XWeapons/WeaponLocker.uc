class WeaponLocker extends Pickup;

#exec OBJ LOAD FILE=..\staticmeshes\industrial_static

struct WeaponEntry
{
	var() class<Weapon> WeaponClass;
	var() int ExtraAmmo;
};

var() bool bSentinelProtected;
var() array<WeaponEntry> Weapons;
var localized string LockerString;

var	FX_WeaponLocker	Effect;

struct PawnToucher
{
	var Pawn P;
	var float NextTouchTime;
};

var array<PawnToucher> Customers;

function bool AddCustomer(Pawn P)
{
	local int			i;
	local PawnToucher	PT;

	if ( Customers.Length > 0 )
		for ( i=0; i<Customers.Length; i++ )
		{
			if ( Customers[i].NextTouchTime < Level.TimeSeconds )
			{
				if ( Customers[i].P == P )
				{
					Customers[i].NextTouchTime = Level.TimeSeconds + 30;
					return true;
				}
				Customers.Remove(i,1);
				i--;
			}
			else if ( Customers[i].P == P )
				return false;
		}

	PT.P = P;
	PT.NextTouchTime = Level.TimeSeconds + 30;
	Customers[Customers.Length] = PT;
	return true;
}

function bool HasCustomer(Pawn P)
{
	local int i;

	if ( Customers.Length > 0 )
		for ( i=0; i<Customers.Length; i++ )
		{
			if ( Customers[i].NextTouchTime < Level.TimeSeconds )
			{
				if ( Customers[i].P == P )
					return false;
				Customers.Remove(i,1);
				i--;
			}
			else if ( Customers[i].P == P )
				return true;
		}

	return false;
}

simulated function PostNetBeginPlay()
{
	local int i;

	Super.PostNetBeginPlay();

	MaxDesireability = 0;

	if ( bHidden )
		return;
	for ( i=0; i<Weapons.Length; i++ )
		MaxDesireability += Weapons[i].WeaponClass.Default.AIRating;
	SpawnLockerWeapon();

	if ( Level.NetMode != NM_DedicatedServer )
		Effect = Spawn(class'FX_WeaponLocker', Self,, Location, Rotation );
}

simulated function destroyed()
{
	if ( Effect != None )
		Effect.Destroy();

	super.Destroyed();
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastWeaponPickupTime = H.LastPickupTime;
}

function Reset()
{
}

simulated function SpawnLockerWeapon()
{
	local LockerWeapon L;
	local Rotator WeaponDir;
	local class<UTWeaponPickup> P;
	local int i;
	local float Interval;

	if ( (Level.NetMode == NM_DedicatedServer) || (Level.DetailMode == DM_Low) )
		return;

	L = spawn(class'LockerWeapon');
	Interval = 65536.0/Weapons.Length;

	for ( i=0; i<8; i++ )
	{
		if ( i >= Weapons.Length )
			L.Emitters[i].Disabled = true;
		else
		{
			P = class<UTWeaponPickup>(Weapons[i].WeaponClass.Default.PickupClass);
			if ( (P == None) || (P.Default.StaticMesh == None) )
				L.Emitters[i].Disabled = true;
			else
			{
				MeshEmitter(L.Emitters[i]).StaticMesh = P.Default.StaticMesh;
				L.Emitters[i].StartLocationOffset = P.default.LockerOffset * vector(WeaponDir);
				WeaponDir.Yaw += Interval;
				MeshEmitter(L.Emitters[i]).StartSpinRange.X.Min = P.Default.Standup.X;
				MeshEmitter(L.Emitters[i]).StartSpinRange.X.Max = P.Default.Standup.X;
				MeshEmitter(L.Emitters[i]).StartSpinRange.Y.Min = P.Default.Standup.Y;
				MeshEmitter(L.Emitters[i]).StartSpinRange.Y.Max = P.Default.Standup.Y;
				MeshEmitter(L.Emitters[i]).StartSpinRange.Z.Min = P.Default.Standup.Z;
				MeshEmitter(L.Emitters[i]).StartSpinRange.Z.Max = P.Default.Standup.Z;
				MeshEmitter(L.Emitters[i]).StartSizeRange.X.Min = 0.9 * P.default.DrawScale;
				MeshEmitter(L.Emitters[i]).StartSizeRange.X.Max = 0.9 * P.default.DrawScale;
 				MeshEmitter(L.Emitters[i]).StartSizeRange.Y.Min = 0.9 * P.default.DrawScale;
				MeshEmitter(L.Emitters[i]).StartSizeRange.Y.Max = 0.9 * P.default.DrawScale;
				MeshEmitter(L.Emitters[i]).StartSizeRange.Z.Min = 0.9 * P.default.DrawScale;
				MeshEmitter(L.Emitters[i]).StartSizeRange.Z.Max = 0.9 * P.default.DrawScale;
			}
		}
	}
}

simulated function String GetHumanReadableName()
{
	return LockerString;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;
	local int i;

	if ( bHidden || HasCustomer(Bot) )
		return 0;

	if ( bSentinelProtected && (Bot(Bot.Controller) != None) && !Bot(Bot.Controller).NeedWeapon() )
		return 0;

	// see if bot already has a weapon of this type
	for ( i=0; i<Weapons.Length; i++ )
		if ( Weapons[i].WeaponClass != None )
		{
			AlreadyHas = Weapon(Bot.FindInventoryType(Weapons[i].WeaponClass));
			if ( AlreadyHas == None )
				desire += Weapons[i].WeaponClass.Default.AIRating;
			else if ( AlreadyHas.NeedAmmo(0) )
				desire += 0.15;
		}
	if ( Bot.Controller.bHuntPlayer && (desire * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local Weapon AlreadyHas;
	local float desire;
	local int i;

	if ( bHidden || HasCustomer(Other) )
		return 0;

	// see if bot already has a weapon of this type
	for ( i=0; i<Weapons.Length; i++ )
	{
		AlreadyHas = Weapon(Other.FindInventoryType(Weapons[i].WeaponClass));
		if ( AlreadyHas == None )
			desire += Weapons[i].WeaponClass.Default.AIRating;
		else if ( AlreadyHas.NeedAmmo(0) )
			desire += 0.15;
	}
	if ( AIController(Other.Controller).PriorityObjective()
		&& ((Other.Weapon.AIRating > 0.5) || (PathWeight > 400)) )
		return 0.2/PathWeight;
	return desire/PathWeight;
}

simulated function UpdatePrecacheMaterials()
{
	local int i;

	for ( i=0; i<Weapons.Length; i++ )
		Weapons[i].WeaponClass.Default.PickupClass.static.StaticPrecache(Level);

	super.UpdatePrecacheMaterials();
}

auto state LockerPickup
{
	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	simulated function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		return true;
	}

	// When touched by an actor.
	simulated function Touch( actor Other )
	{
		local Weapon	Copy;
		local int		i;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			if ( (PlayerController(Pawn(Other).Controller) != None) && (Viewport(PlayerController(Pawn(Other).Controller).Player) != None) )
			{
				if ( (Effect != None) && !Effect.bHidden )
					Effect.TurnOff(30);
			}
			if ( Role < ROLE_Authority )
				return;
			if ( !AddCustomer(Pawn(Other)) )
				return;
			TriggerEvent(Event, self, Pawn(Other));
			for ( i=0; i<Weapons.Length; i++ )
			{
				InventoryType = Weapons[i].WeaponClass;
				Copy =  Weapon(Pawn(Other).FindInventoryType(Weapons[i].WeaponClass));
				if ( Copy != None )
					Copy.FillToInitialAmmo();
				else if ( Level.Game.PickupQuery(Pawn(Other), self) )
				{
					Copy = Weapon(SpawnCopy(Pawn(Other)));
					if ( Copy != None )
					{
						Copy.PickupFunction(Pawn(Other));
						if ( Weapons[i].ExtraAmmo > 0 )
							Copy.AddAmmo(Weapons[i].ExtraAmmo, 0);
					}
				}
			}

			AnnouncePickup( Pawn(Other) );
		}
	}
}

State Disabled
{
	simulated function BeginState()
	{
		local LockerWeapon W;

		Super.BeginState();
		ForEach DynamicActors(class'LockerWeapon', W)
			W.Destroy();
		if ( Effect != None )
			Effect.Destroy();
	}
}

defaultproperties
{
     LockerString="Weapon Locker"
     PickupMessage="You loaded up at a weapon locker."
     PickupSound=Sound'NewWeaponSounds.WeaponsLocker_01'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponStatic.WeaponLockerM'
     bStatic=True
     NetUpdateFrequency=1.000000
     DrawScale=0.500000
     DrawScale3D=(X=1.250000,Y=1.250000)
     PrePivot=(Z=105.000000)
     CollisionRadius=80.000000
     CollisionHeight=50.000000
     RotationRate=(Yaw=0)
     DesiredRotation=(Yaw=0)
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
