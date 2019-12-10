<!doctype html>
<html lang="en" ng-app="app">
  <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      % if config['google_analytics_tag'] is not None:
        <!-- Global site tag (gtag.js) - Google Analytics -->
        <script async src="//www.googletagmanager.com/gtag/js?id={{config['google_analytics_tag']}}"></script>
        <script>
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '{{config['google_analytics_tag']}}');
        </script>
      % end

      % if config['recaptcha_public'] is not None:
        <script src="//www.google.com/recaptcha/api.js?render={{config['recaptcha_public']}}"></script>
        <script>
          get_recaptcha = function() {
            grecaptcha.execute('{{config['recaptcha_public']}}', {action: 'homepage'}).then(function(token) {
              var recaptchaResponse = document.getElementById('recaptchaResponse');
              recaptchaResponse.value = token;
            });
          }
          //grecaptcha.ready();
        </script>
      % end
      <script>
        toggle_privacy = function() {
          var fineprint = document.getElementById('fineprint');
          if(fineprint.style.display == "none") fineprint.style.display = "block";
          else fineprint.style.display = "none";
        }
      </script>

      <link rel="stylesheet" href="/static/bootstrap.min.css">
      <style>
        body {
          background-color: #a1a1a1;
        }
        h1,h2,h3,h4 {
          font-family: Georgia;
        }
        #main {
          background-color: #fff;
          border-radius: 20px;
          padding: 15px;
          padding-top: 20px;
          margin-top: 10%;
        }
        a:hover {
          text-decoration: none;
        }
      </style>

    <title>PanLingua</title>
  </head>
  <body>
    <div class="container" id="main">
      <div class="row">
        <div class="col-md-6">
          <h1><strong>Pan<i><font color="red">L</font></i>ingua</strong></h1>
          <h4>A multilingual preprint search tool</h2>
        </div>
        <div class="col-md-6">
          <p>PanLingua allows you to <strong>search in your own language for <a href="https://biorxiv.org" target="_blank">bioRxiv</a> preprints</strong>. It uses Google Translate to provide machine-generated translations of your query, the results and the full text of the preprints. There is no affiliation between PanLingua and bioRxiv.<br>
          Concept by <a href="https://twitter.com/humbertodebat" target="_blank">Humberto Debat</a>, code by <a href="https://twitter.com/richabdill" target="_blank">Rich Abdill</a>.
        </div>
      </div>
      <div class="row">
        % if error is not None:
          <div class="col-sm-12 alert alert-danger" role="alert">
            {{ error }}
          </div>
        % end
      </div>
      <div id="jsWarning">
        <strong>JavaScript is required for this page to function properly.</strong>
      </div>
      <form action="/" id="searchform" method="post" onsubmit="return get_recaptcha()" style="display:none">
        <div class="form-row align-items-center">
          <div class="col-auto">
              <label class="sr-only" for="q">Search term</label>
              <input type="text" class="form-control form-control-lg" id="q" name="q" maxlength="100" placeholder="Enter a search term here" value="{{q}}" autofocus>
          </div>
          <div class="col-auto">
            <label class="sr-only" for="lang">Language</label>
            <select class="form-control-lg" name="lang">
              % for code, name in languages.items():
                <option value="{{code}}"
                %if lang == code:
                  selected
                %end
                >{{name}}</option>
              % end
            </select>
          </div>
          <input type="hidden" name="recaptcha_response" id="recaptchaResponse">
          <div class="col-auto">
            <button type="submit" class="btn btn-lg" style="background-color:red"><strong>Search</strong></button>
          </div>
        </div>
        <div class="form-row align-items-center">
          <div class="col-sm-3 offset-sm-1">
            <a href="https://translate.google.com" target="_blank"><img src="/static/google_translate.png" style="width: 200px;"></a>
          </div>
        </div>
      </form>
      <div class="row">
        <div class="col-sm-12" style="text-align: right;">
          <a href="https://github.com/rabdill/panlingua">Source code</a> | <a href="#" onclick="toggle_privacy();">Privacy</a>
        </div>
      </div>
      <div class="row" id="fineprint" style="display:none">
        <div class="col-sm-8">
          <h2>Privacy</h2>
          <p>We do not store the contents of any query; all translation is handled by Google.
          % if config['recaptcha_public'] is not None:
            PanLingua uses Google's reCAPTCHA v3 service to fight spam and abuse of the service.
          % end
          % if config['google_analytics_tag'] is not None:
            It
            % if config['recaptcha_public'] is not None:
              also
            % end
            uses Google Analytics (with all advertising features disabled) to better understand how visitors use our site.
          % end
          % if config['google_analytics_tag'] is not None or config['recaptcha_public'] is not None:
            In all cases, the
          % else:
            The
          % end
          Google <a href="https://policies.google.com/privacy">privacy policy</a> and <a href="https://policies.google.com/terms">terms of service</a> apply.
        </div>
      </div>
    </div>

    <script>
      // Make sure users have JS working so we can use reCAPTCHA
      document.getElementById('jsWarning').style.display = "none";
      document.getElementById('searchform').style.display = "block";
    </script>
  </body>
</html>