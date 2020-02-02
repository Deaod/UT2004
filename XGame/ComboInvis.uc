class ComboInvis extends Combo;

function StartEffect(xPawn P)
{
    P.SetInvisibility(60.0);
}

function StopEffect(xPawn P)
{
    P.SetInvisibility(0.0);
}

defaultproperties
{
     ExecMessage="Invisible!"
     ComboAnnouncementName="Invisible"
     keys(0)=8
     keys(1)=8
     keys(2)=4
     keys(3)=4
}
