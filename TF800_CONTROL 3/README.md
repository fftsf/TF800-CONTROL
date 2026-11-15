# TF800 CONTROL — macOS native project

Version de départ : 0.1.0 — cible minimale macOS Ventura 13.0.

Ce dépôt contient un projet SwiftUI natif, pas un site web. Il est destiné à être ouvert dans Xcode sur un Mac.

## État réel de cette livraison

**Déjà implémenté dans le code :**
- Interface SwiftUI sombre avec navigation Accueil / Touches / Éclairage / Profils / Macros / Mises à jour.
- Les deux visuels fournis ont été recadrés pour présenter le clavier allumé et éteint.
- Détection USB HID par les identifiants exacts relevés sur le clavier : VID `0xC0F4` / PID `0x0FF5`. L’indicateur n’est pas forcé à connecté.
- Profils locaux JSON : création, sélection, renommage et suppression (au moins un profil conservé).
- Enregistrement local des affectations de touches et de séquences de macros.
- Les commandes RGB et l'exécution des macros restent désactivées tant que le protocole et les capacités du clavier ne sont pas vérifiés.

**Pas encore implémenté / non validé :**
- Aucun remappage clavier actif au niveau de macOS. Les affectations sont actuellement sauvegardées uniquement. Un CGEventTap seul ne sait pas identifier de façon fiable quel clavier physique a émis une frappe ; l'utiliser ici risquerait de remapper aussi le clavier intégré ou un autre clavier. Une solution par périphérique (HID/driver/virtual HID) doit être validée avant activation.
- Aucune commande d'éclairage : le protocole USB propriétaire et les commandes de l'appareil ne sont pas connus.
- Pas de firmware updater ni de serveur de mises à jour.
- Pas de signature Developer ID / notarisation Apple.
- Projet non compilé et non testé dans cette livraison : l'environnement de génération actuel n'est pas macOS et ne contient pas Xcode.

## Compilation sur un Mac

1. Décompresser le dossier du projet.
2. Ouvrir `TF800Control.xcodeproj` avec Xcode.
3. Choisir le schéma `TF800 CONTROL` et une destination `My Mac`.
4. Compiler avec macOS 13.0 minimum.
5. Pour produire un DMG universel local : ouvrir Terminal dans le dossier du projet et lancer `./Scripts/build-macos.sh`.

Le script produit `TF800_CONTROL_Installer.dmg` et une app dans `build/DerivedData/Build/Products/Release/`.

## Autorisations macOS

La détection HID standard est distincte de l'autorisation Accessibilité. Cette version n'installe aucun pilote et ne demande pas encore l'autorisation Accessibilité, car elle n'effectue pas de remappage global. Si une future version utilise un mécanisme d'interception compatible, elle devra expliquer précisément l'autorisation demandée et ne l'activer qu'après validation de la solution par périphérique.

## Informations nécessaires pour finaliser le support matériel

Les identifiants USB ont été relevés : VID `0xC0F4`, PID `0x0FF5`. Il reste à examiner sur un Mac ses interfaces HID, rapports et éventuels échanges de contrôle. La simple photo ne permet pas de déduire ces données ni le protocole RGB. Ne pas envoyer de firmware ou de commandes supposées au clavier.

## Compiler sans installer Xcode sur son Mac (GitHub Actions)

Le dépôt inclut `.github/workflows/build-macos.yml`. Après avoir placé le contenu du dossier `TF800_CONTROL` dans un dépôt GitHub :

1. Ouvrir l'onglet **Actions** du dépôt.
2. Sélectionner **Build TF800 CONTROL for macOS**.
3. Cliquer sur **Run workflow**.
4. À la fin, ouvrir l'exécution terminée et télécharger l'artefact **TF800-CONTROL-macOS**.

Le build est effectué sur une machine macOS hébergée par GitHub : Xcode n'a donc pas besoin d'être installé localement. L'application obtenue est non signée et non notarisée dans cette configuration ; macOS peut demander une confirmation lors de la première ouverture. Ce workflow n'a pas encore été exécuté dans cette livraison.
