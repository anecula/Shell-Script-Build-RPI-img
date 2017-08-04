#!/bin/bash -e

ValidatorPath=busticket/Validator_RPI
ImagePath=rpi
base=~/imagine

pwd
cd ${ValidatorPath}
#- Sa citeasca versiunea curenta de software folosind comanda ```git describe```
git describe
version=$(git describe | head -n 1 |perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
echo ${version}
#- Sa genereze pachetul debian cu versiunea respectiva de software
cd debian
#1 update changelog
echo 'validator ('${version}') RELEASED; urgency=medium

  * Updated storage paths.

 -- ionut <ionut@devicehub.ro>  Wed, 22 Mar 2017 16:23:58 +0200

' > changelog

#2 generare pachet
pwd
cd ..
if [ ! -f  validator_${version}_armhf.deb ]; then
	sudo dpkg-buildpackage -rfakeroot -D -us -uc -aarmhf
fi

filename=~/imagine/busticket/Validator_RPI/debian/changelog
line=$(head -n 1 ${filename})
echo ${line}
pwd
#version=$(cat changelog | head -n 1 |perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
cd ..

#- Sa actualizeze pachetul debian din repo-ul rpi

if [ validator_${version}_armhf.deb ]; then
	cd ${base}/${ImagePath}/stage3/02-extras/files/
        pwd
	if [ -f validator_* ]; then
		sudo rm validator_*
        
	else
        	cd -
        	cp validator_${version}_armhf.deb  ${base}/${ImagePath}/stage3/02-extras/files/
	fi

fi

echo 'Verificam daca s-a actualizat pachetul debian din repo-ul rpi'
if [ -f ${base}/${ImagePath}/stage3/02-extras/files/validator_${version}_armhf.deb ]; then
	echo 'Pachetul s-a actualizat'
fi

cd ${base}/${ImagePath}
pwd
sudo ./build.sh
IMG_DATE=$(date -u +%Y-%m-%d)
IMG_NAME=Rapbian-SV-lite
if [ -f work/${IMG_DATE}-Rapbian-SV/export-image/${IMG_DATE}-${IMG_NAME}.img ] ;then
	cd ${base}/${ImagePath}
	zip ${IMG_DATE}-${IMG_NAME}.zip  work/${IMG_DATE}-Rapbian-SV/export-image/${IMG_DATE}-${IMG_NAME}.img
	ls
fi
	
echo 'Success'