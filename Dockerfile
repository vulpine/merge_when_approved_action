FROM debian:9.6-slim

LABEL "com.github.actions.name"="Label approved pull requests"
LABEL "com.github.actions.description"="Auto-label pull requests that have a specified number of approvals"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.0"
LABEL repository="http://github.com/vulpine/merge_when_approved_action"
LABEL homepage="http://github.com/vulpine/merge_when_approved_action"
LABEL maintainer="Sophie Matthews <smatthew@yelp.com>"

RUN apt-get update && apt-get install -y \
    curl \
    jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
