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
var simplifypercentage = JSON.parse(fs.readFileSync(__dirname + '/simplifypercentage.json', 'utf8'));
var sourceList         = require(__dirname + '/sourcelist.json');
var output, cmd;

function relativeMapFilePath() {
  return path.relative(__dirname, process.cwd() + '/map.json');
}

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main()
{
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
    kind = 'state';
    country = path[path.length-2];
    state  = path[path.length-1];
  } else
  {
    console.log('Invalid current directory, should be called from WORLD/ or WORLD/COUNTRY/ or WORLD/COUNTRY/STATE/ directory');
    return 0;
  }

  switch (kind) {
    case 'world':
      file = "all.json";
      name = 'NAME';
      code = 'ADM0_A3';
      id   = 'ADM0_A3';
      break;
    case 'country':
    case 'state':
      file = '*.geojson';
      name = 'name';
      code = 'code';
      id   = 'code';
      break;
  }
  /*-----------------------------------------------------------------
   Combine all geo.json file in current directory via Topojson
   ----------------------------------------------------------------*/
  console.log('Combining maps');
  cmd = 'topojson -p submap -p ' + name + ' -p ' + id + ' -p ' + code + ' ' + file + ' -o combine.json';
  output = exec(cmd, true);
  console.log(output.stdout);
  console.log(output.stderr);

  /*-----------------------------------------------------------------
   Compress Topojson using mapshaper.
   Compression enabled faster rendering in the browser.
   ----------------------------------------------------------------*/
  var simplifyper = "3%";
  if (simplifypercentage[relativeMapFilePath()] != undefined) {
    simplifyper = simplifypercentage[relativeMapFilePath()];
  }

  console.log('Simplifying combined Map');
  cmd = 'rm compressed*.json; mapshaper combine.json -simplify ' + simplifyper  + ' -o compressed.json';
  output = exec(cmd, true);
  console.log(output.stdout);
  console.log(output.stderr);

  var idx = 0;
  var geometry = JSON.parse(fs.readFileSync('./compressed.json', 'utf8'));
  var map =
  {
    "type": "Topology",
    "objects": {
      "features": {
        "type": "GeometryCollection",
        "geometries": []
      }
    },
    "arcs" :[],
    "transform": {}
  };

  if (kind == 'world') {
    for (geom in geometry.objects.all.geometries)
    {
      var properties = geometry.objects.all.geometries[geom].properties;
      properties['name']   = properties.NAME;
      properties['code']   = properties.ADM0_A3;
      properties['id']     = properties.ADM0_A3;
      if (sourceList[properties['code']] != undefined) {
        properties['submap'] = sourceList[properties['code']].submap;
      } else {
        properties['submap'] = 0;
      }
      delete properties['NAME'];
      delete properties['ADM0_A3'];
    }
    map.objects.features.geometries = geometry.objects.all.geometries;
  } else {
    for (feature in geometry.objects)
    {
      if (geometry.objects[feature].geometries[0] == null) {
        console.log("No geometry object found for " + feature)

      } else {
        geometry.objects[feature].geometries[0].properties['id'] = feature;
        map.objects.features.geometries[idx++] = geometry.objects[feature].geometries[0];
      }
    }
  }

  map.arcs = geometry.arcs;
  map.transform = geometry.transform;

  fs.writeFile("map.json", JSON.stringify(map, null, 0), function(err) {
    if(err) {
      console.log(err);
    } else {
      console.log("JSON saved to map.json");
    }
  });


}

Main();