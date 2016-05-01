#!/bin/bash

function patch_redis {
  cd node_modules/seneca-redis-store
  mkdir temp
  cd temp
  git clone https://github.com/kamil-mech/seneca-redis-store 
  cd ..
  rm -rf redis-store.js
  cp -rf temp/seneca-redis-store/redis-store.js redis-store.js
  rm -rf temp
  cd ../..
}

function patch_jsonfile {
  cd node_modules/seneca-jsonfile-store
  mkdir temp
  cd temp
  git clone https://github.com/kamil-mech/seneca-jsonfile-store 
  cd ..
  rm -rf jsonfile-store.js
  cp -rf temp/seneca-jsonfile-store/jsonfile-store.js jsonfile-store.js
  rm -rf temp
  cd ../..
}

if [[ -d "sdbth-setup" ]]; then
  rm -rf sdbth-setup
fi

mkdir sdbth-setup
cd sdbth-setup
git clone https://github.com/kamil-mech/seneca-db-test-harness
git clone https://github.com/kamil-mech/well
cd seneca-db-test-harness
npm i
patch_redis
patch_jsonfile
cd ../well
git checkout sdbth-4
cp -rf options.example.js options.well.js
npm i
patch_redis
patch_jsonfile
cd ..
echo "'use strict'

module.exports = {
  well: {
    optionsfile: __dirname + '/well/options.example.js',
    // docker images to run.
    // --link and -e db= will be added automatically.
    // if it exposes a port in dockerfile, tester will automatically
    // wait for it to start listening before booting next.
    dockimages: [
      { name: 'well-app', path: __dirname + '/well/.', testTarget: true }
    ],
    deploymode: 'series', // 'series' or 'parallel',
    knownWarnings: [
      'deprecated'
    ]
  }
}
" > sdbth.conf
echo "bash -c 'cd seneca-db-test-harness; rm -rf node_modules; npm i' & bash -c 'cd well; rm -rf node_modules; npm i'" > update.sh

if [[ "$1" == "-run" ]]; then
  cd seneca-db-test-harness
  node main.js well -all cassandra x=5 -fb -nwo
fi