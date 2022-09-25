#!/bin/bash
# forked from: https://gist.github.com/jonico/d002e30391e8b53919409690704ecdb7

function help {
  echo "Add collaborators to one or more repositories on github"
  echo ""
  echo "Syntax:   $0 -u user [-l] [-D] -r repo1,repo2 <collaborator id>"
  echo ""
  echo "          -u    OAuth token to access github"
  echo "          -l    list collaborators"
  echo "          -r    repositories, list as owner/repo[,owner/repo,...]"
  echo "          -D    remove"
  echo "          id    the collaborator id to add or remove"
}

while getopts "h?u:p:r:Dl?" opt; do
    case $opt in
      h|\?)
         help
         exit 0
         ;;
      u)
         OAUTH_TOKEN=$OPTARG
         ;;
      D)
         METHOD=DELETE
         ;;
      r)
         REPOS=$OPTARG
         ;;
      l)
         LIST=yes
         ;;
    esac
done

shift $((OPTIND-1))

COL_USER=$1

if [[ -z "$OAUTH_TOKEN" ]]; then
   echo Enter your github PAT / OAuth token
   read OAUTH_TOKEN
fi

if [[ -z "$REPOS" ]]; then
   echo Enter the repositories as user/repo. Multiple repos comma separated.
   read REPOS
fi

if [[ -z "$COL_USER" ]]; then
   LIST=yes
fi

if [[ -z "$METHOD" ]] && [[ ! -z "$COL_USER" ]]; then
   echo "[WARN] Assuming you want to add user $COL_USER. Use the -D option to delete"
   METHOD=PUT
fi

array=(${REPOS//,/ })
arrayUser=(${COL_USER//,/ })

if [[ ! -z "$COL_USER" ]]; then
  for repo in "${array[@]}"; do
      for user in "${arrayUser[@]}"; do
         echo "[INFO] $METHOD $user to $repo"
         curl --request $METHOD \
            --url "https://api.github.com/repos/$repo/collaborators/$user" \
            --header "Accept: application/vnd.github.v3+json" \
            --header "Authorization: Bearer $OAUTH_TOKEN" \
            -d '{"permission":"push"}' # for write access
      # -d '{"permission":"pull"}' # for read only access
      done
  done
fi

if [[ ! -z "$LIST" ]]; then
   for repo in "${array[@]}"; do
      echo "[INFO] Current list of collaborators in $repo:"
      curl --request GET \
         --url "https://api.github.com/repos/$repo/collaborators" \
         --header "Accept: application/vnd.github.v3+json" \
         --header "Authorization: Bearer $OAUTH_TOKEN"
   done
fi

exit 0
