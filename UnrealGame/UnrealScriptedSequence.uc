class UnrealScriptedSequence extends ScriptedSequence;

var UnrealScriptedSequence EnemyAcquisitionScript;
var Controller CurrentUser;
var UnrealScriptedSequence NextScript;	// list of scripts with same tag
var bool bFirstScript;				// first script in list of scripts
var() bool bSniping;				// bots should snipe when using this script as a defense point
var() bool bDontChangeScripts;		// bot should go back to this script, not look for other compatible scripts
var bool  bFreelance;					// true if not claimed by any game objective
var() bool bRoamingScript;				// if true, roam after reaching
var bool bAvoid;
var bool bDisabled;
var() bool bNotInVehicle; 		// bot should not attempt to use this script while in a vehicle
var() byte priority;				// used when several scripts available (e.g. defense scripts for an objective)
var() name EnemyAcquisitionScriptTag;	// script to go to after leaving this script for an acquisition
var() float EnemyAcquisitionScriptProbability;	// likelihood that bot will use acquisitionscript
var() name SnipingVolumeTag;		// area defined by volume in which to look for (distant) sniping targets
var() class<Weapon> WeaponPreference;	// bots using this defense point will preferentially use this weapon

var float NumChecked;

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	bDisabled = false;
	FreeScript();
}

function FreeScript()
{
	CurrentUser = None;
}

function bool CheckForErrors()
{
	if ( Tag == '' )
	{
		log(Self$" has no tag - won't be assigned to any objective!");
		return true;
	}

	return Super.CheckForErrors();
}

function BeginPlay()
{
	local UnrealScriptedSequence S, Last;
	local SnipingVolume V;

	Super.BeginPlay();

	if ( EnemyAcquisitionScriptTag != '' )
	{
		ForEach AllActors(class'UnrealScriptedSequence',EnemyAcquisitionScript,EnemyAcquisitionScriptTag)
			break;
	}

	if ( Tag == '' )
		warn(self$" has no tag - won't be assigned to any objective!");
	else if ( bFirstScript )
	{
		Last = self;
		// first one initialized - create script list
		ForEach AllActors(class'UnrealScriptedSequence',S,Tag)
			if ( S != self )
			{
				Last.NextScript = S;
				S.bFirstScript = false;
				Last = S;
			}
	}

	if ( SnipingVolumeTag != 'None' )
		ForEach AllActors(class'SnipingVolume',V,SnipingVolumeTag)
			V.AddDefensePoint(self);
}

function bool HigherPriorityThan(UnrealScriptedSequence S, Bot B)
{
	NumChecked = 1;
	if ( bAvoid )
	{
		bAvoid = false;
		return false;
	}
	if ( bNotInVehicle && Vehicle(B.Pawn) != None )
		return false;
	if ( (CurrentUser != None) && !CurrentUser.bDeleteMe && (CurrentUser != B)
		&& CurrentUser.SameTeamAs(B) )
	{
		if ( (Bot(CurrentUser) != None) && (Bot(CurrentUser).GoalScript != self) )
			Bot(CurrentUser).GoalScript = None;
		else
			return false;
	}
	if ( (S == None) || (S.Priority < Priority) )
		return true;
	if ( S.Priority > Priority )
		return false;
	if ( (B.FavoriteWeapon != None) && (B.FavoriteWeapon == WeaponPreference) )
		return true;
	S.NumChecked += 1;
	return ( FRand() < 1/S.NumChecked );
}

defaultproperties
{
     bFirstScript=True
     bFreelance=True
     EnemyAcquisitionScriptProbability=1.000000
     Begin Object Class=Action_MOVETOPOINT Name=DefensePointDefaultAction1
     End Object
     Actions(0)=Action_MOVETOPOINT'UnrealGame.UnrealScriptedSequence.DefensePointDefaultAction1'

     Begin Object Class=Action_WAITFORTIMER Name=DefensePointDefaultAction2
         PauseTime=3.000000
     End Object
     Actions(1)=Action_WAITFORTIMER'UnrealGame.UnrealScriptedSequence.DefensePointDefaultAction2'

     ScriptControllerClass=Class'UnrealGame.Bot'
}
