#! /bin/bash 

echo "logging in ..."

echo "Writting the session paramiters in id.txt ..." 
mgmt_cli login -r true  --version 1.2 > id.txt
if [[ $? == 0 ]];then 
	echo "OK";
else 
	echo "FAILED";fi

echo "Adding the gateway object and init SIC ... "
mgmt_cli add simple-gateway name "GW1200R3" ip-address 10.0.103.1 one-time-password Chkp!234 color "red" firewall true vpn true  --version 1.2 -s id.txt
if [[ $? == 0  ]];then 
	echo "OK"; 
else 
	echo "FAILED";fi

echo "geting the current Gateway UID ..."
gw_uid=$(mgmt_cli show simple-gateway name "GW1200R3" --format json --version 1.2 -s id.txt | $CPDIR/jq/jq -r '.uid')

echo "gw uid: "$gw_uid  

echo "Configuring the platform ..."
mgmt_cli set generic-object uid "$gw_uid" svnVersionName "R77.20" cpver "9.0" applianceType "slim_fw" slimFwHardwareType "CIP" osInfo.osName "Gaia Embedded" --version 1.2 -s id.txt
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi 
	
echo "Setting up the Interfaces ..."
mgmt_cli set generic-object uid "$gw_uid" interfaces.add.1.create "com.checkpoint.objects.classes.dummy.CpmiInterface" interfaces.add.1.owned-object.officialname "WAN" interfaces.add.1.owned-object.ifindex "0" interfaces.add.1.owned-object.ipaddr "10.0.103.1" interfaces.add.1.owned-object.security.netaccess.leadsToInternet "true"  interfaces.add.1.owned-object.netmask "255.255.255.0" interfaces.add.2.create "com.checkpoint.objects.classes.dummy.CpmiInterface" interfaces.add.2.owned-object.officialname "LAN1" interfaces.add.2.owned-object.ifindex "1" interfaces.add.2.owned-object.ipaddr "192.168.103.1" interfaces.add.2.owned-object.netmask "255.255.255.0" interfaces.add.2.owned-object.security.netaccess.leadsToInternet "false"  interfaces.add.2.owned-object.security.netaccess.access "THIS" interfaces.add.3.create "com.checkpoint.objects.classes.dummy.CpmiInterface" interfaces.add.3.owned-object.officialname "DMZ" interfaces.add.3.owned-object.ifindex "2" interfaces.add.3.owned-object.ipaddr "10.10.103.1" interfaces.add.3.owned-object.netmask "255.255.255.0" interfaces.add.3.owned-object.security.netaccess.leadsToInternet "false"  interfaces.add.3.owned-object.security.netaccess.dmz "true" interfaces.add.3.owned-object.security.netaccess.access "THIS"  --version 1.2 -s id.txt
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi 

echo "Setting the ecryption domain ..."

vpn_enc_domain=$(mgmt_cli -r true show network name "NET_192.168.103.0" -f json --version 1.2 -s id.txt  |  $CPDIR/jq/jq -r  '.uid')
 
mgmt_cli set generic-object uid "$gw_uid" manualEncdomain "$vpn_enc_domain" encdomain "MANUAL" --version 1.2 -s id.txt  
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi  

echo "Adding the gateway to policy installation targets  ..."
mgmt_cli set package name "1200R_VPN_Policy" installation-targets.add "GW1200R3" --version 1.2 -s id.txt
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi 

echo "Adding the gateway to vpn-sat community group ..."
mgmt_cli set vpn-community-star name "1200R_HQFW_VPN_C" satellite-gateways.add "GW1200R3" --version 1.2 -s id.txt
if [[ $? == 0 ]]; 
then 
	echo "OK";
else 
	echo "FAILED";
fi 

echo "Adding the gateway to ROBO-SG group ..."
mgmt_cli set group name "ROBO-SGs" members.add "GW1200R3" --version 1.2 -s id.txt
if [[ $? == 0 ]]; 
then 
	echo "OK";
else 
	echo "FAILED";
fi

echo "Publishing the session ..." 
mgmt_cli publish --version 1.2 -s id.txt 
if [[ $? == 0 ]];
then 
	echo "Session was polished."
else 
	echo "Session wasn't poblished.";fi 

echo "Installing HQ_FW_Policy policy ..."
mgmt_cli install-policy policy-package "standard" access true threat-prevention false targets.1 "HQ_FW" --version 1.2 -s id.txt
if [[ $? == 0 ]] 
then 
	echo "OK";
else 
	echo "FAILED";
fi


echo "Logging out ..."
mgmt_cli logout -s id.txt
if [[ $? == 0 ]] 
then 
	echo "DONE";
else 
	echo "FAILED";
fi
