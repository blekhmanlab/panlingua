# PanLingua

PanLingua is a simple shortcut to searching for preprints on bioRxiv.org using non-English search terms. Most of the work is done by Google and bioRxiv:

1. A user arrives at panlingua.rxivist.org. They are presented with a search box and a list of languages supported by the Google Cloud Translate API.
1. The user inputs a search term in their chosen language and submits the form.
1. The user's input is sent to the Google Cloud Translate API, which provides an English translation of the search term.
1. The translated search term is used to generate a URL of the standard bioRxiv search.
1. The generated bioRxiv URL is passed to translate.google.com, which provides a translated version of that page in whatever language was originally selected by the user.
1. The user is redirected to the translate.google.com page with the search results.

## Contact:

* Humberto Debat, research scientist, Instituto Nacional de Tecnología Agropecuaria (IPAVE-CIAP-INTA)
  * debat.humberto *at* inta.gob.ar
* Rich Abdill, PhD student, University of Minnesota
  * rabdill *at* umn.edu

## Deployment

### Setting up third-party services

PanLingua knits together three Google services: the [Cloud Translation API](https://cloud.google.com/translate/), [reCAPTCHA v3](https://www.google.com/recaptcha/intro/v3.html), and [Google Analytics](https://analytics.google.com).

* Only the Translation API is required.
  * Sign up for a [Google Cloud](https://cloud.google.com) account and enable the Cloud Translation API.
  * Follow [their instructions](https://cloud.google.com/docs/authentication/production) for creating a service account and obtaining a credentials file. This file is how the PanLingua will authenticate to the Google API.
  * Rename this file `google_cloud_credentials.json` and put it in the application's root directory (the same directory holding this README and `main.py`).
* Google reCAPTCHA is optional, but highly recommended if you're exposing your website to the public.
  * Sign up for [reCAPTCHA v3](https://www.google.com/recaptcha/intro/v3.html).
  * Once registration is complete, you'll be given a public and private key for the reCAPTCHA API. Paste these values into `config.py` in the `recaptcha_public` and `recaptcha_private` spots, respectively.
  * For local development, **you'll likely have to disable reCAPTCHA**; the client-side code won't work if it's run from `localhost` instead of whatever production URL you specified to Google.
* Google Analytics is optional.
  * Sign up for an [Analytics account](https://analytics.google.com).
  * Once registration is complete, you'll receive a snippet of Javascript. Within this snippet you'll find an ID that looks something like `UA-123456`. Copy this ID and set it as the value for the `google_analytics_tag` value in `config.py`.

### Development

Working on PanLingua locally does not *require* Docker, but you can avoid cluttering your local environment by [installing it for free](https://hub.docker.com/?overlay=onboarding).

Once Docker is installed and running in the background, you can launch a development environment by running command from the application's root directory:

```sh
docker run -it --rm --name panlingua -p 8120:80 -v "$(pwd)":/app --env GOOGLE_APPLICATION_CREDENTIALS="/app/google_cloud_credentials.json" python:slim bash
```

You run this command, the PanLingua application should be available in your browser at `http://localhost:8120`

You can also launch the application outside of a container. (Using a virtual environment is not required, but is also probably a good idea.) To run the app locally, navigate to the application's root directory and run the following commands:

```sh
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/google_cloud_credentials.json"
pip install -r requirements.txt
python main.py
```

### Production

There are many options for running a Python application in production; we leave these decisions to you. One important note is that the `GOOGLE_APPLICATION_CREDENTIALS` environment variable must be set wherever the application is running.