// Drinks Server by Typhaine Artez - 2020-2025 for OpenSim
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// (changelog at the end of the script)
//
// This is the script that you put in touchable objects. They only need the script and
// no drink object at all. It's sole purpose is to communicate with the server which
// will handle the process with the avatar.

integer MAINCHAN = -48688484;

default {
    changed(integer c) {
        if (CHANGED_OWNER & c) llResetScript();
    }
    on_rez(integer p) {
        llResetScript();
    }
    touch_start(integer n) {
        key id = llDetectedKey(0);
        llRegionSay(MAINCHAN, "list||"+id);
        llMessageLinked(LINK_SET, MAINCHAN, "list", id);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Changelog

// 1.3 2025-09-19
//  * fixed main channel
// 1.1 2020-07-07
//  * public release
// 1.0 sometimes-back-in-2019
//  * initial release
