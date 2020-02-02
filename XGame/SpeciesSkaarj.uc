class SPECIESSkaarj extends SpeciesType
	abstract;

static function string GetRagSkelName(String MeshName)
{
	return "Skaarj";
}

defaultproperties
{
     MaleVoice="XGame.AlienMaleVoice"
     FemaleVoice="XGame.AlienFemaleVoice"
     GibGroup="xEffects.xAlienGibGroup"
     FemaleSkeleton="SkaarjAnims.Skaarj_Skel"
     MaleSkeleton="SkaarjAnims.Skaarj_Skel"
     MaleSoundGroup="XGame.xAlienMaleSoundGroup"
     FemaleSoundGroup="XGame.xAlienFemaleSoundGroup"
     SpeciesName="Skaarj"
     DMTeam=1
     TauntAnims(4)="Gesture_Taunt02"
     TauntAnims(5)="Gesture_Taunt03"
     TauntAnims(6)="Idle_Character03"
     TauntAnims(7)="Gesture_Taunt01"
     TauntAnims(8)="Idle_Character01"
     TauntAnims(9)=
     TauntAnimNames(4)="Hair flip"
     TauntAnimNames(5)="Slash"
     TauntAnimNames(6)="Scan"
     TauntAnimNames(7)="Finger"
     TauntAnimNames(8)="Idle"
     AirControl=1.200000
     JumpZ=1.500000
     ReceivedDamageScaling=1.300000
}
