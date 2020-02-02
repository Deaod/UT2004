// ====================================================================
//  Class:  UT2K4UI.GUIMultiComponent
//
//	GUIMultiComponents are collections of components that work together.
//  When initialized, GUIMultiComponents transfer all of their components
//	to the to the GUIPage that owns them.
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIMultiComponent extends GUIComponent
	Abstract
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(Menu)  editinlinenotify export array<GUIComponent>  Controls;       // An Array of Components that make up this Control
var(State) noexport editconst GUIComponent              FocusedControl; // Which component inside this one has focus
var(Menu)  noexport editconstarray array<GUIComponent>  Components;     // An Array of Controls that can be tabbed to

// Animation
var() noexport editconst     int                  AnimationCount;         // Every time a component begins an animation frame, this is increased

var() bool                  PropagateVisibility;	// Does changes to visibility propagate down the line
var() bool                  bOldStyleMenus;			// Is this a UT2003 menu or UT2004
var(State) bool                  bDrawFocusedLast;       // Draw focused control last (focused control will always appear on top)

// If true, empty Controls array when InitializeControls() is called
// (Generally required in order to use automated components when subclassing classes that have Controls members
//  defined in default properties)
var() bool                    bAlwaysAutomate;

delegate bool HandleContextMenuOpen(GUIComponent Sender, GUIContextMenu Menu, GUIComponent ContextMenuOwner)
{
	return true;
}

delegate bool HandleContextMenuClose(GUIContextMenu Sender)
{
	return true;
}

delegate bool NotifyContextSelect(GUIContextMenu Sender, int ClickIndex) { return false; }
delegate OnCreateComponent(GUIComponent NewComponent, GUIComponent Sender);	// Hook to allow setting of component properties before initialization

// Adds all 'automated' GUIComponent subobjects to the Controls array (only if Controls array is empty).
native final function InitializeControls();

// Re-orders all controls with bTabStop = True, according to TabOrder, from lowest to highest
native final function RemapComponents();

// Returns the index into the Components array of GUIComponent Who
native final function int FindComponentIndex(GUIComponent Who);

// Stub
function InternalOnShow();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

    InitializeControls();	// Build the Controls array
	for (i=0;i<Controls.Length;i++)
	{
		if (Controls[i] == None)
		{
			if ( Controller.bModAuthor )
				log(Name@"- Invalid control found in"@GetMenuPath()$"!! (Control"@i$")",'ModAuthor');
			Controls.Remove(i--,1);
			continue;
		}

		OnCreateComponent(Controls[i], Self);
		Controls[i].InitComponent(MyController, Self);
	}

    RemapComponents();
}

event GUIComponent AddComponent(string ComponentClass, optional bool SkipRemap)
{
    local class<GUIComponent> NewCompClass;
    local GUIComponent NewComp;

	if ( Controller != None )
		NewCompClass = Controller.AddComponentClass(ComponentClass);
	else NewCompClass = class<GUIComponent>(DynamicLoadObject(ComponentClass,class'class'));
    if (NewCompClass != None)
    {

        NewComp = new(None) NewCompClass;
        if (NewComp!=None)
        {
        	NewComp = AppendComponent(NewComp, SkipRemap);
			return NewComp;
        }
    }

    log(Name@"could not create component"@ComponentClass,'AddComponent');
	return none;
}

// This function allows you to append a component that has already been initialized
// Be very careful about how you handle the focus chain
event GUIComponent InsertComponent(GUIComponent NewComp, int Index, optional bool SkipRemap)
{
	if (Index < 0 || Index >= Controls.Length)
		return AppendComponent(NewComp);

	Controls.Insert(Index, 1);
	Controls[Index] = NewComp;
	if (!SkipRemap)
		RemapComponents();
	return NewComp;
}

