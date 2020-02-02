class Vignette extends Actor
    abstract
    transient
    native
;

var() string MapName;
var() class<GameInfo> GameClass;

simulated event Init();
simulated event DrawVignette( Canvas C, float Progress );

defaultproperties
{
     DrawType=DT_None
     bNetTemporary=True
     RemoteRole=ROLE_None
     bUnlit=True
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
