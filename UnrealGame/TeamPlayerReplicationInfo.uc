//=============================================================================
// TeamPlayerReplicationInfo.
//=============================================================================
class TeamPlayerReplicationInfo extends PlayerReplicationInfo;

var class<Scoreboard> LocalStatsScreenClass;
var SquadAI Squad;
var bool bHolding;

// following properties are used for server-side local stats gathering and not replicated (except through replicated functions)

var bool bFirstBlood;

struct WeaponStats
{
	var class<Weapon> WeaponClass;
	var int kills;
	var int deaths;
	var int deathsholding;
};
var array<WeaponStats> WeaponStatsArray;

struct VehicleStats
{
	var class<Vehicle> VehicleClass;
	var int Kills;
	var int Deaths;
	var int DeathsDriving;
};
var array<VehicleStats> VehicleStatsArray;

var int FlagTouches, FlagReturns;
var byte Spree[6];
var byte MultiKills[7];
var int Suicides;
var int flakcount,combocount,headcount,ranovercount,DaredevilPoints;
var byte Combos[5];

replication
{
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		LocalStatsScreenClass;
	reliable if ( Role == ROLE_Authority )
		Squad, bHolding; //, DareDevilPoints;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( UnrealMPGameInfo(Level.Game) != None )
		LocalStatsScreenClass = UnrealMPGameInfo(Level.Game).LocalStatsScreenClass;
}

simulated function UpdateWeaponStats(TeamPlayerReplicationInfo PRI, class<Weapon> W, int newKills, int newDeaths, int newDeathsHolding)
{
	local int i;
	local WeaponStats NewWeaponStats;

	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Kills = newKills;
			WeaponStatsArray[i].Deaths = newDeaths;
			WeaponStatsArray[i].DeathsHolding = newDeathsHolding;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = newKills;
	NewWeaponStats.Deaths = newDeaths;
	NewWeaponStats.DeathsHolding = newDeathsHolding;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}

function AddWeaponKill(class<DamageType> D)
{
	local class<Weapon> W;
	local int i;
	local WeaponStats NewWeaponStats;

	if ( class<VehicleDamageType>(D) != None )
	{
		AddVehicleKill(class<VehicleDamageType>(D));
		return;
	}

	if ( class<WeaponDamageType>(D) == None )
		return;

	W = class<WeaponDamageType>(D).default.WeaponClass;

	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Kills++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}

function AddWeaponDeath(class<DamageType> D)
{
	local class<Weapon> W, LastWeapon;
	local int i;
	local WeaponStats NewWeaponStats;
	local Vehicle DrivenVehicle;

	if (Controller(Owner).Pawn != None)
	{
		DrivenVehicle = Vehicle(Controller(Owner).Pawn);
		if (DrivenVehicle == None)
			DrivenVehicle = Controller(Owner).Pawn.DrivenVehicle;
		if (DrivenVehicle != None)
			AddVehicleDeathDriving(DrivenVehicle.Class);
	}
	if (DrivenVehicle == None)
	{
		LastWeapon = Controller(Owner).GetLastWeapon();

		if ( LastWeapon != None )
			AddWeaponDeathHolding(LastWeapon);
	}

	if ( class<VehicleDamageType>(D) != None )
	{
		AddVehicleDeath(class<VehicleDamageType>(D));
		return;
	}

	if ( class<WeaponDamageType>(D) == None )
		return;

	W = class<WeaponDamageType>(D).default.WeaponClass;

	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Deaths++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Deaths = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}

function AddWeaponDeathHolding(class<Weapon> W)
{
	local int i;
	local WeaponStats NewWeaponStats;

	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].DeathsHolding++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.DeathsHolding = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}

simulated function UpdateVehicleStats(TeamPlayerReplicationInfo PRI, class<Vehicle> V, int newKills, int newDeaths, int newDeathsDriving)
{
	local int i;
	local VehicleStats NewVehicleStats;

	for (i = 0; i < VehicleStatsArray.Length; i++)
		if (VehicleStatsArray[i].VehicleClass == V)
		{
			VehicleStatsArray[i].Kills = newKills;
			VehicleStatsArray[i].Deaths = newDeaths;
			VehicleStatsArray[i].DeathsDriving = newDeathsDriving;
			return;
		}

	NewVehicleStats.VehicleClass = V;
	NewVehicleStats.Kills = newKills;
	NewVehicleStats.Deaths = newDeaths;
	NewVehicleStats.DeathsDriving = newDeathsDriving;
	VehicleStatsArray[VehicleStatsArray.Length] = NewVehicleStats;
}

function AddVehicleKill(class<VehicleDamageType> D)
{
	local class<Vehicle> V;
	local int i;
	local VehicleStats NewVehicleStats;

	V = D.default.VehicleClass;
	if (V == None)
		return;

	for (i = 0; i < VehicleStatsArray.Length; i++)
		if (VehicleStatsArray[i].VehicleClass == V)
		{
			VehicleStatsArray[i].Kills++;
			return;
		}

	NewVehicleStats.VehicleClass = V;
	NewVehicleStats.Kills = 1;
	VehicleStatsArray[VehicleStatsArray.Length] = NewVehicleStats;
}

function AddVehicleDeath(class<DamageType> D)
{
	local class<Vehicle> V;
	local int i;
	local VehicleStats NewVehicleStats;

	if (class<VehicleDamageType>(D) == None)
		return;

	V = class<VehicleDamageType>(D).default.VehicleClass;
	if (V == None)
		return;

	for (i = 0; i < VehicleStatsArray.Length; i++)
		if (VehicleStatsArray[i].VehicleClass == V)
		{
			VehicleStatsArray[i].Deaths++;
			return;
		}

	NewVehicleStats.VehicleClass = V;
	NewVehicleStats.Deaths = 1;
	VehicleStatsArray[VehicleStatsArray.Length] = NewVehicleStats;
}

function AddVehicleDeathDriving(class<Vehicle> V)
{
	local int i;
	local VehicleStats NewVehicleStats;

	for (i = 0; i < VehicleStatsArray.Length; i++)
		if (VehicleStatsArray[i].VehicleClass == V)
		{
			VehicleStatsArray[i].DeathsDriving++;
			return;
		}

	NewVehicleStats.VehicleClass = V;
	NewVehicleStats.DeathsDriving = 1;
	VehicleStatsArray[VehicleStatsArray.Length] = NewVehicleStats;
}

defaultproperties
{
}
