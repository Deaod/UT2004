class FireSkaarj extends Skaarj;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	MyAmmo.ProjectileClass = class'FireSkaarjProjectile';
}

defaultproperties
{
     ScoringValue=7
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw3'
}
