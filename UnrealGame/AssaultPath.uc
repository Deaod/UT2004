//********************************************************************
// AssaultPath
// used to specify alternate routes for attackers
//
//********************************************************************
class AssaultPath extends NavigationPoint
	placeable;

var		GameObjective	AssociatedObjective;
var		AssaultPath		NextPath;
var()	int				Position;	// specifies relative position in a chain of AssaultPaths with the same PathTag and the same ObjectiveTag
var()	name			ObjectiveTag;
var()	name			PathTag[4];		// paths that fan out from the same first AssaultPath share the same PathTag, more than one path can go through a given assaultpath

var()	bool			bEnabled;
var()	bool			bNoReturn;
var()	bool			bReturnOnly;
var		bool			bFirstPath;
var		bool			bLastPath;
var()	bool			bNoGrouping;	// bots won't wait to reform squads at this assault path
	
var()	float			Priority;	// 0 to 1, higher means heavier weighting when determining whether to use this path

event Trigger( Actor Other, Pawn EventInstigator )
{
	bEnabled = !bEnabled;
}

function ValidatePathTags()
{
	if ( PathTag[0] == '' )
		PathTag[0] = Name;
}

function AddTo(GameObjective O)
{
	local AssaultPath A;
	local int i;

	NextPath = None;
	AssociatedObjective = O;
	if ( O.AlternatePaths == None )
	{
		O.AlternatePaths = self;
		return;
	}
	ValidatePathTags();
	for ( A=O.AlternatePaths; A!=None; A=A.NextPath )
	{
		for ( i=0; i<4; i++ )
			if ( (PathTag[i] != '') && A.HasPathTag(PathTag[i]) )
			{
				if ( A.Position < Position )
				{
					A.bLastPath = false;
					bFirstPath = false;
				}
				else if ( A.Position > Position )
				{
					A.bFirstPath = false;
					bLastPath = false;
				}
			}
		if ( A.NextPath == None )
		{
			A.NextPath = self;
			return;
		}
	}
}

function name PickTag()
{
	local name Result;
	local int i, num;

	ValidatePathTags();
	Result = PathTag[0];

	for ( i=0; i<4; i++ )
		if ( PathTag[i] != 'None' )
		{
			num++;
			if ( FRand() < 1/num )
				Result = PathTag[i];
		}
			
	return Result;
}

function bool HasPathTag(name aPathTag)
{
	local int i;

	ValidatePathTags();
	for ( i=0; i<4; i++ )
		if ( PathTag[i] == aPathTag )
			return true;

	return false;
}

function AssaultPath FindNextPath(name AlternatePathTag)
{
	local AssaultPath A;
	local AssaultPath List[16];
	local int i,num;
	local float sum,r;

	for ( A=AssociatedObjective.AlternatePaths; A!=None; A=A.NextPath )
	{
		if ( A.bEnabled && (A.Position > Position) && !A.bReturnOnly
			&& A.HasPathTag(AlternatePathTag) )
		{
			if ( (List[0] == None) || (A.Position < List[0].Position) )
			{
				for ( i=0; i<num; i++ )
					List[i] = None;
				List[0] = A;
				num = 1;
			}
			else if ( A.Position == List[0].Position )
			{
				List[num] = A;
				num++;
				if ( num > 15 )
					break;
			}
		}
	}
			
	if ( num > 0 )
	{
		for ( i=0; i<num; i++ )
			sum += List[i].Priority;
		r = FRand() * sum;
		sum = 0;
		for ( i=0; i<num; i++ )
		{
			sum += List[i].Priority;
			if ( r <= sum )
				return List[i];
		}
		return List[0];
	}
	return none;
}

function AssaultPath FindPreviousPath(name AlternatePathTag)
{
	local AssaultPath A;
	local AssaultPath List[16];
	local int i,num;
	local float sum,r;

	for ( A=AssociatedObjective.AlternatePaths; A!=None; A=A.NextPath )
	{
		if ( A.bEnabled && (A.Position < Position) && A.HasPathTag(AlternatePathTag) && !A.bNoReturn )
		{
			if ( (List[0] == None) || (A.Position == List[0].Position) )
			{
				List[num] = A;
				num++;
				if ( num > 15 )
					break;
			}
			else if ( A.Position < List[0].Position )
				break;
		}
	}

	if ( num > 0 )
	{
		for ( i=0; i<num; i++ )
			sum += List[i].Priority;
		r = FRand() * sum;
		sum = 0;
		for ( i=0; i<num; i++ )
		{
			sum += List[i].Priority;
			if ( r <= sum )
				return List[i];
		}
		return List[0];
	}
	return none;
}

defaultproperties
{
     bEnabled=True
     bFirstPath=True
     bLastPath=True
     Priority=1.000000
}
