# Drinks dispenser

Scripts for a unique source to dispense drinks all over the region.

It is made of 3 scripts:
* `Drinks Server` is needed in only one object on the region. This object should also contain the wearable objects (drinks) to provide to avatars. It does not need to be visible and can be placed anywhere on the region. But it can also be combinated with the `Dispenser` script to make it a touchable dispenser as well.
* `Dispenser` is one simple script to put in touchable objects, bringing the drinks menu to avatar through the server script. It does not do much itself, only triggering communication with the drinks server.
* `Dispensed` is the script to put in all wearable objects (drinks). It does not provide animation or anything else than handling rez and attach to avatar.