event GUIComponent AppendComponent(GUIComponent NewComp, optional bool SkipRemap)
{
	local int index;

    // Attempt to add it sorted in to the array.  The Controls array is sorted by
    // Render Weight.

    while (Index<Controls.Length)
    {
    	if (NewComp.RenderWeight < Controls[Index].RenderWeight)	// We found our spot
        {
			Controls.Insert(Index,1);
			break;
        }
        Index++;
    }

    // Couldn't find a spot, add it at the end
    Controls[Index] = NewComp;

    OnCreateComponent(NewComp, Self);
    if ( NewComp.Controller == None )
	    NewComp.InitComponent(Controller, Self);

	if (!SkipRemap)
		RemapComponents();

	// If current menu is already initialized, we need to call the opened event from here
	if (Controller.bCurMenuInitialized)
		NewComp.Opened(Self);

    return NewComp;
}

event bool RemoveComponent(GUIComponent Comp, optional bool SkipRemap)
{
	local int i;
    for (i=0;i<Controls.Length;i++)
    {
		if (Controls[i] == Comp)
        {
        	Controls.Remove(i,1);

        	if (!SkipRemap)
	        	RemapComponents();

            return true;
        }
	}
    return false;
}

function SetFocusInstead( GUIComponent InFocusComp )
{
	local int i;

	Super.SetFocusInstead(InFocusComp);
	for ( i = 0; i < Controls.Length; i++ )
		Controls[i].SetFocusInstead(InFocusComp);
}

event SetFocus(GUIComponent Who)
{
	if (Who==None)
	{
		if ( !FocusFirst(None) )
			Super.SetFocus(None);

		return;
	}
	else
		FocusedControl = Who;

	MenuStateChange(MSAT_Focused);

	if (MenuOwner!=None)
		MenuOwner.SetFocus(self);
}

event LoseFocus(GUIComponent Sender)
{
	FocusedControl = None;
	Super.LoseFocus(Sender);
}

function bool CanAcceptFocus()
{
	local int i;

	if ( bAcceptsInput && Super.CanAcceptFocus() )
		return true;

	for ( i = 0; i < Controls.Length; i++ )
		if ( Controls[i].CanAcceptFocus() )
			return true;

	return false;
}

event bool FocusFirst(GUIComponent Sender)
{
    local int i;

	if (Components.Length>0)
	{
    	for (i=0;i<Components.Length;i++)
        {
        	if ( Components[i].FocusFirst(Sender) )
				return true;
        }
    }

	for (i=0;i<Controls.Length;i++)
    {
    	if ( Controls[i].FocusFirst(Sender) )
        	return true;
    }

    if ( bAcceptsInput && Super.CanAcceptFocus() )
    {
    	Super.SetFocus(None);
    	return true;
    }

    return false;
}


event bool FocusLast(GUIComponent Sender)
{
	local int i;

	if (Components.Length>0)
	{
    	for (i=Components.Length-1;i>=0;i--)
        {
        	if (Components[i].FocusLast(Sender))
				return true;
        }
	}

	for (i=Controls.Length-1;i>=0;i--)
    {
    	if ( Controls[i].FocusLast(Sender) )
        	return true;
    }

	if ( bAcceptsInput && Super.CanAcceptFocus() )
	{
		Super.SetFocus(None);
		return true;
	}

    return false;
}

event bool NextControl(GUIComponent Sender)
{
	local int Index;

	Index = FindComponentIndex(Sender);
	if ( Index >= 0 )
	{
	    // Find the next possible component
	    while (++Index<Components.Length)
	    {
	    	if ( Components[Index].FocusFirst(None) )
	        	return true;
	    }
	}

   	if ( Super.NextControl(self) )
       	return true;

	return FocusFirst(none);
}

event bool PrevControl(GUIComponent Sender)
{

	local int Index;

	Index = FindComponentIndex(Sender);
    while (--Index>=0)
    {
    	if (Components[Index].FocusLast(None))
            return true;
    }

    if ( Super.PrevControl(self) )
       	return true;

	return FocusLast(none);

}

