class BallAttachment extends xWeaponAttachment;

function InitFor(Inventory I)
{
    Super.InitFor(I);
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();
}

defaultproperties
{
     bHeavy=True
     Mesh=SkeletalMesh'Weapons.BallLauncher_3rd'
}
