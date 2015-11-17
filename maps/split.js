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
  var kind, country, state;
  var name, code, id, adm2_file, adm3_file, submap = 0;

  if (path[path.length-1] == 'WORLD') {
    return 0;
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

  var input = JSON.parse(fs.readFileSync('all.json'));

  if (input == undefined) {
    console.log('all.geo.json missing in current directory');
    return 0;
  }

  var map = '{"type": "FeatureCollection", "features": []}';

  for (idx in input.features) {
    var feature = input.features[idx];
    var output = JSON.parse(map);

    switch (kind) {
      case 'world':
        name  = feature.properties['NAME'];
        code  = feature.properties['ADM0_A3'];
        id    = code;
        submap = 1;
        break;
      case 'country':
        name   = feature.properties.NAME_1;
        code   = country;
        id     = feature.properties.ID_1;

        adm2_file = process.cwd() + '/' + sourceList[country.toUpperCase()].code + '_adm2.shp';
        if (fs.existsSync(adm2_file) || fs.existsSync(adm3_file)) {
          submap = 1;
        }

        break;
      case 'state':
        name   = feature.properties.NAME_2;
        id     = feature.properties.ID_2;
        submap = 0;

        if (feature.properties.NAME_3 != undefined) {
          name = feature.properties.NAME_2 + ' | ' + feature.properties.NAME_3;
          id   = feature.properties.ID_3;
        }

        code = name.replace(/\//g, '|') ;
        break;
      default:
        console.log('Invalid kind %s', kind);
        break;
    }

    var filename = id + '.geojson';
    output.features[0] = feature;
    delete output.features[0].properties;
    output.features[0]['properties'] = {};
    output.features[0]['properties']['kind'] = kind;
    output.features[0]['properties']['name']= name;
    output.features[0]['properties']['code'] = code;
    output.features[0]['properties']['id'] = id;
    output.features[0]['properties']['submap'] = submap;

    fs.writeFileSync(filename, JSON.stringify(output, null, 0));
  }

}

Main();