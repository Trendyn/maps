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

var path        = require('path');
var glob        = require('glob');
var fs          = require('fs');
var exec        = require('exec-sync');
var debug       = require('debug');
var addmapstodb = __dirname + '/addmaptodb.js';


function actionOnDir(dir)
{

  var result = "Passed";
  var reladdmapstodb = path.relative(dir, addmapstodb);


  try {

    console.log('=======================================================================');
    console.log('Adding Map to db for ' + dir );
    console.log('=======================================================================');
    process.stdout.write("Adding map to database\r");

    var cmd = 'cd ' + dir + '; node ' + reladdmapstodb;
    var output = exec(cmd, true);
    debug(output.stdout);
    if (output.stderr) {
      throw new Error(output.stderr);
    }
    console.log("Adding map to database.............................................Done");

    } catch(err) {
      console.log(err.message);
      result = 'Failed';
    } finally {
      console.log('=======================================================================');
      console.log('Making Map for ' + dir + ' ' + result);
      console.log('=======================================================================');
    }
}

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main(dir)
{
  actionOnDir(dir);

  glob('*', function(err, files) {
      files.forEach(function (dir) {
        fs.stat(dir, function (err, stat) {
          if(stat.isDirectory()) {
            actionOnDir(dir);
          }
        });
      });
    }
  );}

Main(process.cwd());