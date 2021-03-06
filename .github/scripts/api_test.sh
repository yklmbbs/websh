#!/bin/bash

set -eux

docker-compose up -d
sleep 5

pushd websh_server
./bin/websh_remover &
remover_pid=$!

./tools/visor &
visor_pid=$!

./bin/websh_server &
pid=$!
sleep 2

# 出力内容を確認する用
curl -s --connect-timeout 5 -X POST -d '{"code":"echo hello", "images":[]}' 'http://0.0.0.0:5000/shellgei'
sleep 3

# 標準出力のテスト
cnt=$(curl -s --connect-timeout 5 -X POST -d '{"code":"echo hello", "images":[]}' 'http://0.0.0.0:5000/shellgei' | grep hello | wc -l)
[ "$cnt" -eq 1 ]
sleep 3

# 標準エラー出力のテスト
cnt=$(curl -s --connect-timeout 5 -X POST -d '{"code":"echo hello >&2", "images":[]}' 'http://0.0.0.0:5000/shellgei' | grep hello | wc -l)
[ "$cnt" -eq 1 ]

popd
