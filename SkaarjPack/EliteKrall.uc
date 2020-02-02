class EliteKrall extends Krall;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	MyAmmo.ProjectileClass = class'EliteKrallBolt';
}

defaultproperties
{
     ScoringValue=3
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
}
