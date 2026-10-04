import from core.prep_pilot {
    PrepProblem,
    DailyPlanItem,
    prepare_problem_library,
    get_today_plan,
    generate_today_plan,
    complete_plan_problem
}

def:pub page -> JsxPage {
    has problems: list[PrepProblem] = [],
        plan: list[DailyPlanItem] = [],
        busy: bool = True,
        message: str = "",
        warning: str = "",
        total_minutes: int = 0,
        generate_count: str = "3",
        generate_topic: str = "Random";

    async def load_prep() -> None {
        busy = True;
        message = "";

        try {
            problems = await prepare_problem_library();
            plan = await get_today_plan();
            total_minutes = sum([item.minutes for item in plan]);
        } except Exception as e {
            message = "Could not load PrepPilot. Please refresh and try again.";
        }

        busy = False;
    }

    async def generate_another_plan() -> None {
        busy = True;
        message = "";
        warning = "";

        try {
            count = int(generate_count);
            plan = await generate_today_plan(
                "Prepare for SWE interviews",
                90,
                count,
                generate_topic
            );
            total_minutes = sum([item.minutes for item in plan]);
            message = f"Generated {len(plan)} problem(s) using your practice history.";
            if generate_topic != "Random" and len(plan) < count {
                warning = f"Only {len(plan)} problem(s) are available for this topic.";
            }
        } except Exception as e {
            message = "Could not generate a coding plan. Please try again.";
        }

        busy = False;
    }

    async def complete_problem(problem_number: int) -> None {
        busy = True;
        message = "";

        try {
            plan = await complete_plan_problem(problem_number);
            message = "Practice marked complete.";
        } except Exception as e {
            message = "Could not save your progress. Please try again.";
        }

        busy = False;
    }

    def problem_for(number: int) -> PrepProblem | None {
        for problem in problems {
            if problem.number == number {
                return problem;
            }
        }

        return None;
    }

    def problem_title(number: int) -> str {
        problem = problem_for(number);
        return problem.title if problem else "Problem";
    }

    def problem_topic(number: int) -> str {
        problem = problem_for(number);
        return problem.topic if problem else "";
    }

    def problem_difficulty(number: int) -> str {
        problem = problem_for(number);
        return problem.difficulty if problem else "";
    }

    def problem_confidence(number: int) -> int {
        problem = problem_for(number);
        return problem.confidence if problem else 1;
    }

    def problem_last_practiced(number: int) -> str {
        problem = problem_for(number);
        if problem is None or problem.last_practiced == "" {
            return "Never";
        }
        return problem.last_practiced;
    }

    completed = len([item for item in plan if item.done]);

    can with entry {
        load_prep();
    }

    return <main style={{
        "maxWidth": "900px",
        "margin": "40px auto",
        "padding": "24px",
        "fontFamily": "Arial, sans-serif",
        "color": "#172033"
    }}>
        <header>
            <h1 style={{
                "fontSize": "36px",
                "fontWeight": "700",
                "marginBottom": "8px",
                "color": "#ffffff"
            }}>
                PrepPilot
            </h1>
            <p style={{"color": "#526078"}}>
                Your adaptive SWE interview practice loop: plan, practice, reflect, repeat.
            </p>
        </header>

        <section style={{
            "border": "1px solid #dce2ec",
            "borderRadius": "16px",
            "padding": "24px",
            "marginTop": "28px",
            "backgroundColor": "#ffffff"
        }}>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center",
                "gap": "16px",
                "flexWrap": "wrap"
            }}>
                <div>
                    <h2 style={{"fontSize": "26px", "fontWeight": "700"}}>
                        Today's Plan
                    </h2>
                    <p style={{"color": "#526078"}}>
                        {total_minutes} minutes · {len(plan)} problems selected from your practice history
                    </p>
                    <p style={{"marginTop": "10px"}}>
                        <a href="/menu" style={{"color": "#2563eb", "fontWeight": "600"}}>
                            Browse all LeetCode problems →
                        </a>
                    </p>
                </div>
                <span style={{
                    "padding": "8px 12px",
                    "borderRadius": "999px",
                    "backgroundColor": "#eef2ff"
                }}>
                    {completed} / {len(plan)} completed
                </span>
            </div>

            {[
                <article
                    key={item.problem_number}
                    style={{
                        "borderTop": "1px solid #e6eaf0",
                        "padding": "20px 0"
                    }}
                >
                    <div style={{
                        "display": "flex",
                        "justifyContent": "space-between",
                        "alignItems": "flex-start",
                        "gap": "16px",
                        "flexWrap": "wrap"
                    }}>
                        <div>
                            <h3 style={{"fontSize": "20px", "fontWeight": "600"}}>
                                {"LC " + str(item.problem_number) + " — " + problem_title(item.problem_number)}
                            </h3>
                            <p style={{"marginTop": "6px", "color": "#526078"}}>
                                {problem_topic(item.problem_number)}
                                {" · "}
                                {problem_difficulty(item.problem_number)}
                                {" · Confidence " + str(problem_confidence(item.problem_number)) + "/5"}
                            </p>
                            <p style={{"marginTop": "10px", "color": "#526078"}}>
                                {item.minutes} min · Last Practiced: {problem_last_practiced(item.problem_number)}
                            </p>
                        </div>

                        <span style={{
                            "padding": "6px 10px",
                            "borderRadius": "999px",
                            "backgroundColor": "#f4f6f8",
                            "color": "#526078"
                        }}>
                            {"Done" if item.done else "Planned"}
                        </span>
                    </div>

                    <div style={{
                        "display": "flex",
                        "gap": "10px",
                        "flexWrap": "wrap",
                        "marginTop": "16px"
                    }}>
                        <a
                            href={"/coding?problem=" + str(item.problem_number)}
                            style={{
                                "padding": "9px 14px",
                                "borderRadius": "8px",
                                "backgroundColor": "#172033",
                                "color": "#ffffff",
                                "textDecoration": "none"
                            }}
                        >
                            Open
                        </a>

                        <button
                            disabled={busy or item.done}
                            onClick={lambda {
                                complete_problem(item.problem_number);
                            }}
                            style={{
                                "padding": "9px 14px",
                                "border": "1px solid #cbd3df",
                                "borderRadius": "8px",
                                "backgroundColor": "#ffffff"
                            }}
                        >
                            {"Completed" if item.done else "Mark complete"}
                        </button>
                    </div>
                </article>
                for item in plan
            ]}
        </section>

        <section style={{
            "border": "1px solid #dce2ec",
            "borderRadius": "16px",
            "padding": "22px 24px",
            "marginTop": "20px",
            "backgroundColor": "#ffffff"
        }}>
            <h2 style={{"fontSize": "22px", "fontWeight": "700", "marginTop": "0"}}>
                Generate Another Coding Plan
            </h2>
            <p style={{"color": "#526078", "marginTop": "6px"}}>
                Choose how many problems to generate and optionally focus on one topic. Lower-confidence and less-recently practiced problems are prioritized.
            </p>

            <div style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))",
                "gap": "14px",
                "marginTop": "16px"
            }}>
                <div>
                    <label htmlFor="generate-count">Number of problems</label>
                    <select id="generate-count" value={generate_count} disabled={busy}
                        onChange={lambda (e: ChangeEvent) { generate_count = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}}>
                        <option value="1">1 problem</option>
                        <option value="2">2 problems</option>
                        <option value="3">3 problems</option>
                        <option value="4">4 problems</option>
                        <option value="5">5 problems</option>
                        <option value="6">6 problems</option>
                        <option value="7">7 problems</option>
                        <option value="8">8 problems</option>
                        <option value="9">9 problems</option>
                        <option value="10">10 problems</option>
                    </select>
                </div>

                <div>
                    <label htmlFor="generate-topic">Topic</label>
                    <select id="generate-topic" value={generate_topic} disabled={busy}
                        onChange={lambda (e: ChangeEvent) { generate_topic = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}}>
                        <option value="Random">Random — all topics</option>
                        <option value="Arrays and Hashing">Arrays and Hashing</option>
                        <option value="Binary Search">Binary Search</option>
                        <option value="Dynamic Programming">Dynamic Programming</option>
                        <option value="Graphs">Graphs</option>
                        <option value="Heap">Heap</option>
                        <option value="Linked List">Linked List</option>
                        <option value="Sliding Window">Sliding Window</option>
                        <option value="Stack">Stack</option>
                        <option value="Trees">Trees</option>
                        <option value="Two Pointers">Two Pointers</option>
                        <option value="Union Find">Union Find</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
            </div>

            <button
                disabled={busy}
                onClick={generate_another_plan}
                style={{
                    "marginTop": "16px",
                    "padding": "12px 18px",
                    "border": "0",
                    "borderRadius": "10px",
                    "backgroundColor": "#172033",
                    "color": "#ffffff",
                    "fontWeight": "600"
                }}
            >
                Generate Plan
            </button>
        </section>

        {if warning != "" {
            <p role="alert" style={{"color": "#dc2626", "fontWeight": "600", "marginTop": "12px"}}>
                {warning}
            </p>
        }}

        <p role="status" style={{"color": "#526078", "minHeight": "24px"}}>
            {"Loading or saving..." if busy else message}
        </p>
    </main>;

}
