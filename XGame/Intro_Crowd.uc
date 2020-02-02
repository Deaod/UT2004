// ====================================================================
//  Class:  XGame.Intro_Crowd
//  Parent: XGame.xIntroPawn
//
// ====================================================================

class Intro_Crowd extends xIntroPawn;

var(Crowd) export editinline array<mesh>	AvailableMeshes;	// Available meshes to pick from	

var Name nextSeq;
var float nextRate;
var float nextTween;
var float nextOffset;

// Assign a random mesh to the pawn if any have been provided

event PostBeginPlay()
{
	if (AvailableMeshes.Length>0)
	{
		LinkMesh(AvailableMeshes[rand(AvailableMeshes.Length)],false);
	}
	Super.PostBeginPlay();
}

function MultiSetup(float delay, name AnimSeq, float AnimRate, float AnimTween, float AnimOffsetClamp)
{
	nextSeq = AnimSeq;
	nextRate = AnimRate;
	nextTween = AnimTween;
	nextOffset = AnimOffsetClamp;

	if (delay>0)
		SetTimer(delay,false);
	else
		Timer();
}

event Timer()
{
	LoopAnim(nextSeq, nextRate, nextTween);
	if (NextOffset>0)
		SetAnimFrame( frand()*NextOffset);
}

defaultproperties
{
     MeshNameString="intro_crowd.crowd_d1_a"
}
