#!/bin/bash -eu

init_env_file() {
  validate_env_var "SCRIPT_DIR"
  validate_env_var "SCRIPT_NAME"
  ENV_FILE=${SCRIPT_DIR}/${SCRIPT_NAME%.sh}.env
  rm -f ${ENV_FILE}
  trap "save_env_file; exit" INT TERM EXIT
}

configurable_env_var() {
  set +u
  PARAM_NAME=$1
  PARAM_VALUE=$(eval echo \$$1)
  if [ "${PARAM_VALUE}xxx" = "xxx" ]; then
    shift
    PARAM_VALUE="$@"
    eval ${PARAM_NAME}=\"${PARAM_VALUE}\"
    export eval ${PARAM_NAME}
  fi
  # Update the value
  print_env_file "${PARAM_NAME}=${PARAM_VALUE}"
  set -u
}

# Setup an env var and record it in the environment file
# The user cannot override the value
env_var() {
  set +u
  PARAM_NAME=$1
  shift
  PARAM_VALUE="$@"
  eval ${PARAM_NAME}=\"${PARAM_VALUE}\"
  export eval ${PARAM_NAME}
  print_env_file "${PARAM_NAME}=${PARAM_VALUE}"
  set -u
}

# Print in file ${ENV_FILE} the content of $1
print_env_file() {
  validate_env_var "ENV_FILE"
  print_file "${ENV_FILE}" "$1"
}

# Checks that the env var with the name provided in param is defined
validate_env_var() {
  set +u
  PARAM_NAME=$1
  PARAM_VALUE=$(eval echo \$$1)
  if [ "${PARAM_VALUE}xxx" = "xxx" ]; then
	echo "[ERROR] Environment variable $PARAM_NAME is not set";
	echo "Please set it either : "
	echo "* in your shell environment (export $PARAM_NAME=xxx)"
	echo "* in the system file /etc/default/exo-bench"
	echo "* in the user file \$HOME/.exobenchrc"
	exit 1;
  fi
  set -u
}

function jmeter-start {
	env_var "JVM_ARGS" "-Xms2g -Xmx${JVM_MAX_MEMORY} -XX:PermSize=${JVM_PERM_SIZE} -Djava.awt.headless=true  -Duser.language=en -Duser.region=EN"
	env_var "JMETER_PARAMS" "$@"
	echo "JVM_ARGS : " ${JVM_ARGS}
	echo "JMeter command line : " ${JMETER_HOME}/bin/jmeter "$JMETER_PARAMS"
	${JMETER_HOME}/bin/jmeter $JMETER_PARAMS || true #Allow to kill
}

init_env_file

configurable_env_var "JMETER_ACTIVATE_LOGS" true
configurable_env_var "JMETER_ACTIVATE_JTL" true

# Archive logs ?
configurable_env_var "ARCHIVE_RESULTS" true

# is it a WARMUP job ?
configurable_env_var "TYPE_WARMUP" false
if ${TYPE_WARMUP} ; then
  echo "# This job type is a WARMUP BENCH (TYPE_WARMUP=${TYPE_WARMUP})"
else
  echo "# This job type is a REAL BENCH (TYPE_WARMUP=${TYPE_WARMUP})"
fi

configurable_env_var "JVM_MAX_MEMORY" "16g"
configurable_env_var "JVM_PERM_SIZE" "128m"

# -------- specific params for classic ThreadGroup loading model -------
#expDuration    when the job type is WARMUP
configurable_env_var "DURATION_WARMUP" 60
if ${TYPE_WARMUP} ; then
  #expDuration    DEFAULT=    600
  env_var "DURATION" $DURATION_WARMUP
else
  #expDuration    DEFAULT=    600
  configurable_env_var "DURATION" 600
fi
#expLoopCount    DEFAULT=    10000000
configurable_env_var "LOOP_COUNT" 10000000
#expRampup    DEFAULT=    10
configurable_env_var "RAMPUP" 10

#expThreadCount  when the job type is WARMUP
configurable_env_var "THREAD_COUNT_WARMUP" 1
if ${TYPE_WARMUP} ; then
  #expThreadCount    DEFAULT=    0
  env_var "THREAD_COUNT" $THREAD_COUNT_WARMUP
else
  #expThreadCount    DEFAULT=    0
  configurable_env_var "THREAD_COUNT" 0
