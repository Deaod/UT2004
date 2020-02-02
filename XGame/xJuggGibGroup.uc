class xJuggGibGroup extends xPawnGibGroup;

static function class<xEmitter> GetBloodEmitClass()
{
	if ( FRand() < 0.4 )
        return class'BotSparks';
    
	if ( class'GameInfo'.static.UseLowGore() )
	{
		if ( class'GameInfo'.static.NoBlood() )
			return Default.NoBloodEmitClass;
 		return Default.LowGoreBloodEmitClass;
 	}
    return Default.BloodEmitClass;
}

defaultproperties
{
}
