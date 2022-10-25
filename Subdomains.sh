#!/bin/bash

#--------- VARIABLES ------------------
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[31m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"

TIEMPO=5
HILOS=10
STATUS_FILE="status.md"

# Direccion del diccionario de dns-resolvers
DNS_RESOLVER="$HOME/Tools/Wordlist/SecLists/Miscellaneous/dns-resolvers.txt" 
#DNS_RESOLVER="~/Tools/resolvers.txt"

# Diccionario para encontrar subdominios
WORDLIST="$HOME/Tools/Wordlist/SecLists/Discovery/DNS/subdomains-top1million-110000.txt"

# Token Github
GITHUB_TOKEN="<< colocar aque ek token de GITHUB ! >>"



#--------- FUNCIONES ------------------
Logo(){
    echo -e """ ${redColour} 
     ▄▄▄▄▄   ▄   ███   ██▄   ████▄ █▀▄▀█ ██   ▄█    ▄      ▄▄▄▄▄  
    █     ▀▄  █  █  █  █  █  █   █ █ █ █ █ █  ██     █    █     ▀▄ 
  ▄  ▀▀▀▀▄ █   █ █ ▀ ▄ █   █ █   █ █ ▄ █ █▄▄█ ██ ██   █ ▄  ▀▀▀▀▄   
   ▀▄▄▄▄▀  █   █ █  ▄▀ █  █  ▀████ █   █ █  █ ▐█ █ █  █  ▀▄▄▄▄▀   
           █▄ ▄█ ███   ███▀           █     █  ▐ █  █ █            
            ▀▀▀                      ▀     █     █   ██            
                                          ▀                        ${turquoiseColour} 
  =============================================== v0.3 by Phr4nt0m ${endColour}                                                             
"""
}

help() {
    echo -e """
    Uso:
        $0 ${purpleColour}[opcion]${greenColour} [dominio] ${endColour}
    
    ${purpleColour}[opcion]${endColour}
      help  - Menu de ayuda. 
      alive - Checkear de los resultados obtenidos cuales estan vivos.
      all   - Utilizar todas las tools.
     (tool) - sublist3r, subfinder, amass, acamar, assetfinder, 
              crtsh, knockpy, github-subdomains, shuffledns, subscraper
              rapiddns, archive.org, sonar.omnisint.io, oneforall,
              subdomainizer, gospider, favfreak.
   
    ${greenColour}[dominio]${endColour}
        dominio.com 
"""
}
            

# Verifica carpeta de subdominios
Directory() {   
    if ! [ -d "Subdomains" ]; then
        mkdir "Subdomains"
    fi
    cd Subdomains
    Create_Status_File
    DIR_=$(pwd) # directorio actual
}

Create_Status_File(){
    if ! [ -f $STATUS_FILE ]; then
        echo -e "# Reporte de subdominios"
        echo -e "## Dominio: $DOMINIO" >> $STATUS_FILE 
        echo -e "|FECHA|PROGRAMA|DOMINIOS|" >> $STATUS_FILE
        echo -e "|-----|--------|--------|" >> $STATUS_FILE
    fi
}

Alive_File_Check(){
    if ! [ -f "alive.txt" ]; then
        echo -e "Necesitas el archivo 'alive.txt' con una lista de urls validas!" 
        exit
    fi
}

#-----------TOOLS------------------------------------------------------------------------------------
## Sublist3r
Tool_sublist3r(){
    echo -e "${greenColour}[+] ${endColour}Sublist3r ..."
    ARCHIVO=".Sub-sublist3r_$(date +%Y%m%d%H%M).txt" 
    #python3 $HOME/Tools/Recon/Sublist3r/sublist3r.py -d $DOMINIO -o .$ARCHIVO -t $HILOS
    sublist3r -d $DOMINIO -t $HILOS| grep $DOMINIO | grep -v "[-]" | tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | Sublist3r  |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Subfinder
Tool_subfinder(){
    echo -e "${greenColour}[+] ${endColour}Subfinder ..."
    ARCHIVO=".Sub-subfinder_$(date +%Y%m%d%H%M).txt" 
    ~/go/bin/subfinder -d $DOMINIO -o $ARCHIVO -t $HILOS
    echo "| $(date +'%d/%m/%Y %R') | Subfinder  |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## AMASS
Tool_amass(){
    # Amass intel
    echo -e "${greenColour}[+] ${endColour}Amass intel ..."
    ARCHIVO=".Sub-amass-intel_$(date +%Y%m%d%H%M).txt" 
    amass intel -whois -d $DOMINIO | grep $DOMINIO | tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | AMASS intel |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO

    # Amass passive
    echo -e "${greenColour}[+] ${endColour}Amass enum ..."
    ARCHIVO=".Sub-amass-enum_$(date +%Y%m%d%H%M).txt" 
    amass enum --passive -d $DOMINIO | grep $DOMINIO| tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | AMASS enum |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Acamar
Tool_acamar(){
    # Tiene un problema que despues de ciertos usos se bloquean algunos servicios y da error el programa.
    echo -e "${greenColour}[+] ${endColour}Acamar ..."
    ARCHIVO=".Sub-acamar_$(date +%Y%m%d%H%M).txt" 
    cd ~/Tools/Recon/Acamar/
    python3 acamar.py $DOMINIO 2>/dev/null
    sleep 2
    cd $DIR_ # vuelve al directorio actual
    sleep 2
    mv ~/Tools/Recon/Acamar/results/$DOMINIO.txt $ARCHIVO && echo "| $(date +'%d/%m/%Y %R') | Acamar|$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Assetfinder
Tool_assetfinder(){
    echo -e "${greenColour}[+] ${endColour}assetfinder ..."
    ARCHIVO=".Sub-assetfinder_$(date +%Y%m%d%H%M).txt" 
    assetfinder -subs-only $DOMINIO | sort -u | tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | Assetfinder |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Certificado de registros de transparencia - CERT SH
Tool_crtsh(){
    echo -e "${greenColour}[+] ${endColour}Crtsh ..."
    ARCHIVO=".Sub-crtsh_$(date +%Y%m%d%H%M).txt" 
    python  ~/Tools/Recon/crtsh.py/crtsh.py --domain $DOMINIO -r | tee $ARCHIVO
    #curl -s https://crt.sh/\?o\=$DOMAIN\&output\=json | jq -r '.[].common_name' | sed 's/*//g' | sort -u| tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | crtsh |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## knockpy
Tool_knockpy(){
    echo -e "${greenColour}[+] ${endColour}Knockpy ..."
    ARCHIVO=".Sub-knockpy_$(date +%Y%m%d%H%M).txt" 
    python3 ~/Tools/Recon/KnockV3/knockpy.py -c $DOMINIO
    cat *.csv | awk -F"," '{print $4}'| sort -u | tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | Knockpy |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Github-subdomain.py
Tool_github-subdomains(){
    echo -e "${greenColour}[+] ${endColour}Github-subdomains ..."
    ARCHIVO=".Sub-github-subdomains_$(date +%Y%m%d%H%M).txt" 
    python3 ~/Tools/Recon/github-search/github-subdomains.py -d $DOMINIO -t $GITHUB_TOKEN | tee $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | Github-subdomains |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}


## Shuffledns  # REVISARR !!!
Tool_shuffledns(){
    echo -e "${greenColour}[+] ${endColour}Shuffledns ..."
    ARCHIVO=".Sub-shuffledns_$(date +%Y%m%d%H%M).txt" 
    shuffledns -d $DOMINIO -w $HOME/Tools/Wordlist/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -r $HOME/Tools/Wordlist/SecLists/Miscellaneous/dns-resolvers.txt -o $ARCHIVO -v
    echo "| $(date +'%d/%m/%Y %R') | Shuffledns |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## SubScraper
Tool_subscraper(){
    echo -e "${greenColour}[+] ${endColour}Subscraper ..."
    ARCHIVO=".Sub-subscraper_$(date +%Y%m%d%H%M).txt" 
    python3 ~/Tools/Recon/subscraper/subscraper.py $DOMINIO -T $HILOS -o $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | Subscraper |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Rapiddns  
Tool_rapiddns(){
    echo -e "${greenColour}[+] ${endColour}Rapiddns ..."
    ARCHIVO=".Sub-rapiddns_$(date +%Y%m%d%H%M).txt" 
    curl -s "https://rapiddns.io/subdomain/$DOMINIO?full=1#result" | grep $DOMINIO |sed 's/<\/td>/\n/g'|sed 's/<td>/\n/g' | grep -v "<" | sort -u| tee -a $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | rapiddns |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Archive.org
Tool_archive.org(){
    echo -e "${greenColour}[+] ${endColour}Archive.org ..."
    ARCHIVO=".Sub-archive.org_$(date +%Y%m%d%H%M).txt" 
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$DOMINIO/*&output=text&fl=original&collapse=urlkey"  | sed -e 's_http*://__' -e "s/\/.*//" | sort -u | tee -a $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | archive.org |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Sonar.omnisint.io   
Tool_sonar.omnisint.io(){
    echo -e "${greenColour}[+] ${endColour}Sonar.omnisint.io ..."
    ARCHIVO=".Sub-sonar.omnisint.io_$(date +%Y%m%d%H%M).txt" 
    curl -s "https://sonar.omnisint.io/subdomains/$DOMINIO" |grep -oE "[a-zA-Z0-9._-]+\.$DOMINIO" | sort -u | tee -a $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | sonar.omnisint.io|$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

Tool_oneforall(){
## OneForAll
    echo -e "${greenColour}[+] ${endColour}One For All ..."
    ARCHIVO=".Sub-oneforall_$(date +%Y%m%d%H%M).txt" 
    python3 ~/Tools/Recon/OneForAll/oneforall.py --target $DOMINIO --path oneforall run
    cat oneforall | awk -F "," '{print $6}' | sort -u |grep $DOMINIO > $ARCHIVO
    echo "| $(date +'%d/%m/%Y %R') | OneForAll |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Subdomainizer 
Tool_subdomainizer(){
    echo -e "${greenColour}[+] ${endColour}Subdomainizer ..."
    ARCHIVO=".Sub-Subdomainizer_$(date +%Y%m%d%H%M).txt" 
    python3 $HOME/Tools/Recon/SubDomainizer/SubDomainizer.py -l alive.txt -d $DOMINIO -o $ARCHIVO -cop subdomainizer_cloud.results 
    echo "| $(date +'%d/%m/%Y %R') | Subdomainizer |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## GoSpider
Tool_gospider(){
    echo -e "${greenColour}[+] ${endColour}Gospider ..."
    ARCHIVO=".Sub-gospider_$(date +%Y%m%d%H%M).txt" 
    gospider -S alive.txt -c 10 -d 1 -t 10 -o gospider -r 
    sleep $TIEMPO
    # Reorganizando la salida
    # Urls
    cat gospider/* | grep "\[url\]" | cut -d"-" -f 4-20| grep $DOMINIO | sort -u | tee $ARCHIVO
    # linkfinder
    cat gospider/* | grep "\[linkfinder\]" | grep $DOMINIO | cut -d "-" -f 2-20 | tee -a $ARCHIVO
    cat gospider/* | grep "\[robots\]" | grep $DOMINIO | cut -d"-" -f 2-10| sort -u | tee -a $ARCHIVO
    # form
    cat gospider/* | grep "\[form\]" | grep $DOMINIO | cut -d"-" -f 2-10| sort -u | tee -a $ARCHIVO
    # Ordena la lista eliminado repetidos
    sort -u $ARCHIVO -o .gospider.tmp ; mv .gospider.tmp $ARCHIVO
    # all javascript files
    cat gospider/* | grep "\[javascript\]" | cut -d"-" -f 2-20 | sort -u | tee JS-Gospider.txt
    echo "| $(date +'%d/%m/%Y %R') | Gospider |$(wc -l $ARCHIVO | cut -d' ' -f1) | " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

## Favfreak
Tool_favfreak(){
    echo -e "${greenColour}[+] ${endColour}Favfreak ..."
    ARCHIVO=".Sub-favfreak_$(date +%Y%m%d%H%M).txt" 
    cat alive.txt | python3 $HOME/Tools/Recon/FavFreak/favfreak.py | tee .favfrek.tmp
    sleep $TIEMPO
    cat .favfrek.tmp | cut -d"'" -f 2| grep $DOMINIO | cut -d "/" -f 3 | cut -d ":" -f 1 | sort -u  > $ARCHIVO
    rm .favfrek.tmp
    echo "| $(date +'%d/%m/%Y %R') | favfreak |$(wc -l $ARCHIVO | cut -d' ' -f1)| " >> $STATUS_FILE
    ARCHIVO=""
    sleep $TIEMPO
}

alive(){
    echo -e "${greenColour}[+] ${endColour}Check Alive ..."
    cat .Sub-*.txt | grep $DOMINIO | sort -u  > Subdomains.txt 
    cat Subdomains.txt | httpx -silent -td -sc -title -ip -o alive.info.json -json -rl 50 
    cat alive.info.json | jq .url | sed 's/"//g' | sort -u >> alive.txt
    cat alive.info.json | jq .host | sed 's/"//g' | sort -u >> ip_list.txt
    cat Subdomains.txt | httpx  -ports 81,8443,8000,8001,8080,8181 -silent -sc -td -title -ip -o OthersPortsAlive.json -json
    cat OthersPortsAlive.json | jq .url | sed 's/"//g'| sort -u >> OthersPortsAlive.txt
}


#-------------------------------------------------------------------------------------
Logo
if [[ -z $1 ]]; then 
    echo -e """
    Uso:   $0  all dominio.com
    Menu ayuda: $0 help
    """
elif [[ $1 == "help" ]]; then
    help     
elif [[ $# -eq 2 ]]; then
    OPCION=$1
    DOMINIO=$2
    echo "Dominio: $DOMINIO"
    case $OPCION in
        all)                Directory; Create_Status_File;Tool_sublist3r; Tool_subfinder; Tool_amass; Tool_acamar; Tool_assetfinder; Tool_crtsh; Tool_knockpy; Tool_github; Tool_shuffledns; Tool_subscraper; Tool_rapiddns; Tool_archive.org; Tool_sonar.omnisint.io; Tool_oneforall; alive; Tool_subdomainizer; Tool_gospider; Tool_favfreak; alive;;
        alive)              alive;;           
        sublist3r)          Tool_sublist3r;;
        subfinder)          Tool_subfinder;;
        amass)              Tool_amass;;
        acamar)             Tool_acamar;;
        assetfinder)        Tool_assetfinder;;
        crtsh)              Tool_crtsh;;
        knockpy)            Tool_knockpy;;
        github-subdomains)  Tool_github-subdomains;;
        shuffledns)         Tool_shuffledns;;
        subscraper)         Tool_subscraper;;
        rapiddns)           Tool_rapiddns;;
        archive.org)        Tool_archive.org;;
        sonar.omnisint.io)  Tool_sonar.omnisint.io;;
        oneforall)          Tool_oneforall;;
        subdomainizer)      Alive_File_Check; Tool_subdomainizer;;
        gospider)           Alive_File_Check; Tool_gospider;;
        favfreak)           Alive_File_Check; Tool_favfreak;;
        *)                  echo "Argumento no valido!";;
    esac
else
    echo "opcion no valida"
fi
