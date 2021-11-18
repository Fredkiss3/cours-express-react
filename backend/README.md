# Backend du Cours Express/React

## Prérequis:

- node >= 16.6.2
- MySQL/MariaDB >= 5.x

## Comment lancer le projet ?

### 1 - Il faut lancer la base de données en amont

pour cela, vous devez :
    
- Créer une base de données du nom de votre choix  
- Récupérer le fichier `ragnarok.sql` et le lancer dans cette base de données créée

### 2 - modifier le fichier `src/config/dev.env` pour correspondre à la base de données

```dotenv
# Port du serveur
PORT=3000

# Base de données
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
DB_NAME=ragnarok
```


### 3 - Installer les dépendances

```bash
npm install
```


### 4 - Lancer le serveur

```bash
npm run start
```

### 5 - Pour lancer le serveur en production

```bash
# Compilation du projet
npm run build 

# Lancement du serveur
npm run start
```
