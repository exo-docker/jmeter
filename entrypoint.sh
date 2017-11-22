#!/bin/bash -eu

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or fallback
USER_ID=${LOCAL_USER_ID:-1000}
USER_NAME=${LOCAL_USER_NAME:-jmeter}
echo "Starting with UID=$USER_ID($USER_NAME)"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m $USER_NAME

# allow starting the container with bash (for Docker image debuging purpose)
if [[ ${@:-nothing} == bash* ]]; then
    shift # we remove bash from the arguments
    [ ! -z "$@" ] && echo "Starting bash but ignoring other parameters ($@)"
    bash
else
    # WARNING Not supporting spaces
    PROPERTIES=$(env | grep "^${JMETER_PROPERTY_PREFIX:-NOT_EXISTS}" || true)

    PROPERTIES_STRING=""
    for i in ${PROPERTIES}
    do
        PROPERTIES_STRING="${PROPERTIES_STRING} -J$(echo ${i} | sed s/${JMETER_PROPERTY_PREFIX}//g)"
    done

    if [ ! -z "${PROPERTIES_STRING}" ]; then
        echo Executing with additional properties : ${PROPERTIES_STRING}
    fi

    exec /usr/local/bin/gosu $USER_NAME /usr/local/jmeter/bin/jmeter ${PROPERTIES_STRING} "$@"
fi
