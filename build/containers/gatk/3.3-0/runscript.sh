if [ "$1" = "help" ]
then
	exec java -jar /usr/bin/gatk.jar --help
fi

java_args=$1
shift
exec java $java_args /usr/bin/gatk.jar $@