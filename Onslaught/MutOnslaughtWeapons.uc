//Mutator to use Onslaught weapons in other gametypes
class MutOnslaughtWeapons extends Mutator
    config;

var() config string ReplacedWeaponClassNames0; //not an array because playinfo doesn't like it
var() config string ReplacedWeaponClassNames1, ReplacedWeaponClassNames2;
var() config bool bConfigUseOnslaughtWeapon0, bConfigUseOnslaughtWeapon1, bConfigUseOnslaughtWeapon2;
var() byte bUseOnslaughtWeapon[3];
var class<Weapon> ReplacedWeaponClasses[3];
var class<WeaponPickup> ReplacedWeaponPickupClasses[3];
var class<Ammo> ReplacedAmmoPickupClasses[3];
var class<Weapon> OnslaughtWeaponClasses[3];
var string OnslaughtWeaponPickupClassNames[3];
var string OnslaughtAmmoPickupClassNames[3];
var localized string ONSWeaponDisplayText[6], ONSWeaponDescText[6];

function PostBeginPlay()
{
	local int FireMode, x;
	local string ReplacedWeaponPickupClassName;

	for (x = 0; x < 3; x++)
	{
		bUseOnslaughtWeapon[x] = byte(bool(GetPropertyText("bConfigUseOnslaughtWeapon"$x)));
		ReplacedWeaponClasses[x] = class<Weapon>(DynamicLoadObject(GetPropertyText("ReplacedWeaponClassNames"$x),class'Class'));
		ReplacedWeaponPickupClassName = string(ReplacedWeaponClasses[x].default.PickupClass);
		for(FireMode = 0; FireMode<2; FireMode++)
		{
			if( (ReplacedWeaponClasses[x].default.FireModeClass[FireMode] != None)
			 && (ReplacedWeaponClasses[x].default.FireModeClass[FireMode].default.AmmoClass != None)
			 && (ReplacedWeaponClasses[x].default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass != None) )
			{
				ReplacedAmmoPickupClasses[x] = class<Ammo>(ReplacedWeaponClasses[x].default.FireModeClass[FireMode].default.AmmoClass.default.PickupClass);
				break;
			}
		}
		OnslaughtWeaponPickupClassNames[x] = string(OnslaughtWeaponClasses[x].default.PickupClass);
	}

	Super.PostBeginPlay();
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int x, i;
	local WeaponLocker L;

	bSuperRelevant = 0;
	if (xWeaponBase(Other) != None)
	{
		for (x = 0; x < 3; x++)
			if (bUseOnslaughtWeapon[x] == 1 && xWeaponBase(Other).WeaponType == ReplacedWeaponClasses[x])
				xWeaponBase(Other).WeaponType = OnslaughtWeaponClasses[x];
	}
	else if (Weapon(Other) != None)
	{
		if ( Other.IsA('BallLauncher') )
        		return true;
		for (x = 0; x < 3; x++)
			if (bUseOnslaughtWeapon[x] == 1 && Other.Class == ReplacedWeaponClasses[x])
		 		return false;
 	}
	else if (WeaponPickup(Other) != None)
	{
		for (x = 0; x < 3; x++)
			if (bUseOnslaughtWeapon[x] == 1 && Other.Class == ReplacedWeaponPickupClasses[x])
			{
				ReplaceWith(Other, OnslaughtWeaponPickupClassNames[x]);
				return false;
			}
	}
	else if (Ammo(Other) != None)
	{
		for (x = 0; x < 3; x++)
			if (bUseOnslaughtWeapon[x] == 1 && Other.Class == ReplacedAmmoPickupClasses[x])
			{
				ReplaceWith(Other, OnslaughtAmmoPickupClassNames[x]);
				return false;
			}
	}
	else if (WeaponLocker(Other) != None)
	{
		L = WeaponLocker(Other);
		for (x = 0; x < 3; x++)
			if (bUseOnslaughtWeapon[x] == 1)
				for (i = 0; i < L.Weapons.Length; i++)
					if (L.Weapons[i].WeaponClass == ReplacedWeaponClasses[x])
						L.Weapons[i].WeaponClass = OnslaughtWeaponClasses[x];
	}

        return true;
}

