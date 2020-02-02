class TankVictim extends Actor
    placeable;

#exec TEXTURE   IMPORT      NAME=TankVictimTex  FILE=textures\tank_victim.tga LODSET=3 DXT=3 MIPS=1

#exec ANIM  IMPORT      ANIM=TankVictimAnims ANIMFILE=models\tank_victim.PSA COMPRESS=1
#exec ANIM  DIGEST      ANIM=TankVictimAnims VERBOSE USERAWINFO

#exec MESH  MODELIMPORT MESH=TankVictimMesh MODELFILE=models\tank_victim.PSK RIGID=1
#exec MESH  ORIGIN      MESH=TankVictimMesh X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#exec MESH  SCALE       MESH=TankVictimMesh X=1.0 Y=1.0 Z=1.0
#exec MESH  DEFAULTANIM MESH=TankVictimMesh ANIM=TankVictimAnims
#exec MESH  SETTEXTURE  MESH=TankVictimMesh NUM=0 TEXTURE=TankVictimTex

auto state SleepS
{
    function BeginState()
    {
        SimAnim.AnimSequence = 'Sleep';
        SimAnim.AnimRate = 155;
        SimAnim.bAnimLoop = true;
        SimAnim.TweenRate = 16;
        LoopAnim('Sleep',,0.25);
    }

    function Trigger( Actor Other, Pawn EventInstigator )
    {
        SimAnim.AnimSequence = 'WakeUp';
        SimAnim.bAnimLoop = false;
        SimAnim.TweenRate = 40;
        PlayAnim('WakeUp');
        GotoState('Wake');
    }
}

state Wake
{
    function AnimEnd(int Channel)
    {
        SimAnim.AnimSequence = 'Idle';
        SimAnim.bAnimLoop = true;
        SimAnim.TweenRate = 40;
        LoopAnim('Idle',,0.1);
        SetTimer(15, false);
        GotoState('Ready');
    }
}

state Ready
{
    function Timer()
    {
        GotoState('SleepS');
    }
}

defaultproperties
{
     DrawType=DT_Mesh
     bStasis=True
     bReplicateAnimations=True
     Mesh=SkeletalMesh'XEffects.TankVictimMesh'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
