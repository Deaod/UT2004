//=============================================================================
// DMMutator.
//=============================================================================

class DMMutator extends Mutator
	HideDropDown
	CacheExempt
	config;

var() globalconfig bool bMegaSpeed; // OBSOLETE
var() globalconfig float AirControl; // OBSOLETE
var() globalconfig bool bBrightSkins;

// mc - localized PlayInfo descriptions & extra info
const PROPNUM = 2;
var localized string DMMutPropsDisplayText[PROPNUM];
var localized string DMMutDescText[PROPNUM];

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

defaultproperties
{
     AirControl=0.350000
     bBrightSkins=True
     DMMutPropsDisplayText(0)="Mega Speed"
     DMMutPropsDisplayText(1)="Air Control"
     DMMutDescText(0)="Greatly increase game speed."
     DMMutDescText(1)="Specifies how much air control players have."
}
