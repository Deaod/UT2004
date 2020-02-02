class xPawnSoundGroup extends Object
    abstract;

var() array<Sound> Sounds;
var() array<Sound> DeathSounds;
var() array<Sound> PainSounds;

Enum ESoundType
{
    EST_Land,
    EST_CorpseLanded,
    EST_HitUnderWater,
    EST_Jump,
    EST_LandGrunt,
    EST_Gasp,
    EST_Drown,
    EST_BreatheAgain,
    EST_Dodge,
    EST_DoubleJump
};

static function Sound GetHitSound()
{
	return default.PainSounds[rand(default.PainSounds.length)];
}

static function Sound GetDeathSound()
{
	return default.DeathSounds[rand(default.DeathSounds.length)];
}

static function Sound GetSound(ESoundType soundType)
{
    return default.Sounds[int(soundType)];
}

defaultproperties
{
     Sounds(0)=SoundGroup'PlayerSounds.Final.Land'
     Sounds(1)=SoundGroup'PlayerSounds.Final.CorpseLanded'
}
