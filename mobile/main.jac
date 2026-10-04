import from "@jac/mobui" {
    View,
    Text,
    Pressable,
    ScrollView,
    Platform
}

def:pub app -> JsxElement {
    has plan: list[dict[str, any]] = [],
        busy: bool = True,
        message: str = "";

    async def request_plan(
        endpoint: str,
        payload: dict[str, any]
    ) -> list[dict[str, any]] {
        backend_host = (
            ""
            if Platform.OS == "web"
            else (
                "http://10.0.2.2:8001"
                if Platform.OS == "android"
                else "http://localhost:8001"
            )
        );

        response = await fetch(
            backend_host + "/function/" + endpoint,
            {
                "method": "POST",
                "headers": {
                    "Content-Type": "application/json",
                    "X-Jac-Endpoint": JSON.stringify([
                        "",
                        "core/prep_pilot.jac",
                        "func",
                        endpoint
                    ])
                },
                "body": JSON.stringify(payload)
            }
        );

        if not response.ok {
            error_body = await response.text();
            raise Exception(
                "HTTP " + str(response.status) + ": " + error_body
            );
        }

        result: any = await response.json();

        if not result["ok"] {
            raise Exception(JSON.stringify(result));
        }

        return result["data"]["result"];
    }

    async def load_plan() -> None {
        busy = True;
        message = "";

        try {
            plan = await request_plan("get_today_plan", {});
        } except Exception as e {
            message = "Could not load today's plan. Please try again.";
        }

        busy = False;
    }

    async def generate_another_plan() -> None {
        busy = True;
        message = "";

        try {
            plan = await request_plan(
                "generate_today_plan",
                {
                    "goal": "Prepare for SWE interviews",
                    "available_minutes": 90,
                    "problem_count": 3,
                    "topic": "Random"
                }
            );
            message = "New plan generated.";
        } except Exception as e {
            message = "Could not generate a coding plan. Please try again.";
        }

        busy = False;
    }

    async def complete_problem(problem_number: int) -> None {
        busy = True;
        message = "";

        try {
            plan = await request_plan(
                "complete_plan_problem",
                {"problem_number": problem_number}
            );
            message = "Saved.";
        } except Exception as e {
            message = "Could not save your progress. Please try again.";
        }

        busy = False;
    }

    async can with entry {
        await load_plan();
    }

    completed = len([item for item in plan if item["done"]]);

    return <ScrollView
        style={{
            "flex": 1,
            "backgroundColor": "#f5f7fb"
        }}
        contentContainerStyle={{
            "padding": 24,
            "paddingTop": 64,
            "paddingBottom": 48
        }}
    >
        <Text style={{
            "fontSize": 30,
            "fontWeight": "700",
            "color": "#172033"
        }}>
            PrepPilot
        </Text>

        <Text style={{
            "fontSize": 16,
            "marginTop": 8,
            "color": "#526078"
        }}>
            Today's adaptive LeetCode plan
        </Text>

        <Text style={{
            "fontSize": 18,
            "fontWeight": "600",
            "marginTop": 24,
            "color": "#172033"
        }}>
            {completed} / {len(plan)} completed
        </Text>

        {[
            <View
                key={item["problem_number"]}
                style={{
                    "backgroundColor": "#ffffff",
                    "padding": 20,
                    "borderRadius": 16,
                    "marginTop": 16,
                    "borderWidth": 1,
                    "borderColor": "#dce2ec"
                }}
            >
                <Text style={{
                    "fontSize": 18,
                    "fontWeight": "600",
                    "color": "#172033"
                }}>
                    {"LC " + str(item["problem_number"])}
                </Text>

                <Text style={{
                    "marginTop": 8,
                    "color": "#526078"
                }}>
                    {item["minutes"]} min · Confidence: {item["confidence"]}/5
                </Text>
                <Text style={{
                    "marginTop": 8,
                    "color": "#526078"
                }}>
                    Last practiced: {
                        item["last_practiced"]
                        if item["last_practiced"] != ""
                        else "Never"
                    }
                </Text>
                
                <Pressable
                    disabled={busy or item["done"]}
                    onPress={lambda {
                        complete_problem(item["problem_number"]);
                    }}
                    style={{
                        "marginTop": 16,
                        "padding": 14,
                        "borderRadius": 10,
                        "backgroundColor": (
                            "#dcfce7"
                            if item["done"]
                            else "#dbeafe"
                        )
                    }}
                >
                    <Text style={{
                        "fontWeight": "600",
                        "color": "#172033",
                        "textAlign": "center"
                    }}>
                        {"Completed" if item["done"] else "Mark complete"}
                    </Text>
                </Pressable>
            </View>
            for item in plan
        ]}

        <Pressable
            disabled={busy}
            onPress={generate_another_plan}
            style={{
                "marginTop": 24,
                "padding": 16,
                "borderRadius": 10,
                "backgroundColor": "#172033"
            }}
        >
            <Text style={{
                "color": "#ffffff",
                "fontWeight": "600",
                "textAlign": "center"
            }}>
                Generate Another Coding Plan
            </Text>
        </Pressable>

        <Text style={{
            "marginTop": 12,
            "color": "#526078"
        }}>
            {"Loading or saving..." if busy else message}
        </Text>
    </ScrollView>;
}
