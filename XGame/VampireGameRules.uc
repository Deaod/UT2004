class VampireGameRules extends GameRules;

var() float ConversionRatio;
		
function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	if ( (InstigatedBy != Injured) && (InstigatedBy != None) && (InstigatedBy.Health > 0) 
		&& (InstigatedBy.PlayerReplicationInfo != None) && (Injured.PlayerReplicationInfo != None) 
		&& ((InstigatedBy.PlayerReplicationInfo.Team == None) || (InstigatedBy.PlayerReplicationInfo.Team != Injured.PlayerReplicationInfo.Team)) )
		InstigatedBy.Health = Min( InstigatedBy.Health+Damage*ConversionRatio, Max(InstigatedBy.Health,InstigatedBy.HealthMax) );
	return Damage;
}

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the gamerules name- only used if mutator adds me and deletes itself.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = GetHumanReadableName();
}

defaultproperties
{
     ConversionRatio=0.500000
}
