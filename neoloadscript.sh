#!/bin/bash

set -e -x


export PATH=$PATH:$NEOLOADPATH
export PATH=$PATH:$NEOLOADPATH1
mkdir /usr/local/share/Neoloadresults
NeoLoadCmd -checkoutProject "$PROJECT" -launch "$SCENARIO" -noGUI -NTS "$NTS" -NTSLogin "$NTSLOGIN" -leaseLicense "$LEASELICENSE" -exit -NTSCollabPath "/$NTSCOLLABPATH" -report /usr/local/share/Neoloadresults/report.html,/usr/local/share/Neoloadresults/report.xml -SLAJUnitResults /usr/local/share/Neoloadresults/junit-sla-results.xml -SLAJUnitMapping pass
python ci/scripts/junitslaconversion.py
mv /usr/local/share/Neoloadresults/* neoloadouput
