/**
 * Created by athakwani on 7/5/14.
 */
'use strict';

process.env.NODE_ENV = 'development';

var connection     = null;
var config         = require("../lib/config/config");
var util           = require('util');
var ok             = require('okay');
var db             = require("../lib/controllers/db");
var User           = require("../lib/controllers/user");
var Poll           = require('../lib/controllers/poll');
var usersArray     = [];
var dob = '06/07/1983';
var password = "test";
var name     = "test";
var gender   = "female";


function adduser(idx) {

  if (idx >= usersArray.length) {
    return 0;
  }

  var usr = usersArray[idx];
  console.log(usr);
  User.findByEmail(
    usr.email, function(err, user) {
      if (err) {
        console.log(err.message);
        adduser(idx + 1);
      } else if (user) {
        var vote = Math.floor((Math.random() * 100)) % 2;
        Poll.postVote('1', user.id, vote == 0 ? 2: vote, function(result) {
          console.log(result);
          adduser(idx + 1);
        })
      } else {
        User.addUser(
          usr.email,
          password,
          name,
          './public/avatar/avatar00' + Math.floor((Math.random() * 100) % 8) + '.png',
          gender,
          dob,
          usr.latitude,
          usr.longitude,
          function (err, user) {
            if (err) {
              console.log(err.message);
              adduser(idx + 1);
            } else if (user) {
              var log = util.format("Added user %s with lat %d lng %d", usr.email, usr.latitude, usr.longitude)
              //console.log (log);
              var vote = Math.floor((Math.random() * 100)) % 2;
              Poll.postVote('1', user.id, vote == 0 ? 2: vote, function(result) {
                console.log(result);
                adduser(idx + 1);
              });
            } else {
              console.log("User " + usr.email + " not added");
              adduser(idx + 1);
            }
          });
      }
    }
  );

  return 0;
}

function addusers(count) {
  var emailfrmt = "root%d@root.com";

  for (var cnt = 0; cnt < count; cnt++) {
    var email = util.format(emailfrmt, cnt);
    var latitude = (Math.random() * 100) % 90;
    var longitude = (Math.random() * 1000) % 180;
    var sign = Math.floor((Math.random() * 100)) % 2;
    var pick = Math.floor((Math.random() * 100)) % 2;

    if (pick) {
      if (sign) {
        latitude = -latitude;
      }
    } else {
      if (sign) {
        longitude = -longitude;
      }
    }
    usersArray[cnt] = {'email': email, 'latitude': latitude, 'longitude': longitude, 'sign': sign, 'pick': pick};
  }

  adduser(0);

}

addusers(5000);
