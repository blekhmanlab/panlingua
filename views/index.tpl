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
          grecaptcha.ready(get_recaptcha);
        </script>
      % end
      <script>
        function form_submit() {
          % if config['google_analytics_tag'] is not None:
            var selected_language = document.getElementById('lang');
            ga('send', 'event', 'Translation', 'Submit', selected_language.value);
          % end
          % if config['recaptcha_public'] is not None:
            get_recaptcha()
          % end
          return true
        }
        function toggle_privacy() {
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
          <h4><span id="subtitle"></span></h2>
        </div>
        <div class="col-md-6">
          <p><span id="description"></span>
          There is no affiliation between PanLingua and <a href="https://biorxiv.org" target="_blank">bioRxiv</a>.<br>
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
        <strong><span id="jswarning">JavaScript required</span></strong>
      </div>
      <form action="/" id="searchform" method="post" onsubmit="return form_submit()" style="display:none">
        <div class="form-row align-items-center">
          <div class="col-auto">
              <label class="sr-only" for="q"><span id="search_label"></span></label>
              <input type="text" class="form-control form-control-lg" id="q" name="q" maxlength="100" placeholder="Search" value="{{q}}" autofocus>
          </div>
          <div class="col-auto">
            <label class="sr-only" for="lang"><span id="language_label"></span></label>
            <select class="form-control-lg" name="lang" id="lang" onchange="translate_page()">
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
          <a href="https://github.com/rabdill/panlingua"><span id="source_link"></span></a> | <a href="#" onclick="toggle_privacy();"><span id="privacy_toggle"></span></a>
        </div>
      </div>
      <div class="row" id="fineprint" style="display:none">
        <div class="col-sm-8">
          <h2 id="privacy_header"></h2>

          <p><span id="privacy_text"></span> The Google <a href="https://policies.google.com/privacy">privacy policy</a> and <a href="https://policies.google.com/terms">terms of service</a> apply.
        </div>
      </div>
    </div>

    <script>
      // Make sure users have JS working so we can use reCAPTCHA
      document.getElementById('jsWarning').style.display = "none";
      document.getElementById('searchform').style.display = "block";
    </script>
    <script>
      translate_page = function(lang) {
        if(lang==undefined) {
          lang = document.getElementById('lang').value;
        }
        console.log("Translating page into " + lang)

        // make the URL reflect the current language
        window.history.pushState(null, null, window.location.origin+"/?lang="+lang);

        for(var entry in text[lang]) {
          document.getElementById(entry).innerHTML = text[lang][entry];
        }
        // translate the text box:
        document.getElementById('q').placeholder = text[lang]['search_label'];
      }
      text = {}
      % for lang in content.text.keys():
        text['{{ lang }}'] = {
        % for entry, translation in content.text[lang].items():
          '{{ entry}}': "{{ translation }}",
        % end
        };
      % end

      translate_page();
    </script>
  </body>
</html>