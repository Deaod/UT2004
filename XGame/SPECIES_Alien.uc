class SPECIES_Alien extends SpeciesType
	abstract;

static function string GetRagSkelName(String MeshName)
{
	return "Alien2";
}

defaultproperties
{
     MaleVoice="XGame.AlienMaleVoice"
     FemaleVoice="XGame.AlienFemaleVoice"
     GibGroup="xEffects.xAlienGibGroup"
     FemaleSkeleton="Aliens.Skeleton_Alien"
     MaleSkeleton="Aliens.Skeleton_Alien"
     MaleSoundGroup="XGame.xAlienMaleSoundGroup"
     FemaleSoundGroup="XGame.xAlienFemaleSoundGroup"
     SpeciesName="Alien"
     TauntAnims(10)="Gesture_Taunt02"
     TauntAnims(11)="Idle_Character02"
     TauntAnimNames(8)="Tail wag"
     TauntAnimNames(9)="Gun check"
     TauntAnimNames(10)="Dismissal"
     TauntAnimNames(11)="360"
     AirControl=1.200000
     GroundSpeed=1.400000
     ReceivedDamageScaling=1.300000
     AccelRate=1.100000
}
