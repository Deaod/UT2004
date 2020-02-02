//==============================================================================
//  Created on: 12/12/2003
//  Components for easily grouping components with a GUISectionBackground
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class ComponentGroup extends GUIMultiComponent;

var automated GUISectionBackground i_Background;
var localized string Caption;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);
	
	SetCaption(Caption);
}

function GUIComponent ManageComponent( GUIComponent C )
{
	if ( C != None )
		i_Background.ManageComponent(C);

	return C;
}

function GUIComponent AppendComponent(GUIComponent NewComp, optional bool bSkipRemap)
{
	return ManageComponent( Super.AppendComponent(NewComp, bSkipRemap) );
}

function GUIComponent InsertComponent(GUIComponent Newcomp, int Index, optional bool bSkipRemap)
{
	return ManageComponent( Super.InsertComponent(NewComp, Index, bSkipRemap) );
}

function bool RemoveComponent(GUIComponent Comp, optional bool bSkipRemap)
{
	i_Background.UnmanageComponent(Comp);
	return Super.RemoveComponent(Comp, bSkipRemap);
}

function SetCaption( string NewCaption )
{
	Caption = NewCaption;
	i_Background.Caption = Caption;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=CGBackground
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=CGBackground.InternalPreDraw
     End Object
     i_Background=GUISectionBackground'GUI2K4.ComponentGroup.CGBackground'

}
