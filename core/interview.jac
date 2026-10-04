import from datetime { date }

node PracticeActivity {
    has day: str,
        category: str,
        title: str,
        done: bool = False;
}

def:pub prepare_interview_day() -> list[PracticeActivity] {
    today = date.today().isoformat();
    existing: list[PracticeActivity] = [root-->][?:PracticeActivity, day == today];

    categories = ["coding", "behavioral", "resume"];
    titles = [
        "Solve or review one coding problem",
        "Practice one behavioral question",
        "Review one resume bullet"
    ];

    for i in range(3) {
        matches: list[PracticeActivity] = [
            activity for activity in existing
            if activity.category == categories[i]
        ];
        if not matches {
            root ++> PracticeActivity(
                day=today,
                category=categories[i],
                title=titles[i]
            );
        }
    }

    return [root-->][?:PracticeActivity, day == today];
}

def:pub save_interview_activity(
    selected_day: str,
    category: str,
    done: bool
) -> list[PracticeActivity] {
    activities = [
        activity for activity in [root-->][?:PracticeActivity]
        if activity.day == selected_day
    ];

    for activity in activities {
        if activity.category == category {
            activity.done = done;
        }
    }

    return activities;
}