singular function EnableMe()
{
	local int i;

	Super.EnableMe();
	for ( i = 0; i < Controls.Length; i++ )
		EnableComponent(Controls[i]);
}

singular function DisableMe()
{
	local int i;

	Super.DisableMe();
	for ( i = 0; i < Controls.Length; i++ )
		DisableComponent(Controls[i]);
}

event SetVisibility(bool bIsVisible)
{
	local int i;

	Super.SetVisibility(bIsVisible);

    if ( !PropagateVisibility )
    	return;

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetVisibility(bIsVisible);
}

event Opened(GUIComponent Sender)
{
	local int i;

	if (Sender == None)
		Sender = Self;

	Super.Opened(Sender);
    for (i=0;i<Controls.Length;i++)
    	Controls[i].Opened(Sender);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	local int i;

	if (Sender == None)
		Sender = Self;

	Super.Closed(Sender, bCancelled);
    for (i=0;i<Controls.Length;i++)
    	Controls[i].Closed(Sender, bCancelled);
}

event Free() 			// This control is no longer needed
{
	local int i;

    for (i=0;i<Controls.Length;i++)
    	Controls[i].Free();

	Controls.Remove(0,Controls.Length);
	Components.Remove(0,Components.Length);

	FocusedControl = None;
    Super.Free();
}

event BeginAnimation( GUIComponent Animating )
{
	AnimationCount++;
	if ( AnimationCount > 0 )
		bAnimating = True;

	if ( MenuOwner != None )
		MenuOwner.BeginAnimation( Animating );
}

event EndAnimation( GUIComponent Animating, EAnimationType Type )
{
	AnimationCount--;
	if ( AnimationCount <= 0 )
	{
		bAnimating = False;
		AnimationCount = 0;
	}

	if ( MenuOwner != None )
		MenuOwner.EndAnimation( Animating, Type );

	if ( Animating == Self )
		OnEndAnimation(Animating, Type);
}

function LevelChanged()
{
	local int i;

	Super.LevelChanged();
	for ( i = 0; i < Controls.Length; i++ )
		Controls[i].LevelChanged();
}

function CenterMouse()
{
	local int i;

	if ( FocusedControl != None )
	{
		FocusedControl.CenterMouse();
		return;
	}

	for ( i = 0; i < Components.Length; i++ )
	{
		if ( Components[i].CanAcceptFocus() )
		{
			Components[i].CenterMouse();
			return;
		}
	}

	Super.CenterMouse();
}

function DebugTabOrder()
{
	local int i;

	CheckInvalidTabOrder();
	CheckDuplicateTabOrder();
	for ( i = 0; i < Controls.Length; i++ )
		Controls[i].DebugTabOrder();
}

function CheckInvalidTabOrder()
{
	local int i;

	for ( i = 0; i < Components.Length; i++ )
		if ( Components[i].TabOrder == -1 )
			log(GetMenuPath()@"Component["$i$"] ("$Components[i].GetMenuPath()$") has no tab order assigned!");
}

function CheckDuplicateTabOrder()
{
	local int i, j;
	local array<intbox> TabOrders;
	local bool bDup;

	for ( i = 0; i < Components.Length; i++ )
	{
		bDup = false;
		if ( Components[i].TabOrder == -1 )
			continue;

		for ( j = 0; j < TabOrders.Length; j++ )
		{
			if ( Components[i].TabOrder == TabOrders[j].X2 )
			{
				log(GetMenuPath()@"Dulicate tab order ("$Components[i].TabOrder$") - components "$TabOrders[j].X1$" ("$Components[TabOrders[j].X1].GetMenuPath()$") & "$i$" ("$Components[i].GetMenuPath()$")");
				bDup = True;
			}
		}

		if ( !bDup )
		{
			j = TabOrders.Length;
			TabOrders.Length = j + 1;
			TabOrders[j].X1 = j;
			TabOrders[j].X2 = Components[i].TabOrder;
		}
	}
}

defaultproperties
{
     bDrawFocusedLast=True
     bTabStop=True
}
