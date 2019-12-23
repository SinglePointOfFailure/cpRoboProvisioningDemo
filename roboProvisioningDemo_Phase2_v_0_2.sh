#! /bin/bash 
echo " 		--- Phase 2 ---		"
echo "logging in ..."
echo "Writting the session paramiters in id.txt ..." 
mgmt_cli login -r true  --version 1.2 > id.txt
if [[ $? == 0 ]];then 
	echo "OK";
else 
	echo "FAILED";fi

echo "removing the gateway to policy installation targets  ..."
mgmt_cli set package name "GW1200R1_legacy" installation-targets.remove "GW1200R1" --version 1.2 -s id.txt
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi 
echo "Adding the gateway to policy installation targets  ..."
mgmt_cli set package name "1200R_VPN_Policy" installation-targets.add "GW1200R1" --version 1.2 -s id.txt
if [[ $? == 0 ]];
then 
	echo "OK";
else 
	echo "FAILED";fi 

echo "Removing the gateway to legacy vpn-sat community group ..."
mgmt_cli set vpn-community-star name "GW1200R1_LEGACY_ VPN_C" satellite-gateways.remove "GW1200R1" --version 1.2 -s id.txt
if [[ $? == 0 ]]; 
then 
	echo "OK";
else 
	echo "FAILED";
fi 

echo "Adding the gateway to vpn-sat community group ..."
mgmt_cli set vpn-community-star name "1200R_HQFW_VPN_C" satellite-gateways.add "GW1200R1" --version 1.2 -s id.txt
if [[ $? == 0 ]]; 
then 
	echo "OK";
else 
	echo "FAILED";
fi 

echo "Adding the gateway to ROBO-SG group ..."
mgmt_cli set group name "ROBO-SGs" members.add "GW1200R1" --version 1.2 -s id.txt
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

echo "Installing 1200R_VPN_Policy ..." 
mgmt_cli install-policy policy-package "1200R_VPN_Policy" access true threat-prevention false --version 1.2 -s id.txt
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

