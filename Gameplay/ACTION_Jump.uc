class ACTION_Jump extends ScriptedAction;

enum JumpType
{
	JUMP_Normal,
	JUMP_Double,
	JUMP_DodgeLeft,
	JUMP_DodgeRight
};

var(Action) JumpType JumpAction;

function bool InitActionFor(ScriptedController C)
{
	if ( C.Pawn == None )
		return false;

	C.Pawn.SetPhysics(PHYS_Walking);
	
	Switch( JumpAction )
	{
		case JUMP_Normal:
			C.Pawn.DoJump(false);
			break;
		case JUMP_Double:
			C.Pawn.DoJump(false);
			C.bPendingDoubleJump = true;
			C.bNotifyApex = true;
			break;
		case JUMP_DodgeLeft:
			C.Pawn.Dodge(DCLICK_Left);
			break;		
		case JUMP_DodgeLeft:
			C.Pawn.Dodge(DCLICK_Right);
			break;		
	}
	return false;	
}

defaultproperties
{
     ActionString="Jump"
}
