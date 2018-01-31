
void CloseDoor(int id)
{
    int iCommandable = 1;
    if (id == GetLocalInt(OBJECT_SELF, "CloseID"))
    {
        if (!GetCommandable(OBJECT_SELF))
        {
            iCommandable = 0;
            SetCommandable(TRUE,OBJECT_SELF);
        }
        ActionCloseDoor(OBJECT_SELF);
        ActionLockObject(OBJECT_SELF);
        if (!iCommandable) SetCommandable(FALSE, OBJECT_SELF);
    }
}

void main()
{
    int id = GetTimeMillisecond();
    SetLocalInt(OBJECT_SELF, "CloseID", id);
    DelayCommand(30.0, CloseDoor(id));
}

