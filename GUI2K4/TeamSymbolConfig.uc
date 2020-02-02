//==============================================================================
//	Created on: 09/15/2003
//	Configure the avatars for each team's banner
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class TeamSymbolConfig extends LockedFloatingWindow;

var automated GUIImage i_RedPreview, i_BluePreview;

var automated GUISectionBackground sb_Bk2;
var automated AltSectionBackground sb_Bk3;

var automated GUIVertImageListBox lb_Symbols;
var automated GUIHorzScrollButton b_AddRed, b_AddBlue;

var GUIVertImageList li_Sym;
var Material InitialRed, InitialBlue;
var localized string ResetString, RedString;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<string> TeamSymbols;
	local Material m;
	local int i;

	Super.InitComponent(MyController, MyOwner);

	Controller.GetTeamSymbolList( TeamSymbols, false );
	li_Sym = lb_Symbols.List;
	li_Sym.bDropSource=True;
	li_Sym.OnEndDrag=EndSymbolDrag;

	for ( i = 0; i < TeamSymbols.Length; i++ )
	{
		m = Material(DynamicLoadObject( TeamSymbols[i], Class'Material' ));
		if ( m != None )
		{
			lb_Symbols.AddImage(m);
		}
	}

	b_Ok.SetPosition(0.789829,0.880000,0.159649,0.050000);
	b_Cancel.SetPosition(0.599011,0.880000,0.159649,0.050000);

	sb_Main.SetPosition(0.651078,0.050317,0.264769,0.313203);


	sb_Main.ManageComponent(i_RedPreview);
	sb_Main.Caption = RedString;
	sb_Main.bFillClient=true;


	sb_Bk2.ManageComponent(i_BluePreview);
	sb_Bk3.ManageComponent(lb_Symbols);

	b_Cancel.Caption = ResetString;
	b_Cancel.OnClick=ResetClick;

}

function HandleParameters( string RedSymbol, string BlueSymbol )
{
	local int i;
	local Material M;
	local bool GotRed, GotBlue;

	if ( RedSymbol == "" )
		GotRed = true;

	if ( BlueSymbol == "" )
		GotBlue = true;

	while ( i < li_Sym.ItemCount && !(GotRed && GotBlue) )
	{
		M = li_Sym.GetImageAtIndex(i);
		if ( !GotRed && string(M) ~= RedSymbol )
		{
			InitialRed = M;
			GotRed = true;
			if ( SetRedImage(M) )
				continue;
		}

		if ( !GotBlue && string(M) ~= BlueSymbol )
		{
			InitialBlue = M;
			GotBlue = true;
			if ( SetBlueImage(M) )
				continue;
		}

		i++;
	}
}

function bool ResetClick(GUIComponent Sender)
{
	if ( Sender == b_Cancel )
	{
		SetRedImage(InitialRed);
		SetBlueImage(InitialBlue);
	}

	return true;
}

function EndSymbolDrag(GUIComponent Accepting, bool bAccepted)
{
	local int i;
	local array<ImageListElem> Pending;

	if (bAccepted && Accepting != None)
	{
		Pending = li_sym.GetPendingElements();

		for (i = 0; i < Pending.Length; i++)
		{
			if ( Accepting == i_RedPreview )
				SetRedImage(Pending[i].Image);
			else if ( Accepting == i_BluePreview )
				SetBlueImage( Pending[i].Image );
		}

		li_Sym.bRepeatClick = False;
	}

	if (Accepting == None)
		li_Sym.bRepeatClick = True;

	li_Sym.SetOutlineAlpha(255);
	if ( li_Sym.bNotify )
		li_Sym.CheckLinkedObjects(li_Sym);
}

function bool DragDropped(GUIComponent Sender)
{
	local Material Mat;

	Mat = li_Sym.Get();
	return Mat != None && Mat != GUIImage(Sender).Image;
}

// Returns true if successfully removed image from main list
function bool SetRedImage(Material Mat)
{
	local int i;
	local bool bResult;

	if ( Mat == None )
	{
		if ( i_RedPreview.Image != None )
		{
			i = li_Sym.FindImage(i_RedPreview.Image);
			if ( i == -1 )
				li_Sym.Add( i_RedPreview.Image );
		}

		i_RedPreview.Image = None;
		return false;
	}

	// The image must exist in our list for us to add it
	// Otherwise, we could end up with both teams having the same image, which causes problems
	// when you try to change one of those images, as you then end up with two copies of the same image in the list
	i = li_Sym.FindImage( Mat );
	if ( i != -1 )
	{
		if ( i_RedPreview.Image != None && i_RedPreview.Image != Mat )
			li_Sym.Replace( i, i_RedPreview.Image );

		else
		{
			li_Sym.Remove(i);
			bResult = true;
		}
		i_RedPreview.Image = Mat;
	}

	return bResult;
}

