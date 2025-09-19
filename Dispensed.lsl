// Drink Target by Typhaine Artez - 2020-2025 for OpenSim
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// (changelog at the end of the script)
//
// This is the script that you put in touchable objects. They only need the script and
// no drink object at all. It's sole purpose is to communicate with the server which
// will handle the process with the avatar.

key av = NULL_KEY;

////////////////////////////////////////////////////////////////////////////////////////////////////
//R&D by Keknehv Psaltery, 05/25/2006
// with a little poking by Strife, and a bit more
// some more munging by Talarus Luan
// Final cleanup by Keknehv Psaltery
// Changed jump value to 411 (4096 ceiling) by Jesse Barnett
// Compute the number of jumps necessary
warpPos(vector destpos) {
    integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;
    // Try and avoid stack/heap collisions
    if (jumps > 411) jumps = 411;
    list rules = [ PRIM_POSITION, destpos ];  //The start for the rules list
    integer count = 1;
    while ((count = count << 1) < jumps) rules += rules;
    llSetPrimitiveParams(rules + llList2List(rules, (count - jumps) << 1, count));
    if (llVecDist(llGetPos(), destpos) > .001) {
        while (--jumps) llSetPos(destpos);
    }
}
 
////////////////////////////////////////////////////////////////////////////////////////////////////
default {
    on_rez(integer p) {
        if (FALSE == p && 0 != llGetAttached()) state setup;
        if (FALSE != p) llSetTimerEvent(10.0); // kill object if not attached within 10 seconds
    }
    timer() {
        llDie();
    }
    dataserver(key id, string data) {
        list l = llParseString2List(data, ["||"], []);
        data = llList2String(l, 0);
        if ("channel" == data) {
            llRegionSay((integer)llList2String(l, 1), "ready||"+(string)llGetStartParameter());
        }
        else if ("attach" == data) {
            av = (key)llList2String(l, 1);
            vector pos = (vector)llList2String(l, 2);
            if (pos != ZERO_VECTOR) warpPos(pos);
            llRequestPermissions(av, PERMISSION_ATTACH);
        }
    }
    run_time_permissions(integer p) {
        if ((PERMISSION_ATTACH & p) && av == llGetPermissionsKey()) {
            if (!llGetAttached()) {
                llSetTimerEvent(0.0);
                llAttachToAvatarTemp(0);
            }
        }
    }
    attach(key id) {
        if (NULL_KEY != id && 0 != llGetStartParameter()) {
            list l = llParseString2List(llGetObjectDesc(), ["~"], []);
            if (2 == llGetListLength(l)) llSetLinkPrimitiveParamsFast(LINK_ROOT, [
                PRIM_POS_LOCAL, (vector)llList2String(l, 0),
                PRIM_ROT_LOCAL, (rotation)llList2String(l, 1)
            ]);
        }
    }
    touch_start(integer n) {
        if (llGetOwner() == llDetectedKey(0) && 0 != llGetAttached() && 0 != llGetStartParameter()) {
            state drop;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
state setup {
    touch_start(integer n) {
        if (llGetOwner() == llDetectedKey(0) && llGetAttached()) {
            llSetObjectDesc((string)llGetLocalPos() + "~" + (string)llGetLocalRot());
            state default;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
state drop {
    state_entry() {
        integer chan = (integer)(llFrand(-1000000000.0) - 1000000000.0);
        llListen(chan, "", llGetOwner(), "");
        llDialog(llGetOwner(), "\nFinish your drink?", ["Yes", "No"], chan);
    }
    listen(integer chan, string name, key id, string msg) {
        if ("Yes" == msg) llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
        else state default;
    }
    run_time_permissions(integer p) {
        if (PERMISSION_ATTACH & p) llDetachFromAvatar();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Changelog

// 1.3 2025-09-19
//  * fixed moving object closer to avatar in steps (warpPos)
// 1.2 2020-12-03
//  * Fixed version
// 1.1 2020-07-07
//  * public release
// 1.0 sometimes-back-in-2019
//  * initial release
