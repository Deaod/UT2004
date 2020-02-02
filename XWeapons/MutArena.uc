class MutArena extends Mutator
    config;

var() config string ArenaWeaponClassName;
var bool bInitialized;
var class<Weapon> ArenaWeaponClass;
var string ArenaWeaponPickupClassName;
var string ArenaAmmoPickupClassName;
var localized string ArenaDisplayText, ArenaDescText;

simulated function BeginPlay()
{
	local WeaponLocker L;

	foreach AllActors(class'WeaponLocker', L)
		L.GotoState('Disabled');

	Super.BeginPlay();
}

function Initialize()
{
    local int FireMode;

	bInitialized = true;
	DefaultWeaponName = ArenaWeaponClassName;
	ArenaWeaponClass = class<Weapon>(DynamicLoadObject(ArenaWeaponClassName,class'Class'));
	DefaultWeapon = ArenaWeaponClass;
	ArenaWeaponPickupClassName = string(ArenaWeaponClass.default.PickupClass);
    for( FireMode = 0; FireMode<2; FireMode++ )
    {
        if( (ArenaWeaponClass.default.FireModeClass[FireMode] != None)
        && (ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass != None)
        && (ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass != None) )
        {
			ArenaAmmoPickupClassName = string(ArenaWeaponClass.default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass);
			break;
		}
	}
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    if ( !bInitialized )
		Initialize();

	bSuperRelevant = 0;
    if ( xWeaponBase(Other) != None )
		xWeaponBase(Other).WeaponType = ArenaWeaponClass;
    else if ( (Weapon(Other) != None) && (Other.Class != ArenaWeaponClass) )
    {
        if ( Weapon(Other).bNoInstagibReplace )
        {
            bSuperRelevant = 0;
            return true;
        }
 		return false;
 	}
	else if ( (WeaponPickup(Other) != None) && (string(Other.Class) != ArenaWeaponPickupClassName) )
		ReplaceWith( Other, ArenaWeaponPickupClassName);
	else if ( (Ammo(Other) != None) && (string(Other.Class) != ArenaAmmoPickupClassName) )
		ReplaceWith( Other, ArenaAmmoPickupClassName);
	else
	{
		if ( Other.IsA('WeaponLocker') )
			Other.GotoState('Disabled');
		return true;
	}
	return false;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local array<CacheManager.WeaponRecord> Recs;
	local string WeaponOptions;
	local int i;

	Super.FillPlayInfo(PlayInfo);

	class'CacheManager'.static.GetWeaponList(Recs);
	for (i = 0; i < Recs.Length; i++)
	{
		if (WeaponOptions != "")
			WeaponOptions $= ";";

		WeaponOptions $= Recs[i].ClassName $ ";" $ Recs[i].FriendlyName;
	}

	PlayInfo.AddSetting(default.RulesGroup, "ArenaWeaponClassName", default.ArenaDisplayText, 0, 1, "Select", WeaponOptions);
}

static event string GetDescriptionText(string PropName)
{
	if (PropName == "ArenaWeaponClassName")
		return default.ArenaDescText;

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     ArenaWeaponClassName="XWeapons.RocketLauncher"
     ArenaDisplayText="Arena Weapon"
     ArenaDescText="Determines which weapon will be used in the arena match"
     GroupName="Arena"
     FriendlyName="Arena"
     Description="Replace weapons and ammo in map."
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
