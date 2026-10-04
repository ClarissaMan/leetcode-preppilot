import from datetime { date }

node PrepProblem {
    has number: int,
        title: str,
        difficulty: str,
        topic: str,
        slug: str = "",
        confidence: int = 1,
        last_practiced: str = "",
        notes: str = "",
        last_result: str = "";
}

node DailyPlanItem {
    has day: str,
        problem_number: int,
        minutes: int,
        reason: str,
        confidence: int = 1,
        last_practiced: str = "",
        done: bool = False;
}

def:pub problem_topics() -> list[str] {
    return [
        "Arrays and Hashing",
        "Binary Search",
        "Dynamic Programming",
        "Graphs",
        "Heap",
        "Linked List",
        "Sliding Window",
        "Stack",
        "Trees",
        "Two Pointers",
        "Union Find",
        "Other"
    ];
}

def:pub prepare_problem_library() -> list[PrepProblem] {
    seeds = [
        [1, "two-sum", "Two Sum", "Easy", "Arrays and Hashing"],
        [3, "longest-substring-without-repeating-characters", "Longest Substring Without Repeating Characters", "Medium", "Sliding Window"],
        [15, "3sum", "3Sum", "Medium", "Two Pointers"],
        [20, "valid-parentheses", "Valid Parentheses", "Easy", "Stack"],
        [33, "search-in-rotated-sorted-array", "Search in Rotated Sorted Array", "Medium", "Binary Search"],
        [49, "group-anagrams", "Group Anagrams", "Medium", "Arrays and Hashing"],
        [70, "climbing-stairs", "Climbing Stairs", "Easy", "Dynamic Programming"],
        [98, "validate-binary-search-tree", "Validate Binary Search Tree", "Medium", "Trees"],
        [102, "binary-tree-level-order-traversal", "Binary Tree Level Order Traversal", "Medium", "Trees"],
        [139, "word-break", "Word Break", "Medium", "Dynamic Programming"],
        [200, "number-of-islands", "Number of Islands", "Medium", "Graphs"],
        [206, "reverse-linked-list", "Reverse Linked List", "Easy", "Linked List"],
        [215, "kth-largest-element-in-an-array", "Kth Largest Element in an Array", "Medium", "Heap"],
        [322, "coin-change", "Coin Change", "Medium", "Dynamic Programming"],
        [347, "top-k-frequent-elements", "Top K Frequent Elements", "Medium", "Heap"],
        [417, "pacific-atlantic-water-flow", "Pacific Atlantic Water Flow", "Medium", "Graphs"],
        [684, "redundant-connection", "Redundant Connection", "Medium", "Union Find"],
        [704, "binary-search", "Binary Search", "Easy", "Binary Search"]
    ];

    existing = [root-->][?:PrepProblem];

    for seed in seeds {
        seed_number = int(seed[0]);
        seed_slug = str(seed[1]);
        seed_title = str(seed[2]);
        seed_difficulty = str(seed[3]);
        seed_topic = str(seed[4]);

        matches = [
            problem for problem in existing
            if problem.number == seed_number
        ];

        if not matches {
            root ++> PrepProblem(
                number=seed_number,
                slug=seed_slug,
                title=seed_title,
                difficulty=seed_difficulty,
                topic=seed_topic
            );
        } else {
            for problem in matches {
                if problem.slug == "" {
                    problem.slug = seed_slug;
                }
            }
        }
    }

    return [root-->][?:PrepProblem];
}

def find_problem(
    problems: list[PrepProblem],
    problem_number: int
) -> PrepProblem | None {
    for problem in problems {
        if problem.number == problem_number {
            return problem;
        }
    }

    return None;
}

def:pub get_problem(problem_number: int) -> PrepProblem | None {
    problems = prepare_problem_library();
    return find_problem(problems, problem_number);
}

def:pub add_problem(
    number: int,
    title: str,
    difficulty: str,
    topic: str,
    slug: str
) -> PrepProblem {
    if number <= 0 {
        raise ValueError("LeetCode number must be positive");
    }

    clean_title = title.strip();
    clean_difficulty = difficulty.strip();
    clean_topic = topic.strip();
    clean_slug = slug.strip().strip("/");

    if clean_title == "" {
        raise ValueError("Problem name is required");
    }

    if clean_difficulty not in ["Easy", "Medium", "Hard"] {
        raise ValueError("Difficulty must be Easy, Medium, or Hard");
    }

    if clean_topic == "" {
        clean_topic = "Other";
    }

    if clean_topic not in problem_topics() {
        raise ValueError("Please choose a topic from the supported list");
    }

    if clean_slug == "" {
        raise ValueError("A LeetCode problem URL is required");
    }

    existing = prepare_problem_library();
    if find_problem(existing, number) is not None {
        raise ValueError(f"LeetCode {number} is already in your library");
    }

    for problem in existing {
        if problem.slug == clean_slug {
            raise ValueError("That LeetCode problem is already in your library");
        }
    }

    return root ++> PrepProblem(
        number=number,
        slug=clean_slug,
        title=clean_title,
        difficulty=clean_difficulty,
        topic=clean_topic,
        confidence=1,
        last_practiced="",
        notes="",
        last_result=""
    );
}

def:pub save_problem_practice(
    problem_number: int,
    confidence: int,
    notes: str,
    result: str
) -> PrepProblem | None {
    if confidence < 1 or confidence > 5 {
        raise ValueError("Confidence must be between 1 and 5");
    }

    valid_results = [
        "solved_independently",
        "needed_hint",
        "saw_solution",
        "could_not_solve"
    ];

    if result not in valid_results {
        raise ValueError("Invalid practice result");
    }

    problem = get_problem(problem_number);

    if problem is None {
        return None;
    }

    problem.confidence = confidence;
    problem.notes = notes;
    problem.last_practiced = date.today().isoformat();
    problem.last_result = result;

    today = date.today().isoformat();
    for item in [root-->][?:DailyPlanItem, day == today] {
        if item.problem_number == problem_number {
            item.confidence = problem.confidence;
            item.last_practiced = problem.last_practiced;
        }
    }

    return problem;
}

