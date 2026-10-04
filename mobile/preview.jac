import os;
import sys;
import webbrowser;
import from urllib.request { urlopen }

with entry {
    app_url = os.environ.get(
        "INTERVIEW_APP_URL", "http://localhost:8000"
    ).rstrip("/");
    preview_url = app_url + "/mobile";

    try {
        with urlopen(preview_url, timeout=10) as response {
            response.read(1);
        }
    } except Exception as e {
        print("Could not reach the mobile preview: " + preview_url);
        print("Start `jac run` in another terminal first.");
        print("If its App URL is different, set INTERVIEW_APP_URL to that URL.");
        sys.`exit(1);
    }

    print("Mobile browser preview: " + preview_url);
    print("Uses the running web application's backend and planner data.");
    if not webbrowser.open(preview_url) {
        print("Open the URL above in your browser.");
    }
}
