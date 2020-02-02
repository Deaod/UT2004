class CTFTeamAI extends TeamAI;

var CTFFlag FriendlyFlag, EnemyFlag; 
var float LastGotFlag;

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local CTFSquadAI S;

	if ( O == None )
		O = EnemyFlag.HomeBase;
	S = CTFSquadAI(Super.AddSquadWithLeader(C,O));
	if ( S != None )
	{
		S.FriendlyFlag = FriendlyFlag;
		S.EnemyFlag = EnemyFlag;
	}
	return S;
}

defaultproperties
{
     SquadType=Class'UnrealGame.CTFSquadAI'
     OrderList(0)="Attack"
     OrderList(1)="Defend"
     OrderList(2)="Attack"
     OrderList(3)="Attack"
     OrderList(4)="Attack"
     OrderList(5)="Defend"
     OrderList(6)="Freelance"
     OrderList(7)="Attack"
}
