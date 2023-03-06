#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = '02/09/2023'
#__description__ = 'Select only this stations'

echo
echo "--------------- INIT ----------------"

# Variables list
code_list=('A899' 'A836' 'A802' 'A811' 'A827' 'A878' 'A881' 'A804' 'A838' 'A812' 'A831' 'A832' 'A801' 'A834' 'A886' 'A813' 'A809' 'A826' 'A803' 'A889' 'A884' 'A882' 'A879' 'A808' 'A833' 'A840' 'A897' 'A867' 'A837' 'A829' 'A894' 'A883' 'A830' 'A866' 'A853' 'A814' 'A880' 'A852' 'A815' 'A839' 'A844' 'A845' 'A856' 'A810' 'A805' 'A865' 'A870' 'A828' 'A806' 'A863' 'A854' 'A860' 'A841' 'A868' 'A858' 'A861' 'A817' 'A859' 'A857' 'A876' 'A816' 'A875' 'A864' 'A848' 'A862' 'A851' 'A874' 'A855' 'A843' 'A846' 'A823' 'A873' 'A807' 'B804' 'B806' 'A818' 'A746' 'A819' 'A820' 'A822' 'A872' 'A714' 'A751' 'A715' 'A871' 'A821' 'A752' 'A835' 'A842' 'A824' 'A869' 'A725' 'A750' 'A716' 'A749' 'A849' 'A703' 'A850' 'A718' 'A741' 'A705' 'A709' 'A763' 'A721' 'A707' 'A757' 'A768' 'A737' 'A743' 'A759' 'A723' 'A727' 'A731' 'A758' 'A762' 'A747' 'A734' 'A736' 'A735' 'A754' 'A764' 'A704' 'A748' 'A719' 'A702' 'A756' 'A729' 'A722' 'A733' 'A520' 'A710' 'A519' 'A732' 'A724' 'A717' 'A011' 'A512' 'A507' 'A760' 'A730' 'A616' 'A035' 'A422' 'A016' 'A761' 'A025' 'A405' 'A003' 'A026' 'A909' 'A029' 'A033' 'A933' 'A455')

for code in ${code_list[@]}; do

    echo "Starting to move:" ${code}
    mv /home/nice/Downloads/inmet/dados_${code}_H_* /home/nice/Documentos/FPS_SESA/database/inmet/inmet_used_sesa
    
done

echo
echo "------------- THE END --------------"

