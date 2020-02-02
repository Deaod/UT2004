//==============================================================================
//	Created on: 10/21/2003
//	A small menu for viewing/editing ID3 v1/v2 tags
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class ID3TagEditor extends FloatingWindow;

var automated GUIPanel  p_Main;

var StreamInterface   FileManager;
var StreamInteraction Handler;

var GUIMultiOptionListBox  lb_Fields;
var GUIMultiOptionList     li_Fields;
var array<AnimatedEditbox> ed_Fields;

var string FileName;
var Stream Stream;
var StreamTag ID3Tag;

var localized string EditBoxHint;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent(MyController, MyOwner);
	p_Main.OnCreateComponent = InternalOnCreateComponent;
	p_Main.AppendComponent(lb_Fields);

	li_Fields = lb_Fields.List;
	li_Fields.OnCreateComponent = ListCreateComponent;
	li_Fields.bDrawSelectionBorder = False;

	SetFileManager();
}

event Closed(GUIComponent Sender, bool bCancelled )
{
	Super.Closed(Sender, bCancelled);

	Stream.SaveID3Tag();
}

function bool SetFileManager()
{
	if ( FileManager != None )
	{
		if ( Handler == None && !SetHandler() )
			return false;

		return true;
	}

	if ( Handler == None && !SetHandler() )
		return false;

	FileManager = Handler.FileManager;
	return FileManager != None;
}

function bool SetHandler()
{
	local int i;

	if ( Controller == None || Controller.ViewportOwner == None )
		return false;

	for ( i = 0; i < Controller.ViewportOwner.LocalInteractions.Length; i++ )
	{
		if ( StreamInteraction(Controller.ViewportOwner.LocalInteractions[i]) != None )
		{
			Handler = StreamInteraction(Controller.ViewportOwner.LocalInteractions[i]);
			return true;
		}
	}


	log("StreamPlayer.SetHandler() - no StreamInteractions found!",'MusicPlayer');
	return false;
}

function HandleObject( Object Obj, optional Object OptionalObject_1, optional Object OptionalObj_2 )
{
	// REMOVE ME
	Assert(FileName != "");

	if ( Obj != None )
		Stream = Stream(Obj);

	if ( Stream == None )
		Stream = FileManager.CreateStream(FileName);

	if ( Stream != None )
		ID3Tag = Stream.GetTag();

	ReadTag();
}

function HandleParameters( string ParamA, string ParamB )
{
	Filename = ParamA;
}

function InternalOnChange(GUIComponent Sender)
{
	local int i, idx;
	local GUIMenuOption mo;

//	log(Name@"InternalOnChange Sender:"$Sender);
	if ( GUIMultiOptionList(Sender) != None )
	{
		mo = li_Fields.Get();
		if ( mo == None )
		{
			warn("mo was None"); // FIXME
			return;
		}
		idx = FindFieldIndex( mo.Caption );
		if ( i != -1 )
			ID3Tag.Fields[i].FieldValue = mo.GetComponentValue();
	}
}

function int FindFieldIndex( string Caption )
{
	local int i;

	for ( i = 0; i < ID3Tag.Fields.Length; i++ )
	{
		if ( ID3Tag.Fields[i].FieldName == Caption )
			return i;
	}

	return -1;
}

function ReadTag()
{
	local int i;
	local AnimatedEditBox box;

	if ( ID3Tag == None )
		return;

	for ( i = 0; i < ID3Tag.Fields.Length; i++ )
	{
		box = AnimatedEditBox( li_Fields.AddItem("GUI2K4.AnimatedEditBox", None, ID3Tag.Fields[i].FieldName) );
		box.SetComponentValue( ID3Tag.Fields[i].FieldValue, True );
	}
}
/*
function InternalOnCreateComponent( GUIComponent NewComp, GUIComponent Sender )
{
	if ( GUILabel(NewComp) != None )
	{
		NewComp.StyleName = "TextLabel";
		NewComp.bScaleToParent=True;
		NewComp.bBoundToParent=True;
		NewComp.ScalingType=SCALE_X;
	}

	if ( AnimatedEditBox(NewComp) != None )
	{
		NewComp.OnChange = InternalOnChange;
		AnimatedEditBox(NewComp).LabelStyleName = "TextLabel";
		NewComp.Hint = EditBoxHint;
		NewComp.bScaleToParent=True;
		NewComp.bBoundToParent=True;
		NewComp.ScalingType=SCALE_X;
	}

}
*/

function SetPanelPosition(Canvas C)
{
	local float AT;

	AT = t_WindowTitle.ActualTop() + t_WindowTitle.ActualHeight() + 2;
	p_Main.WinTop = p_Main.RelativeTop( AT );
	p_Main.WinHeight = p_Main.RelativeHeight( (Bounds[3] - ActualHeight(0.015)) - AT );
}

function ListCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
	NewComp.bAutoSizeCaption = False;
}

defaultproperties
{
     Begin Object Class=GUIPanel Name=MainPanel
         WinTop=0.091595
         WinLeft=0.011250
         WinWidth=0.978750
         WinHeight=0.896250
         RenderWeight=0.200000
     End Object
     p_Main=GUIPanel'GUI2K4.ID3TagEditor.MainPanel'

     Begin Object Class=GUIMultiOptionListBox Name=FieldList
         bVisibleWhenEmpty=True
         OnCreateComponent=FieldList.InternalOnCreateComponent
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Fields=GUIMultiOptionListBox'GUI2K4.ID3TagEditor.FieldList'

     EditBoxHint="Click to edit"
     WindowName="Tag Editor"
     MinPageWidth=0.458984
     MinPageHeight=0.330155
}
