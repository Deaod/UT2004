class ShieldAttachment extends xWeaponAttachment;

var ForceRing ForceRing3rd;
var ShieldEffect3rd ShieldEffect3rd;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        ShieldEffect3rd;
}

simulated function Destroyed()
{
    if (ShieldEffect3rd != None)
        ShieldEffect3rd.Destroy();

    if (ForceRing3rd != None)
        ForceRing3rd.Destroy();

    Super.Destroyed();
}

function InitFor(Inventory I)
{
    Super.InitFor(I);

	if ( (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None)
		|| (Instigator.PlayerReplicationInfo.Team.TeamIndex > 1) )
		ShieldEffect3rd = Spawn(class'ShieldEffect3rd', I.Instigator);
	else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
		ShieldEffect3rd = Spawn(class'ShieldEffect3rdRED', I.Instigator);
	else
		ShieldEffect3rd = Spawn(class'ShieldEffect3rdBLUE', I.Instigator);
    ShieldEffect3rd.SetBase(I.Instigator);
}

simulated event ThirdPersonEffects()
{
    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
            if (ForceRing3rd == None)
            {
                ForceRing3rd = Spawn(class'ForceRing');
                AttachToBone(ForceRing3rd, 'tip');
            }

            ForceRing3rd.Fire();
        }
    }	

    Super.ThirdPersonEffects();
}

function SetBrightness(int b, bool hit)
{
    if (ShieldEffect3rd != None)
        ShieldEffect3rd.SetBrightness(b, hit);
}

defaultproperties
{
     bHeavy=True
     Mesh=SkeletalMesh'Weapons.ShieldGun_3rd'
}
