import "../core/site/styles/global.css";
import "../core/site/styles/site.css";
import "../core/site/styles/brand.css";

import from core.prep_pilot {
    PrepProblem,
    DailyPlanItem,
    prepare_problem_library,
    save_problem_practice,
    generate_today_plan,
    get_today_plan,
    complete_plan_problem
}

def:pub app(children: any) -> JsxElement {
    return <>{children}</>;
}