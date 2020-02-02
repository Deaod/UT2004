class ComboSpeed extends Combo;

var xEmitter LeftTrail, RightTrail;

function StartEffect(xPawn P)
{
    LeftTrail = Spawn(class'SpeedTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(LeftTrail, 'lfoot');

    RightTrail = Spawn(class'SpeedTrail', P,, P.Location, P.Rotation);
    P.AttachToBone(RightTrail, 'rfoot');

    P.AirControl *= 1.4;
    P.GroundSpeed *= 1.4;
    P.WaterSpeed *= 1.4;
    P.AirSpeed *= 1.4;
    P.JumpZ *= 1.5;
}

function StopEffect(xPawn P)
{
    if (LeftTrail != None)
        LeftTrail.Destroy();

    if (RightTrail != None)
        RightTrail.Destroy();

    Level.Game.SetPlayerDefaults(P);
}

defaultproperties
{
     ExecMessage="Speed!"
     Duration=16.000000
     ComboAnnouncementName="Speed"
     keys(0)=1
     keys(1)=1
     keys(2)=1
     keys(3)=1
}
