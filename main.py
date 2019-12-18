"""Configures and launches the PanLingua web app

On startup, the application fetches a list of currently supported
languages from the Google Cloud Translate API.
"""
import json
import os.path
import sys
import bottle
from google.cloud import translate_v2 as translate
import requests
import config
import content

# phone google to get a list of available languages
GOOGLE = translate.Client()
LANGDATA = GOOGLE.get_languages()
LANGUAGES = {}
if len(LANGDATA) < 50:
    print("FATAL: Didn't get a good list of languages from Google.")
    sys.exit(1)

for x in LANGDATA:
    LANGUAGES[x['language']] = x['name']

# The app stores a translated version of its homepage, and updates the page
# to reflect the language selected by the user.
do_translate = True
if os.path.exists('translations.json'):
    with open('translations.json','r') as f:
        print('Pulling translations from file!')
        content.text = json.load(f)
        do_translate = False
    if len(content.text.keys()) < 50:
        print('Data in translations file looks funny. Re-translating.')
        do_translate = True
if do_translate:
    # translate all the content into languages
    for lang in LANGUAGES.keys():
        if lang == 'en': continue
        print(f"Translating text into {lang}")
        content.text[lang] = {}
        for entry, text in content.text['en'].items():
            resp = GOOGLE.translate(text, source_language='en', target_language=lang)
            content.text[lang][entry] = resp['translatedText']

    with open('translations.json','w') as f:
        print("RECORDING!")
        json.dump(content.text, f)

# - ROUTES -
@bottle.get('/')
def index():
    """The application homepage.

    Returns the homepage (the app's only page), populated with the
    list of languages and prompting the user for a search query. The
    form submits to the same URL.

    Inputs are all pulled from the bottle.request.query object. This
    will probably never actually be used, but it would allow someone
    to link to a search form that's filled in ahead of time:
    - q: The search string entered by the user
    - lang: An "alpha-2" abbreviation (ISO 3166) of the source language
        selected by the user
    """
    query = bottle.request.query.q
    lang = bottle.request.query.lang
    if lang == "":
        lang = "en"
    return bottle.template('index', lang=lang, q=query, languages=LANGUAGES, content=content, error=None, config=config.to_display)

@bottle.post('/')
def search():
    """Processes POST requests to the homepage

    Translates the query into English and redirects the user directly
    to a bioRxiv search page.

    Inputs are all pulled from the POSTed form:
    - q: The search string entered by the user
    - lang: An "alpha-2" abbreviation (ISO 3166) of the source language
        selected by the user
    - recaptcha_response: A token obtained by the reCAPTCHA service when
        the form is loaded. Designed to prevent automated submissions.
    """
    query = bottle.request.forms.getunicode('q')
    lang = bottle.request.forms.get('lang')

    traceback = {'query':query, 'lang':lang}

    # validate the recaptcha
    if config.recaptcha_private is not None:
        recaptcha = bottle.request.forms.get('recaptcha_response')
        if recaptcha in ['', None]:
            raise bottle.HTTPError(status=500, body="Unable to validate authenticity of request (no reCAPTCHA data).", traceback=traceback)

        body = {
            'secret': config.recaptcha_private,
            'response': recaptcha,
            'remoteip': bottle.request.remote_addr # TODO: is this reliable?
        }
        resp = requests.post('https://www.google.com/recaptcha/api/siteverify', data=body)
        if resp.status_code != 200:
            raise bottle.HTTPError(status=500, body="Unable to validate authenticity of request (error returned from Google).", traceback=traceback)
        try:
            validate = resp.json()
        except:
            raise bottle.HTTPError(status=500, body="Unable to validate authenticity of request (unable to decode Google response).", traceback=traceback)
        if 'success' not in validate.keys():
            raise bottle.HTTPError(status=500, body="Unable to validate authenticity of request.", traceback=traceback)
        if not validate['success']:
            raise bottle.HTTPError(status=400, body="Request flagged as suspicious, sorry.", traceback=traceback)

    if query in [None, '']:
        raise bottle.HTTPError(status=400, body="Request must specify a query and a source language.", traceback=traceback)
    if lang in [None, '']:
        traceback['lang'] = 'es' # default to spanish if something weird happens
        raise bottle.HTTPError(status=400, body="Request must specify a query and a source language.", traceback=traceback)
    if lang not in LANGUAGES.keys():
        traceback['lang'] = 'es'
        raise bottle.HTTPError(status=400, body="Unrecognized language specified", traceback=traceback) # default to spanish
    if lang == 'en':
        raise bottle.HTTPError(status=400, body="English translation is not supported; use biorxiv.org search directly.", traceback=traceback)
    if len(query) > 100:
        raise bottle.HTTPError(status=400, body="The query is too long. Limit is 100 letters.", traceback=traceback)
    resp = GOOGLE.translate(query, source_language=lang)
    return bottle.redirect(f"https://translate.google.com/translate?sl=en&tl={lang}&u=https%3A%2F%2Fwww.biorxiv.org%2Fsearch%2F{resp['translatedText']}", 303)

@bottle.error(400)
def error400(error):
    print(error)
    return bottle.template('index', lang=error.traceback['lang'], q="", languages=LANGUAGES, content=content, config=config.to_display, error=error.body)
@bottle.error(404)
def error404(error):
    return bottle.template('index', lang="es", q="", languages=LANGUAGES, content=content, config=config.to_display, error=error.body)
@bottle.error(500)
def error500(error):
    return bottle.template('index', lang="es", q="", languages=LANGUAGES, content=content, config=config.to_display, error=error.body)

# Search engine stuff
@bottle.route('/robots.txt')
def robots():
    return bottle.static_file(filename='robots.txt', root='./static/')
@bottle.route('/favicon.ico')
def favicon():
    return bottle.static_file(filename='favicon.ico', root='./static/')

# - SERVER -
@bottle.route('/static/<path:path>')
def callback(path):
    return bottle.static_file(path, root='./static/')

if config.prod:
  bottle.run(host='0.0.0.0', port=80, server="gunicorn")
else:
  bottle.run(host='0.0.0.0', port=80, debug=True, reloader=True)
