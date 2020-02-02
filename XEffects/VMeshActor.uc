class VMeshActor extends Actor
    placeable;

var() Name StartAnim;
var() float StartAnimSpeed;

function Tick(float dt)
{
    //if (Mesh != None && StartAnim != AnimSequence)
    //    LoopAnim(StartAnim, StartAnimSpeed, 0.0);
}

defaultproperties
{
     StartAnim="All"
     StartAnimSpeed=1.000000
     DrawType=DT_Mesh
     RemoteRole=ROLE_None
     bUnlit=True
}
