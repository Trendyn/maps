#!/usr/bin/node
/*
 This code is licensed to OpinionCurrent Owners.

 Dependencies:
 1. node-dir

 Revision History

 Committer   Date         Change
 ==============================================================
 Ashish     10/30/2014    Initial Version

 */

var exec        = require('exec-sync');
var debug       = require('debug');
var src         = process.cwd();

function Main()
{
  var cmd = "cd " + src + "; sed 's/180\\.000/179\\.000/g' < all.json > cliped.json; rm all.json; mv cliped.json all.json";
  console.log(cmd);
  var output = exec(cmd, true);
  debug(output.stdout);
  if (output.stderr) {
    debug(output.stderr);
  }
}

Main();