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
var debug              = require('debug')('app');
var sourceList         = require(__dirname + '/sourcelist.json');
var output, cmd;

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main() {
  var cwd = process.cwd();
  var path = cwd.split('/');
  var kind, country, filename, tablename;
  var adm0, adm1, adm2, adm3, cmd, query;

  if (path[path.length-1] == 'WORLD') {
    kind='world';
  } else if (path[path.length-2] == 'WORLD') {
    kind = 'country';
    country = path[path.length-1];
  } else if (path[path.length-3] == 'WORLD') {
    return 0;
  } else
  {
    console.log('Invalid current directory, should be called from WORLD/ or WORLD/COUNTRY/ directory');
    return 0;
  }

  debug('kind = ' + kind);
  debug('country = ' + country);

  switch (kind) {
    case 'world':
      var file = process.cwd() + '/*.shp';
      var cmd = 'ogr2ogr -skipfailures -overwrite -progress -f "MySQL" MYSQL:"opinions,host=localhost,user=root,password=opinions,port=3306" -nln "world" ' + file + ' -lco engine=MYISAM';
      break;
    case 'country':
      adm0 = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm0.shp';
      adm1 = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm1.shp';
      adm2 = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm2.shp';
      adm3 = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm3.shp';

      filename = adm3;
      tablename = sourceList[country.toUpperCase()].code + '_adm3';
      query = '"SELECT iso AS country_code, name_0 AS country_name, id_1 AS state_code, name_1 AS state_name, id_2 as county_code, name_2 as county_name, id_3 AS city_code, name_3 as city_name from ' + tablename + '"';

      do {
        if (!fs.existsSync(filename)) {
          filename = adm2;
          tablename = sourceList[country.toUpperCase()].code + '_adm2';
          query = '"SELECT iso AS country_code, name_0 AS country_name, id_1 AS state_code, name_1 AS state_name, id_2 as county_code, name_2 as county_name from ' + tablename + '"';
        }

        if (!fs.existsSync(filename)) {
          filename = adm1;
          tablename = sourceList[country.toUpperCase()].code + '_adm1';
          query = '"SELECT iso AS country_code, name_0 AS country_name, id_1 AS state_code, name_1 AS state_name from ' + tablename + '"';
        }

        if (!fs.existsSync(filename)) {
          filename = adm0;
          tablename = sourceList[country.toUpperCase()].code + '_adm0';
          query = '"SELECT iso AS country_code, sovereign AS country_name from ' + tablename + '"';
        }

      } while (0);

      var cmd = 'ogr2ogr -overwrite -progress -f "MySQL" MYSQL:"opinions,host=localhost,user=root,password=opinions,port=3306" -nln "' + country + '" ' + filename + ' -sql ' + query + ' -lco engine=MYISAM';
      break;
    default:
      debug('Invalid kind %s', kind);
      break;
  }

  debug(cmd);
  var output = exec(cmd, true);

  if (output.stdout) console.log(output.stdout);
  if (output.stderr) console.log(output.strerr);

}

Main();