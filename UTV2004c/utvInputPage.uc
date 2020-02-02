//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvInputPage extends ut2k3guIPage;

var string TypedStr;
var bool bIgnoreKeys;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController, MyOwner);

	bIgnoreKeys = true;
	TypedStr = "";
}

function bool MyOnDraw (Canvas canvas)
{
	local PlayerController pc;

	pc = PlayerOwner();

	if ((pc != none) && (pc.myhud != none)) {
		pc.myhud.DrawTypingPrompt (Canvas, "UTVSAY " $ TypedStr);
	}
	else {
		Log ("utv: Current player has no hud, closing chat");
		Controller.CloseMenu ();
		return true;
	}

	return true;
}

function bool MyOnKeyType(out byte Key, optional string Unicode)
{
	if (bIgnoreKeys)
		return true;

	if (Key >= 0x20) {
		if (Unicode != "")
			TypedStr = TypedStr $ Unicode;
		else
			TypedStr = TypedStr $ Chr (Key);
        return true;
    }

    return false;
}

function bool MyOnKeyEvent(out byte Key, out byte Action, float delta)
{
	if (Action == 1) {	//press
		bIgnoreKeys = false;
	}
	if (Key == 0x1b) {	//escape
		Controller.CloseMenu ();
		return true;
	}
	else if (Action != 1) {
        return false;
	}
	else if (Key == 0x0d) {	//enter
		if (TypedStr != "") {
			class'utvReplication'.default.ChatString = TypedStr;
		}
		Controller.CloseMenu ();

        return true;
	}
	else if (Key == 0x08 || Key == 0x25) {  //backspace, left
		if (Len (TypedStr) > 0)
			TypedStr = Left (TypedStr, Len (TypedStr) - 1);
        return true;
	}

	return false;
}

defaultproperties
{
     bRenderWorld=True
     bRequire640x480=False
     bAllowedAsLast=True
     OnDraw=utvInputPage.MyOnDraw
     OnKeyType=utvInputPage.MyOnKeyType
     OnKeyEvent=utvInputPage.MyOnKeyEvent
}
