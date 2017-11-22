# JMeter container

## Usage

Important directories :
* ``/scripts/`` for the jmeter scripts and csv datasources
* ``/output/`` for all jmeter generated data (log file, csv/jtl files, reports, ...)

```
docker run -ti --rm -v /path/to/my/scripts:/scripts:ro -v /path/to/results:/output:rw \
    exoplatform/jmeter:latest -n -t /scripts/myscript.jmx -o /output/result
```

### Usage for benchmark

```
docker run -ti --rm -v /path/to/my/scripts:/scripts:ro -v /path/to/results:/output:rw \
    exoplatform/jmeter:latest -n -t /scripts/myscript.jmx -o /output/result/
```

WARNING: don't forget to pass the ``-n`` parameter to run jmeter in no gui mode

### Usage for report generation

```
docker run -ti --rm -v /path/to/results:/output:rw \
    exoplatform/jmeter:latest -g /output/bench/benchmark.csv -o /output/report/
```

## Bench properties

Any property prefixed with ``JMETERPROP_`` will be passed to the jmeter script on a -j option.

For example, if you add the parameter ``-e JMETERPROP_param1=value1`` to the docker command line, the option ``-Jparam1=value1`` will be added to the jmeter command line

## Configuration

### JVM Heap

You can configure JMeter's JVM Heap with the ``HEAP`` environment variable :

```
docker run -ti --rm -e HEAP="-Xms512m -Xmx512m" exoplatform/jmeter:latest
```

### User UID inside the container

To avoid file permission problems when writting files in mounted directory from the host (ex: ``/output/``), you can specify the user UID to use to launch jmeter inside the container with the variable ``LOCAL_USER_ID``.

ex: laucnh JMeter with the same UID than the current user launching the container on the host :

```
docker run -ti --rm -e LOCAL_USER_ID=`id -u $USER` \
    -v /path/to/my/scripts:/scripts -v /path/to/results:/output \
    exoplatform/jmeter:latest -n -t /scripts/myscript.jmx -o /output/result
```
