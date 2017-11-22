# JMeter container

## Usage

```
docker run -ti --rm -v /path/to/my/scripts:/scripts -v /path/to/results:/output -e HEAP="-e HEAP="-Xms512m -Xmx512m" exoplatform/jmeter:latest -t /scripts/myscript.jmx -o /output/result``
```

## Bench properties

Any property prefixed with ``JMETERPROP_`` will be passed to the jmeter script on a -j option.

For example, if you add the parameter ``-e JMETERPROP_param1=value1`` to the docker command line, the option ``-Jparam1=value1`` will be added to the jmeter command line

