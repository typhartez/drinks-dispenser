// Drinks Server by Typhaine Artez - 2020 for OpenSim
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// (changelog at the end of the script)
//
// Drop this script on actual drink objects. It does not handle animation or anything else
// than the communication with the drinks server.

integer MAINCHAN = -4958688484;

key av = NULL_KEY;

default {
    on_rez(integer p) {
        if (FALSE == p && 0 != llGetAttached()) state setup;
        llRegionSay(MAINCHAN, "ready||"+(string)p);
        if (FALSE != p) llSetTimerEvent(10.0); /|/ kill object if not attached within 10 seconds
    }
    timer() {
        llDie();
    }
    dataserver(key id, string data) {
        list l = llParseString2List(data, ["||"], []);
        if ("attach" == llList2String(l, 0)) {
            av = (key)llList2String(l, 1);
            llRequestPermissions(av, PERMISSION_ATTACH);
        }
    }
    run_time_permissions(integer p) {
        if ((PERMISSION_ATTACH & p) && av == llGetPermissionsKey()) {
            if (!llGetAttached()) {
                llSetTimerEvent(0.0);
                llAttachToAvatarTemp(0);
                // warning for OpenSim 0.8.2 users
                llOwnerSay("Due to a problem on some OpenSim versions, please don't try to detach the drink.\nClick on it and click Yes to the question asking if the drink is finished.");
            }
        }
    }
    attach(key id) {
        if (NULL_KEY != id && 0 != llGetStartParameter()) {
            list l = llParseString2List(llGetObjectDesc(), ["~"], []);
            if (2 == llGetListLength(l))
                llSetLinkPrimitiveParamsFast(LINK_ROOT, [
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
state setup {
    touch_start(integer n) {
        if (llGetOwner() == llDetectedKey(0) && llGetAttached()) {
            llSetObjectDesc((string)llGetLocalPos() + "~" + (string)llGetLocalRot());
            state default;
        }
    }
}
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

////////////////////////////////////////////////////////////////////////////////
// Changelog

// 1.1 2020-07-07
//  * public release
// 1.0 sometimes-back-in-2019
//  * initial release
