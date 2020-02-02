class MutLowGrav extends Mutator;

var float GravityZ;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.DefaultGravity = GravityZ;
}

function bool MutatorIsAllowed()
{
	return true;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local PhysicsVolume PV;
    local vector XYDir;
    local float ZDiff,Time;
    local JumpPad J;

    PV = PhysicsVolume(Other);

	if ( PV != None )
	{
		PV.Gravity.Z = FMax(PV.Gravity.Z,GravityZ);
		PV.BACKUP_Gravity = PV.Gravity;
		PV.bAlwaysRelevant = true;
		PV.RemoteRole = ROLE_DumbProxy;
	}
	J = JumpPad(Other);
	if ( J != None )
	{
		XYDir = J.JumpTarget.Location - J.Location;
		ZDiff = XYDir.Z;
		Time = 2.5f * J.JumpZModifier * Sqrt(Abs(ZDiff/GravityZ));
		J.JumpVelocity = XYDir/Time;
		J.JumpVelocity.Z = ZDiff/Time - 0.5f * GravityZ * Time;
	}

	//vehicles shouldn't be affected by this mutator (it would break them)
	if (Vehicle(Other) != None && KarmaParams(Other.KParams) != None)
		KarmaParams(Other.KParams).KActorGravScale *= class'PhysicsVolume'.default.Gravity.Z / GravityZ;

	return true;
}

defaultproperties
{
     GravityZ=-300.000000
     GroupName="Gravity"
     FriendlyName="LowGrav"
     Description="Low gravity."
}
