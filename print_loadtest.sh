#!/bin/bash

host=http://172.17.0.3:8080

t0=$(date +%s%N)

run_single_print() {
  json=$(curl -s $host'/print/shogun/report.pdf' -H 'Content-Type: application/json' -H 'Accept: */*' -H 'Cache-Control: no-cache' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' --data-binary @test.json --compressed)

  url=$(echo $json | jq .statusURL)
  downUrl=$(echo $json | jq .downloadURL)
  url=$host${url:1:-1}
  downUrl=$host${downUrl:1:-1}

  res=notdone

  while (test $res != true)
  do
    sleep 0.1
    json=$(curl -s $url)
    res=$(echo $json | jq .done)
  done

  status=$(echo $json | jq .status)

  if (test ${status:1:-1} = error) then
     echo Failed!
  else
     curl -s $downUrl -o $1.pdf
  fi
}

for i in $(seq 1 $1)
do
  run_single_print $i &
done

wait

t1=$(date +%s%N)
echo Time: $((($t1-$t0) / 1000000))ms