fi
# -------- specific params for Stepping  Thread Group loading model -------
#expVUGDownDuration    DEFAULT=    15
configurable_env_var "VUG_DOWN_DURATION" 15
#expVUGDownStep    DEFAULT=    100
configurable_env_var "VUG_DOWN_STEP" 100
#expVUGMaxThread  when the job type is WARMUP
configurable_env_var "VUG_MAX_THREAD_WARMUP" 10
#expVUGMaxThreadDuration
configurable_env_var "VUG_MAX_THREAD_DURATION_WARMUP" 600
if ${TYPE_WARMUP} ; then
  #expVUGMaxThread    DEFAULT=    1000
  env_var "VUG_MAX_THREAD" $VUG_MAX_THREAD_WARMUP
  #expVUGMaxThreadDuration    DEFAULT=    180
  env_var "VUG_MAX_THREAD_DURATION" $VUG_MAX_THREAD_DURATION_WARMUP
else
  #expVUGMaxThread    DEFAULT=    1000
  configurable_env_var "VUG_MAX_THREAD" 1000
  #expVUGMaxThreadDuration    DEFAULT=    180
  configurable_env_var "VUG_MAX_THREAD_DURATION" 180
fi
#expVUGUpDuration    DEFAULT=    180
configurable_env_var "VUG_UP_DURATION" 180
#expVUGUpRampup    DEFAULT=    30
configurable_env_var "VUG_UP_RAMPUP" 30
#expVUGUpStep    DEFAULT=    100
configurable_env_var "VUG_UP_STEP" 100
#expVUGWaitTime    DEFAULT=    15
configurable_env_var "VUG_WAIT_TIME" 15
# -------- specific params for PERF_PLF41_ENT_INTRANET_CHAT_WRITE_PRIVATE_CHAT scenario -------
configurable_env_var "VLOOP_CHAT" 2000
configurable_env_var "SYNC_GROUP_SIZE" 5
# -------- common params -------
#expHost    DEFAULT=    norma
configurable_env_var "HOST"    "localhost"
#expPort    DEFAULT=    8080
configurable_env_var "PORT"    "8080"
#expGroupingRequestsByUsersLevel    DEFAULT=    true
configurable_env_var "GROUPING_REQUESTS_BY_USERS_LEVEL" true
#expPageResponseTimeout    DEFAULT=    30000
configurable_env_var "PAGE_RESPONSE_TIME" 30000
#expThinkTime    DEFAULT=    20000
configurable_env_var "THINK_TIME" 20000
#expUserDatasetName    DEFAULT=    None
configurable_env_var "USER_DATASET_NAME" ""
# -------- typical params --------
#expSpaceDatasetName    DEFAULT=    None
configurable_env_var "SPACE_DATASET_NAME" ""
#expTopicDatasetName    DEFAULT=    None
configurable_env_var "TOPIC_DATASET_NAME" ""
#expWikiDatasetName    DEFAULT=    None
configurable_env_var "WIKI_DATASET_NAME" ""
#expDocumentDatasetName    DEFAULT=    None
configurable_env_var "DOCUMENT_DATASET_NAME" ""
configurable_env_var "CHAT_IMG_LIST_DATASET_NAME" ""
configurable_env_var "UNIFIED_SEARCH_DATASET_NAME" ""
configurable_env_var "UNIFIED_SEARCH_FEATURES" ""
# #############################################################################
# Mandatory env var to define to use the script
# We always re-export vars coming from validate_env_var to record them in our env file
# #############################################################################
validate_env_var "SCENARIO_PATH"
env_var "SCENARIO_PATH" "${SCENARIO_PATH}" #For logging purpose
validate_env_var "JAVA_HOME"
env_var "JAVA_HOME" "${JAVA_HOME}" #For logging purpose

#expCsvDatasetFolder    DEFAULT=    /home/qahudson/testsuite/csv/
validate_env_var "CSV_DATASET_FOLDER"
env_var "CSV_DATASET_FOLDER" "${CSV_DATASET_FOLDER}" #For logging purpose

# #############################################################################
# Script
# #############################################################################
# Validate that we are using the right account
validate_user ${AUTHORIZED_USER}

if [ -d "${CSV_DATASET_FOLDER}" ]; then
  env_var "CSV_DATASET_FOLDER_OPT" "-JexpCsvDatasetFolder=${CSV_DATASET_FOLDER}"
else
  env_var "CSV_DATASET_FOLDER_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${USER_DATASET_NAME}" ]; then
  env_var "USER_DATASET_NAME_OPT" "-JexpUserDatasetName=${USER_DATASET_NAME}"
