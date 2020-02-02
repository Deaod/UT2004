class SPECIES_Bot extends SpeciesType
	abstract;

static function string GetRagSkelName(String MeshName)
{
	return "Bot2";
}

defaultproperties
{
     MaleVoice="XGame.RobotVoice"
     FemaleVoice="XGame.FemRobotVoice"
     GibGroup="xEffects.xBotGibGroup"
     MaleSoundGroup="XGame.xBotSoundGroup"
     FemaleSoundGroup="XGame.xBotSoundGroup"
     SpeciesName="Robot"
     RaceNum=1
     DMTeam=1
     TauntAnims(9)=
     TauntAnimNames(8)="Want some?"
     ReceivedDamageScaling=1.200000
     DamageScaling=1.200000
     AccelRate=1.100000
     WalkingPct=0.800000
     CrouchedPct=0.700000
}
