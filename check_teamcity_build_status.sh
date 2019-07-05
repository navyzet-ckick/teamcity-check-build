#!/usr/bin/env bash

##### Config #########
TeamCityLink="https://teamcity.your.domain"
TeamCityToken="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SlackHookUrl="https://hooks.slack.com/services/XXXXXXXXX/XXXXXXX/XXXXXXXXXXXXXXXXXXX"
SlackChanel="#alertts-chanel"
SlackUserName="TeamCity build status"
FolderStatus="/tmp/teamcity_build_status/"
LogFile="/tmp/check_teamcity_build_status.log"
######################
BuildTypeId="${1}"

mkdir -p $FolderStatus

get_api () {
    Request="${1}"
    Answer=$(curl -s --header "Authorization: Bearer ${TeamCityToken}" --header "Accept: application/json" "${TeamCityLink}/app/rest/${Request}" | jq -c '.build[0]')
    echo "${Answer}"
}

slack_send () {
        TEXT=${1}
        curl --silent --data-urlencode "payload={\"text\": \"${TEXT}\", \"channel\": \"${SlackChanel}\", \"username\": \"${SlackUserName}\", \"as_user\": \"true\", \"link_names\": \"true\", \"icon_emoji\": \":slack:\" }" ${SlackHookUrl}
        echo ${TEXT}
}

Answer=$(get_api "buildTypes/id:${BuildTypeId}/builds/")

case $(echo ${Answer} | jq '.status') in
        '"SUCCESS"')
                if [ -f "${FolderStatus}/${BuildTypeId}" ]; then
                        echo "File ${FolderStatus}/${BuildTypeId} exist. Message send" >> ${LogFile}
                        slack_send ":male-mechanic: Success build <$(echo ${Answer} | jq '.webUrl'| sed 's/"//g')&tab=buildLog&state=&expand=all#_state=|${BuildTypeId}>"
                        echo ":male-mechanic: Success build <$(echo ${Answer} | jq '.webUrl'| sed 's/"//g')&tab=buildLog&state=&expand=all#_state=|${BuildTypeId}>"
                        echo "delete file ${FolderStatus}/${BuildTypeId}" >> ${LogFile}
                        rm "${FolderStatus}/${BuildTypeId}"
                else
                        echo "File ${FolderStatus}/${BuildTypeId} dont exist. Message dont send"  >> ${LogFile}
                fi
                exit 0
                ;;
        '"FAILURE"')
                echo $(echo ${Answer} | jq '.buildTypeId' | sed 's/"//g')  >> ${LogFile}
                echo "Build ${BuildTypeId} failed" >> ${LogFile}
                if [ -f "${FolderStatus}/${BuildTypeId}" ]; then
                        echo "File ${FolderStatus}/${BuildTypeId} exist. Dont send message" >> ${LogFile}
                else
                        slack_send ":zombie: Failure build <$(echo ${Answer} | jq '.webUrl'| sed 's/"//g')&tab=buildLog&state=&expand=all#_state=|${BuildTypeId}>"
                        touch "${FolderStatus}/${BuildTypeId}"
                fi
                exit 2
                ;;
esac