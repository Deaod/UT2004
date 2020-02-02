//==============================================================================
//	Listbox for GUIMultiOptionLists
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUIMultiOptionListBox extends GUIListBoxBase;

var() editconst GUIMultiOptionList List;
var() int NumColumns;

function InitBaseList(GUIListBase LocalList)
{
	local GUIMultiOptionList L;

	L = GUIMultiOptionList(LocalList);
	if ( L == None || L == List )
		return;

	Super.InitBaseList(LocalList);

	if ( List != None )
	{
        List.KillTimer();
		List.OnClick = None;
		List.OnChange = None;
		List.OnCreateComponent = None;
		List.OnSaveIni = None;
		List.OnLoadIni = None;

        RemoveComponent(List,true);
        List = GUIMultiOptionList(AppendComponent(L));
	}

	else List = GUIMultiOptionList(AppendComponent(L));

	if ( List != None )
	{
		List.OnClick=InternalOnClick;
		List.OnClickSound=CS_Click;
		List.OnChange=InternalOnChange;
		List.OnCreateComponent=ListCreateComponent;
		List.OnSaveINI=ListSaveIni;
		List.OnLoadINI=ListLoadIni;
	}
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local GUIMultiOptionList L;
	local class<GUIMultiOptionList> ListClass;

	Super.InitComponent(MyController, MyOwner);

	MyScrollBar.Step = NumColumns;
	if (DefaultListClass != "")
	{
		ListClass = class<GUIMultiOptionList>(Controller.AddComponentClass(DefaultListClass));
		if ( ListClass != None )
			L = new(None) ListClass;

		if (L == None)
		{
	       	log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
			return;
        }

		if (L == None)
		{
			Warn("Could not initialize list!");
			return;
		}

	    InitBaseList(L);
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	OnClick(Self);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
//log(Name@"InternalonChange:"$Sender);
	OnChange(Sender);
}

function int ItemCount()
{
	return List.ItemCount;
}

function ListLoadIni(GUIComponent Sender, string S)
{
	OnLoadIni(Sender, S);
}

function string ListSaveIni(GUIComponent Sender)
{
	return OnSaveIni(Sender);
}

function ListCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
	NewComp.IniOption = "@Internal";
	NewComp.OnSaveINI = ListSaveINI;
	NewComp.OnLoadINI = ListLoadINI;

	OnCreateComponent(NewComp, Sender);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	Super.InternalOnCreateComponent(NewComp, Sender);

	if (GUIMultiOptionList(NewComp) != None)
		GUIMultiOptionList(NewComp).NumColumns = NumColumns;
}

function InternalOnScrollRelease(GUIComponent Sender)
{
	MyScrollBar.GripPreDraw(MyScrollBar.MyGripButton);
}


singular function EnableMe()
{
	local int i;

	Super.EnableMe();
	for ( i = 0; i < List.ItemCount; i++ )
		EnableComponent(List.GetItem(i));
}

singular function DisableMe()
{
	local int i;

	Super.DisableMe();
	for ( i = 0; i < List.ItemCount; i++ )
		DisableComponent(List.GetItem(i));
}

defaultproperties
{
     NumColumns=1
     DefaultListClass="XInterface.GUIMultiOptionList"
}
