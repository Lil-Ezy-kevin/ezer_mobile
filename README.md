# Ez'er Services — App mobile (Flutter)

## ⚠️ Version adaptée pour macOS 10.13 (High Sierra)

Ce projet a été ajusté pour rester compatible avec **Flutter 3.3.x**, la
dernière version qui tourne encore sur macOS 10.13 (Flutter 3.7+ exige
10.14 minimum). Concrètement : dépendances abaissées à des versions plus
anciennes, et 4 widgets trop récents remplacés par leurs équivalents
classiques (SegmentedButton → boutons simples, NavigationBar →
BottomNavigationBar, etc.).

**Si un jour tu passes à une machine plus récente**, tu peux revenir aux
dernières versions de Flutter et des dépendances sans souci — rien dans
le code métier n'en dépend.

Télécharge précisément cette version :
```bash
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.3.10-stable.zip
unzip flutter_macos_3.3.10-stable.zip
```
(remplace l'éventuelle installation plus récente déjà faite dans ce dossier)


App mobile native Android + iOS pour la marketplace Ez'er Services,
consommant l'API REST fournie dans le dossier `ezer-api/`.

## ⚠️ Étape indispensable avant de lancer le projet

Ce dossier contient uniquement le **code source** (`lib/`, `pubspec.yaml`).
Les dossiers `android/` et `ios/` (projets natifs générés par Flutter)
ne sont pas inclus car ils doivent être générés par le SDK Flutter installé
sur votre machine. Sans le SDK ici, impossible de les produire à l'avance.

Sur votre ordinateur (avec [Flutter installé](https://docs.flutter.dev/get-started/install)) :

```bash
# 1. Créer un nouveau projet Flutter vide
flutter create ezer_mobile
cd ezer_mobile

# 2. Remplacer pubspec.yaml et le dossier lib/ par ceux fournis ici
#    (écraser les fichiers générés par défaut)

# 3. Installer les dépendances
flutter pub get

# 4. Lancer sur un émulateur / simulateur ou un appareil connecté
flutter run
```

## Configuration de l'URL de l'API

Par défaut l'app pointe vers `http://10.0.2.2:5000/api` (adresse de votre
PC vue depuis un émulateur Android). Adaptez selon votre cas au lancement :

```bash
# Simulateur iOS / Flutter web
flutter run --dart-define=EZER_API_BASE_URL=http://127.0.0.1:5000/api

# Appareil physique (PC et téléphone sur le même Wi-Fi)
flutter run --dart-define=EZER_API_BASE_URL=http://192.168.1.XX:5000/api

# Une fois l'API déployée sur Render
flutter run --dart-define=EZER_API_BASE_URL=https://votre-api.onrender.com/api
```

Pour un build de production, passez la même option à `flutter build apk`
ou `flutter build ios`.

## Comptes de démonstration (mêmes que l'app web)

- Admin : admin@ezerdev.com / Admin123!
- Prestataires : moussa@demo.ezer, ibrahim@demo.ezer, abdou@demo.ezer,
  harouna@demo.ezer, oumar@demo.ezer — mot de passe : Demo123!

## Ce qui est couvert (V1)

- Authentification (inscription / connexion) avec JWT persistant
- Recherche de prestataires (service, ville), profil détaillé, avis
- Envoi d'une demande de service, appel / WhatsApp direct
- Tableau de bord Client (suivi des demandes, paiement simulé)
- Tableau de bord Prestataire (demandes reçues, changement de statut, gains)
- Tableau de bord Admin simplifié (statistiques, vérification des prestataires)
- Notifications

## Pas encore couvert / pistes d'amélioration

- Édition du profil prestataire (photo, bio) depuis le mobile — l'endpoint
  API existe déjà (`POST /api/provider/profile`), il manque juste l'écran
- Admin mobile limité aux stats + vérification ; le reste (paiements,
  export CSV, gestion fine des demandes) reste sur le dashboard web
- Notifications push (actuellement uniquement en liste, à tirer par pull)
- Publication sur Play Store / App Store (icônes, splash natif, signature)
