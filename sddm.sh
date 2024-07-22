#!/bin/bash

SDDM=`cat /etc/pam.d/sddm | sed "s/^#%PAM\-1\.0//g"`
SDDM_OUT=""
while IFS= read -r SDDM_LINE
do
	if ( echo $SDDM_LINE | grep auth | grep sufficient | grep pam_fprintd );then
		echo $SDDM_LINE
		continue
	fi
	if ( echo $SDDM_LINE | grep auth | grep try_first_pass );then
		echo $SDDM_LINE
		continue
	fi
	SDDM_OUT="$(cat << EOF
${SDDM_OUT}
${SDDM_LINE}
EOF
)"
done < <(printf '%s\r' "$SDDM")

cat << EOF
#%PAM-1.0
auth [success=1 new_authtok_reqd=1 default=ignore] pam_unix.so try_first_pass likeauth nullok
auth sufficient pam_fprintd.so
$SDDM_OUT
EOF
