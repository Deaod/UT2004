class MasterServerGameStats extends GameStats
	native;

var MasterServerUplink Uplink;

function Init()
{
	Log("MasterServerGameStats initializing");
	Super.Init();
}

function Logf(string LogString)
{
	Super.Logf(LogString);
	if( Uplink == None )
	{
		// Log("Couldn't log stat line as MasterServerUplink was not found >>"$LogString$"<<");
	}
	else
	if( !Uplink.LogStatLine(LogString) )		// If master server rejects stats for us, disconnect from the Uplink actor.
		Uplink = None;
}

defaultproperties
{
}
