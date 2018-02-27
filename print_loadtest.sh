#!/bin/bash

host=http://localhost:1236

run_single_print() {
  t0=$(date +%s%N)
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

  t1=$(date +%s%N)

  status=$(echo $json | jq .status)

  if (test ${status:1:-1} = error) then
     echo Failed!
  else
     echo $((($t1-$t0) / 1000000))
  fi
}

for i in $(seq 1 $1)
do
  run_single_print &
done
