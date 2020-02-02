//==============================================================================
//  Created on: 11/17/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MOTDConfigPage extends GUIArrayPropPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	sb_Bk1.WinWidth = 0.621875;
	sb_Bk1.WinHeight = 0.340625;
	sb_Bk1.WinLeft = 0.043750;
	sb_Bk1.WinTop = 0.116666;
	sb_Bk1.TopPadding = 0.01;
	sb_Bk1.LeftPadding = 0.01;
	sb_Bk1.RightPadding = 0.01;
}

function SetOwner(GUIComponent NewOwner)
{
	Super.SetOwner(NewOwner);
	PropValue.Length = 4;
}

function string GetDataString()
{
	return JoinArray(PropValue, "|", True);
}

function SetItemOptions( GUIMenuOption mo )
{
	local moEditBox ed;

	ed = moEditBox(mo);
	if ( ed != None )
		ed.MyEditBox.MaxWidth = 60;
}

defaultproperties
{
     Delim="|"
     WinTop=0.218750
     WinLeft=0.166992
     WinWidth=0.684570
     WinHeight=0.509375
}
