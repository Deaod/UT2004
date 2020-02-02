class MasterServerLink extends Info
	native
	transient;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct native tMasterServerEntry
{
    var string 	Address;
    var int		Port;
};

var native const pointer LinkPtr;
var globalconfig int LANPort;
var globalconfig int LANServerPort;

var globalconfig array<tMasterServerEntry> 	MasterServerList;
var array<tMasterServerEntry> 				ActiveMasterServerList;

var int LastMSIndex; 		// Index of the last used master server


native function bool Poll( int WaitTime );

// Cheap and easy load balancing coming up here.
/*
event GetMasterServer( out string OutAddress, out int OutPort )
{
	local int Index;
	Index      = rand(MasterServerList.Length);
	OutAddress = MasterServerList[Index].Address;
	OutPort    = MasterServerList[Index].Port;
}
*/

event GetMasterServer( out string OutAddress, out int OutPort )
{
	local int Index;

	if (ActiveMasterServerList.Length==0)
	{
		for (Index=0;Index<MasterServerList.Length;Index++)
		{
			ActiveMasterServerList.Length = Index+1;
			ActiveMasterServerList[Index].Address = MasterServerList[Index].Address;
			ActiveMasterServerList[Index].Port = MasterServerList[Index].Port;
		}
	}

	Index       = rand(ActiveMasterServerList.Length);
	LastMSIndex = Index;

	OutAddress = ActiveMasterServerList[Index].Address;
	OutPort    = ActiveMasterServerList[Index].Port;
}

simulated function Tick( float Delta )
{
	Poll(0);
}

defaultproperties
{
     LANPort=11777
     LANServerPort=10777
     MasterServerList(0)=(Address="ut2004master1.epicgames.com",Port=28902)
     MasterServerList(1)=(Address="ut2004master2.epicgames.com",Port=28902)
     bAlwaysTick=True
}
