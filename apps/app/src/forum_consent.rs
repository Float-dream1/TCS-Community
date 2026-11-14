//! Pre-accepts the cookie banner of the embedded community forum.
//!
//! The forum page in the launcher is a cross-origin `<iframe>`, so the
//! frontend cannot touch its storage. The cookie the forum's consent library
//! (`fof/cookie-consent`, built on vanilla-cookieconsent) reads lives in the
//! shared WebView2 cookie jar instead, which the launcher can write directly.
//!
//! An existing cookie is left untouched: a player who declined on the site
//! keeps that decision.

use std::time::Duration as StdDuration;

use tauri::WebviewWindow;
use tauri::webview::cookie::{
    Cookie, SameSite, time::Duration as CookieDuration,
};
use url::Url;

const FORUM_URL: &str = "https://www.tcscraft.com/";
const CONSENT_COOKIE: &str = "cc_cookie";
const CONSENT_COOKIE_DOMAIN: &str = "www.tcscraft.com";
const CONSENT_COOKIE_DAYS: i64 = 182;
const ATTEMPTS: u32 = 20;
const RETRY_DELAY: StdDuration = StdDuration::from_millis(500);

/// Values the forum stores for a visitor that accepted the default categories.
///
/// The forum only declares a `necessary` category, so accepting it is the
/// whole banner. The value is percent-encoded because the consent library
/// runs `decodeURIComponent` before parsing the JSON.
fn consent_value() -> String {
    let now =
        chrono::Utc::now().to_rfc3339_opts(chrono::SecondsFormat::Secs, true);
    let consent_id = uuid::Uuid::new_v4();
    let payload = format!(
        r#"{{"categories":["necessary"],"revision":0,"data":null,"consentId":"{consent_id}","consentTimestamp":"{now}","lastConsentTimestamp":"{now}","services":{{}}}}"#
    );

    urlencoding::encode(&payload).into_owned()
}

fn consent_cookie() -> Cookie<'static> {
    // `Cookie::build` percent-encodes the value it is given, which would
    // double-encode the payload above, so the raw value is set afterwards.
    let mut cookie = Cookie::build((CONSENT_COOKIE, "necessary"))
        .domain(CONSENT_COOKIE_DOMAIN)
        .path("/")
        .secure(true)
        .same_site(SameSite::Lax)
        .max_age(CookieDuration::days(CONSENT_COOKIE_DAYS))
        .build();
    cookie.set_value(consent_value());
    cookie
}

enum Outcome {
    Stored,
    AlreadyPresent,
}

fn preset(window: &WebviewWindow) -> Result<Outcome, String> {
    let url = Url::parse(FORUM_URL).map_err(|error| error.to_string())?;
    let existing = window
        .cookies_for_url(url)
        .map_err(|error| error.to_string())?;
    if existing
        .iter()
        .any(|cookie| cookie.name() == CONSENT_COOKIE)
    {
        return Ok(Outcome::AlreadyPresent);
    }

    window
        .set_cookie(consent_cookie())
        .map_err(|error| error.to_string())?;

    Ok(Outcome::Stored)
}

/// Writes the consent cookie once the webview can reach its cookie jar.
pub fn install(window: &WebviewWindow) {
    let window = window.clone();

    tauri::async_runtime::spawn(async move {
        for _ in 0..ATTEMPTS {
            match preset(&window) {
                Ok(Outcome::Stored) => {
                    tracing::info!(
                        "Pre-accepted the community forum cookie banner"
                    );
                    return;
                }
                Ok(Outcome::AlreadyPresent) => return,
                Err(error) => {
                    tracing::debug!(
                        "Could not preset the community cookie consent yet: {error}"
                    );
                }
            }

            tokio::time::sleep(RETRY_DELAY).await;
        }

        tracing::warn!(
            "Gave up presetting the community forum cookie consent cookie"
        );
    });
}
