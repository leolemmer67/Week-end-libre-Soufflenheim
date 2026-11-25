# 🎣 Week-End libre — Section Carpe de Soufflenheim

Site de réservation des postes de pêche pour les week-ends libres à l'étang du Landgraben.

🌐 Site en ligne : https://week-end-libre-soufflenheim.vercel.app

## Fonctionnalités

- Choix d'une session et d'un poste sur le plan interactif de l'étang (10 postes)
- Disponibilité des postes en temps réel
- Formulaire de réservation, règlement via PayPal
- Espace administration : création des sessions, liste et suppression des réservations, blocage manuel d'un poste
- Page de positionnement des postes par glisser-déposer

## Technique

- Pages HTML statiques : `index.html` (public), `admin.html`, `positionnement.html`
- Base de données et connexion des administrateurs : [Supabase](https://supabase.com)
- Hébergement : Vercel (déploiement automatique à chaque modification sur GitHub)

## Sécurité

- **Aucun mot de passe n'est stocké dans le code.** Les administrateurs se connectent avec un compte Supabase (email + mot de passe), géré dans Supabase → *Authentication → Users*.
- Les droits sont appliqués par la base elle-même (Row Level Security) : un visiteur peut voir quels postes sont pris et réserver, mais ne peut ni lire les coordonnées des autres clients, ni modifier ou supprimer quoi que ce soit.
- Le script de configuration est dans [`supabase/securite.sql`](supabase/securite.sql).
- La clé Supabase présente dans les pages est la clé publique « anon » : elle est faite pour être visible, la protection repose sur les règles de la base.

### Ajouter un administrateur

Supabase → *Authentication → Users → Add user → Create new user* (email + mot de passe, cocher *Auto Confirm User*).

### Désactiver les inscriptions publiques

Supabase → *Authentication → Sign In / Providers* → désactiver *Allow new users to sign up*, pour que personne ne puisse se créer un compte administrateur.

## Structure de la base

| Table | Contenu |
|---|---|
| `sessions` | `id`, `nom`, `date_debut`, `date_fin`, `active` |
| `reservations` | `id`, `session_id`, `poste_numero`, `nom_client`, `email_client`, `telephone_client`, `paypal_order_id`, `created_at` |
| `postes_config` | `poste_id`, `pos_x`, `pos_y` (position en % sur le plan) |
