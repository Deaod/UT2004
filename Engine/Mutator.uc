//=============================================================================
// Mutator.
//
// Mutators allow modifications to gameplay while keeping the game rules intact.
// Mutators are given the opportunity to modify player login parameters with
// ModifyLogin(), to modify player pawn properties with ModifyPlayer(), to change
// the default weapon for players with GetDefaultWeapon(), or to modify, remove,
// or replace all other actors when they are spawned with CheckRelevance(), which
// is called from the PreBeginPlay() function of all actors except those (Decals,
// Effects and Projectiles for performance reasons) which have bGameRelevant==true.
//=============================================================================
class Mutator extends Info
    DependsOn(GameInfo)
    CacheExempt // rjp -- for Caching
    native;

var Mutator NextMutator;
var class<Weapon> DefaultWeapon;
var string DefaultWeaponName;
var bool bUserAdded;		// mc - mutator was added by user (cmdline or mutator list)
var bool bAddToServerPackages;		// if true, the package this mutator is in will be added to serverpackages at load time

var() cache string            IconMaterialName;
var() cache string            ConfigMenuClassName;
var() cache string            GroupName; // Will only allow one mutator with this tag to be selected.

/* rjp ---
	A note about mutators & the caching system:
	In order for your mutator to appear in the game's mutator lists, you must create a cache file which
	contains your mutator's important information.

	This can be done automatically using a commandlet.  If you wish to ensure support for multiple
	languages in your mutator, you should always export localized strings to .int before exporting the mutator's cache
	information.  This ensures that the caching system will recognize that your mutator has localized properties and
	will adjust your mutator's cache entry accordingly.

	To export localized properties, use the 'dumpint' commandlet:
	'ucc dumpint <PackageFileName.ext>' - generates .int file containing all localized properties.

	To export cache entries, use the 'exportcache' commandlet:
	'ucc exportcache <PackageName.ext>' - generates a .ucl file containing all required caching information.

	Ex: (ACoolMutator.u)

	ucc dumpint ACoolMutator.u
	  - generates ACoolMutator.int
	ucc exportcache ACoolMutator.u
	  - generates ACoolMutator.ucl file containing an entry for each mutator, gameinfo, weapon, and crosshair in
	    the ACoolMutator package.


    Adding "Object=()" lines to your mutator's .int file is no longer necessary.  If the caching system finds any
    Object=() entries in an .int file for your mutator, it will automatically create the necessary .ucl file the first
    time the game is started.

	-- rjp
*/
var() localized cache string  FriendlyName;
var() localized cache string  Description;

/* Don't call Actor PreBeginPlay() for Mutator
*/
event PreBeginPlay()
{
	if ( !MutatorIsAllowed() )
		Destroy();
	else if (bAddToServerPackages)
		AddToPackageMap();
}

function bool MutatorIsAllowed()
{
	return !Level.IsDemoBuild() || Class==class'Mutator';
}

function Destroyed()
{
	local Mutator M;

	// remove from mutator list
	if ( Level.Game.BaseMutator == self )
		Level.Game.BaseMutator = NextMutator;
	else
	{
		for ( M=Level.Game.BaseMutator; M!=None; M=M.NextMutator )
			if ( M.NextMutator == self )
			{
				M.NextMutator = NextMutator;
				break;
			}
	}
	Super.Destroyed();
}

function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

function ModifyLogin(out string Portal, out string Options)
{
	if ( NextMutator != None )
		NextMutator.ModifyLogin(Portal, Options);
}

//Notification that a player is exiting
function NotifyLogout(Controller Exiting)
{
	if (NextMutator != None)
		NextMutator.NotifyLogout(Exiting);
}

