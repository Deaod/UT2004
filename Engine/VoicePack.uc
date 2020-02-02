//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
	abstract;


var() localized string VoicePackName;
var() localized string VoicePackDescription;	// Do I need this? Hint text maybe?

/*
ClientInitialize() sets up playing the appropriate voice segment, and returns a string
 representation of the message
*/
function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex);
static function PlayerSpeech(name Type, int Index, string Callsign, Actor PackOwner);

static function byte GetMessageIndex(name PhraseName)
{
	return 0;
}

static function int PickRandomTauntFor(controller C, bool bNoMature, bool bNoHumanOnly)
{
	return 0;
}

defaultproperties
{
     LifeSpan=10.000000
}
