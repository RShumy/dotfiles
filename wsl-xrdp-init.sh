#!bash/bin/

read -p "Please input the password for sudo commands:" CHANGE_XRDP_INI_PASS
if [ -n "$CHANGE_XRDP_INI_PASS" ];
then 
	
	echo "Value of CHANGE_XRDP_INI_PASS = ${CHANGE_XRDP_INI_PASS}" 
	echo "Changes under way!"
	echo $CHANGE_XRDP_INI_PASS | sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
	PORT="$(grep '3390' /etc/xrdp/xrdp.ini)"
	echo "Value of PORT: ${PORT}"
	BPP="$(grep 'max_bpp=128' /etc/xrdp/xrdp.ini)"
	echo "Value of BPP: ${BPP}"
	XSERVERBPP="$(grep 'xserverbpp=128' /etc/xrdp/xrdp.ini)"
	echo "Value of XSERVERBPP: ${XSERVERBPP}"
	XSTART_EXEC_LINE=$(echo "$(grep 'exec /bin/sh /etc/X11' /etc/xrdp/startwm.sh)") 
	echo "Value lines to comment: ${XSTART_EXEC_LINE}"
	#if [ -z "${PORT}" ]; then
	#	echo "Changing port number to 3390 from 3389"
	#	sudo sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
	#fi
	#if [ -z "$BPP" ]; then 
	#	echo "Setting max_bpp to 128"
	#	sudo sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
	#fi
	#if [ -z "$XSERVERBPP" ]; then
	#	sudo sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini
	#fi
	if [ -n "$XSTART_EXEC_LINE" ]; then
		sudo sed -i -r "s/(.+X11)/#\1/g" /etc/xrdp/startwm.sh
	fi

fi
unset CHANGE_XRDP_INI_PASS
echo "Value of CHANGE_XRDP_INI_PASS after changes = ${CHANGE_XRDP_INI_PASS}" 

