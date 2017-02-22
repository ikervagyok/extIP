#!/run/current-system/sw/bin/bash

if [ -f ~/.extIP ]
  then
    oldIP="$(< ~/.extIP)"
  else
    oldIP="0.0.0.0"
fi
newIP=`curl http://ipecho.net/plain; echo`

sendMail() {
  echo -e "IP-Address\n${newIP}" | sendmail -r "admin@microserver (Microserver)" ikervagyok@gmail.com
}

writeIP() {
  echo "${newIP}" > ~/.extIP
}

if [ "${oldIP}" != "${newIP}" ]
  then
    sendMail
    writeIP
fi

