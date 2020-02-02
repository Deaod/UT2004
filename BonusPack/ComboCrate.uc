class ComboCrate extends Combo;

var CrateActor Effect;

function StartEffect(xPawn P)
{
    if (P.Role == ROLE_Authority)
        Effect = Spawn(class'CrateActor', P,, P.Location + P.CollisionHeight * vect(0,0,0.55), P.Rotation);
}

function StopEffect(xPawn P)
{
    if (Effect != None)
        Effect.Destroy();
}

defaultproperties
{
     ExecMessage="Camouflaged!"
     Duration=45.000000
     ComboAnnouncementName="Camouflaged"
     keys(0)=4
     keys(1)=4
     keys(2)=4
     keys(3)=4
}
