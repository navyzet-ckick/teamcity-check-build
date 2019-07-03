#!/usr/bin/env bash

##### Config #########
TeamCityLink="https://teamcity.your.domain"
TeamCityToken="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SlackHookUrl="https://hooks.slack.com/services/XXXXXXXXX/XXXXXXX/XXXXXXXXXXXXXXXXXXX"
SlackChanel="#alertts-chanel"
SlackUserName="TeamCity build status"
FolderStatus="/tmp/teamcity_build_status/"
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
}

Answer=$(get_api "buildTypes/id:${BuildTypeId}/builds/")

echo ${Answer}

case $(echo ${Answer} | jq '.status') in
        '"SUCCESS"')
                if [ -f "${FolderStatus}/${BuildTypeId}" ]; then
                        echo "File ${FolderStatus}/${BuildTypeId} exist. Message send"
                        slack_send ":male-mechanic: Success build <$(echo ${Answer} | jq '.webUrl'| sed 's/"//g')&tab=buildLog&state=&expand=all#_state=|${BuildTypeId}>"
                        echo "delete file ${FolderStatus}/${BuildTypeId}"
                        rm "${FolderStatus}/${BuildTypeId}"
                else
                        echo "File ${FolderStatus}/${BuildTypeId} dont exist. Message dont send"
                fi
                        exit 0
                        ;;
        '"FAILURE"')

                echo $(echo ${Answer} | jq '.buildTypeId' | sed 's/"//g')
                echo "Build ${BuildTypeId} failed"
                if [ -f "${FolderStatus}/${BuildTypeId}" ]; then
                        echo "File ${FolderStatus}/${BuildTypeId} exist. Dont send message"
                else
                        slack_send ":zombie: Failure build <$(echo ${Answer} | jq '.webUrl'| sed 's/"//g')&tab=buildLog&state=&expand=all#_state=|${BuildTypeId}>"
                        touch "${FolderStatus}/${BuildTypeId}"
                fi
                        exit 2
                ;;
esac