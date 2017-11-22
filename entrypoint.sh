#!/bin/bash -eu

# WARNING Not supporting spaces
PROPERTIES=$(env | grep "^${JMETER_PROPERTY_PREFIX}")

PROPERTIES_STRING=""
for i in ${PROPERTIES}
do
    PROPERTIES_STRING="${PROPERTIES_STRING} -J$(echo ${i} | sed s/${JMETER_PROPERTY_PREFIX}//g)"
done

if [ ! -z "${PROPERTIES_STRING}" ]; then
    echo Executing with additional properties : ${PROPERTIES_STRING}
fi

/usr/local/jmeter/bin/jmeter -n ${PROPERTIES_STRING} "$@"