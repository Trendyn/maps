#!/usr/bin/node
/*
 This code is licensed to OpinionCurrent Owners.

 Dependencies:
 1. node-dir
 2. combine.js

 Revision History

 Committer   Date         Change
 ==============================================================
 Ashish     10/30/2014    Initial Version

 */

var fs          = require("fs");
var path        = require('path');
var nodedir     = require('node-dir');
var exec        = require('exec-sync');
var async       = require("async");
var debug       = require('debug');
var src         = process.cwd();
var shp2geojson = __dirname + '/shp2geojson.js';
var clip        = __dirname + '/clipmaps.js';
var split       = __dirname + '/split.js';
var combine     = __dirname + '/combine.js';
var addmapstodb = __dirname + '/addmaptodb.js';
var makedir     = __dirname + '/makedir.js';
var downloadmap = __dirname + '/downloadmap.js';
var sourceList  = require(__dirname + '/sourcelist.json');


function actionOnDir(dir, cb)
{

  var result = "Passed";
  var relShp2geojson = path.relative(dir, shp2geojson);
  var relSplit       = path.relative(dir, split);
  var relClip        = path.relative(dir, clip);
  var relCombine     = path.relative(dir, combine);
  var reladdmapstodb = path.relative(dir, addmapstodb);
  var relmakedir     = path.relative(dir, makedir);
  var reldownloadmap = path.relative(dir, downloadmap);


  try {

    var cwdpath = dir.split('/');
    var kind, country, state;

    if (cwdpath[cwdpath.length-1] == 'WORLD') {
      kind = 'world';
    } else if (cwdpath[cwdpath.length-2] == 'WORLD') {
      kind = 'country';
      country = cwdpath [cwdpath.length-1];
    } else if(cwdpath[cwdpath.length-3] == 'WORLD') {
      kind = 'state';
      country = cwdpath [cwdpath.length-2];
      state  = cwdpath[cwdpath.length-1];
    } else
    {
      console.log('Invalid current directory, should be called from WORLD/ or WORLD/COUNTRY/ or WORLD/COUNTRY/STATE/ directory');
      return 0;
    }

    console.log('=======================================================================');
    console.log('Making Map for ' + dir.substr(dir.indexOf('WORLD'), dir.length));
    console.log('=======================================================================');
    
    if (!fs.existsSync(dir + "/map.json"))
    {
      process.stdout.write("Downloading Map\r");
  
      var cmd = 'cd ' + dir + '; node ' + reldownloadmap;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Downloading Map....................................................Done");
      process.stdout.write("Extracting from Shapefile\r");
  
      var cmd = 'cd ' + dir + '; node ' + relShp2geojson;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Extracting from Shapefile..........................................Done");
      process.stdout.write("Clipping maps\r");

      var cmd = 'cd ' + dir + '; node ' + relClip;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Clipping maps......................................................Done");

      if(kind == "state" || kind == "country")
      {
        process.stdout.write("Making sub-directories\r");

        var cmd = 'cd ' + dir + '; node ' + relmakedir;
        var output = exec(cmd, true);
        debug(output.stdout);
        if (output.stderr) {
          throw new Error(output.stderr);
        }
      }
      console.log("Making sub-directories ............................................Done");

      process.stdout.write("Splitting Maps\r");

      var cmd = 'cd ' + dir + '; node ' + relSplit;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Splitting Maps.....................................................Done");
      process.stdout.write("Combining Maps\r");

      var cmd = 'cd ' + dir + '; node ' + relCombine;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Combining Maps.....................................................Done");
      process.stdout.write("Adding map to database\r");

      var cmd = 'cd ' + dir + '; node ' + reladdmapstodb;
      var output = exec(cmd, true);
      debug(output.stdout);
      if (output.stderr) {
        throw new Error(output.stderr);
      }
      console.log("Adding map to database.............................................Done");
    }

    if (kind == 'world' || kind == 'state' || (kind == 'country' && sourceList[country].submap == "1")) {
      nodedir.subdirs(dir, function(err, subdirs) {
        if (err) throw err;
        async.each (subdirs, function(dir, cb) {
         actionOnDir(dir, cb);
        },
        function(err) {
          process.exit(1);
        });
      });
    }

    } catch(err) {
      console.log(err.message);
      result = 'Failed';
      cb(err.message);
    } finally {
      console.log('=======================================================================');
      console.log('Making Map for ' + dir.substr(dir.indexOf('WORLD'), dir.length) + ' ' + result);
      console.log('=======================================================================');
      cb(null);
    }
}

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
actionOnDir(src, function() {
  console.log("Map creation done");
});
