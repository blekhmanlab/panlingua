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
          <p>PanLingua allows you to <strong>search for bioRxiv preprints in your own language</strong>, using Google Translate to provide machine-generated translations of your query, the results and the full text of the preprints. Concept by <a href="https://twitter.com/humbertodebat" target="_blank">Humberto Debat</a>, <a href="https://github.com/rabdill/panlingua">code</a> by <a href="https://twitter.com/richabdill" target="_blank">Rich Abdill</a>.
        </div>
      </div>
      <div class="row">
        % if error is not None:
          <div class="col-sm-12 alert alert-danger" role="alert">
            {{ error }}
          </div>
        % end
      </div>
      <form action="/" method="post" onsubmit="return get_recaptcha()">
        <div class="form-row align-items-center">
          <div class="col-auto">
              <label class="sr-only" for="q">Search term</label>
              <input type="text" class="form-control form-control-lg" id="q" name="q" maxlength="100" placeholder="Enter a search term here" value="{{q}}">
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
            <div class="col-sm-1">
          <div class="col-sm-3">
            <a href="https://translate.google.com" target="_blank"><img src="/static/google_translate.png" style="width: 200px;"></a>
          </div>
        </div>
      </form>
    </div>
  </body>
</html>