function string GetInventoryClassOverride(string InventoryClassName)
{
	local int x;

	for (x = 0; x < 3; x++)
		if (InventoryClassName ~= string(ReplacedWeaponClasses[x]))
			return string(OnslaughtWeaponClasses[x]);

	return Super.GetInventoryClassOverride(InventoryClassName);
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

	PlayInfo.AddSetting(default.RulesGroup, "bConfigUseOnslaughtWeapon0", default.ONSWeaponDisplayText[0], 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "ReplacedWeaponClassNames0", default.ONSWeaponDisplayText[1], 0, 1, "Select", WeaponOptions);
	PlayInfo.AddSetting(default.RulesGroup, "bConfigUseOnslaughtWeapon1", default.ONSWeaponDisplayText[2], 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "ReplacedWeaponClassNames1", default.ONSWeaponDisplayText[3], 0, 1, "Select", WeaponOptions);
	PlayInfo.AddSetting(default.RulesGroup, "bConfigUseOnslaughtWeapon2", default.ONSWeaponDisplayText[4], 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "ReplacedWeaponClassNames2", default.ONSWeaponDisplayText[5], 0, 1, "Select", WeaponOptions);
}

static event string GetDescriptionText(string PropName)
{
	if (PropName == "bConfigUseOnslaughtWeapon0")
		return default.ONSWeaponDescText[0];
	if (PropName == "ReplacedWeaponClassNames0")
		return default.ONSWeaponDescText[1];
	if (PropName == "bConfigUseOnslaughtWeapon1")
		return default.ONSWeaponDescText[2];
	if (PropName == "ReplacedWeaponClassNames1")
		return default.ONSWeaponDescText[3];
	if (PropName == "bConfigUseOnslaughtWeapon2")
		return default.ONSWeaponDescText[4];
	if (PropName == "ReplacedWeaponClassNames2")
		return default.ONSWeaponDescText[5];

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     ReplacedWeaponClassNames0="XWeapons.RocketLauncher"
     ReplacedWeaponClassNames1="XWeapons.BioRifle"
     ReplacedWeaponClassNames2="XWeapons.FlakCannon"
     bConfigUseOnslaughtWeapon1=True
     bConfigUseOnslaughtWeapon2=True
     OnslaughtWeaponClasses(0)=Class'Onslaught.ONSAVRiL'
     OnslaughtWeaponClasses(1)=Class'Onslaught.ONSMineLayer'
     OnslaughtWeaponClasses(2)=Class'Onslaught.ONSGrenadeLauncher'
     OnslaughtAmmoPickupClassNames(0)="Onslaught.ONSAVRiLAmmoPickup"
     OnslaughtAmmoPickupClassNames(1)="Onslaught.ONSMineAmmoPickup"
     OnslaughtAmmoPickupClassNames(2)="Onslaught.ONSGrenadeAmmoPickup"
     ONSWeaponDisplayText(0)="Include AVRiL"
     ONSWeaponDisplayText(1)="Replace this with AVRiL"
     ONSWeaponDisplayText(2)="Include Mine Layer"
     ONSWeaponDisplayText(3)="Replace this with Mine Layer"
     ONSWeaponDisplayText(4)="Include Grenade Launcher"
     ONSWeaponDisplayText(5)="Replace this with Grenade Launcher"
     ONSWeaponDescText(0)="Choose if the AVRiL will be added to the game"
     ONSWeaponDescText(1)="Replace this weapon with the AVRiL"
     ONSWeaponDescText(2)="Choose if the Mine Layer will be added to the game"
     ONSWeaponDescText(3)="Replace this weapon with the Mine Layer"
     ONSWeaponDescText(4)="Choose if the Grenade Launcher will be added to the game"
     ONSWeaponDescText(5)="Replace this weapon with the Grenade Launcher"
     GroupName="Arena"
     FriendlyName="Onslaught Weapons"
     Description="Add the Onslaught weapons to other gametypes."
}
