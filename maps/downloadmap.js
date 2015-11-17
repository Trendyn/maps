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
var sourceList         = require(__dirname + '/sourcelist.json');
var output, cmd;

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main() {
  var cwd = process.cwd();
  var path = cwd.split('/');
  var kind, country;
  var src;

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

    switch (kind) {
      case 'world':
        src = sourceList['WORLD'] != undefined ? sourceList['WORLD'].url : undefined;
        break;
      case 'country':
        src = sourceList[country] != undefined ? sourceList[country].url : undefined;
        break;
      default:
        console.log('Invalid kind %s', kind);
        break;
    }

  if (src != undefined) {
    var filename = src.split('/');
    if (!fs.existsSync(filename[filename.length-1])) {
      var cmd = 'wget ' + src;
      var output = exec(cmd, true);
      debug(output.stdout);
      debug(output.stderr);
    }

    var cmd = 'unzip *.zip';
    var output = exec(cmd, true);
    debug(output.stdout);
    debug(output.stderr);

    src = src.split('/');
    src = src[src.length-1];
  }
}

Main();