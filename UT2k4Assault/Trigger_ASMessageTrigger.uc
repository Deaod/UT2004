//=============================================================================
// Trigger_ASMessageTrigger
//=============================================================================
// Broadcasts a message to all players
//=============================================================================

class Trigger_ASMessageTrigger extends Triggers;

var()	enum EPSM_AssaultTeam
{
	EMT_Attackers,
	EMT_Defenders,
	EMT_All,
} AssaultTeam;

var() Sound				AnnouncerSound;		// Announcer Sound played
var() localized string	Message;			// Message displayed
var() byte				AnnouncementLevel;	
var bool bSoundsPrecached;

var() AnnouncerQueueManager.EAPriority	Priority;


event Trigger( Actor Other, Pawn EventInstigator )
{
	local byte				RealTeam;

	RealTeam = GetTeamNum();
	if ( AnnouncerSound != None && ASGameInfo(Level.Game).IsPlaying() )
		ASGameInfo(Level.Game).QueueAnnouncerSound( AnnouncerSound.Name, AnnouncementLevel, RealTeam, Priority, 210 );
}

function byte GetTeamNum()
{
	local byte DefendingTeam;

	if ( AssaultTeam == EMT_All )
		return 255;

	DefendingTeam = Level.Game.GetDefenderNum();

	if ( AssaultTeam == EMT_Defenders )
		return DefendingTeam;

	return 1 - DefendingTeam;
}


simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if ( !bRewardSounds &&(AnnouncerSound != None) && !bSoundsPrecached )
	{
		bSoundsPrecached = true;
		V.PrecacheSound(AnnouncerSound.Name);
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     AssaultTeam=EMT_All
     Message="My Message"
     AnnouncementLevel=1
     bCollideActors=False
}
