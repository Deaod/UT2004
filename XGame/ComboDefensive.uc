class ComboDefensive extends Combo;

var xEmitter Effect;

function StartEffect(xPawn P)
{
    if (P.Role == ROLE_Authority)
        Effect = Spawn(class'RegenCrosses', P,, P.Location, P.Rotation);

    SetTimer(0.9, true);
    Timer();
}

function Timer()
{
    if (Pawn(Owner).Role == ROLE_Authority)
    {
        Pawn(Owner).GiveHealth(5, Pawn(Owner).SuperHealthMax);
        if ( Pawn(Owner).Health == Pawn(Owner).SuperHealthMax )
			Pawn(Owner).AddShieldStrength(5);
    }
}

function StopEffect(xPawn P)
{
    if ( Effect != None )
        Effect.Destroy();
}

defaultproperties
{
     ExecMessage="Booster!"
     ComboAnnouncementName="Booster"
     keys(0)=2
     keys(1)=2
     keys(2)=2
     keys(3)=2
}
