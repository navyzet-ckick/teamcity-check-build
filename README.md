# teamcity-check-build
Check build status in teamcity and slack alert.

Requiments:
* jq 

Configs:
* TeamCityLink - teamcity url
* TeamCityToken - teamcity access token 
* SlackHookUrl - Slack webhook url https://winnersoftlab.slack.com/apps/A0F7XDUAZ-incoming-webhooks
* SlackUserName - Slack sender name
* FolderStatus - folder storage of builds states.

Instalation:

    sudo apt-get install jq
    git clone git@github.com:navyzet-ckick/teamcity-check-build.git
    cd teamcity-check-build
    sudo cp check_teamcity_build_status.sh /usr/local/bin/check_teamcity_build_status.sh
    sudo chmod +x /usr/local/bin/check_teamcity_build_status.sh

Use:
    
    /usr/local/bin/check_teamcity_build_status.sh TeamCity_Build_Configuration_ID