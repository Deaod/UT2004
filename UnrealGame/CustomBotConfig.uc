class CustomBotConfig extends Object
	abstract
	config;

var localized string FavoriteWeapon, NoPreference;

struct CustomConfiguration
{
	var config string CharacterName;		// name of character (from UPL) to modify
	var config string PlayerName;			// name to change playername to.
	var config string CustomVoice;
	var config GameProfile.EPlayerPos CustomOrders;
	var() config string FavoriteWeapon;
	var() config float Aggressiveness;		// 0 to 1 (0.3 default, higher is more aggressive)
	var() config float Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
	var() config float CombatStyle;		// 0 to 1 (0= stay back more, 1 = charge more)
	var() config float StrafingAbility;	// -1 to 1 (higher uses strafing more)
	var() config float Tactics;			// -1 to 1 (higher uses better team tactics)
	var() config float ReactionTime;        // -1 to 1
	var() config float Jumpiness;		// 0 to 1
	var config bool bJumpy;				// OBSOLETE
};

var config array<CustomConfiguration> ConfigArray;

/* Used to configure custom bot AI parameters
*/
static function Customize(RosterEntry R)
{
	local int i;

	for ( i=0; i<Default.ConfigArray.Length; i++ )
		if ( R.PlayerName ~= Default.ConfigArray[i].CharacterName )
		{
			R.ModifiedPlayerName = Default.ConfigArray[i].PlayerName;
			if ( Default.ConfigArray[i].FavoriteWeapon == "" )
				R.FavoriteWeapon = None;
			else
				R.FavoriteWeapon = class<Weapon>(DynamicLoadObject(Default.ConfigArray[i].FavoriteWeapon, class'Class'));
			R.Aggressiveness = Default.ConfigArray[i].Aggressiveness;
			R.Accuracy = Default.ConfigArray[i].Accuracy;
			R.CombatStyle = Default.ConfigArray[i].CombatStyle;
			R.StrafingAbility = Default.ConfigArray[i].StrafingAbility;
			R.Tactics = Default.ConfigArray[i].Tactics;
			R.ReactionTime = Default.ConfigArray[i].ReactionTime;
			R.Jumpiness = Default.ConfigArray[i].Jumpiness;
			R.VoiceTypeName = Default.ConfigArray[i].CustomVoice;
			R.SetOrders(Default.ConfigArray[i].CustomOrders);
			return;
		}
}

// Copied from xUtil - used for custom configurations
final simulated static function string GetFavoriteWeaponFor(CustomConfiguration CC)
{
local class<Weapon> WeaponClass;

	if ( CC.FavoriteWeapon != "" )
	{
		WeaponClass = class<Weapon>(DynamicLoadObject(CC.FavoriteWeapon, class'Class'));
		if (WeaponClass != None)
			return Default.FavoriteWeapon@WeaponClass.default.ItemName;
	}

	return Default.NoPreference;
}

final simulated static function int RatingModifier(string CharacterName)
{
	local int Hash;

	Hash = Asc(CharacterName);
	if ( Hash == 2 )
		Hash = 1;
	return ( Hash%5 - 2);
}

final simulated static function int AccuracyRating(CustomConfiguration CC)
{
	if ( 2 * CC.Accuracy < -1 )
		return ( 55 + 8 * FMax(-7,2 * CC.Accuracy) );
	if ( 2 * CC.Accuracy == 0 )
		return ( 75 - RatingModifier(CC.CharacterName) );
	if ( 2 * CC.Accuracy < 1 )
		return ( 75 + 20 * 2 * CC.Accuracy - 0.5 * RatingModifier(CC.CharacterName) );
	return Min(100, 95 + 2 * CC.Accuracy );
}

final simulated static function int AgilityRating(CustomConfiguration CC)
{
	local float Add;

	Add = 3 * CC.Jumpiness;
	if ( CC.StrafingAbility < -1 )
		return ( Add + 58 + 8 * FMax(-7,CC.StrafingAbility) );
	if ( (Add == 0) && (CC.StrafingAbility == 0) )
		return ( 75 + 0.5 * RatingModifier(CC.CharacterName) );
	if ( CC.StrafingAbility < 1 )
		return ( Add + 75 + 17 * CC.StrafingAbility - 0.5 * RatingModifier(CC.CharacterName) );
	return Min(100, Add + 92 + CC.StrafingAbility );
}

final simulated static function int TacticsRating(CustomConfiguration CC)
{
	if ( CC.Tactics < -1 )
		return ( 55 + 8 * FMax(-7,CC.Tactics) );
	if ( CC.Tactics == 0 )
		return ( 75 + RatingModifier(CC.CharacterName) );
	if ( CC.Tactics < 1 )
		return ( 75 + 20 * CC.Tactics + 0.5 * RatingModifier(CC.CharacterName) );
	return Min(100, 95 + CC.Tactics );
}

final simulated static function int AggressivenessRating(CustomConfiguration CC)
{
	return Clamp(73 + 25 * (CC.Aggressiveness + CC.CombatStyle) + 0.5 * RatingModifier(CC.CharacterName),0,100);
}

static function int IndexFor(string PlayerName)
{
	local int i;

    for (i=0; i<Default.ConfigArray.Length; i++)
    	if (PlayerName ~= Default.ConfigArray[i].CharacterName)
        	return i;

    return -1;
}

defaultproperties
{
     FavoriteWeapon="Favorite Weapon:"
     NoPreference="No Weapon Preference"
}
