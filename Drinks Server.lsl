// Drinks Server by Typhaine Artez - 2020-2025 for OpenSim
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// (changelog at the end of the script)
//
// This is the server script that should be contained in only one object that contains
// the drinks (drinks must have the Dispensed script to work with the dispenser).
// The object does not have to be visible and can be placed everywhere on the region.
// It's possible to set the server as a dispenser too, by combining this script with the
// Dispenser script in the same object.

/////////////////////////////////////////////////////////////////////////////////////////
// Setup: change variables below accordingly to your build.

// Main channel the server will listen at. You should change this only if another script
// is using the same channel
integer MAINCHAN  = -48688484;

// Total time in seconds after which an object is considered lost
float TIMEOUT   = 60.0;

// Timer to regularly check for dispensed drinks
float CHKTIME   = 10.0;

// End of setup (do not modify code below unless you know what you do)
/////////////////////////////////////////////////////////////////////////////////////////

list drinks;    // list of available drinks
list dialogs;   // avatar_id, channel, handle, page, timestamp, rezzed_uuid
list pending;   // object_param, object_name, avatar_id

loadDrinks() {
    drinks = [];
    integer c = llGetInventoryNumber(INVENTORY_OBJECT);
    while (~(--c)) drinks += llGetInventoryName(INVENTORY_OBJECT, c);
    llOwnerSay((string)llGetListLength(drinks) + " drinks loaded");
}

integer listenFor(key id) {
    integer chan = (integer)("0x" + llGetSubString(id, 0, 7));
    integer handle = llListen(chan, "", "", "");
    list dlgdata = [id, chan, handle, 0, llGetUnixTime(), NULL_KEY];
    integer i = llListFindList(dialogs, [id]);
    if (~i) dialogs = llListReplaceList(dialogs, dlgdata, i, i+5);
    else dialogs += dlgdata;
    return chan;
}

stopListenerAt(integer i) {
    llListenRemove(llList2Integer(dialogs, i+2));
    dialogs = llDeleteSubList(dialogs, i, i+5);
    if ([] == dialogs) llSetTimerEvent(0.0);
}

dialogFor(key id) {
    integer i = llListFindList(dialogs, [id]);
    if (!~i) return;

    integer chan = llList2Integer(dialogs, i+1);
    integer page = llList2Integer(dialogs, i+3);
    dialogs = llListReplaceList(dialogs, [llGetUnixTime()], i+5, i+5);

    string txt = "\nSelect your drink\n\n";
    list btns;
    if (13 > llGetListLength(drinks)) btns = llListSort(drinks, 1, TRUE);
    else btns = llList2List(drinks, page, page+8);
    txt += llDumpList2String(btns, "\n");
    if (12 < llGetListLength(drinks)) i = 11;
    else i = 12;
    while (i > llGetListLength(btns))
        btns += [" "];
    if (11 == i) btns += ["NEXT >"];

    llDialog(id, txt,
        llList2List(btns,9,11)+llList2List(btns,6,8)+llList2List(btns,3,5)+llList2List(btns,0,2),
        chan
    );
}

integer changePageFor(key id, integer add) {
    integer i = llListFindList(dialogs, [id]);
    if (!~i) return -1;

    integer page = llList2Integer(dialogs, i+3)+add;
    if (page >= llGetListLength(drinks)) page = 0;
    dialogs = llListReplaceList(dialogs, [page], i+3, i+3);
    return page;
}

default {
    changed(integer c) {
        if (CHANGED_OWNER & c) llResetScript();
        if (CHANGED_INVENTORY & c) loadDrinks();
    }
    on_rez(integer p) {
        llResetScript();
    }
    state_entry() {
        loadDrinks();
        llListen(MAINCHAN, "", "", "");
    }
    link_message(integer sender, integer num, string str, key id) {
        if (MAINCHAN == num && "list" == str) {
            if ([] == dialogs) llSetTimerEvent(CHKTIME);
            listenFor(id);
            dialogFor(id);
        }
    }
    listen(integer chan, string name, key id, string msg) {
        if (MAINCHAN == chan) {
            list l = llParseString2List(msg, ["||"], []);
            msg = llList2String(l, 0);
            if ("list" == msg) {
                // list||avatar_id
                id = (key)llList2String(l, 1);
                if ([] == dialogs) llSetTimerEvent(CHKTIME);
                listenFor(id);
                dialogFor(id);
            }
            else if ("ready" == msg) {
                integer i = llListFindList(pending, [(integer)llList2String(l, 1)]);
                if (~i) {
                    vector pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                    osMessageObject(id, "attach||"+(string)llList2Key(pending, i+2)+"||"+(string)pos);
                    pending = llDeleteSubList(pending, i, i+2);
                }
            }
        }
        else {
            integer i = llListFindList(dialogs, [id]);
            if (~i) {
                if ("NEXT >" == msg) {
                    changePageFor(id, 9);
                    dialogFor(id);
                }
                else if (~llListFindList(drinks, [msg])) {
                    vector pos = llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);
                    integer param = (integer)("0x" + llGetSubString(id, 0, 7));
                    pending += [param, msg, id];
                    pos = llGetPos();
                    llRezAtRoot(msg, pos, ZERO_VECTOR, ZERO_ROTATION, param);
                    stopListenerAt(llListFindList(dialogs, [id]));
                }
            }
        }
    }
    timer() {
        integer i = llGetListLength(dialogs) - 1;
        for (; i > -1; i -= 5) {
            integer time = llList2Integer(dialogs, i);
            if (TIMEOUT < llGetUnixTime() - time)
                stopListenerAt(i-4);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Changelog

// 1.3 2025-09-19
//  * fixed main channel
// 1.2 2020-07-07
//  * public release
// 1.1 2020-06-12
//  * fixed rezzing bug when dispensers at more than 10 meters far
// 1.0 sometimes-back-in-2019
//  * initial release
