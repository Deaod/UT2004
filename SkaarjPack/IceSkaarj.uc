class IceSkaarj extends Skaarj;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	MyAmmo.ProjectileClass = class'IceSkaarjProjectile';
}

defaultproperties
{
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw2'
}
