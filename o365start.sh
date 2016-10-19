#!/bin/bash
###########################################################################
##       ffff55555                                                       ##
##     ffffffff555555                                                    ##
##   fff      f5    55         Deployment Script Version 0.0.1           ##
##  ff    fffff     555                                                  ##
##  ff    fffff f555555                                                  ##
## fff       f  f5555555             Written By: EIS Consulting          ##
## f        ff  f5555555                                                 ##
## fff   ffff       f555             Date Created: 12/02/2015            ##
## fff    fff5555    555             Last Updated: 01/21/2016            ##
##  ff    fff 55555  55                                                  ##
##   f    fff  555   5       This script will start the pre-configured   ##
##   f    fff       55       WAF configuration.                          ##
##    ffffffff5555555                                                    ##
##       fffffff55                                                       ##
###########################################################################
###########################################################################
##                              Change Log                               ##
###########################################################################
## Version #     Name       #                    NOTES                   ##
###########################################################################
## 11/23/15#  Thomas Stanley#    Created base functionality              ##
###########################################################################
## 09/2/16#  Gregory Coward#    Modified to work with Azure O365         ##
###########################################################################

### Parameter Legend  ###
## devicearr=0 #ismaster true or false
## devicearr=1 #hostname of this device
## devicearr=2 #IP address of this device
## devicearr=3 #login password for the BIG-IP
## devicearr=4 #BYOL License key
## devicearr=5 #master hostname
## devicearr=6 #master address

## vipportarr=0 #port numbers of the BIG-IP VIP semicolon delimited (80;443;8080)

## iapparr=0 #entity ID (ex: https://access.f5demo.net/idp/f5/)
## iapparr=1 #AD domain FQDN
## iapparr=2 #AD domain IP Address
## iapparr=3 #Federated Domain FQDN  (ex: f5demo.net )
## iapparr=4 #Auth SSL Cert .pfx format (should match applcation_fqdn)
## iapparr=5 #Auth Cert Password
## iapparr=6 #application FQDN (ex: access.f5demo.net )
## iapparr=7 #iapp source URL

## Build the arrays based on the semicolon delimited command line argument passed from json template.
IFS=';' read -ra devicearr <<< "$1"    
IFS=';' read -ra vipportarr <<< "$2"    
IFS=';' read -ra iapparr <<< "$3"

## Construct the blackbox.conf file using the arrays.
row1='"1":["'${iapparr[1]}'","'${iapparr[2]}'"]'

deployment1='o365":{"traffic-group": "traffic-group-local-only","strict-updates": "disabled","variables": {"apm__login_domain":"'${iapparr[3]}'", "apm__credentials": "no","apm__log_settings": "/Common/default-log-setting","apm__ad_monitor": "ad_icmp","apm__saml_entity_id": "'${iapparr[0]}'","apm__saml_entity_id_format": "URL","general__assistance_options": "full","general__config_mode": "basic","idp_encryption__cert": "/Common/default.crt","idp_encryption__key": "/Common/default.key","webui_virtual__addr": "'${devicearr[2]}'","webui_virtual__cert": "/Common/default.crt","webui_virtual__key": "/Common/default.key","webui_virtual__port": "6443"},"tables": {"apm__active_directory_servers": {"column-names": [ "fqdn", "addr" ],"rows": { '$row1' }}}}'

jsonfile='{"loadbalance":{"is_master":"'${devicearr[0]}'","master_hostname":"'${devicearr[5]}'","master_address":"'${devicearr[6]}'","master_password":"'${devicearr[3]}'","device_hostname":"'${devicearr[1]}'","device_address":"'${devicearr[2]}'","device_password":"'${devicearr[3]}'"},"bigip":{"application_name":"F5 O365 Federation","application_fqdn":"'${iapparr[6]}'","ntp_servers":"1.pool.ntp.org 2.pool.ntp.org","ssh_key_inject":"false","change_passwords":"false","license":{"basekey":"'${devicearr[4]}'"},"modules":{"auto_provision":"true","ltm":"nominal","afm":"none","asm":"none","apm":"nominal"},"redundancy":{"provision":"false"},"network":{"provision":"false"},"iappconfig":{"f5.microsoft_office_365_idp.v1.1.0":{"template_location":"'${iapparr[7]}'","deployments":{"'$deployment1'}}}}}'

echo $jsonfile > /config/blackbox.conf

## Move the files and run them.
mv ./azureo365.sh /config/azureo365.sh

chmod +w /config/startup
echo "/config/azureo365.sh" >> /config/startup
chmod u+x /config/azureo365.sh
bash /config/azureo365.sh
