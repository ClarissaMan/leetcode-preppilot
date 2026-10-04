import json;
import os;
import sys;
import from urllib.request { Request, urlopen }

def planner_request(
    endpoint: str,
    payload: dict[str, any]
) -> list[dict[str, any]] {
    base_url = os.environ.get(
        "INTERVIEW_API_URL",
        "http://localhost:8001"
    ).rstrip("/");

    request = Request(
        base_url + "/function/" + endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    );

    with urlopen(request, timeout=20) as response {
        result = json.loads(response.read().decode("utf-8"));
    }

    if not result.get("ok", False) {
        raise RuntimeError("Server request failed");
    }

    return result["data"]["result"];
}

def run_interview_cli(args: list[str]) -> int {
    if not args or args[0] == "--help" {
        print("PrepPilot");
        print("");
        print("Commands:");
        print("  today");
        print("  complete <problem-number>");
        return 0;
    }

    command = args[0];

    if command not in ["today", "complete"] {
        print("Unknown command. Use --help.");
        return 2;
    }

    if command in ["today"] and len(args) != 1 {
        print("Usage: " + command);
        return 2;
    }

    if command == "complete" {
        if len(args) != 2 {
            print("Usage: complete <problem-number>");
            return 2;
        }

        try {
            problem_number = int(args[1]);
        } except Exception {
            print("Problem number must be an integer.");
            return 2;
        }
    }

    try {
        if command == "today" {
            plan = planner_request("get_today_plan", {});
        } 
        else {
            plan = planner_request(
                "complete_plan_problem",
                {"problem_number": problem_number}
            );
        }

        print("");
        print("PREPPILOT — TODAY'S PLAN");
        print("");

        completed = 0;

        for item in plan {
            marker = "x" if item["done"] else " ";

            if item["done"] {
                completed += 1;
            }

            print(
                f"[{marker}] LC {item['problem_number']} "
                f"— {item['minutes']} min"
            );
            last_practiced = item.get("last_practiced", "") or "Never";
            confidence = item.get("confidence", 1);
            print(f"    Confidence {confidence}/5; Last Practiced: {last_practiced}");
        }

        print("");
        print(f"{completed} / {len(plan)} completed");
        return 0;

    } except Exception as e {
        print("PrepPilot error: Could not complete the request. Please make sure the server is running and try again.");
        return 1;
    }
}

with entry {
    sys.`exit(run_interview_cli(sys.argv[1:]));
}