// XInterface.LadderButton
//
// A button that displays a gfx button with a map picture in it.
// The button is meant to be used by/for singleplayer ladders.
////////////////////////////////////////////////////////////////////

class LadderButton extends GUIGFXButton;

var MatchInfo MatchInfo;
var int MatchIndex;
var int LadderIndex;

function SetState(int Rung)
{
local string NewStyleName;

    if (MatchInfo == None)
        return;

    // Set our state based on Rung
    // We Also set our Graphic
    if (Rung < MatchIndex)  // Match out of reach
    {
        Graphic = Material(DynamicLoadObject("SinglePlayerThumbs."$MatchInfo.LevelName$"_G", class'Material', true));
        MenuState = MSAT_Disabled;
        NewStyleName="LadderButton";
    }
    else
    {
        Graphic = Material(DynamicLoadObject("SinglePlayerThumbs."$MatchInfo.LevelName, class'Material', true));
        MenuState = MSAT_Blurry;
        if (Rung == MatchIndex)
            NewStyleName="LadderButton";
        else
            NewStyleName="LadderButtonHi";
    }

    if (!(NewStyleName ~= StyleName))
    {
        StyleName = NewStyleName;
        Style = Controller.GetStyle(StyleName,FontScale);
        if (Style == None)
        {
            Log("NewStyle IS None");
        }
    }
}

defaultproperties
{
     Graphic=Texture'SinglePlayerThumbs.Grey'
     Position=ICP_Scaled
     bClientBound=True
     StyleName="LadderButton"
}
