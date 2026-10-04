import from core.prep_pilot {
    PrepProblem,
    get_problem,
    save_problem_practice
}

def:pub page -> JsxPage {
    has problem: PrepProblem | None = None,
        problem_number: int = 0,
        notes: str = "",
        confidence: int = 1,
        result: str = "solved_independently",
        busy: bool = True,
        message: str = "";

    async def load_problem() -> None {
        busy = True;
        message = "";

        try {
            win: any = window;
            params: any = Reflect.construct(
                win.URLSearchParams,
                [window.location.search]
            );
            raw_number = params.get("problem") or "";

            if raw_number == "" {
                message = "No problem was selected. Return to today's plan.";
                busy = False;
                return;
            }

            problem_number = int(raw_number);
            problem = await get_problem(problem_number);

            if problem is None {
                message = "That problem could not be found.";
                busy = False;
                return;
            }

            notes = problem.notes;
            confidence = problem.confidence;
            result = problem.last_result if problem.last_result != "" else "solved_independently";
        } except Exception as e {
            message = "Could not load this problem. Please return to the plan and try again.";
        }

        busy = False;
    }

    async def save_reflection() -> None {
        if problem is None {
            return;
        }

        busy = True;
        message = "";

        try {
            saved = await save_problem_practice(
                problem.number,
                confidence,
                notes,
                result
            );
            problem = saved;
            message = "Saved. Your next plan will use this updated confidence and recency.";
        } except Exception as e {
            message = "Could not save your reflection. Please try again.";
        }

        busy = False;
    }

    def confidence_button(
        value: int,
        label: str
    ) -> JsxElement {
        return <button
            disabled={busy}
            onClick={lambda { confidence = value; }}
            style={{
                "padding": "10px 14px",
                "border": "1px solid #cbd3df",
                "borderRadius": "8px",
                "backgroundColor": "#ffffff",
                "fontWeight": "600"
            }}
        >
            {label}
        </button>;
    }

    can with entry {
        load_problem();
    }

    return <main style={{
        "maxWidth": "820px",
        "margin": "32px auto",
        "padding": "24px",
        "fontFamily": "Arial, sans-serif",
        "color": "#172033"
    }}>
        <div style={{"display": "flex", "gap": "16px", "flexWrap": "wrap"}}>
            <a href="/" style={{"color": "#526078"}}>
                ← Back to today's plan
            </a>
            <a href="/menu" style={{"color": "#2563eb", "fontWeight": "600"}}>
                Problem menu →
            </a>
        </div>

        {if problem is not None {
            <section style={{
                "marginTop": "24px",
                "border": "1px solid #dce2ec",
                "borderRadius": "16px",
                "padding": "24px",
                "backgroundColor": "#ffffff"
            }}>
                <p style={{"color": "#526078"}}>
                    {"LeetCode " + str(problem.number) + " · " + problem.topic + " · " + problem.difficulty}
                </p>

                <h1 style={{
                    "fontSize": "32px",
                    "fontWeight": "700",
                    "marginTop": "8px"
                }}>
                    {problem.title}
                </h1>

                <a
                    href={"https://leetcode.com/problems/" + problem.slug + "/"}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                        "display": "inline-block",
                        "marginTop": "12px",
                        "color": "#2563eb"
                    }}
                >
                    Open problem on LeetCode ↗
                </a>

                <div style={{"marginTop": "28px"}}>
                    <h2 style={{"fontSize": "20px", "fontWeight": "600"}}>
                        Reflect on this attempt
                    </h2>
                    <p style={{"color": "#526078"}}>
                        Confidence: {confidence}/5. This value affects future recommendations.
                    </p>

                    <div style={{
                        "display": "flex",
                        "gap": "8px",
                        "flexWrap": "wrap",
                        "marginTop": "12px"
                    }}>
                        {confidence_button(1, "1 · Need help")}
                        {confidence_button(2, "2 · Shaky")}
                        {confidence_button(3, "3 · Getting there")}
                        {confidence_button(4, "4 · Strong")}
                        {confidence_button(5, "5 · Confident")}
                    </div>
                </div>

                <div style={{"marginTop": "24px"}}>
                    <label htmlFor="practice-result">
                        Practice result
                    </label>
                    <select
                        id="practice-result"
                        value={result}
                        disabled={busy}
                        onChange={lambda (e: ChangeEvent) {
                            result = e.target.value;
                        }}
                        style={{
                            "display": "block",
                            "marginTop": "8px",
                            "padding": "10px",
                            "border": "1px solid #cbd3df",
                            "borderRadius": "8px",
                            "backgroundColor": "#ffffff"
                        }}
                    >
                        <option value="solved_independently">Solved independently</option>
                        <option value="needed_hint">Needed a hint</option>
                        <option value="saw_solution">Saw the solution</option>
                        <option value="could_not_solve">Could not solve</option>
                    </select>
                </div>

                <div style={{"marginTop": "24px"}}>
                    <label htmlFor="coding-notes">
                        What you learned
                    </label>
                    <textarea
                        id="coding-notes"
                        value={notes}
                        disabled={busy}
                        onChange={lambda (e: ChangeEvent) {
                            notes = e.target.value;
                        }}
                        placeholder="Key idea, mistake, edge case, time complexity, or what you want to remember next time..."
                        style={{
                            "display": "block",
                            "width": "100%",
                            "minHeight": "220px",
                            "padding": "14px",
                            "marginTop": "10px",
                            "border": "1px solid #cbd3df",
                            "borderRadius": "10px",
                            "backgroundColor": "#ffffff",
                            "color": "#172033"
                        }}
                    />
                </div>

                <button
                    disabled={busy}
                    onClick={save_reflection}
                    style={{
                        "marginTop": "16px",
                        "padding": "12px 20px",
                        "backgroundColor": "#172033",
                        "color": "#ffffff",
                        "border": "0",
                        "borderRadius": "8px",
                        "fontWeight": "600"
                    }}
                >
                    {"Saving..." if busy else "Save reflection"}
                </button>

                <p role="status" style={{"color": "#526078", "minHeight": "24px"}}>
                    {message}
                </p>
            </section>
        } else {
            <p style={{"marginTop": "24px", "color": "#526078"}}>
                {"Loading..." if busy else message}
            </p>
        }}
    </main>;
}
