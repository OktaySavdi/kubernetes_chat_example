#!/bin/bash
###############################################################
##  Name:  Oktay SAVDI
##  Date:  01.03.2020
###############################################################

#Folder for certificate
CertFolder="/opt/certificate"

#Namespace name
Namespace=oto

#Kibana certificate
KeyFile=kibana.key
CertFile=kibana.cert

#elastic Operator URL - https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html
ElasticURL=https://download.elastic.co/downloads/eck/1.0.1/all-in-one.yaml

#Node IP
NODE=$(kubectl get nodes --selector='!node-role.kubernetes.io/master' -o=jsonpath='{range .items[0]}{.status.addresses[0].address}{"\n"}{end}' )

#Change to your company details
country=TR
state=TR
locality=Istanbul
organization=OS
organizationalunit=OS
CommonName=kibana.$NODE.nip.io
email=OS@OktaySavdi.com

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
Bold=$(tput bold)
Normal=$(tput sgr0)

###### Install Elasticsearch CRD #######
printf  "${Yellow} Create Elasticsearch CRD\n ${Color_Off}"
 {
        kubectl apply -f $ElasticURL
        printf  "${Green}✓${Color_Off} Elasticsearch installed\n"
}  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
      }
while [[ $(kubectl get pods -n elastic-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done
#while [[ $(kubectl get pods -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True" ]]; do printf "." && sleep 1; done
#while [[ $(kubectl get pods elastic-operator-0 -n elastic-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
#while [[ $(kubectl get pods -l control-plane=elastic-operator -n elastic-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done

###### Create Namespace #######
printf  "${Yellow} Create Namespace\n ${Color_Off}"
 {
        kubectl create ns $Namespace
        printf  "${Green}✓${Color_Off} Namespace Created\n"
}  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
      }

###### Install Elasticsearch #######
printf  "${Yellow} Install Elasticsearch\n ${Color_Off}"
 {
        kubectl create -f elasticsearch.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} Elasticsearch installed\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
while [[ $(kubectl get pods -l elasticsearch.k8s.elastic.co/statefulset-name=elasticsearch-es-default -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done

###### Create Folder #######
printf  "\n${Yellow} Create Folder\n ${Color_Off}"
  {
        [ ! -d "$CertFolder" ] && mkdir $CertFolder
        printf  "${Green}✓${Color_Off} Folder Created\n"
    } || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }

###### Create Certificate #######
printf  "${Yellow} Create Certificate\n ${Color_Off}"

 {
    #Generate a key
    openssl req -newkey rsa:2048 -nodes -keyout $CertFolder/$KeyFile -x509 -days 365 -out $CertFolder/$CertFile -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$CommonName/emailAddress=$email" > /dev/null 2>&1
    printf  "${Green}✓${Color_Off} Certificate Created\n"
}  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }

###### Create Secret For Kibana Certificate #######
printf  "${Yellow} Secret Certificate\n ${Color_Off}"
 {
    kubectl create secret tls tls-k8s-kibana-ingress --cert=$CertFolder/$CertFile --key=$CertFolder/$KeyFile -n $Namespace
    printf  "${Green}✓${Color_Off} Certificate Secret\n"
}  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }

###### Install Kibana #######
printf  "${Yellow}-${Color_Off} Installing Kibana"
 {
        kubectl create -f kibana.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} Kibana installed\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
while [[ $(kubectl get pods -l kibana.k8s.elastic.co/name=kibana -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done


###### Retriving Kibana Password #######
printf  "\n${Yellow} Retriving Kibana Password\n ${Color_Off}"

KibanaPASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n $Namespace -o=jsonpath='{.data.elastic}' | base64 --decode)
 {
        kubectl create secret generic elastic-secret --from-literal=es_username=elastic --from-literal=es_password=$KibanaPASSWORD -n $Namespace
        printf  "${Green}✓${Color_Off} Secret Created\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
printf  "Kibana username: ${Cyan}elastic \n ${Color_Off}"
printf  "Kibana password: ${Cyan}$KibanaPASSWORD \n ${Color_Off}"

###### Install RabbitMQ #######
printf  "${Yellow} Installing RabbitMQ\n ${Color_Off}"

 {
        kubectl create -f rabbitmq.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} RabbitMQ installed\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
while [[ $(kubectl get pods -l run=rabbitmq -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done

###### Install Redis #######
printf  "\n${Yellow} Installing Redis\n ${Color_Off}"

 {
        kubectl create -f redis.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} Redis installed\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
while [[ $(kubectl get pods -l run=redis -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done

###### ConfigMap #######
printf  "\n${Yellow} Create ConfigMap\n ${Color_Off}"

 {
        kubectl create -f configmap.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} ConfigMap Created\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }

###### Chat #######
printf  "${Yellow} Chat Install\n ${Color_Off}"

 {
        kubectl create -f chat.yaml -n $Namespace
        printf  "${Green}✓${Color_Off} Chat installed\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }
while [[ $(kubectl get pods -l app=chat -n $Namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do printf "." && sleep 1; done

###### Install Ingress #######
printf  "\n${Yellow} Installing Ingress\n ${Color_Off}"

 {
        sed "s/NODE/$NODE/g" ingress.yaml | kubectl apply -n $Namespace -f -
        printf  "${Green}✓${Color_Off} ingress Created\n"
    }  || {
        printf "${Red}x${Color_Off} Nested Caught (@ $__EXCEPTION_LINE__)\n"
        exit 1
    }

array=( chat rabbit kibana )
for i in "${array[@]}"
do
    URL=$(kubectl get ingresses $i -n $Namespace -o=jsonpath='{.spec.rules[*].host}')
	printf  "$i   URL: ${Cyan}$URL \n ${Color_Off}"
done