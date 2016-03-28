#! /bin/sh
#

## make sure JavaChat is ready
if [ -z "$CHAT_HOME" ]
then
  CHAT_HOME=`dirname $0`
fi

if [ ! -f $CHAT_HOME/dist/JavaChat.jar ]
then
  echo 'ERROR: JavaChat library not found (project not built?)' 1>&2
  exit 1
fi

## configure java cmdline for JavaChat

# classpath + no other jvm options + main class
if [ -z "$CLASSPATH" ]
then
  CLASSPATH="$CHAT_HOME/dist/JavaChat.jar:$CHAT_HOME/lib/*"
else
  CLASSPATH="$CHAT_HOME/dist/JavaChat.jar:$CHAT_HOME/lib/*:$CLASSPATH"
fi
CHAT_OPTS=
CHAT_ARGS=javachat.JavaChat

#### include gumshoe?

if [ "x$1" = x--gumshoe ]
then
  ## make sure gumshoe is ready
  if [ -z "$GUMSHOE_HOME" ]
  then
    echo ERROR: GUMSHOE_HOME environment variable is not set 1>&2
    exit 1
  fi
  if [ ! -f $GUMSHOE_HOME/gumshoe-probes/target/gumshoe-probes-0.1.0-SNAPSHOT.jar -o \
       ! -f $GUMSHOE_HOME/gumshoe-tools/target/gumshoe-tools-0.1.0-SNAPSHOT.jar  ]
  then
    echo 'ERROR: gumshoe libraries not found (GUMSHOE_HOME wrong value or project not built?)' 1>&2
    exit 1
  fi

  ## update java cmdline for gumshoe

  # add gumshoe probe (data collection/filtering) and tool (gui) libs to classpath
  CLASSPATH="$CLASSPATH:$GUMSHOE_HOME/gumshoe-probes/target/gumshoe-probes-0.1.0-SNAPSHOT.jar"
  CLASSPATH="$CLASSPATH:$GUMSHOE_HOME/gumshoe-tools/target/gumshoe-tools-0.1.0-SNAPSHOT.jar"
  # add tiny hook to JVM
  CHAT_OPTS="$CHAT_OPTS -Xbootclasspath/p:$GUMSHOE_HOME/gumshoe-hooks/target/gumshoe-hooks-0.1.0-SNAPSHOT.jar"
  # makes a better demo if we report faster (30s) and don't trim the stack
  CHAT_OPTS="$CHAT_OPTS -Dgumshoe.socket-io.period=30000"
  CHAT_OPTS="$CHAT_OPTS -Dgumshoe.socket-io.exclude="
  # gumshoe becomes "main"
  CHAT_ARGS="com.dell.gumshoe.tools.Gumshoe $CHAT_ARGS"
fi

## run it
java -classpath "$CLASSPATH" $CHAT_OPTS $CHAT_ARGS
