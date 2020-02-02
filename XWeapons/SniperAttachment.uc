class SniperAttachment extends xWeaponAttachment;

var() LightningCharge3rd charge;

simulated function Destroyed()
{
    if (charge != None)
        charge.Destroy();

    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
    if ( Level.NetMode != NM_DedicatedServer )
    {
        if (charge == None)
        {
            charge = Spawn(class'LightningCharge3rd');
            AttachToBone(charge, 'tip');
        }
        WeaponLight();
    }

    Super.ThirdPersonEffects();
}

defaultproperties
{
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=165
     LightSaturation=170
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     Mesh=SkeletalMesh'Weapons.Sniper_3rd'
}
