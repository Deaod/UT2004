class xVehicleCTFGame extends xCTFGame;

var(LoadingHints) private localized array<string> VCTFHints;

function bool AllowTransloc()
{
	return false;
}

static function bool NeverAllowTransloc()
{
	return true;
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.VCTFHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.VCTFHints.Length; i++ )
		Hints[Hints.Length] = default.VCTFHints[i];

	return Hints;
}

defaultproperties
{
     VCTFHints(0)="You can't carry the flag in a Manta or a Raptor."
     bAllowTrans=False
     bDefaultTranslocator=False
     bAllowVehicles=True
     MapListType="XInterface.MapListVehicleCTF"
     MapPrefix="VCTF"
     BeaconName="VCTF"
     GameName="Vehicle CTF"
     Description="Like traditional Capture The Flag, only adding vehicles into the mix! Only ground-based vehicles can carry the flag."
     ScreenShotName="UT2004Thumbnails.VCTFShots"
     DecoTextName="XGame.xVehicleCTFGame"
     Acronym="VCTF"
}
