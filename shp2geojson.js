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

var exec               = require('exec-sync');
var fs                 = require('fs');
var path               = require('path');
var debug              = require('debug');
var sourceList         = require(__dirname + '/sourcelist.json');
var output, cmd;

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main() {
  var cwd = process.cwd();
  var path = cwd.split('/')
  var kind, country, state;

  if (path[path.length-1] == 'WORLD') {
    kind = 'world';
  } else if (path[path.length-2] == 'WORLD') {
    kind = 'country';
    country = path[path.length-1];
  } else if(path[path.length-3] == 'WORLD') {
    kind = 'state';
    country = path[path.length-2];
    state  = path[path.length-1];
  } else
  {
    console.log('Invalid current directory, should be called from WORLD/ or WORLD/COUNTRY/ or WORLD/COUNTRY/STATE/ directory');
    return 0;
  }

  var output = exec('rm all.json', true);

  switch (kind) {
    case 'world':
      var file = process.cwd() + '/*.shp';
      var cmd = 'ogr2ogr -f GeoJSON all.json ' + file;
      break;
    case 'country':
      var file = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm1.shp';

      if (!fs.existsSync(file)) {
        file = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm0.shp';
      }
      var cmd = 'ogr2ogr -f GeoJSON all.json ' + file;
      break;
    case 'state':
      var field = 'ID_1';
      var name = state;
      var dir = process.cwd();
      var files = fs.readdirSync(dir + '/../');
      var file = dir + '/../*_adm2.shp';

      for (var idx in files) {
        if (files[idx].search('adm3.shp') != -1) {
          file = dir + '/../' + files[idx];
          break;
        }
      }

      debug(file);

      var cmd = 'ogr2ogr -f GeoJSON -where "' + field + ' IN (\'' + name + '\')" all.json ' + file;

      console.log(cmd);
      break;
    default:
      console.log('Invalid kind %s', kind);
      break;
  }

  var output = exec(cmd, true);

  if (output.stdout) console.log(output.stdout);
  if (output.stderr) console.log(output.strerr);

}

Main();