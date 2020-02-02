//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerCoreBlue extends ONSPowerCore;

var ONSPowerCoreEnergy  PCEnergyEffect;

simulated function PowerCoreDestroyed()
{
    Super.PowerCoreDestroyed();

    if (PCEnergyEffect != None)
        PCEnergyEffect.Destroy();
}

simulated function CheckShield()
{
    Super.CheckShield();

    if (CoreStage == 0)
    {
        if (PCEnergyEffect != None && ((PCEnergyEffect.IsA('ONSPowerCoreEnergyRed') && DefenderTeamIndex == 1) || (PCEnergyEffect.IsA('ONSPowerCoreEnergyBlue') && DefenderTeamIndex == 0)))
            PCEnergyEffect.Destroy();

        if (PCEnergyEffect == None)
        {
            if (DefenderTeamIndex == 0)
                PCEnergyEffect = Spawn(class'ONSPowerCoreEnergyRed');
            else
                PCEnergyEffect = Spawn(class'ONSPowerCoreEnergyBlue');
        }
    }
    else if (PCEnergyEffect != None)
        PCEnergyEffect.Destroy();
}

defaultproperties
{
     DefenderTeamIndex=1
}
