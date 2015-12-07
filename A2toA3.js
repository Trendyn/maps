/**
 * Created by athakwani on 11/9/14.
 */
var nodedir     = require('node-dir');
var exec        = require('exec-sync');
var fs          = require('fs');
var A2toA3      = JSON.parse(fs.readFileSync(__dirname + '/A2toA3.json', 'utf8'));

/*-------------------------------------------------------------
 Script Entry Point.
 -------------------------------------------------------------*/
function Main()
{
  nodedir.files(process.cwd(), function(err, files) {
    if (err) throw err;
    console.log(files);
    for (var idx in files) {
      var split = files[idx].split('/');
      var filename = split[split.length - 1];
      filename = filename.split('.')[0];
      var re = new RegExp(filename, "g");
      var newfile = files[idx].replace(re, A2toA3[filename]);

      cmd = 'mv ' + files[idx] + ' ' + newfile;
      console.log(cmd);
      output = exec(cmd, true);
    }
  });
}

Main();