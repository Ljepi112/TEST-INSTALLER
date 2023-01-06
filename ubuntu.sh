#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

source tools/colors.sh

rm -rf /var/lib/dpkg/lock
rm -rf /var/cache/debconf/*.*

echo -e "\n\n$Purple Priprava okolja za namestitveni program ... $Color_Off"
echo "============================================="

check_locale() {

    echo -e "\n$Cyan Nastavitev UTF8 ...$Color_Off"

    apt-get -qq update
    apt-get install -qq language-pack-en-base > /dev/null
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    apt-get install -qq software-properties-common > /dev/null

    echo -e "$IGreen OK $Color_Off"
}

# Adds PPA's
add_ppa() {
    echo -e "\n$Cyan Dodajanje repositorije PPA ... $Color_Off"

    for ppa in "$@"; do
        add-apt-repository -y $ppa > /dev/null 2>&1
        check $? "Dodajanje $ppa Ni uspela!"
    done

    echo -e "$IGreen OK $Color_Off"
}

# Installs Environment Prerequisites
add_pkgs() {
    # Update apt
    echo -e "\n$Cyan Posodabljanje paketov ... $Color_Off"

    apt-get -qq update
    check $? "Posodabljanje paketov ni uspelo!"

    echo -e "$IGreen OK $Color_Off"

    # PHP
    echo -e "\n$Cyan Namestitev PHP ... $Color_Off"

    apt-get install -qq curl debconf-utils php-pear php8.2-curl php8.2-dev php8.2-gd php8.2-mbstring php8.2-zip php8.2-mysql php8.2-xml php8.2-fpm php8.2-intl php8.2-bcmath php-redis > /dev/null
    apt-get purge -y '^php7.4.*' > /dev/null
    check $? "Namestitev PHP ni uspela!"

    echo -e "$IGreen OK $Color_Off"
}

# Installs Composer
install_composer() {
    echo -e "\n$Cyan Nameščanje skladatelja ... $Color_Off"

    php -r "readfile('http://getcomposer.org/installer');" | sudo php -- --install-dir=/usr/bin/ --filename=composer > /dev/null
    check $? "Namestitev skladatelja ni uspelo!"

    echo -e "$IGreen OK $Color_Off"
}

# Adds installer packages
installer_pkgs() {
    echo -e "\n$Cyan Dodajanje namestitvenih paketov ... $Color_Off"

    composer install -q > /dev/null 2>&1
    check $? "Dodajanje namestitvenih paketov ni uspelo!"

    echo -e "$IGreen OK $Color_Off"
}

# Checks the returned code
check() {
    if [ $1 -ne 0 ]; then
        echo -e "$Red NAPAKA: $2 \n Poskusite znova zagon skripta prek 'sudo ./install.sh' $Color_Off"
        exit $1
    fi
}

check_locale

add_ppa ppa:linuxuprising/libpng12 ppa:ondrej/php

add_pkgs

install_composer

installer_pkgs

echo -e "\n$Purple Zagon namestitvenega programa ... $Color_Off"
echo "============================================="
php artisan install
