class SPECIES_Jugg extends SpeciesType
	abstract;

static function string GetRagSkelName(String MeshName)
{
	return "Jugg2";
}

defaultproperties
{
     MaleVoice="XGame.JuggMaleVoice"
     FemaleVoice="XGame.JuggFemaleVoice"
     GibGroup="xGame.xJuggGibGroup"
     FemaleSkeleton="Jugg.SkeletonJugg"
     MaleSkeleton="Jugg.SkeletonJugg"
     MaleSoundGroup="XGame.xJuggMaleSoundGroup"
     FemaleSoundGroup="XGame.xJuggFemaleSoundGroup"
     SpeciesName="Juggernaut"
     RaceNum=3
     DMTeam=1
     TauntAnims(10)="Gesture_Taunt02"
     TauntAnims(11)="Idle_Character02"
     TauntAnimNames(7)="Flex"
     TauntAnimNames(8)="Stomp"
     TauntAnimNames(9)="Back scratch"
     TauntAnimNames(10)="Show butt"
     TauntAnimNames(11)="Head scratch"
     AirControl=0.700000
     ReceivedDamageScaling=0.700000
     AccelRate=0.700000
     WalkingPct=0.800000
     CrouchedPct=0.800000
     DodgeSpeedFactor=0.900000
     DodgeSpeedZ=0.900000
}
