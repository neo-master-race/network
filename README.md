# Network

## Elixir 

Nous avons décidé d'utiliser le langage de programmation [Elixir](https://elixir-lang.org) plutôt que l'API réseau d'[Unity](https://unity3d.com/fr/) pour : 

  1. apprendre un nouveau langage,
  2. prendre de l'avance en cours de _Systèmes Distribués_ où le langage ([erlang](http://www.erlang.org/) a été abordé (langage sur lequel est basé Elixir),
  3. profiter de la puissance de ce langage : peu de ressources utilisées pour beaucoup de performance.

Elixir est multi-paradigme ; il supporte les programmations :

  * fonctionnelle,
  * concurrente,
  * temps réel,
  * distribuée.

Ce langage de programmation fonctionne sur la machine virtuelle Erlang.
Ainsi, Elixir profite de la faible latence des systèmes qui sont distribués et tolérants aux pannes, mais est aussi puissant dans les domaines de l'embarqué et du web.

### Installation

Plusieurs manières d'[installer Elixir](https://elixir-lang.org/install.html) sont mises à disposition.
La dernière version d'Elixir est la 1.6.1. Elle nécessite Erlang 19 ou 20.

Nous vous conseillons fortement d'installer Elixir depuis les sources.

Il est important de souligner que les dépôts ne contiennent pas systématiquement la dernière version du langage (notamment pour Fedora / RHEL / CentOS / EPEL), dans ce cas, préférez installer Elixir depuis les sources).

Une fois l'installation faite, vérifier votre version d'Elixir `elixir --version`.

#### Distribution

Utilisez simplement le système de gestion des paquets de votre distribution.
Notez que les paquets disponibles pour Fedora / RHEL / CentOS / EPEL / Raspberry Pi contiennent une ancienne version d'Elixir / Erlang. Préférez donc, pour ces distributions, l'installation depuis les sources ([Elixir](https://github.com/elixir-lang/elixir) et [Erlan](https://github.com/erlang/otp)).

##### Ubuntu 14.04 à 17.04 ou Debian 7 à 9

```
$ wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
$ sudo apt-get update
$ sudo apt-get install esl-erlang
$ sudo apt-get install elixir
```

##### Arch Linux (Community repo)
```
$ pacman -S elixir
```

Pour toutes autres distributions, voir la [documentation officielle d'Elixir sur son installation](https://elixir-lang.org/install.html#distributions).

#### [Paquets pré-compilés](https://elixir-lang.org/install.html#precompiled-package)

  1. Installez [Erlang](http://erlang.org/doc/installation_guide/INSTALL.html).
  2. Téléchargez et dézippez le [paquet](https://github.com/elixir-lang/elixir/releases/download/v1.6.1/Precompiled.zip).
  3. Ajoutez le bin path d'Elixir dans votre variable d'environnement PATH : `export PATH="$PATH:/usr/bin"`.

#### Gestionnaire de versions

Des outils permettent l'installation et la gestion de plusieurs versions d'Erlang et/ou d'Elixir :

  * asdf (Elixir et Erlang)
  * xenv (Elixir)
  * iex (Elixir)
  * erl (Erlang)

Pour l'installation de la dernière version d'Elixir sur Fedora, il existe [cette solution vec asdf](https://github.com/asdf-vm/asdf).

#### Sources

  1. Installez [Erlang](https://github.com/erlang/otp) (19 ou 20)
  `$ git clone https://github.com/erlang/otp.git`  
  `$ cd otp`  
  `$ ./otp_build autoconf`  
  `$ ./configure`  
  `$ make`  
  `$ mke install`  
  2. Installez [Elixir](https://elixir-lang.org/install.html#compiling-from-source-unix-and-mingw)
    1. Depuis git
  `$ git clone https://github.com/elixir-lang/elixir.git`  
  `$ cd elixir`  
  `$ make clean test`  
    2. Depuis un [.zip](https://github.com/elixir-lang/elixir/archive/v1.6.1.zip) ou [.tar.gz](https://github.com/elixir-lang/elixir/archive/v1.6.1.tar.gz), dézippez, allez dans lee dossier nouvellement créé et y lancez `$ make`
  3. Ajoutez le bin path d'Elixir dans votre variable d'environnement PATH : `export PATH="$PATH:/usr/local/bin"`.

### Lancement du projet

#### iex ; en mode intéractif
#### Avec mixgit clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.2

### Mix format

Note : Pour plus d'informations, consultez le [site officiel d'Elixir](https://elixir-lang.org/).

