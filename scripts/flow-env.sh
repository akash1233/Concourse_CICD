#!/bin/bash

set +e +x

# Concourse commonly uses GITHUB_PRIVATE_KEY.  If it's present then install that
#   same SSH key in the keystore so Flow can authenticate to GitHub with it too.
function detectPrivateGithubKey() {
  if [[ ${GITHUB_PRIVATE_KEY} ]]
    then
      eval `ssh-agent -s` >> /dev/null
      mkdir ~/.ssh

      filepath=~/.ssh/id_rsa
      echo $GITHUB_PRIVATE_KEY | sed -e 's/ RSA PRIVATE /_RSA_PRIVATE_/g' \
                                     -e 's/ /\n/g' \
                                     -e 's/_RSA_PRIVATE_/ RSA PRIVATE /g' \
                                     > $filepath
      chmod 600 $filepath >> /dev/null

      ssh-add $filepath 2> /dev/null

      # ssh-add -l >> /dev/null
  fi
}

# Source the shell script and activate the virtual env "ci"
function prepareVirtualEnv(){
  if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh >> /dev/null
  fi

  if [ -f /.virtualenvs/ci/bin/activate ]; then
    source /.virtualenvs/ci/bin/activate >> /dev/null
  fi
}

detectPrivateGithubKey

prepareVirtualEnv

# Detect a local version of flow.  If present, install flow from there, overriding 
#   production version.  This is used in the flow pipeline to test with the latest
#   development code as opposed to the default wheel installed on the image.
if [ -d '../flow-repo/flow' ]; then
  deactivate
  mkvirtualenv ci-dev
  pip install -e ../flow-repo
elif [ -d '../code-repo/flow' ]; then
  deactivate
  mkvirtualenv ci-dev
  pip install -e ../code-repo
fi