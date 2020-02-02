class SuperShockAmmo extends ShockAmmo;

simulated function CheckOutOfAmmo()
{
}

simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
    return true;
}

defaultproperties
{
     MaxAmmo=1
     InitialAmount=1
}
