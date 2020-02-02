class xJuggMaleSoundGroup extends xPawnSoundGroup;


static function Sound GetHitSound()
{
	if ( FRand() < 0.01 )
		return sound'NewDeath.mj_hit15';
	return default.PainSounds[rand(default.PainSounds.length)];
}

defaultproperties
{
     Sounds(2)=SoundGroup'PlayerSounds.Final.HitUnderWaterJuggMale'
     Sounds(3)=Sound'PlayerSounds.JumpSounds.MaleJump1'
     Sounds(4)=SoundGroup'PlayerSounds.Final.LandGruntJuggMale'
     Sounds(5)=SoundGroup'PlayerSounds.Final.GaspJuggMale'
     Sounds(6)=SoundGroup'PlayerSounds.Final.DrownJuggMale'
     Sounds(7)=SoundGroup'PlayerSounds.Final.BreathAgainJuggMale'
     Sounds(8)=Sound'PlayerSounds.JumpSounds.MaleDodge'
     Sounds(9)=Sound'PlayerSounds.JumpSounds.MaleJump2'
     DeathSounds(0)=Sound'NewDeath.MaleJugg.mj_death01'
     DeathSounds(1)=Sound'NewDeath.MaleJugg.mj_death05'
     DeathSounds(2)=Sound'NewDeath.MaleJugg.mj_death07'
     DeathSounds(3)=Sound'NewDeath.MaleJugg.mj_death08'
     DeathSounds(4)=Sound'NewDeath.MaleJugg.mj_death11'
     PainSounds(0)=Sound'NewDeath.MaleJugg.mj_hit01'
     PainSounds(1)=Sound'NewDeath.MaleJugg.mj_hit02'
     PainSounds(2)=Sound'NewDeath.MaleJugg.mj_hit06'
     PainSounds(3)=Sound'NewDeath.MaleJugg.mj_hit07'
     PainSounds(4)=Sound'NewDeath.MaleJugg.mj_hit11'
     PainSounds(5)=Sound'NewDeath.MaleJugg.mj_hit13'
}
