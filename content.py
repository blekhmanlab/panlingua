from config import to_display as config

text = {
    'en': {
        'subtitle': 'A multilingual pre-print search tool',
        'jswarning': 'JavaScript is required for this page to function.',
        'description': 'PanLingua enables you to search in your own language for pre-prints on bioRxiv.org. It uses Google Translate to provide machine-generated translations of your query, the results and the text of the manuscripts.',
        'search_label': 'Search term',
        'language_label': 'Language',
        'privacy_toggle': 'Privacy',
        'privacy_header': 'Privacy',
        'source_link': 'Source code',
        'privacy_text': 'We do not store the contents of any query. All translation is performed by Google. '
    }
}
if config['recaptcha_public'] is not None:
    text['en']['privacy_text'] += "PanLingua uses Google's reCAPTCHA v3 service to fight spam and abuse of the service. "
if config['google_analytics_tag'] is not None:
    text['en']['privacy_text'] += 'Panlingua '
if config['recaptcha_public'] is not None:
    text['en']['privacy_text'] += 'also '
if config['google_analytics_tag'] is not None:
    text['en']['privacy_text'] += 'uses Google Analytics (with all advertising features disabled) to better understand how visitors use our site. '