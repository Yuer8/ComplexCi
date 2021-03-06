if (( $# >= 1 ))
then
    regressionResult=$1
else
    echo './calGroovyBenchmark.sh <regressionResult>'
    exit;
fi


logFile=`ls -t | head -1`
tail $logFile
fullLogFile=`readlink -f $logFile`
serId=`echo $logFile | sed -e 's/\.log$//'`
echo $serId

cd ../Master_algorithm

groovy  -cp "target/algorithm-1.0-SNAPSHOT.jar:`readlink -f ~`/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar"  src/main/java/org/dc/algorithm/NetMaster.groovy  ../data/randomGraphPythonResults/$serId/$serId.csv  ../data/randomGraph.zip > /tmp/groovyResult
cat /tmp/groovyResult


valueResult=" score , "
timeResult=" time , "
minPointResult=" minPoint , "
algoEndsPointResult=" algoEndsPoint , "
for i in genRandomGraph_0 genRandomGraph_1 genRandomGraph_2 genRandomGraph_3
do
	valueResult=$valueResult`egrep $i /tmp/groovyResult  | awk -F ":" '{print $2}'`" , "
	timeResult=$timeResult`egrep "$i duration" $fullLogFile | awk -F ":" '{print $2}'`" , "
	minPointResult=$minPointResult`egrep "$i Min Component Point" $fullLogFile | awk -F ":" '{print $2}'`" , "
	algoEndsPointResult=$algoEndsPointResult`egrep "$i Algorithm ends min point" $fullLogFile | awk -F ":" '{print $2}'`" , "
done
valueResult=$valueResult`egrep "^[0-9]\.([0-9]*)" /tmp/groovyResult`
timeResult=$timeResult`egrep "duration" $fullLogFile | tail -1 | awk -F ":" '{print $2}'`
echo " $serId , genRandomGraph_0, genRandomGraph_1, genRandomGraph_2, genRandomGraph_3  , total " >> $regressionResult
echo $valueResult   >> $regressionResult
echo $timeResult   >> $regressionResult
echo $minPointResult   >> $regressionResult
echo $algoEndsPointResult   >> $regressionResult


echo $regressionResult
cat $regressionResult

grep "score" $regressionResult | sed 's/\s//g' | awk -F ',' '{print $6}' > /tmp/overrallScore

printf "\n\nscore overall:\n"

cat /tmp/overrallScore

printf "\n\n"

cd -
