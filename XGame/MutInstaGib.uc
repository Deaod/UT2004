//=============================================================================
// InstaGib - all hits are instant kill! old sk00l
//=============================================================================
class MutInstaGib extends Mutator
	config;

var name WeaponName, AmmoName;
var string WeaponString, AmmoString;
var config bool bAllowTranslocator;
var config bool bAllowBoost;
var localized string TranslocDisplayText, BoostDisplayText, TranslocDescText, BoostDescText;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "bAllowTranslocator", default.TranslocDisplayText, 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bAllowBoost", default.BoostDisplayText, 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bAllowTranslocator":	return default.TranslocDescText;
		case "bAllowBoost":			return default.BoostDescText;
	}

	return Super.GetDescriptionText(PropName);
}

simulated function BeginPlay()
{
	local xPickupBase P;
	local Pickup L;

	foreach AllActors(class'xPickupBase', P)
	{
		P.bHidden = true;
		if (P.myEmitter != None)
			P.myEmitter.Destroy();
	}
	foreach AllActors(class'Pickup', L)
		if ( L.IsA('WeaponLocker') )
			L.GotoState('Disabled');

	Super.BeginPlay();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( bAllowBoost && (TeamGame(Level.Game) != None) )
		TeamGame(Level.Game).TeammateBoost = 1.0;
	if ( bAllowTranslocator )
		DeathMatch(Level.Game).bOverrideTranslocator = true;
}

function string RecommendCombo(string ComboName)
{
	if ( (ComboName != "xGame.ComboSpeed") && (ComboName != "xGame.ComboInvis") )
	{
		if ( FRand() < 0.65 )
			ComboName = "xGame.ComboInvis";
		else
			ComboName = "xGame.ComboSpeed";
	}

	return Super.RecommendCombo(ComboName);
}

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA(WeaponName) || Other.IsA(AmmoName) )
	{
		if ( NextMutator != None )
			NextMutator.AlwaysKeep(Other);

		return true;
	}

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('Weapon') )
	{
        if ( Weapon(Other).bNoInstagibReplace )
        {
            bSuperRelevant = 0;
            return true;
        }

		if ( Other.IsA('TransLauncher') && bAllowTranslocator )
		{
            bSuperRelevant = 0;
            return true;
        }

		if ( !Other.IsA(WeaponName) )
		{
			Level.Game.bWeaponStay = false;
			return false;
		}
	}

	if ( Other.IsA('Pickup') )
	{
		if ( Other.bStatic || Other.bNoDelete )
			Other.GotoState('Disabled');
		return false;
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
     WeaponName="SuperShockRifle"
     AmmoName="ShockAmmo"
     WeaponString="xWeapons.SuperShockRifle"
     AmmoString="xWeapons.ShockAmmo"
     TranslocDisplayText="Allow Translocator"
     BoostDisplayText="Allow Teammate boosting"
     TranslocDescText="Players get a Translocator in their inventory."
     BoostDescText="Teammates get a big boost when shot by the instagib rifle."
     DefaultWeaponName="xWeapons.SuperShockRifle"
     GroupName="Arena"
     FriendlyName="InstaGib"
     Description="Instant-kill combat with modified Shock Rifles."
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
