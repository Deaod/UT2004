class RosterEntry extends Object
		editinlinenew;

var() class<UnrealPawn> PawnClass;
var() string PawnClassName;
var() string PlayerName;
var() string ModifiedPlayerName;
var() string VoiceTypeName;
var() enum EOrders
{
	ORDERS_None,
	ORDERS_Attack,
	ORDERS_Defend,
	ORDERS_Freelance,
	ORDERS_Support,
	ORDERS_Roam
} Orders;
var() bool bTaken;

var() class<Weapon> FavoriteWeapon;
var() float Aggressiveness;		// 0 to 1 (0.3 default, higher is more aggressive)
var() float Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var() float CombatStyle;		// 0 to 1 (0= stay back more, 1 = charge more)
var() float StrafingAbility;	// -1 to 1 (higher uses strafing more)
var() float Tactics;			// -1 to 1 (higher uses better team tactics)
var() float ReactionTime;
var() float Jumpiness;			// -1 to 1
var bool bJumpy;				// OBSOLETE

function Init() //amb
{
    if( PawnClassName != "" ) 
        PawnClass = class<UnrealPawn>(DynamicLoadObject(PawnClassName, class'class'));
    //log(self$" PawnClass="$PawnClass);
}

function PrecacheRosterFor(UnrealTeamInfo T);

function SetOrders( GameProfile.EPlayerPos Position)
{
	switch ( Position )
	{
		case POS_Defense:
			Orders = ORDERS_Defend;
			break;
		case POS_Offense:
			Orders = ORDERS_Attack;
			break;
		case POS_Roam:
			Orders = ORDERS_Freelance;
			break;
		case POS_Supporting:
			Orders = ORDERS_Support;
			break;
	}
}		

function bool RecommendSupport()
{
	return ( Orders == ORDERS_Support );
}

function bool NoRecommendation()
{
	return ( Orders == ORDERS_None );
}

function bool RecommendDefense()
{
	return ( Orders == ORDERS_Defend );
}

function bool RecommendFreelance()
{
	return ( Orders == ORDERS_Freelance );
}

function bool RecommendAttack()
{
	return ( Orders == ORDERS_Attack );
}

function InitBot(Bot B)
{
    class'CustomBotConfig'.static.Customize(self);

	B.FavoriteWeapon = FavoriteWeapon;
	B.Aggressiveness = FClamp(Aggressiveness, 0, 1);
	B.BaseAggressiveness = B.Aggressiveness;
	B.Accuracy = FClamp(Accuracy, -5, 5);
	B.StrafingAbility = FClamp(StrafingAbility, -5, 5);
	B.CombatStyle = FClamp(CombatStyle, 0, 1);
	B.Tactics = FClamp(Tactics, -5, 5);
	B.ReactionTime = FClamp(ReactionTime, -5, 5);
	B.Jumpiness = Jumpiness;
	if ( B.PlayerReplicationInfo != None )
		B.PlayerReplicationInfo.VoiceTypeName = VoiceTypeName;
}

defaultproperties
{
     Aggressiveness=0.300000
     CombatStyle=0.200000
}
