//=============================================================================
// InstagibMutator.
//=============================================================================

class InstagibMutator extends MutZoomInstagib
	HideDropDown
	CacheExempt;

var float GravityZ;
var bool bLowGrav;

function PostBeginPlay()
{
	if ( InstagibCTF(Level.Game) == None )
		return;
		
	if ( InstagibCTF(Level.Game).bZoomInstagib )
	{
		WeaponName = 'ZoomSuperShockRifle';
		WeaponString = "xWeapons.ZoomSuperShockRifle";
		DefaultWeaponName = "xWeapons.ZoomSuperShockRifle";
	}
	bAllowTranslocator = InstagibCTF(Level.Game).bAllowTrans;
	bAllowBoost = InstagibCTF(Level.Game).bAllowBoost;
	if ( InstagibCTF(Level.Game).bLowGrav )
	{
		bLowGrav = true;
		Level.DefaultGravity = GravityZ;
	}

	Super.PostBeginPlay();
}

function bool MutatorIsAllowed()
{
	return true;
}

function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	// Do not add game-type default mutators to list
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
}

static event string GetDescriptionText(string PropName)
{
	return "";
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local PhysicsVolume PV;
    local vector XYDir;
    local float ZDiff,Time;
    local JumpPad J;

	if ( bLowGrav )
	{
		PV = PhysicsVolume(Other);

		if ( PV != None )
		{
			PV.Gravity.Z = FMax(PV.Gravity.Z,GravityZ);
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
	}
	return Super.CheckReplacement(Other,bSuperRelevant);
}

defaultproperties
{
     GravityZ=-300.000000
     WeaponName="SuperShockRifle"
     WeaponString="xWeapons.SuperShockRifle"
     DefaultWeaponName="xWeapons.SuperShockRifle"
}
