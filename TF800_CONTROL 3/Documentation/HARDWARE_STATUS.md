# État matériel vérifié — T-WOLF TF800

## Identifiants relevés sur le Mac de l'utilisateur

- Vendor ID (VID) : `0xC0F4`
- Product ID (PID) : `0x0FF5`
- Version USB affichée : `1.10`
- Nom fabricant affiché : `Usb KeyBoard`
- Vitesse affichée : jusqu'à `1,5 Mb/s`
- Courant requis affiché : `98 mA`

## Ce que fait le code

La détection utilise désormais les deux identifiants USB exacts `0xC0F4` et `0x0FF5` avec IOKit HID. Elle ne dépend plus du nom commercial déclaré par le périphérique, qui peut être générique (« Usb KeyBoard »).

## Ce qui n'est pas encore établi

Les identifiants VID/PID suffisent à reconnaître le périphérique, mais ne décrivent pas son protocole de contrôle. Il faut encore examiner les descripteurs HID, les interfaces et les rapports d'entrée/sortie pour savoir si le rétroéclairage est pilotable et si une interception par périphérique est réalisable.

Aucune commande RGB, aucun remappage global et aucune macro exécutée ne sont activés dans cette version. L'état RGB est laissé à « Inconnu » plutôt que d'être inventé.
