//=============================================================================
// Trigger_ASTouchDamage
//=============================================================================
// Deals damage to actors touching the trigger
//=============================================================================

class Trigger_ASTouchDamage extends Triggers;

var() int				Damage;
var() class<DamageType>	DamageType;


var()	enum EPSM_AssaultTeam
{
	EMT_Attackers,
	EMT_Defenders,
	EMT_All,
} AssaultTeam;


function bool IsRelevant( Pawn P )
{
	local byte DefendingTeam;

	if ( AssaultTeam == EMT_All )
		return true;

	DefendingTeam = Level.Game.GetDefenderNum();

	if ( AssaultTeam == EMT_Defenders && P.GetTeamNum() == DefendingTeam )
		return true;

	if ( AssaultTeam != EMT_Defenders && P.GetTeamNum() == (1 - DefendingTeam) )
		return true;

	return false;
}

function Touch( Actor Other )
{
	local Pawn			P;

	P = Pawn(Other);

	if ( P == None || !IsRelevant(P) )
		return;
		
	P.TakeDamage(Damage, P, P.Location, vect(0,0,0), DamageType);
}

defaultproperties
{
     Damage=200
     DamageType=Class'Engine.Suicided'
     bStatic=True
     bNoDelete=True
     bOnlyAffectPawns=True
}
