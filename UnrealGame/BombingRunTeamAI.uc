class BombingRunTeamAI extends TeamAI;

var GameObject Bomb; 
var float LastGotFlag;
var GameObjective HomeBase, EnemyBase, BombBase;

function CallForBall(Pawn Recipient)
{
	local Bot B;
	
	if ( (Bomb.Holder == None) || (Bomb.Holder.PlayerReplicationInfo.Team != Team) )
		return;
	
	B = Bot(Bomb.Holder.Controller);
	if ( B == None )
		return;
		
	BombingRunSquadAI(B.Squad).TryPassTo(vector(Bomb.Holder.Rotation),B,Recipient);
}		

function SetObjectiveLists()
{
	local GameObjective O;

	ForEach AllActors(class'GameObjective',O)
		if ( O.bFirstObjective )
		{
			Objectives = O;
			break;
		}
		
	For ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( O.DefenderTeamIndex == 255 )
			BombBase = O;
		else if ( O.DefenderTeamIndex == Team.TeamIndex )
			HomeBase = O;
		else
			EnemyBase = O;
	}
}

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local BombingRunSquadAI S;

	if ( O == None )
		O = EnemyBase;
	S = BombingRunSquadAI(Super.AddSquadWithLeader(C,O));
	S.Bomb = Bomb;
	S.HomeBase = HomeBase;
	S.EnemyBase = EnemyBase;
	S.BombBase = BombBase;
	return S;
}

defaultproperties
{
     SquadType=Class'UnrealGame.BombingRunSquadAI'
     OrderList(0)="Attack"
     OrderList(3)="Attack"
     OrderList(4)="Freelance"
     OrderList(5)="Defend"
     OrderList(6)="Attack"
     OrderList(7)="Defend"
}
