### Production deploy pipeline instructions 
Steps:
- Download fly from IOM concourse url and paste the fly.exe file under C://windows/system32
- Enter the below command to login to the server
```fly -t iom-dct-apps-prod login -c https://cicd-iom.apps-np.homedepot.com```
- Copy and paste the below url in chrome for authentication 
``https://cicd-iom.apps-np.homedepot.com/auth/github?team_name=main&fly_local_port=57020``
- Execute the below command to create a team with basic auth
```fly set-team -n proddeployteam --basic-auth-username ci --basic-auth-password changeme -t iom-dct-apps-prod```
- login to the concourse team
```fly login -n proddeployteam -t iom-dct-apps-prod```
- Edit the below command before executing(replace ldap username and password with ```XXX``)
  - get a prod-pipeline.yml and secrets.yml from IOM team and navigate to the path where you save the yml files
```fly sp -t iom-dct-apps-prod -p proddeploy -c prod-pipeline.yml -n -l secrets.yml --var "prod-pipeline-cfuser=XXX " --var "prod-pipeline-password=XXX"```

