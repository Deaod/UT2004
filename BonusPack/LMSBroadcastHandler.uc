//=============================================================================
// BroadcastHandler
//
// Message broadcasting is delegated to BroadCastHandler by the GameInfo.
// The BroadCastHandler handles both text messages (typed by a player) and
// localized messages (which are identified by a LocalMessage class and id).
// GameInfos produce localized messages using their DeathMessageClass and
// GameMessageClass classes.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class LMSBroadcastHandler extends BroadcastHandler;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bPartitionSpectators = true;
}

static event bool AcceptPlayInfoProperty(string PropName)
{
	if (PropName == "bPartitionSpectators")
		return false;

	return Super.AcceptPlayInfoProperty(PropName);
}

defaultproperties
{
}
