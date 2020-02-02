class SkaarjPupae extends Monster;

var name DeathAnims[3];
var bool bLunging;

function SetMovementPhysics()
{
	SetPhysics(PHYS_Falling); 
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	PlayAnim(DeathAnims[Rand(3)], 0.7, 0.1);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	TweenAnim('TakeHit', 0.05);
}

function PlayVictory()
{
	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
	bShotAnim = true;
	PlayAnim('Stab', 1.0, 0.1);
	Controller.Destination = Location;
	Controller.GotoState('TacticalMove','WaitForAnim');
}

singular function Bump(actor Other)
{
	local name Anim;
	local float frame,rate;
	
	if ( bShotAnim && bLunging )
	{
		bLunging = false;
		GetAnimParams(0, Anim,frame,rate);
		if ( Anim == 'Lunge' )
			MeleeDamageTarget(12, (20000.0 * Normal(Controller.Target.Location - Location)));
	}		
	Super.Bump(Other);
}

function RangedAttack(Actor A)
{
	local float Dist;
	
	if ( bShotAnim )
		return;
		
	Dist = VSize(A.Location - Location);
	if ( Dist > 350 )
		return;
	bShotAnim = true;
	PlaySound(ChallengeSound[Rand(4)], SLOT_Interact);
	if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
  		if ( FRand() < 0.5 )
  			SetAnimAction('Bite');
  		else
  			SetAnimAction('Stab');
		MeleeDamageTarget(8, vect(0,0,0));
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		return;
	}
	
	// lunge at enemy
	bLunging = true;
	Enable('Bump');
	SetAnimAction('Lunge');
	Velocity = 500 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
	if ( dist > CollisionRadius + A.CollisionRadius + 35 )
		Velocity.Z += 0.7 * dist;
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
     DeathAnims(0)="Dead"
     DeathAnims(1)="Dead2"
     DeathAnims(2)="Dead3"
     bAlwaysStrafe=True
     HitSound(0)=Sound'SkaarjPack_rc.Pupae.injur1pp'
     HitSound(1)=Sound'SkaarjPack_rc.Pupae.injur1pp'
     HitSound(2)=Sound'SkaarjPack_rc.Pupae.injur2pp'
     HitSound(3)=Sound'SkaarjPack_rc.Pupae.injur2pp'
     DeathSound(0)=Sound'SkaarjPack_rc.Pupae.death1pp'
     DeathSound(1)=Sound'SkaarjPack_rc.Pupae.death1pp'
     DeathSound(2)=Sound'SkaarjPack_rc.Pupae.death1pp'
     DeathSound(3)=Sound'SkaarjPack_rc.Pupae.death1pp'
     ChallengeSound(0)=Sound'SkaarjPack_rc.Pupae.hiss2pp'
     ChallengeSound(1)=Sound'SkaarjPack_rc.Pupae.hiss1pp'
     ChallengeSound(2)=Sound'SkaarjPack_rc.Pupae.roam1pp'
     ChallengeSound(3)=Sound'SkaarjPack_rc.Pupae.hiss3pp'
     bCrawler=True
     MeleeRange=25.000000
     GroundSpeed=300.000000
     WaterSpeed=300.000000
     JumpZ=450.000000
     Health=60
     MovementAnims(0)="Crawl"
     MovementAnims(1)="Crawl"
     MovementAnims(2)="Crawl"
     MovementAnims(3)="Crawl"
     TurnLeftAnim="Crawl"
     TurnRightAnim="Crawl"
     SwimAnims(0)="Crawl"
     SwimAnims(1)="Crawl"
     SwimAnims(2)="Crawl"
     SwimAnims(3)="Crawl"
     WalkAnims(0)="Crawl"
     WalkAnims(1)="Crawl"
     WalkAnims(2)="Crawl"
     WalkAnims(3)="Crawl"
     AirAnims(0)="Lunge"
     AirAnims(1)="Lunge"
     AirAnims(2)="Lunge"
     AirAnims(3)="Lunge"
     TakeoffAnims(0)="Lunge"
     TakeoffAnims(1)="Lunge"
     TakeoffAnims(2)="Lunge"
     TakeoffAnims(3)="Lunge"
     DoubleJumpAnims(0)="Lunge"
     DoubleJumpAnims(1)="Lunge"
     DoubleJumpAnims(2)="Lunge"
     DoubleJumpAnims(3)="Lunge"
     DodgeAnims(0)="Lunge"
     DodgeAnims(1)="Lunge"
     DodgeAnims(2)="Lunge"
     DodgeAnims(3)="Lunge"
     AirStillAnim="Lunge"
     TakeoffStillAnim="Lunge"
     IdleSwimAnim="Crawl"
     Mesh=VertMesh'SkaarjPack_rc.Pupae1'
     Skins(0)=Texture'SkaarjPackSkins.Skins.JPupae1'
     Skins(1)=Texture'SkaarjPackSkins.Skins.JPupae1'
     CollisionRadius=28.000000
     CollisionHeight=12.000000
     Mass=80.000000
     RotationRate=(Yaw=65000,Roll=0)
}
