//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KarmaBoostVolume extends PhysicsVolume;

var()   Array< class<Actor> >   AffectedClasses;
var()   float                   EntryAngleFactor; // Actor DOT volume direction must be greater than this
var()   float                   BoostForce;       // Karma force to be applied
var()   bool                    bBoostRelative;   // If true, boost the actor in the direction of the actor instead of the volume direction

simulated event Touch(Actor Other)
{
    local int i;

	Super.Touch(Other);

    if (Other != None)
    {
        for (i=0; i<AffectedClasses.Length; i++)
        {
            if (Other.Class == AffectedClasses[i])
            {
                TryBoost(Other);
                break;
            }
        }
    }
}

simulated event UnTouch(Actor Other)
{
	Super.UnTouch(Other);

	Gravity = Default.Gravity;
}

simulated function TryBoost(Actor Other)
{
    local float EntryAngle;

    EntryAngle = Normal(Other.Velocity) dot Vector(Rotation);

    if (EntryAngle > EntryAngleFactor)
        ActivateBoost(Other);
}

simulated function ActivateBoost(Actor Other)
{
    if (bBoostRelative)
        Gravity = Default.Gravity + (BoostForce * Normal(Other.Velocity));
    else
        Gravity = Default.Gravity + (BoostForce * Vector(Rotation));
}

defaultproperties
{
     EntryAngleFactor=0.700000
     bDirectional=True
}