/* called by GameInfo.RestartPlayer()
	change the players jumpz, etc. here
*/
function ModifyPlayer(Pawn Other)
{
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

/* return what should replace the default weapon
   mutators further down the list override earlier mutators
*/
function Class<Weapon> GetDefaultWeapon()
{
	local Class<Weapon> W;

	if ( NextMutator != None )
	{
		W = NextMutator.GetDefaultWeapon();
		if ( W == None )
			W = MyDefaultWeapon();
	}
	else
		W = MyDefaultWeapon();
	return W;
}

/* GetInventoryClass()
return an inventory class - either the class specified by InventoryClassName, or a
replacement.  Called when spawning initial inventory for player
*/
function Class<Inventory> GetInventoryClass(string InventoryClassName)
{
	InventoryClassName = GetInventoryClassOverride(InventoryClassName);
	return class<Inventory>(DynamicLoadObject(InventoryClassName, class'Class'));
}

/* GetInventoryClassOverride()
return the string passed in, or a replacement class name string.
*/
function string GetInventoryClassOverride(string InventoryClassName)
{
	// here, in mutator subclass, change InventoryClassName if desired.  For example:
	// if ( InventoryClassName == "Weapons.DorkyDefaultWeapon"
	//		InventoryClassName = "ModWeapons.SuperDisintegrator"

	if ( NextMutator != None )
		return NextMutator.GetInventoryClassOverride(InventoryClassName);
	return InventoryClassName;
}

function class<Weapon> MyDefaultWeapon()
{
	if ( (DefaultWeapon == None) && (DefaultWeaponName != "") )
		DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));

	return DefaultWeapon;
}

function AddMutator(Mutator M)
{
	if ( NextMutator == None )
		NextMutator = M;
	else
		NextMutator.AddMutator(M);
}

function string RecommendCombo(string ComboName)
{
	return ComboName;
}

function string NewRecommendCombo(string ComboName, AIController C)
{
	local string NewComboName;

	NewComboName = RecommendCombo(ComboName);
	if (NewComboName != ComboName)
		return NewComboName;

	if (NextMutator != None)
		return NextMutator.NewRecommendCombo(ComboName, C);
	return ComboName;
}

/* ReplaceWith()
Call this function to replace an actor Other with an actor of aClass.
*/
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

/* Force game to always keep this actor, even if other mutators want to get rid of it
*/
function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	bResult = CheckReplacement(Other, bSuperRelevant);
	if ( bResult && (NextMutator != None) )
		bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckRelevance(Actor Other)
{
	local bool bResult;
	local byte bSuperRelevant;

	if ( AlwaysKeep(Other) )
		return true;

	// allow mutators to remove actors

	bResult = IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

//
// Called when a player sucessfully changes to a new class
//
function PlayerChangedClass(Controller aPlayer)
{
	if ( NextMutator != None )
		NextMutator.PlayerChangedClass(aPlayer);
}

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = GetHumanReadableName();
}

function GetServerPlayers( out GameInfo.ServerResponseLine ServerState )
{
}

// jmw - Allow mod authors to hook in to the %X var parsing

function string ParseChatPercVar(Controller Who, string Cmd)
{
	if (NextMutator !=None)
		Cmd = NextMutator.ParseChatPercVar(Who,Cmd);

	return Cmd;
}

function MutatorFillPlayInfo(PlayInfo PlayInfo)
{
	FillPlayInfo(PlayInfo);

	if (NextMutator != None)
    	NextMutator.MutatorFillPlayInfo(PlayInfo);
}

event bool OverrideDownload( string PlayerIP, string PlayerID, string PlayerURL, out string RedirectURL )
{
	if( NextMutator != None )
		return NextMutator.OverrideDownload( PlayerIP, PlayerID, PlayerURL, RedirectURL );

	return true;
}

function ServerTraveling(string URL, bool bItems)
{
	if (NextMutator != None)
    	NextMutator.ServerTraveling(URL,bItems);
}


function bool CanEnterVehicle(Vehicle V, Pawn P)
{
	if( NextMutator != None )
		return NextMutator.CanEnterVehicle(V, P);

	return true;
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	if( NextMutator != None )
		NextMutator.DriverEnteredVehicle(V, P);
}

function bool CanLeaveVehicle(Vehicle V, Pawn P)
{
	if( NextMutator != None )
		return NextMutator.CanLeaveVehicle(V, P);

	return true;
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	if( NextMutator != None )
		NextMutator.DriverLeftVehicle(V, P);
}

defaultproperties
{
     IconMaterialName="MutatorArt.nosym"
}
