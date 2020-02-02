class AnnouncerVoice extends Info
	abstract
	native;

var cache string SoundPackage;
var cache string FallbackSoundPackage;
var string AlternateFallbackSoundPackage;

var cache localized string AnnouncerName;

struct CachedSound
{
	var name CacheName;
	var sound CacheSound;
};

var array<CachedSound> CachedSounds;	// sounds which had to be gotten from backup package
var bool bPrecachedBaseSounds;
var bool bPrecachedGameSounds;

var const cache bool bEnglishOnly;

function sound GetSound(name AName)
{
	local sound NewSound;
	local int i;

	// check fallback sounds
	for ( i=0; i<CachedSounds.Length; i++ )
		if ( AName == CachedSounds[i].CacheName)
			return CachedSounds[i].CacheSound;

	// DLO is cheap if already loaded
	NewSound = Sound(DynamicLoadObject(SoundPackage$"."$AName, class'Sound', true));

	if ( NewSound == None )
		NewSound = PrecacheSound(AName);

	return NewSound;
}

function sound PrecacheSound(name AName)
{
	local sound NewSound;

	NewSound = Sound(DynamicLoadObject(SoundPackage$"."$AName, class'Sound', true));

	if ( (NewSound == None) && (FallBackSoundPackage != "" ) )
		NewSound = PrecacheFallbackPackage( FallBackSoundPackage, AName );

	if ( (NewSound == None) && (AlternateFallbackSoundPackage != "" ) )
		NewSound = PrecacheFallbackPackage( AlternateFallbackSoundPackage, AName );

	if ( NewSound == None )
		warn("Could not find "$AName$" in "$SoundPackage$" nor in fallback package "$FallBackSoundPackage $ "nor in Alternate" $ AlternateFallbackSoundPackage );

	return NewSound;
}

function Sound PrecacheFallbackPackage( string Package, name AName )
{
	local sound NewSound;
	local int	i;

	NewSound = Sound(DynamicLoadObject(Package$"."$AName, class'Sound', true));
	if ( NewSound != None )
	{
		for ( i=0; i<CachedSounds.Length; i++ )
			if ( CachedSounds[i].CacheName == AName )
			{
				CachedSounds[i].CacheSound = NewSound;
				return NewSound;
			}

		CachedSounds.Length = CachedSounds.Length + 1;
		CachedSounds[CachedSounds.Length-1].CacheName	= AName;
		CachedSounds[CachedSounds.Length-1].CacheSound	= NewSound;

		return NewSound;
	}

	return None;
}

function PrecacheAnnouncements( bool bRewardSounds )
{
	local class<GameInfo> GameClass;
	local Actor A;

	if ( !bPrecachedGameSounds )
	{
		bPrecachedGameSounds =  ( (Level.GRI != None) && (Level.GRI.GameClass != "") );
		GameClass = Level.GetGameClass();
		GameClass.Static.PrecacheGameAnnouncements(self, bRewardSounds);
	}

	ForEach DynamicActors(class'Actor', A)
		A.PrecacheAnnouncer(self, bRewardSounds);

	if ( !bPrecachedBaseSounds )
	{
		bPrecachedBaseSounds = true;

		if ( bRewardSounds )
		{
			PrecacheSound('Headshot');
			PrecacheSound('Headhunter');
			PrecacheSound('Berzerk');
			PrecacheSound('Booster');
			PrecacheSound('FlackMonkey');
			PrecacheSound('Combowhore');
			PrecacheSound('Invisible');
			PrecacheSound('Speed');
			PrecacheSound('Camouflaged');
			PrecacheSound('Pint_sized');
			PrecacheSound('first_blood');
			PrecacheSound('adrenalin');
			PrecacheSound('Double_Kill');
			PrecacheSound('MultiKill');
			PrecacheSound('MegaKill');
			PrecacheSound('UltraKill');
			PrecacheSound('MonsterKill_F');
			PrecacheSound('LudicrousKill_F');
			PrecacheSound('HolyShit_F');
			PrecacheSound('Killing_Spree');
			PrecacheSound('Rampage');
			PrecacheSound('Dominating');
			PrecacheSound('Unstoppable');
			PrecacheSound('GodLike');
			PrecacheSound('WhickedSick');
		}
		else
		{
			PrecacheSound('one');
			PrecacheSound('two');
			PrecacheSound('three');
			PrecacheSound('four');
			PrecacheSound('five');
			PrecacheSound('six');
			PrecacheSound('seven');
			PrecacheSound('eight');
			PrecacheSound('nine');
			PrecacheSound('ten');
		}
	}
}

defaultproperties
{
     AlternateFallbackSoundPackage="AnnouncerAssault"
}
