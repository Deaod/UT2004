class LinkedReplicationInfo extends ReplicationInfo
	abstract
	native;

var LinkedReplicationInfo NextReplicationInfo;

replication
{
	// Variables the server should send to the client.
	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		NextReplicationInfo;
}

defaultproperties
{
     NetUpdateFrequency=1.000000
}
