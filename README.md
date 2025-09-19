# Drinks dispenser

Scripts for a unique source to dispense drinks all over the region.

It is made of 3 scripts:
* `Drinks Server` is needed in only one object on the region. This object should also contain the wearable objects (drinks) to provide to avatars. It does not need to be visible and can be placed anywhere on the region. But it can also be combined with the `Dispenser` script to make it a touchable dispenser as well.
* `Dispenser` is one simple script to put in touchable objects, bringing the drinks menu to avatar through the server script. It does not do much itself, only triggering communication with the drinks server.
* `Dispensed` is the script to put in all wearable objects (drinks). It does not provide animation or anything else than handling rez and attach to avatar.

## Requirements

The server needs several OSSL functions to be active for the person who rezzed it :
* osSetPrimitiveParams()
* osMessageObject().

If you do not have those rights, the server will not work.

## Simple setup

1. Wear objects(drinks) to enable for wearing and adjust them in position and rotation and drop in them the `Dispensed` script. Be sure to have the animation and associated script as `Dispensed` does not handle animation at all, only communication with the drinks server and attachment to the avatar. When it's ok, click the object to store the adjust in the description, then detach it.

2. Put all objects in one object, alongside the `Drinks Server` script. This object will become the unique drinks provider. If at anytime you want to add or remove drinks (with the `Dispensed` script), just modify this object's content. The server script will detect the change and adapt the list of available drinks.

3. Choose one or several objects to become dispensers, aka touchable to get a menu of drinks. The drinks server itself can be a dispenser, but it's not mandatory (the server can be an hidden object)