def clear_today_plan(today: str) -> None {
    for item in [root-->][?:DailyPlanItem] {
        if item.day == today {
            del item;
        }
    }
}

def problem_rank(problem: PrepProblem) -> tuple[int, int, str] {
    if problem.last_practiced == "" {
        return (problem.confidence, 1, "9999-99-99");
    }

    return (problem.confidence, 0, problem.last_practiced);
}

def problem_minutes(problem: PrepProblem) -> int {
    if problem.difficulty == "Easy" {
        return 10;
    }

    if problem.difficulty == "Medium" {
        return 20;
    }

    return 30;
}

def recommendation_reason(problem: PrepProblem) -> str {
    if problem.last_practiced == "" and problem.confidence <= 1 {
        return "New problem with no practice history";
    }

    if problem.confidence <= 2 and problem.last_practiced != "" {
        return "Low confidence; revisit this problem soon";
    }

    if problem.confidence <= 3 {
        return "Medium confidence; reinforce the pattern";
    }

    return "Higher confidence; spaced review keeps the pattern fresh";
}

def rule_based_plan(
    problems: list[PrepProblem],
    available_minutes: int,
    excluded_numbers: list[int] = [],
    topic: str = "Random",
    problem_count: int = 3
) -> list[dict[str, any]] {
    if problem_count < 1 or problem_count > 10 {
        raise ValueError("Problem count must be between 1 and 10");
    }

    candidates = [
        problem for problem in problems
        if problem.number not in excluded_numbers
        and (topic == "Random" or problem.topic == topic)
    ];

    ranked = sorted(
        candidates,
        key=lambda (problem: PrepProblem) {
            problem_rank(problem)
        }
    );

    chosen = ranked[:problem_count];
    if not chosen {
        return [];
    }

    return [
        {
            "problem_number": problem.number,
            "minutes": problem_minutes(problem),
            "reason": recommendation_reason(problem)
        }
        for problem in chosen
    ];
}

def validate_recommendations(
    recommendations: list[dict[str, any]],
    problems: list[PrepProblem],
    available_minutes: int
) -> bool {
    if len(recommendations) < 1 or len(recommendations) > 10 {
        return False;
    }

    valid_numbers = [
        problem.number
        for problem in problems
    ];

    selected_numbers: list[int] = [];
    total_minutes = 0;

    for recommendation in recommendations {
        problem_number = int(recommendation["problem_number"]);
        minutes = int(recommendation["minutes"]);

        if problem_number not in valid_numbers {
            return False;
        }

        if problem_number in selected_numbers {
            return False;
        }

        if minutes <= 0 {
            return False;
        }

        selected_numbers.append(problem_number);
        total_minutes += minutes;
    }

    return total_minutes > 0;
}

def:pub generate_today_plan(
    goal: str = "Prepare for SWE interviews",
    available_minutes: int = 90,
    problem_count: int = 3,
    topic: str = "Random"
) -> list[DailyPlanItem] {
    problem_count = int(problem_count);
    available_minutes = int(available_minutes);
    
    if problem_count < 1 or problem_count > 10 {
        raise ValueError("Problem count must be between 1 and 10");
    }

    if topic != "Random" and topic not in problem_topics() {
        raise ValueError("Please choose a supported topic or Random");
    }
    if available_minutes < 60 {
        raise ValueError("Available time must be at least 60 minutes");
    }

    problems = prepare_problem_library();
    today = date.today().isoformat();
    existing_plan = [
        root-->
    ][?:DailyPlanItem, day == today];
    excluded_numbers = [item.problem_number for item in existing_plan];

    recommendations = rule_based_plan(
        problems,
        available_minutes,
        excluded_numbers,
        topic,
        problem_count
    );

    if len(recommendations) < problem_count {
        recommendations = rule_based_plan(
            problems,
            available_minutes,
            [],
            topic,
            problem_count
        );
    }

    if not validate_recommendations(
        recommendations,
        problems,
        available_minutes
    ) {
        raise ValueError("Could not build a valid daily plan");
    }

    clear_today_plan(today);

    for recommendation in recommendations {
        root ++> DailyPlanItem(
            day=today,
            problem_number=int(recommendation["problem_number"]),
            minutes=int(recommendation["minutes"]),
            reason=str(recommendation["reason"]),
            confidence=int([problem.confidence for problem in problems if problem.number == int(recommendation["problem_number"])][0]),
            last_practiced=str([problem.last_practiced for problem in problems if problem.number == int(recommendation["problem_number"])][0])
        );
    }

    return [root-->][?:DailyPlanItem, day == today];
}

def:pub get_today_plan() -> list[DailyPlanItem] {
    today = date.today().isoformat();

    plan = [
        root-->
    ][?:DailyPlanItem, day == today];

    if not plan {
        return generate_today_plan();
    }

    problems = prepare_problem_library();
    for item in plan {
        for problem in problems {
            if problem.number == item.problem_number {
                item.confidence = problem.confidence;
                item.last_practiced = problem.last_practiced;
            }
        }
    }

    return plan;
}

def:pub complete_plan_problem(
    problem_number: int
) -> list[DailyPlanItem] {
    today = date.today().isoformat();

    plan = [
        root-->
    ][?:DailyPlanItem, day == today];

    for item in plan {
        if item.problem_number == problem_number {
            item.done = True;
        }
    }

    return plan;
}
