// ====================================================================
//  Class:  UnrealGame.CinematicGame
//  Parent: Engine.GameInfo
//
//  <Enter a description here>
// ====================================================================

class CinematicGame extends GameInfo
	HideDropDown
	CacheExempt;

var config bool bPreviouslyViewed;		// If True, this intro is interruptable

function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (Level.Title ~= "End Game")
    	Tag = 'BackToMenu';
}


event Trigger( Actor Other, Pawn EventInstigator )
{
	local controller C;
	for( C=Level.ControllerList;C!=None;C=C.NextController )
    {
		if (PlayerController(C) != None)
        	PlayerController(C).ClientOpenMenu(class'GameEngine'.default.MainMenuClass);
    }

}



function AddDefaultInventory( pawn PlayerPawn )
{
	return;
}

function SetGameSpeed( Float T )
{
	GameSpeed = 1.0;
    Level.TimeDilation = 1.0;
    SetTimer(Level.TimeDilation, true);
}

event PostLogin( PlayerController NewPlayer )
{

	// Disable the idle timer

	if ( (NewPlayer.Player!=None) && (NewPlayer.Player.Console!=None) )
		NewPlayer.Player.Console.TimeTooIdle = 0;

	Super.PostLogin(NewPlayer);
	TriggerEvent('startgame', NewPlayer, NewPlayer.Pawn);
}
function Logout( Controller Exiting )
{
	local PlayerController PC;

	PC = PlayerController(Exiting);
	if ( (PC!=None) && (PC.Player!=None) && (PC.Player.Console!=None) )
		PC.Player.Console.TimeTooIdle = PC.Player.Console.Default.TimeTooIdle;

	Super.Logout(Exiting);
}

defaultproperties
{
     HUDType="UnrealGame.CinematicHud"
     PlayerControllerClassName="UnrealGame.CinematicPlayer"
}