else
  env_var "USER_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${SPACE_DATASET_NAME}" ]; then
  env_var "SPACE_DATASET_NAME_OPT" "-JexpSpaceDatasetName=${SPACE_DATASET_NAME}"
else
  env_var "SPACE_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${TOPIC_DATASET_NAME}" ]; then
  env_var "TOPIC_DATASET_NAME_OPT" "-JexpTopicDatasetName=${TOPIC_DATASET_NAME}"
else
  env_var "TOPIC_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${WIKI_DATASET_NAME}" ]; then
  env_var "WIKI_DATASET_NAME_OPT" "-JexpWikiDatasetName=${WIKI_DATASET_NAME}"
else
  env_var "WIKI_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${DOCUMENT_DATASET_NAME}" ]; then
  env_var "DOCUMENT_DATASET_NAME_OPT" "-JexpDocumentDatasetName=${DOCUMENT_DATASET_NAME}"
else
  env_var "DOCUMENT_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${CHAT_IMG_LIST_DATASET_NAME}" ]; then
  env_var "CHAT_IMG_LIST_DATASET_NAME_OPT" "-JexpImgList=${CHAT_IMG_LIST_DATASET_NAME}"
else
  env_var "CHAT_IMG_LIST_DATASET_NAME_OPT" ""
fi
if [ -f "${CSV_DATASET_FOLDER}/${UNIFIED_SEARCH_DATASET_NAME}" ]; then
  env_var "UNIFIED_SEARCH_DATASET_NAME_OPT" "-JexpSearchDatasetName=${UNIFIED_SEARCH_DATASET_NAME}"
else
  env_var "UNIFIED_SEARCH_DATASET_NAME_OPT" ""
fi
if [ ${UNIFIED_SEARCH_FEATURES:+x} ]; then
  env_var "UNIFIED_SEARCH_FEATURES_OPT" "-JexpSearchType=${UNIFIED_SEARCH_FEATURES}"
else
  env_var "UNIFIED_SEARCH_FEATURES_OPT" ""
fi


JMETER_OUTPUT_OPTS=""
if $JMETER_ACTIVATE_LOGS; then
  JMETER_OUTPUT_OPTS="${JMETER_OUTPUT_OPTS} -j ${RESULTS_DIR}/${JMETER_NAME}.log"
fi
if $JMETER_ACTIVATE_JTL; then
  JMETER_OUTPUT_OPTS="${JMETER_OUTPUT_OPTS} -l ${RESULTS_DIR}/bench.jtl"
fi

# Launch JMeter
jmeter-start \
  -JexpHost=${HOST} \
  -JexpPort=${PORT} \
  -JexpDuration=${DURATION} \
  -JexpLoopCount=${LOOP_COUNT} \
  -JexpRampup=${RAMPUP} \
  -JexpThreadCount=${THREAD_COUNT} \
  -JexpVUGMaxThreadDuration=${VUG_MAX_THREAD_DURATION} \
  -JexpVUGMaxThread=${VUG_MAX_THREAD} \
  -JexpVUGWaitTime=${VUG_WAIT_TIME} \
  -JexpVUGUpStep=${VUG_UP_STEP} \
  -JexpVUGUpDuration=${VUG_UP_DURATION} \
  -JexpVUGUpRampup=${VUG_UP_RAMPUP} \
  -JexpVUGDownStep=${VUG_DOWN_STEP} \
  -JexpVUGDownDuration=${VUG_DOWN_DURATION} \
  -JexpGroupingRequestsByUsersLevel=${GROUPING_REQUESTS_BY_USERS_LEVEL} \
  -JexpPageResponseTimeout=${PAGE_RESPONSE_TIME} \
  -JexpThinkTime=${THINK_TIME} \
  -JexpVLoopChat=${VLOOP_CHAT}\
  -JexpSynNumber=${SYNC_GROUP_SIZE}\
  ${CSV_DATASET_FOLDER_OPT} ${USER_DATASET_NAME_OPT} ${SPACE_DATASET_NAME_OPT} ${TOPIC_DATASET_NAME_OPT} ${WIKI_DATASET_NAME_OPT} ${DOCUMENT_DATASET_NAME_OPT} ${CHAT_IMG_LIST_DATASET_NAME_OPT} ${UNIFIED_SEARCH_DATASET_NAME_OPT} ${UNIFIED_SEARCH_FEATURES_OPT} \
  -n \
  ${JMETER_OUTPUT_OPTS} \
