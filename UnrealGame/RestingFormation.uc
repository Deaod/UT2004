class RestingFormation extends Info;

var Bot Occupant[16];
var vector Offset[16];
var vector LookDir[16];
var float FormationSize;

function LeaveFormation(Bot B)
{
	if ( Occupant[B.FormationPosition] == B )
		Occupant[B.FormationPosition] = None;
}

function bool SetFormation(Bot B, Int Pos, bool bFullCheck)
{
	local vector HitLocation, HitNormal;
	local actor HitActor, Center;

	Center = SquadAI(Owner).FormationCenter();
	if ( Center == None )
		Center = B.Pawn;
	if ( (Occupant[Pos] == None)
		|| !Occupant[Pos].Formation() )
	{
		if ( bFullCheck )
		{
			// FIXME - check if valid position, with traces
			HitActor = Trace(HitLocation, HitNormal,Center.Location, GetLocationFor(Pos,B),false);
			if ( (HitActor != None) && (HitNormal.Z < MINFLOORZ) )
				return false;
		}
		LeaveFormation(B);
		Occupant[Pos] = B;
		return true;
	}
}

function int RecommendPositionFor(Bot B)
{
	local int i;
	
	i = Rand(15);
	if ( SetFormation(B,i,true) )
		return i;
	for ( i=0; i<16; i++ )
		if ( SetFormation(B,i,true) )
			return i;
	for ( i=0; i<16; i++ )
		if ( SetFormation(B,i,false) )
			return i;
	return Rand(15);
}

function vector GetLocationFor(int Pos, Bot B)
{
	local vector Loc,X,Y,Z;
	local actor Center;

	Center = SquadAI(Owner).FormationCenter();
	if ( Center == None )
		Center = B.Pawn;

	GetAxes(SquadAI(Owner).GetFacingRotation(),X,Y,Z);
	Loc = Center.Location + Offset[Pos].X * X + Offset[Pos].Y * Y;
	// FIXME adjust based on traces, try to make a legal destination
	return Loc;
}

function vector GetViewPointFor(Bot B,int Pos)
{
	local vector ViewPoint;
	local actor Center;
	local int i;
	local actor Best;
	
	if ( B.Pawn.Anchor != None )
	{
		For ( i=0; i<B.Pawn.Anchor.PathList.Length; i++ )
		{
			if ( (B.Pawn.Anchor.PathList[i] != None) && (VSize(B.Pawn.Location - B.Pawn.Anchor.PathList[i].End.Location) > 400)
				&& (FRand() > 0.3) && (VSize(B.FocalPoint -  B.Pawn.Anchor.PathList[i].End.Location) > 100)
				&& FastTrace(B.Pawn.Location, B.Pawn.Anchor.PathList[i].End.Location) )
				Best = B.Pawn.Anchor.PathList[i].End;
		}
	}
	
	if ( Best != None )
		return (Best.Location + 0.5 * B.Pawn.CollisionHeight * vect(0,0,1));
	
	if ( B.Pawn.bStationary || (Vehicle(B.Pawn) != None) )
	{
		ViewPoint = (B.Pawn.Location + 2000 * VRand());
		ViewPoint.Z = B.Pawn.Location.Z;
		if ( ((ViewPoint - B.Pawn.Location) Dot (B.FocalPoint - B.Pawn.Location)) > 0 )
			ViewPoint = 2 * B.Pawn.Location - ViewPoint;
		if ( !FastTrace(ViewPoint, B.Pawn.Location) )
			ViewPoint = B.FocalPoint;
	}
	else
	{
		Center = SquadAI(Owner).FormationCenter();
		if ( Center == None )
			return (B.Pawn.Location + 200*VRand());

		ViewPoint = 2 * B.Pawn.Location - Center.Location;
		ViewPoint.Z = B.Pawn.Location.Z;
	}

	return ViewPoint;
}

defaultproperties
{
     offset(0)=(X=100.000000,Y=300.000000)
     offset(1)=(X=300.000000)
     offset(2)=(X=100.000000,Y=-300.000000)
     offset(3)=(X=-100.000000,Y=300.000000)
     offset(4)=(X=-100.000000,Y=-300.000000)
     offset(5)=(X=-400.000000)
     offset(6)=(X=-100.000000,Y=-150.000000)
     offset(7)=(X=-100.000000,Y=150.000000)
     offset(8)=(X=-400.000000,Y=-120.000000)
     offset(9)=(X=-400.000000,Y=120.000000)
     offset(10)=(X=-300.000000,Y=300.000000)
     offset(11)=(X=-300.000000,Y=-300.000000)
     offset(12)=(X=300.000000,Y=300.000000)
     offset(13)=(X=300.000000,Y=-300.000000)
     offset(14)=(X=-200.000000,Y=450.000000)
     offset(15)=(X=-200.000000,Y=-450.000000)
     FormationSize=750.000000
}
