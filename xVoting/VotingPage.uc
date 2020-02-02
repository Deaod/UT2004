//====================================================================
//  xVoting.VotingPage
//  Voting page is the base for MapVoting and KickVoting pages.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class VotingPage extends LargeWindow DependsOn(VotingHandler);

var automated MapVoteFooter f_Chat;
var() editconst noexport VotingReplicationInfo MVRI;

//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local PlayerController PC;

	Super.Initcomponent(MyController, MyOwner);

	PC = PlayerOwner();
	MVRI = VotingReplicationInfo(PC.VoteReplicationInfo);

	// Turn pause off if currently paused (stops replication)
	if(PlayerOwner() != None && PlayerOwner().Level.Pauser != None)
		PlayerOwner().SetPause(false);
}
//------------------------------------------------------------------------------------------------
function Free()
{
	MVRI = None;
    Super.Free();
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=MapVoteFooter Name=MatchSetupFooter
         WinTop=0.686457
         WinLeft=0.019921
         WinWidth=0.962109
         WinHeight=0.291406
         TabOrder=10
     End Object
     f_Chat=MapVoteFooter'xVoting.VotingPage.MatchSetupFooter'

     bRequire640x480=False
     bAllowedAsLast=True
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.800000
     bAcceptsInput=False
}
