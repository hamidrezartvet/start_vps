
sshpass -p "H@midrezart1vet" ssh -o "StrictHostKeyChecking=no" root@194.26.232.71 "sudo touch true.php && \
 secondLine=$(free -g | sed -n '2p') && \
 ls
"

