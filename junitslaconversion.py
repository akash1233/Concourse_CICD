
# coding: utf-8

# # Code to convert Neoload Junitsla custom report to Junit Schema

# #Importing ElementTree package and input file

# In[9]:

import xml.etree.ElementTree as ET
#Importing the Neoload junit sla file
tree = ET.parse('/usr/local/share/Neoloadresults/junit-sla-results.xml')
#tree = ET.parse('testsuites_allslas.xml')


# #Update root tag and attributes

# In[10]:

#main root directory
#Remove the root attribute and update the root tag to testsuites to follow junit schema
root = tree.getroot()
root.attrib.pop('name', None)
root.tag = "testsuites"
#print (root.tag)
#print(root.attrib)



# #Create dictionary to hold sucess and failure

# In[11]:

#Dictionary to hold success and failure
testdetail = {}

#Create dictionary to hold testsuite name and associated count of success and failure
#For example
#com.neotys.ResponseErrorPercentage.PerRun.BoxTruck_02__resService_14success = 2
#com.neotys.ResponseErrorPercentage.PerRun.BoxTruck_02__resService_14failure = 2
for testsuite in root:
    success = 0
    failure = 0
    #print (child.attrib['name'])
    value = testsuite.attrib['name']
    testdetail[value] = testsuite.attrib['name']
    for testcase in testsuite:
        #added time attribute to test case as this is one of the requirement
        testcase.attrib['time'] = "5.0"
        #print (subchild.attrib['result'])
        if testcase.attrib['result'] == "success":
            success = success + 1
        elif testcase.attrib['result'] == "failure":
            failure = failure + 1
    successvalue = value + 'success'
    failurevalue = value + 'failure'
    testdetail[successvalue] = success
    testdetail[failurevalue] = failure

#print (testdetail['com.neotys.ResponseErrorPercentage.PerRun.BoxTruck_02__resService_13success'])
#print (testdetail['com.neotys.ResponseErrorPercentage.PerRun.BoxTruck_02__resService_13failure'])


# In[12]:

import re
#line = 'bla bla bla<form>Form 1</form> some text...<form>Form 2</form> more text?'
line = "com.neotys.Tablessla.PerRun.ISMT"
matches = re.search('com.neotys.(.*?).PerRun.(.*?)', line, re.S)
print (matches.group(1))
print(line)


# In[13]:

#Remove the attribute com.neotys.ResponseErrorPercentage.PerRun since it adds the SLA'S at the overall test level
for testsuite in root.iter('testsuite'):
    #print (testsuite.attrib['name'])
    if testsuite.attrib['name'] == "com.neotys.ResponseErrorPercentage.PerRun":
        #print (testsuite.attrib)
        root.remove(testsuite)
    if testsuite.attrib['name'] == "com.neotys.ResponseTimeSla.PerRun":
        #print (testsuite.attrib)
        root.remove(testsuite)






# In[27]:

#Created two lists to identify unique sla names and create a transaction name with com.neotys.uniquesla.PerRun
transactions = []
transactionnames = []

for testsuite in root.iter('testsuite'):
    print(testsuite.attrib['name'])
    matches = re.search('com.neotys.(.*?).PerRun', testsuite.attrib['name'], re.S)
    print ("matches group", matches.group(1))

    transactions.append(matches.group(1))

transactionsset = set(transactions)
print (transactionsset)

for value in transactionsset:
    transactionname = 'com.neotys.'+value+'.PerRun'
    transactionnames.append(transactionname)

print (transactionnames)


# In[28]:

#Remove any test suties which is not equal to com.neotys.uniquesla.PerRun
for testsuite in root.iter('testsuite'):
    #print (testsuite.attrib['name'])
    if testsuite.attrib['name'] not in  transactionnames:
        #print (testsuite.attrib)
        root.remove(testsuite)



# In[29]:

#Build New Test Suite to add attributes time, tests, errors, skipped and failures

for testsuite in root:
            #print (testsuite.attrib)
            successnewvalue = testsuite.attrib['name'] + 'success'
            #print (successnewvalue)
            failurenewvalue = testsuite.attrib['name'] + 'failure'
            #print (failurenewvalue)
            testsuite.attrib['time'] = "5.0"
            testsuite.attrib['tests'] = str(testdetail[successnewvalue]+testdetail[failurenewvalue])
            testsuite.attrib['errors'] = "0"
            testsuite.attrib['skipped'] = "0"
            testsuite.attrib['failures'] = str(testdetail[failurenewvalue])

#print (testsuite.attrib)


# In[30]:

#Output the updated xml
tree.write('/usr/local/share/Neoloadresults/junitslaoutput.xml')


# In[ ]:
