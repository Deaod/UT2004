class SpeciesGameRules extends GameRules;
		
function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	if ( xPawn(injured) != None )
		Damage = xPawn(injured).Species.static.ModifyReceivedDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
	if ( (InstigatedBy != Injured) && (xPawn(InstigatedBy) != None) )
		Damage = xPawn(InstigatedBy).Species.static.ModifyImpartedDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
	return Damage;
}

defaultproperties
{
}
