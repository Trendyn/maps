#!/usr/bin/node
/*
 This code is licensed to OpinionCurrent Owners.

 Dependencies:
 2. topojson - https://github.com/mbostock/topojson
 3. mapshaper - https://github.com/mbloch/mapshaper

 Revision History

 Committer   Date         Change
 ==============================================================
 Ashish     10/30/2014    Initial Version

 */

var fs                 = require('fs');
var path               = require('path');
var exec               = require('exec-sync');
var debug              = require('debug');
var output, cmd;

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main() {
  var cwd = process.cwd();
  var path = cwd.split('/');
  var kind, country, state;
  var name, code, id;

  if (path[path.length-1] == 'WORLD') {
    kind = 'world';
  } else if (path[path.length-2] == 'WORLD') {
    kind = 'country';
    country = path[path.length-1];
  } else if(path[path.length-3] == 'WORLD') {
    return 0;
  } else
  {
    console.log('Invalid current directory, should be called from WORLD/ or WORLD/COUNTRY/ or WORLD/COUNTRY/STATE/ directory');
    return 0;
  }

  var input = JSON.parse(fs.readFileSync('all.json'));

  if (input == undefined) {
    console.log('all.geo.json missing in current directory');
    return 0;
  }

  for (idx in input.features) {
    var feature = input.features[idx];

    switch (kind) {
      case 'world':
        name = feature.properties['NAME'];
        code = feature.properties['ADM0_A3'];
        id   = code;
        break;
      case 'country':
        name = feature.properties.NAME_1;
        code = feature.properties.ID_1;
        id   = code;
        break;
      default:
        console.log('Invalid kind %s', kind);
        break;
    }

    if (!fs.existsSync(id)) {
      var cmd = 'mkdir ' + id;
      var output = exec(cmd, true);
      debug(output.stdout);
      debug(output.stderr);
    }
  }

}

Main();
