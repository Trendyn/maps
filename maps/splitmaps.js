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

var path     = require('path');
var nodedir  = require('node-dir');
var exec     = require('exec-sync');
var splitScriptPath = __dirname + '/split.js';

function actionOnDir(dir)
{
  console.log(process.cwd());
  var relSplitScriptPath = path.relative(dir, splitScriptPath);
  var cmd = 'cd ' + dir + '; node ' + relSplitScriptPath + ' map.json';
    console.log("Executing: " + cmd);
  var output = exec(cmd, true);
  console.log(output.stdout);
  console.log(output.stderr);
}

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main()
{
  if (process.argv.length < 3) {
    console.log('Usage: node ' + process.argv[1] + ' <root dir>');
  }

  root = process.argv[2];

  nodedir.subdirs(root, function(err, subdirs) {
    if (err) throw err;
    subdirs.forEach(function(path) {
      actionOnDir(path);
    })
  });
}

Main();