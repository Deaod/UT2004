//==============================================================================
//  Created on: 11/22/2003
//  Base class for single player high scores
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================
class SPHighScoreBase extends Object
	abstract;

/** Menu labels of chars unlocked */
var array<string> UnlockedChars;

function UnlockChar(string char, optional string PlayerHash);
function string StoredPlayerID();

defaultproperties
{
}
