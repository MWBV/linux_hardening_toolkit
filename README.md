# linux-hardening-toolkit

![Build](https://github.com/mwbv/linux-hardening-toolkit/actions/workflows/lint.yml/badge.svg)
![Tests](https://github.com/mwbv/linux-hardening-toolkit/actions/workflows/test.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Version](https://img.shields.io/github/v/release/mwbv/linux-hardening-toolkit)
![Shell](https://img.shields.io/badge/shell-bash-89e051.svg)
![Python](https://img.shields.io/badge/python-3.10+-3572A5.svg)

> Suite de scripts Bash et Python pour automatiser le hardening d'une machine Linux.  
> Développé dans le cadre de mes études en cybersécurité — applique les recommandations CIS Benchmark de façon reproductible et documentée.

![Demo](docs/demo.gif)

---

## Table des matières

- [À propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Scripts disponibles](#-scripts-disponibles)
- [Architecture](#-architecture)
- [Tests](#-tests)
- [Ce que j'ai appris](#-ce-que-jai-appris)
- [Auteur](#-auteur)
- [Licence](#-licence)

---

## 📖 À propos

Ce projet est né d'un besoin concret dans mon homelab : chaque fois que je déployais une nouvelle VM sur Proxmox, je refaisais les mêmes étapes manuellement — durcir SSH, configurer le firewall, vérifier les comptes suspects. Ce toolkit automatise l'ensemble de ce processus en une seule commande.

L'objectif n'est pas de remplacer des outils professionnels comme Lynis ou OpenSCAP, mais de comprendre ce qu'ils font en les réimplémentant from scratch, avec du Bash et Python.

---

## ✨ Fonctionnalités

- ✅ **Audit système complet** — CPU, RAM, disque, uptime, users connectés
- ✅ **Audit des utilisateurs** — détecte comptes sans mot de passe, UID 0 non-root, shells suspects
- ✅ **Hardening SSH** — désactive root login, password auth, configure port et timeouts
- ✅ **Configuration firewall** — règles iptables avec politique DROP, sauvegarde de la config existante
- ✅ **Déploiement fail2ban** — configuration jail SSH, rapport d'IPs bannies
- ✅ **Durcissement kernel** — paramètres sysctl sécurité (IP forwarding, ICMP, etc.)
- ✅ **Analyse de logs** — parse auth.log, extrait IPs suspectes, tentatives par force brute
- ✅ **Vérification d'intégrité** — hash SHA256 des fichiers critiques, alerte si modification
- ✅ **Rapport HTML** — synthèse complète générée automatiquement après chaque audit
- 🚧 **Notifications** — webhook Discord en cas d'alerte (en cours)

---

## 🔧 Prérequis

| Dépendance | Version | Installation |
|-----------|---------|-------------|
| Bash | 5.x+ | Inclus Linux |
| Python | 3.10+ | `apt install python3` |
| iptables | any | `apt install iptables` |
| fail2ban | any | installé via `install.sh` |

> ⚠️ **Root requis** pour les scripts de hardening. Toujours tester avec `--dry-run` en premier.

---

## 🚀 Installation

### Installation automatique (recommandée)

```bash
git clone https://github.com/mwbv/linux-hardening-toolkit.git
cd linux-hardening-toolkit
chmod +x install.sh
./install.sh
```

`install.sh` vérifie les dépendances, installe ce qui manque, et configure les permissions.

### Installation manuelle

```bash
git clone https://github.com/mwbv/linux-hardening-toolkit.git
cd linux-hardening-toolkit

# Dépendances Python
pip install -r requirements.txt

# Permissions
chmod +x scripts/*.sh
```

---

## 💻 Utilisation

### Audit complet (recommandé pour débuter)

```bash
sudo ./scripts/run-all.sh
```

Génère un rapport HTML dans `examples/report_YYYY-MM-DD.html`.

### Mode dry-run (simulation sans modification)

```bash
# Tester SSH hardener sans rien modifier
sudo ./scripts/ssh-hardener.sh --dry-run

# Tester firewall sans appliquer les règles
sudo ./scripts/firewall-setup.sh --dry-run
```

### Scripts individuels

```bash
# Audit des utilisateurs
sudo ./scripts/user-audit.sh

# Analyser les logs des dernières 24h
python3 python/log-analyzer.py --file /var/log/auth.log --hours 24

# Vérifier l'intégrité des fichiers critiques
python3 python/hash-checker.py --baseline docs/baseline.json
```

### Exemple de sortie

```
[linux-hardening-toolkit v0.3]
================================
[+] System : Debian GNU/Linux 12 (bookworm) | Kernel 6.1.0
[+] Uptime : 3 days, 4:22
[!] WARNING : 2 accounts found with empty passwords
[!] WARNING : UID 0 account found : toor
[+] SSH     : Hardening applied (root login disabled, port changed)
[+] Firewall: 14 rules applied, policy set to DROP
[+] Fail2ban: 3 IPs currently banned
[✓] Report  : examples/report_2025-04-25.html
```

---

## 📁 Scripts disponibles

### Bash (`scripts/`)

| Script | Description | Sudo requis |
|--------|-------------|:-----------:|
| `system-info.sh` | Collecte CPU, RAM, disque, uptime, users actifs | Non |
| `user-audit.sh` | Détecte comptes sans mot de passe, UID 0, shells suspects | Oui |
| `ssh-hardener.sh` | Désactive root login et password auth, configure timeouts | Oui |
| `firewall-setup.sh` | Règles iptables, politique DROP, sauvegarde config existante | Oui |
| `fail2ban-deploy.sh` | Install + configuration jail SSH + rapport IPs bannies | Oui |
| `sysctl-hardening.sh` | Paramètres kernel sécurité | Oui |
| `cronjob-audit.sh` | Liste crons de tous les users, détecte entrées suspectes | Oui |
| `run-all.sh` | Lance tout, génère rapport HTML | Oui |

### Python (`python/`)

| Script | Description |
|--------|-------------|
| `log-analyzer.py` | Parse auth.log, extrait IPs et tentatives échouées |
| `port-scanner.py` | Scanner TCP basique avec rapport formaté |
| `hash-checker.py` | Vérifie intégrité SHA256 des fichiers critiques |
| `backup-manager.py` | Backup automatique avec rotation et compression |

---

## 🏗️ Architecture

```
linux-hardening-toolkit/
├── scripts/                # Scripts Bash
│   ├── system-info.sh
│   ├── user-audit.sh
│   ├── ssh-hardener.sh
│   ├── firewall-setup.sh
│   ├── fail2ban-deploy.sh
│   ├── sysctl-hardening.sh
│   ├── cronjob-audit.sh
│   └── run-all.sh          # Point d'entrée principal
├── python/                 # Scripts Python
│   ├── log-analyzer.py
│   ├── port-scanner.py
│   ├── hash-checker.py
│   └── backup-manager.py
├── tests/                  # Tests pytest
│   ├── test_log_analyzer.py
│   └── test_hash_checker.py
├── docs/                   # Documentation
│   ├── architecture.md
│   ├── baseline.json       # Hashes de référence
│   └── demo.gif
├── examples/               # Rapports générés
│   └── sample-report.html
├── .github/
│   └── workflows/
│       ├── lint.yml        # ShellCheck à chaque push
│       └── test.yml        # pytest automatique
├── install.sh
├── requirements.txt
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🧪 Tests

```bash
# Lancer tous les tests
pytest tests/ -v

# Avec rapport de couverture
pytest tests/ --cov=python --cov-report=term-missing
```

Les tests utilisent des mocks pour simuler les appels système — ils fonctionnent sans root.

---

## 📚 Ce que j'ai appris

Ce projet m'a permis de consolider plusieurs concepts :

- **Bash avancé** — gestion d'arguments (`getopts`), codes de retour, fonctions réutilisables
- **Sécurité SSH** — comprendre chaque directive de `sshd_config` et ses implications
- **iptables** — différence entre les chaînes INPUT/OUTPUT/FORWARD, politique DROP vs REJECT
- **Python scripting** — argparse pour des CLI propres, hashlib pour la cryptographie de base
- **systemd** — créer des services et timers pour automatiser des tâches récurrentes
- **Tests** — mocker des appels système avec `unittest.mock` pour des tests sans side effects

---

## 👤 Auteur

**Kokou Hegno** — Étudiant AAS Cybersécurité & Administration Systèmes  
Indian Hills Community College — Promotion 2025

- GitHub: [@mwbv](https://github.com/mwbv)
- LinkedIn: [linkedin.com/in/kokouhegno](https://linkedin.com/in/kokouhegno)

---

## 📄 Licence

MIT — voir [LICENSE](LICENSE) pour les détails.
