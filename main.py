"""Configures and launches the PanLingua web app

On startup, the application fetches a list of currently supported
languages from the Google Cloud Translate API.
"""

import sys
import bottle
from google.cloud import translate_v2 as translate
import config

# phone google to get a list of available languages
GOOGLE = translate.Client()
LANGDATA = GOOGLE.get_languages()
LANGUAGES = {}
if len(LANGDATA) < 50:
    print("FATAL: Didn't get a good list of languages from Google.")
    sys.exit(1)

for x in LANGDATA:
    LANGUAGES[x['language']] = x['name']

# - ROUTES -
@bottle.get('/')
def index():
    """The application homepage.

    It responds to empty requests by returning the homepage (the app's
    only page), populated with the list of languages and prompting the
    user for a search query. The form submits to the same URL. If a
    request comes in with a query attached, the app translates the query
    into English and redirects the user directly to a bioRxiv search page.

    Inputs are all pulled from the bottle.request.query object:
    - q: The search string entered by the user
    - lang: An "alpha-2" abbreviation (ISO 3166) of the source language
        selected by the user
    """
    query = bottle.request.forms.get('q')
    lang = bottle.request.forms.get('lang')
    recaptcha = bottle.request.forms.get('recaptcha_response')
    print(f'|{recaptcha}|')
    print('---')
    error = (None, None)
    if lang == "": # default to spanish
        lang = "es"
    if query is None:
        return bottle.template('index', lang=lang, q=query, languages=LANGUAGES, error=None, config=config.to_display)
    if len(query) > 100:
        raise bottle.HTTPError(status=400, body="The query is too long. Limit is 100 letters.")
        # It's tempting to translate errors into the language specified by the
        # user, but that could allow a malicious user to trick us into sending
        # lots of calls to Google without bothering to form a legitimate query
    if lang not in LANGUAGES.keys():
        raise bottle.HTTPError(status=400, body="Unrecognized language specified")

    resp = GOOGLE.translate(query, source_language=lang)
    return bottle.redirect(f"https://translate.google.com/translate?sl=en&tl={lang}&u=https%3A%2F%2Fwww.biorxiv.org%2Fsearch%2F{resp['translatedText']}", 303)

@bottle.error(400)
def error400(error):
    return bottle.template('index', lang="es", q="", languages=LANGUAGES, config=config.to_display, error=error.body)
@bottle.error(404)
def error404(error):
    return bottle.template('index', lang="es", q="", languages=LANGUAGES, config=config.to_display, error=error.body)

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

bottle.run(host='0.0.0.0', port=80, debug=True, reloader=True)
