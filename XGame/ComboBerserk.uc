class ComboBerserk extends Combo;

var xEmitter Effect;

function StartEffect(xPawn P)
{
    if (P.Role == ROLE_Authority)
        Effect = Spawn(class'OffensiveEffect', P,, P.Location, P.Rotation);

    if (P.Weapon != None)
        P.Weapon.StartBerserk();

    P.bBerserk = true;
}

function StopEffect(xPawn P)
{
    local Inventory Inv;

    if (Effect != None)
        Effect.Destroy();

    for ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
        if (Inv.IsA('Weapon'))
        {
            Weapon(Inv).StopBerserk();
        }

    P.bBerserk = false;
}

defaultproperties
{
     ExecMessage="Berserk!"
     ComboAnnouncementName="Berzerk"
     keys(0)=2
     keys(1)=2
     keys(2)=1
     keys(3)=1
}
