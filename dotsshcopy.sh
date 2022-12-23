#!/bin/bash

#Script to copy user directory for multiple servers
#Author: Vinicius Sá
#Date: 22/08/22


[ $# -eq 0 ] && { echo "USAGE: -a ldap_name_user IP1,IP2,IP3"; exit 1; }

FILE=/home/${2}/.ssh/id_rsa.pub
AuthorizedKey=/home/${2}/.ssh/authorized_keys
STRING=`cat /home/${2}/.ssh/id_rsa.pub`
LOGFILE=/var/log/dotsshcopy
USERDOTSSH=/home/${2}/.ssh/


[ -f "$LOGFILE" ] || touch "$LOGFILE"

exec &> >(tee -a "$LOGFILE")

echo "Checking if ${USERDOTSSH} exist"
if [ -d "$USERDOTSSH" ]; then
    echo "$USERDOTSSH exist, continuing "
else
    echo "$USERDOTSSH does not exist, exiting..." && exit 1;
fi


if  grep -q "$STRING" "$AuthorizedKey" ; then
         echo "${STRING} is inside ${AuthorizedKey}" ;
else
         echo "${STRING} is not in ${AuthorizedKey}, sending..." && bash -c "cat $FILE >> $AuthorizedKey" && echo "done" || echo "fail"
fi


while getopts "a:d:" optname
  do
    case "$optname" in
      "a")
          IFS=, # split on space characters
          array=(${3})
          for i in "${array[@]}"; do
                  echo "coping ${USERDOTSSH} for IP ${i}" && sudo rsync -avR /home/./${2} root@${i}:/home  && ssh root@${i} "sudo chown -R ${2}:${2} /home/${2} && chmod 755 /home/${2}"
          done
          ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 255;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
  done
