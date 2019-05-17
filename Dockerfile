FROM debian:9.6-slim

LABEL "com.github.actions.name"="Merge approved pull requests"
LABEL "com.github.actions.description"="Auto-merge pull requests that have a specified number of approvals and no Terraform changes"
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="red"

LABEL version="1.0.0"
LABEL repository="http://github.com/vulpine/merge_when_approved_action"
LABEL homepage="http://github.com/vulpine/merge_when_approved_action"
LABEL maintainer="Sophie Matthews <smatthew@yelp.com>"

RUN apt-get update && apt-get install -y \
    curl \
    jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
