class EliteKrallBolt extends KrallBolt;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	FinalBlend(Skins[0]).Material = TrailTex;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local xEmitter sparks;
	
    if ( EffectIsRelevant(Location,false) )
    {
		sparks = Spawn(class'LinkProjSparksYellow',,, HitLocation, rotator(HitNormal));
		sparks.Skins[0] = texture'Shock_Sparkle';
	}
    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
	Destroy();
}

defaultproperties
{
     TrailTex=Texture'XEffectMat.Link.link_muz_blue'
     Damage=25.000000
}
