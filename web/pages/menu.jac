import from core.prep_pilot {
    PrepProblem,
    prepare_problem_library,
    add_problem
}

def:pub page -> JsxPage {
    has problems: list[PrepProblem] = [],
        busy: bool = True,
        adding: bool = False,
        message: str = "",
        warning: str = "",
        new_number: str = "",
        new_url: str = "",
        new_title: str = "",
        new_difficulty: str = "Medium",
        new_topic: str = "Arrays and Hashing",
        selected_topic: str = "All topics",
        selected_difficulty: str = "All difficulties";

    async def load_problems() -> None {
        busy = True;
        message = "";
        warning = "";

        try {
            problems = await prepare_problem_library();
        } except Exception as e {
            message = "Could not load the problem library. Please refresh and try again.";
        }

        busy = False;
    }

    async def create_problem() -> None {
        adding = True;
        message = "";
        warning = "";

        try {
            number = int(new_number.strip());

            url_parts = new_url.strip().split("/problems/");
            if len(url_parts) < 2 {
                raise ValueError("Please paste a valid LeetCode problem URL");
            }

            slug = url_parts[1].split("/")[0].split("?")[0].strip();
            if slug == "" {
                raise ValueError("Could not find the problem slug in that URL");
            }

            created = await add_problem(
                number,
                new_title,
                new_difficulty,
                new_topic,
                slug
            );

            problems = await prepare_problem_library();
            new_number = "";
            new_url = "";
            new_title = "";
            new_difficulty = "Medium";
            new_topic = "Arrays and Hashing";
            message = f"Added LeetCode {created.number}: {created.title}";
        } except Exception as e {
            error_text = str(e);
            if "already in your library" in error_text {
                warning = "This LeetCode problem is already in your library.";
            } else {
                warning = "Could not add this LeetCode problem. Please check the information and try again.";
            }
        }

        adding = False;
    }

    def confidence_label(value: int) -> str {
        if value <= 1 {
            return "Need help";
        }
        if value == 2 {
            return "Shaky";
        }
        if value == 3 {
            return "Getting there";
        }
        if value == 4 {
            return "Strong";
        }
        return "Confident";
    }


    can with entry {
        load_problems();
    }

    return <main style={{
        "maxWidth": "980px",
        "margin": "32px auto",
        "padding": "24px",
        "fontFamily": "Arial, sans-serif",
        "color": "#172033"
    }}>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "flex-start",
            "gap": "16px",
            "flexWrap": "wrap"
        }}>
            <div>
                <a href="/" style={{"color": "#526078"}}>
                    ← Back to today's plan
                </a>
                <h1 style={{
                    "fontSize": "34px",
                    "fontWeight": "700",
                    "marginTop": "18px",
                    "color": "white"
                }}>
                    Problem Menu
                </h1>
                <p style={{"color": "#526078", "marginTop": "8px"}}>
                    Browse, filter, and expand your personal LeetCode library.
                </p>
            </div>
            <span style={{
                "padding": "8px 12px",
                "borderRadius": "999px",
                "backgroundColor": "#eef2ff",
                "fontWeight": "600"
            }}>
                {len(problems)} problems
            </span>
        </div>

        <section style={{
            "border": "1px solid #dce2ec",
            "borderRadius": "16px",
            "padding": "22px",
            "marginTop": "22px",
            "backgroundColor": "#f8fafc"
        }}>
            <h2 style={{"fontSize": "20px", "fontWeight": "700"}}>
                Filter
            </h2>
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))",
                "gap": "14px",
                "marginTop": "14px"
            }}>
                <div>
                    <label htmlFor="topic-filter">Topic tag</label>
                    <select
                        id="topic-filter"
                        value={selected_topic}
                        onChange={lambda (e: ChangeEvent) {
                            selected_topic = e.target.value;
                        }}
                        style={{
                            "display": "block",
                            "width": "100%",
                            "boxSizing": "border-box",
                            "marginTop": "6px",
                            "padding": "10px",
                            "border": "1px solid #cbd3df",
                            "borderRadius": "8px",
                            "backgroundColor": "#ffffff"
                        }}
                    >
                        <option value="All topics">All topics</option>
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

                <div>
                    <label htmlFor="difficulty-filter">Difficulty</label>
                    <select
                        id="difficulty-filter"
                        value={selected_difficulty}
                        onChange={lambda (e: ChangeEvent) {
                            selected_difficulty = e.target.value;
                        }}
                        style={{
                            "display": "block",
                            "width": "100%",
                            "boxSizing": "border-box",
                            "marginTop": "6px",
                            "padding": "10px",
                            "border": "1px solid #cbd3df",
                            "borderRadius": "8px",
                            "backgroundColor": "#ffffff"
                        }}
                    >
                        <option value="All difficulties">All difficulties</option>
                        <option value="Easy">Easy</option>
                        <option value="Medium">Medium</option>
                        <option value="Hard">Hard</option>
                    </select>
                </div>


            </div>
        </section>

        <section style={{
            "border": "1px solid #dce2ec",
            "borderRadius": "16px",
            "padding": "22px",
            "marginTop": "18px",
            "backgroundColor": "#f8fafc"
        }}>
            <h2 style={{"fontSize": "22px", "fontWeight": "700"}}>
                Add a LeetCode Problem
            </h2>
            <p style={{"color": "#526078", "marginTop": "6px"}}>
                Add a problem you want PrepPilot to remember. New problems start at confidence 1/5 and have no practice history.
            </p>

            <div style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(auto-fit, minmax(220px, 1fr))",
                "gap": "14px",
                "marginTop": "16px"
            }}>
                <div>
                    <label htmlFor="new-number">LeetCode number</label>
                    <input id="new-number" type="number" value={new_number} disabled={adding} placeholder="e.g. 125"
                        onChange={lambda (e: ChangeEvent) { new_number = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}} />
                </div>
                <div>
                    <label htmlFor="new-title">Problem name</label>
                    <input id="new-title" value={new_title} disabled={adding} placeholder="e.g. Valid Palindrome"
                        onChange={lambda (e: ChangeEvent) { new_title = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}} />
                </div>
                <div>
                    <label htmlFor="new-difficulty">Difficulty</label>
                    <select id="new-difficulty" value={new_difficulty} disabled={adding}
                        onChange={lambda (e: ChangeEvent) { new_difficulty = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}}>
                        <option value="Easy">Easy</option>
                        <option value="Medium">Medium</option>
                        <option value="Hard">Hard</option>
                    </select>
                </div>
                <div>
                    <label htmlFor="new-topic">Topic tag</label>
                    <select id="new-topic" value={new_topic} disabled={adding}
                        onChange={lambda (e: ChangeEvent) { new_topic = e.target.value; }}
                        style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}}>
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

            <div style={{"marginTop": "14px"}}>
                <label htmlFor="new-url">LeetCode problem URL</label>
                <input id="new-url" value={new_url} disabled={adding} placeholder="https://leetcode.com/problems/valid-palindrome/"
                    onChange={lambda (e: ChangeEvent) { new_url = e.target.value; }}
                    style={{"display": "block", "width": "100%", "boxSizing": "border-box", "marginTop": "6px", "padding": "10px", "border": "1px solid #cbd3df", "borderRadius": "8px", "backgroundColor": "#ffffff"}} />
            </div>

            <button disabled={adding} onClick={create_problem}
                style={{"marginTop": "16px", "padding": "11px 18px", "border": "0", "borderRadius": "9px", "backgroundColor": "#172033", "color": "#ffffff", "fontWeight": "600"}}>
                {"Adding..." if adding else "Add problem to library"}
            </button>
        </section>

        {if warning != "" {
            <p role="alert" style={{"color": "#dc2626", "fontWeight": "600", "marginTop": "12px"}}>
                {warning}
            </p>
        }}

        <p role="status" style={{"color": "#526078", "minHeight": "24px", "marginTop": "16px"}}>
            {"Loading..." if busy else message}
        </p>

        <section style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(280px, 1fr))", "gap": "16px", "marginTop": "12px"}}>
            {[
                <article key={problem.number} style={{"border": "1px solid #dce2ec", "borderRadius": "14px", "padding": "18px", "backgroundColor": "#ffffff"}}>
                    <div style={{"display": "flex", "justifyContent": "space-between", "gap": "12px", "alignItems": "flex-start"}}>
                        <div>
                            <p style={{"color": "#526078", "margin": "0"}}>{"LeetCode " + str(problem.number)}</p>
                            <h2 style={{"fontSize": "19px", "fontWeight": "650", "marginTop": "6px"}}>{problem.title}</h2>
                        </div>
                        <span style={{"padding": "5px 8px", "borderRadius": "999px", "backgroundColor": "#f3f4f6", "fontSize": "13px", "whiteSpace": "nowrap"}}>{problem.difficulty}</span>
                    </div>
                    <p style={{"color": "#526078", "marginTop": "10px"}}>{problem.topic}</p>
                    <p style={{"color": "#526078", "marginTop": "10px"}}>{"Confidence: " + str(problem.confidence) + "/5 · " + confidence_label(problem.confidence)}</p>
                    <p style={{"color": "#526078", "marginTop": "4px"}}>{"Last practiced: " + (problem.last_practiced if problem.last_practiced != "" else "Never")}</p>
                    <a href={"/coding?problem=" + str(problem.number)} style={{"display": "inline-block", "marginTop": "14px", "padding": "9px 13px", "borderRadius": "8px", "backgroundColor": "#172033", "color": "#ffffff", "textDecoration": "none", "fontWeight": "600"}}>Practice this problem</a>
                </article>
                for problem in problems
                if (selected_topic == "All topics" or problem.topic == selected_topic)
                and (selected_difficulty == "All difficulties" or problem.difficulty == selected_difficulty)
            ]}
        </section>


    </main>;
}