// Returns true if successfully removed image from main list
function bool SetBlueImage(Material Mat)
{
	local int i;
	local bool bResult;

	if ( Mat == None )
	{
		if ( i_BluePreview.Image != None )
		{
			i = li_Sym.FindImage(i_BluePreview.Image);
			if ( i == -1 )
				li_Sym.Add( i_BluePreview.Image );
		}

		i_BluePreview.Image = None;
		return false;
	}
	// The image must exist in our list for us to add it
	// Otherwise, we could end up with both teams having the same image, which causes problems
	// when you try to change one of those images, as you then end up with two copies of the same image in the list
	i = li_Sym.FindImage( Mat );
	if ( i != -1 )
	{
		if ( i_BluePreview.Image != None && i_BluePreview.Image != Mat )
			li_Sym.Replace( i, i_BluePreview.Image );

		else
		{
			li_Sym.Remove(i);
			bResult = True;
		}
		i_BluePreview.Image = Mat;
	}

	return bResult;
}

function bool AddOnPredraw(Canvas C)
{
	b_AddRed.WinLeft = sb_Main.WinLeft - b_AddRed.WinWidth;
	b_AddRed.WinLeft = sb_Bk2.WinLeft - b_AddRed.WinWidth;
	return false;
}

function bool butClick(GUIComponent Sender)
{
	local material m;

	m = li_Sym.Get();
	if (m!=None)
	{
		if (Sender==b_AddRed)
			SetRedImage(M);
		else if (Sender==b_AddBlue)
			SetBlueImage(M);
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=RedPreview
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageColor=(B=0,G=0,R=245)
         ImageStyle=ISTY_Scaled
         DropShadowY=-1
         WinTop=0.148005
         WinLeft=0.105502
         WinWidth=0.240119
         WinHeight=0.407497
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bDropTarget=True
         OnDragDrop=TeamSymbolConfig.DragDropped
     End Object
     i_RedPreview=GUIImage'GUI2K4.TeamSymbolConfig.RedPreview'

     Begin Object Class=GUIImage Name=BluePreview
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageColor=(B=245,G=0,R=0)
         ImageStyle=ISTY_Scaled
         DropShadowY=-1
         WinTop=0.152873
         WinLeft=0.653149
         WinWidth=0.240119
         WinHeight=0.400195
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bDropTarget=True
         OnDragDrop=TeamSymbolConfig.DragDropped
     End Object
     i_BluePreview=GUIImage'GUI2K4.TeamSymbolConfig.BluePreview'

     Begin Object Class=GUISectionBackground Name=back2
         bFillClient=True
         Caption="Blue Team"
         WinTop=0.472192
         WinLeft=0.651078
         WinWidth=0.264769
         WinHeight=0.313203
         OnPreDraw=back2.InternalPreDraw
     End Object
     sb_Bk2=GUISectionBackground'GUI2K4.TeamSymbolConfig.back2'

     Begin Object Class=AltSectionBackground Name=back3
         bFillClient=True
         Caption="Available Team Symbols"
         LeftPadding=0.000000
         RightPadding=0.000000
         WinTop=0.050317
         WinLeft=0.030960
         WinWidth=0.494261
         WinHeight=0.698945
         OnPreDraw=back3.InternalPreDraw
     End Object
     sb_Bk3=AltSectionBackground'GUI2K4.TeamSymbolConfig.back3'

     Begin Object Class=GUIVertImageListBox Name=SymbList
         CellStyle=CELL_FixedCount
         NoVisibleRows=5
         NoVisibleCols=5
         OnCreateComponent=SymbList.InternalOnCreateComponent
         WinTop=0.472192
         WinLeft=0.651078
         WinWidth=0.264769
         WinHeight=0.313203
     End Object
     lb_Symbols=GUIVertImageListBox'GUI2K4.TeamSymbolConfig.SymbList'

     Begin Object Class=GUIHorzScrollButton Name=bAddRed
         bIncreaseButton=True
         StyleName="AltComboButton"
         WinTop=0.200000
         WinLeft=0.619922
         WinWidth=0.033984
         WinHeight=0.043750
         OnPreDraw=TeamSymbolConfig.AddOnPredraw
         OnClick=TeamSymbolConfig.butClick
         OnKeyEvent=bAddRed.InternalOnKeyEvent
     End Object
     b_AddRed=GUIHorzScrollButton'GUI2K4.TeamSymbolConfig.bAddRed'

     Begin Object Class=GUIHorzScrollButton Name=bAddBlue
         bIncreaseButton=True
         StyleName="AltComboButton"
         WinTop=0.634896
         WinLeft=0.615039
         WinWidth=0.033984
         WinHeight=0.043750
         OnClick=TeamSymbolConfig.butClick
         OnKeyEvent=bAddBlue.InternalOnKeyEvent
     End Object
     b_AddBlue=GUIHorzScrollButton'GUI2K4.TeamSymbolConfig.bAddBlue'

     ResetString="Reset"
     RedString="Red Team"
     WindowName="Configure Team Symbols"
     WinTop=0.091927
     WinLeft=0.055664
     WinWidth=0.885742
     WinHeight=0.802344
}
