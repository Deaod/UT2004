class Corroded extends DamageType
	abstract;

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	return Default.PawnDamageEffect;
}

defaultproperties
{
     DeathString="%o was dissolved by %k's."
     FemaleSuicide="%o dissolved in slime."
     MaleSuicide="%o dissolved in slime."
     bLocationalHit=False
     FlashFog=(X=450.000000,Y=700.000000,Z=230.000000)
}
