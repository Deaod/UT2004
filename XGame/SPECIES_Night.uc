class SPECIES_Night extends SPECIES_Human
	abstract;


static function int ModifyImpartedDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Damage *= Default.DamageScaling;
	if ( instigatedBy.Health > 0 )
		instigatedBy.Health = Clamp(int(instigatedBy.Health+Damage*0.5), instigatedBy.Health, instigatedBy.HealthMax);
	
	return Damage;
}

defaultproperties
{
     MaleVoice="XGame.NightMaleVoice"
     FemaleVoice="XGame.NightFemaleVoice"
     MaleSoundGroup="XGame.xNightMaleSoundGroup"
     FemaleSoundGroup="XGame.xNightFemaleSoundGroup"
     SpeciesName="Night"
     RaceNum=5
     TauntAnims(8)="Gesture_Taunt03"
     TauntAnims(9)="Idle_Character03"
     DamageScaling=0.700000
}
