Shiny.addCustomMessageHandler("tw_consumer_key",
  function(message) {
    app = function() {
      // facebook access token if the user is logged in and sharing permissions
      var twToken = null;
      var consumer_key = message.key;

      return {
        
        init : function() {
          // initialize hellojs
          hello.init({
          	//twitter: "kfBgv9XxrZNz0xW3DybF68cEk",
          	twitter: consumer_key
          }, {
            // Redirected page 
            oauth_proxy: 'https://auth-server.herokuapp.com/proxy'
          });
          
          hello.on('auth.login', function(auth) {
            var response = hello(auth.network).getAuthResponse();
        	  twToken = response.oauth_token;
          	// Call user information, for the given network
          	hello(auth.network).api('me').then(function(r) {
          		// Inject it into the container
          		app.changeText('login-user', 'こんにちは、'+ r.name + '=サン！ ');
          		app.changeText('twLogin', 'ログアウト');
          	});
          });
          
          hello.on('auth.logout', function(auth){
            twToken = null;
            localStorage.removeItem("hello");
        		app.changeText('login-user', '');
        		app.changeText('twLogin', 'Sign in with Twitter');
          });
    
          
          // register click event on facebook share base64 image button
          $('#twShare64Btn').click(app.twitterShare64Click);
          $('#insert').click(app.insertTwitterData);
          $('#twLogin').click(function(){
            if (twToken !== null) {
              app.twitterLogout();
            } else {
              app.twitterLogin();
            }
          });
        },
        
        dataURItoBlob : function(dataURI) {
          var binary = atob(dataURI.split(',')[1]);
          var array = [];
          for(var i = 0; i < binary.length; i++) {
              array.push(binary.charCodeAt(i));
          }
          return new Blob([new Uint8Array(array)], {type: 'image/jpeg'});
        },
          
        
        changeText : function(htmlID, txt){
      		var label = document.getElementById(htmlID);
      		label.innerHTML = txt;
        },
        
        changeValue : function(htmlID, val){
      		var label = document.getElementById(htmlID);
      		label.value = val;
        },
        
        twitterLogin : function() {
          // if the user isn't logged in or doesn't have sharing permissions,
          // prompt for it and then store the access token and attempt to sharethe image
          hello('twitter').login().then(function(r) {
          	alert('Twitterにログインしました。作った名刺をシェアしてみましょう！');
          }, function(e) {
          	alert('Signin error: ' + e.error.message);
          });
        },
    
        twitterLogout : function() {
          hello('twitter').logout().then(function(r) {
          	alert('ログアウトしました。');
          }, function(e) {
          	alert('Logout error: ' + e.error.message);
          });
        },
    
        // user clicked on sharing the base64 image
        twitterShare64Click : function() {
          // if there is an access token, call the function to share the image
          if (twToken !== null) {
            app.twitterShare64();
          } else {
            app.twitterLogin();
          }
        },
    
        // insert user data of Twitter
        insertTwitterData : function() {
          // if there is an access token, call the function to share the image
          if (twToken !== null) {
          	hello('twitter').api('me').then(function(r) {
          		var icon_url = r.profile_image_url_https.replace(/normal/g, "200x200");
          		var dat = {
          		  serif: r.description,
          		  username: r.name,
          		  tw_account: r.screen_name,
          		  site_url: r.url,
          		  icon_path: icon_url
          		};
    		      Shiny.onInputChange("insert_by_twitter", JSON.stringify(dat));
          	});
            
          } else {
            app.twitterLogin();
          }
        },
    
        // share a base64 encoded image to facebook
        twitterShare64 : function() {
      		var el_card = document.getElementById("card");
          var base64img  = el_card.querySelector("img").getAttribute('src');
          var tweet_text = document.getElementById("tweet").value;
          hello("twitter").api('me/share', 'post', {
              message : tweet_text,
              file: app.dataURItoBlob(base64img)
          }).then(function(json){
            console.log(json);
          }, function(e) {
            console.log(e);
          });
        	alert('ツイートしました！');
        }
      };
    }();
    
    $(function () { app.init(); });
  }
); 