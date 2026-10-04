# LeetCode PrepPilot

**Name:** Clarissa Man
**UMID:** 97211153

## Overview

**LeetCode PrepPilot** is a personal SWE interview preparation planner built entirely with **Jac**. It helps turn LeetCode practice into a repeatable feedback loop:

> **Plan → Practice → Reflect → Repeat**

Instead of giving every problem equal priority, PrepPilot maintains a personal problem library and generates adaptive daily coding plans using the user's confidence level and practice history.

The project includes a shared Jac backend, a web application, a native mobile client, and a command-line interface. All four interfaces use the same underlying planner data and server-side logic.

## Main Features

### 1. Adaptive Daily Coding Plans

PrepPilot generates a daily coding plan with a configurable number of problems.

The recommendation engine is rule-based and considers:

- Problem confidence, from **1 to 5**
- Practice history and last-practiced date
- Problem topic
- Requested number of problems
- Existing problems already selected for today's plan

Lower-confidence problems are prioritized, and previously practiced problems are ordered by how long ago they were practiced. Problems that have never been practiced are also tracked as part of the recommendation system.

Each recommended problem receives a suggested practice time based on difficulty:

- **Easy:** 10 minutes
- **Medium:** 20 minutes
- **Hard:** 30 minutes

The default plan is designed as an **all-topics, 3-problem interview preparation session**. Users can also generate a new coding plan at any time, choosing specific topics and between **1–10 problems** to create a customized practice set.

Problems in the daily plan can be marked as completed.

The web and mobile interfaces display the number of completed problems and the total number of problems in the current plan.

### 2. Problem Reflection and Progress Tracking

Each problem stores personal practice information, including:

- Confidence level
- Last-practiced date
- Practice result
- Personal notes (key ideas, mistakes, edge cases, or anything they want to remember)

Updating a problem's confidence and practice date changes the information used by future recommendations.

### 3. Problem Library

The application starts with a curated library of common interview problems covering topics such as: Arrays and Hashing, Binary Search, Dynamic Programming, Graphs, Heap, Linked List, Sliding Window, Stack, Trees, Two Pointers, Union Find, etc.

The Problem Menu allows users to:

- Browse all problems
- Filter by topic
- Filter by difficulty
- Add any addition LeetCode problems users want to their personal library

---

# Setup

Clone the repository:

```bash
git clone https://github.com/ClarissaMan/leetcode-preppilot.git
cd leetcode-preppilot
```

Install Jac:

```bash
python3 -m venv .venv
source .venv/bin/activate
curl -fsSL https://raw.githubusercontent.com/jaseci-labs/jaseci/main/scripts/install.sh | bash
export PATH="$HOME/.local/bin:$PATH"
```

The project pins the Jac version in `jac.toml`:

```toml
jac-version = "==0.37.23"
```

Verify the installed version with:

```bash
jac --version
```

---

# Web Application

The project is configured so that the default application is the web application.

From the repository root, run:

```bash
jac run
```

This starts the web application and its server using the default configuration in `jac.toml`.

Open the local address shown by Jac in your browser.

The web application provides three main pages:

### Today's Plan

The homepage displays:

- Current daily coding plan
- Problem title, number, topic, and difficulty
- Confidence level
- Last-practiced date
- Estimated practice time
- Completion status
- Generate another plan

Users can open a problem, mark it as complete, or generate a new plan based on their preferred topics and number of problems.

### Coding Reflection

Selecting a problem opens its coding/reflection page.

From there, users can:

1. Open the problem on LeetCode
2. Set confidence from 1–5
3. Record the practice result
4. Write personal notes
5. Save the reflection

The updated confidence and practice date are then available to the recommendation engine for future plans.

### Problem Menu

The Problem Menu provides a personal LeetCode library where users can:

- Browse problems
- Filter by topic
- Filter by difficulty
- Add new LeetCode problems
- Click into a problem to see its details (confidence level, notes, practice result, etc.)

---

# Mobile App

## Run the Mobile App

Keep `jac run` running. Open a new terminal in the repository root, activate your environment if needed, and run:

```bash
jac run mobile
```

This opens the mobile preview, usually at `http://localhost:8000/mobile`. If the browser does not open automatically, open that address manually by appending `/mobile` to the Web App URL shown in the first terminal.

## Mobile Functionality

The mobile interface is intentionally more limited than the web application. This design reflects how PrepPilot is intended to be used in practice:

- **Web application:** Full LeetCode practice and planning workflow
- **Mobile application:** Quick plan management while away from a laptop

When using the mobile app, users can:

- View today's recommended problems
- **Mark a problem as completed**
- **Generate another coding plan**

### Completing a Problem

The mobile app allows users to mark a problem as completed, but it does **not** provide the detailed problem-editing functionality available on the web. For example, when viewing a problem on mobile, users cannot modify Confidence level, Notes, Practice results, Last-practiced date, etc.

The purpose of this restriction is intentional. Actual LeetCode practice typically requires a laptop or desktop browser to access the LeetCode website and write and test code. Therefore, detailed practice tracking is designed to happen on the **web application**.

The mobile app instead provides a convenient way to mark a problem as completed if the user has already practiced it but forgot to update its completion status on the web application.

### Generating Another Plan

Users can also generate another coding plan directly from the mobile app.

The mobile version uses a simplified plan-generation workflow: it only generates **3 problems from random topics**.

This differs from the web application, where users have more control over plan generation. (i.e. On web app, users can select specific topics, choose the number of problems to generate, or generate a plan based on those selected preferences.)

The simplified mobile workflow is intentional so that the phone interface focuses on quick actions rather than the more detailed planning and practice workflow provided on the web.

---

# Command-Line Interface

## Start the Application

Keep `jac run` running. Open a new terminal in the repository root, activate your environment if needed, and run the CLI commands below.

### View Today's Plan

Run:

```bash
jac run cli -- today
```

The CLI displays the current Today's Plan, including:

- Problem number
- Estimated practice time
- Confidence
- Last-practiced date
- Completion status

### Mark a Problem Complete

Run:

```bash
jac run cli -- complete 33
```

Replace `33` with the LeetCode problem number that appears in your current plan.

The CLI uses the same `PrepProblem` and `DailyPlanItem` data as the web and mobile applications. Therefore, changes made through the CLI are reflected across the other interfaces. For example, after completing a problem through the CLI, refresh the web application to verify that the completion status has been updated.

---

# How the Four Components Fit Together

PrepPilot is organized around one shared planner backend with multiple clients.

```text
                     ┌─────────────────────┐
                     │   core/prep_pilot   │
                     │                     │
                     │  Problem Library    │
                     │  Daily Plans        │
                     │  Confidence         │
                     │  Practice History   │
                     │  Recommendation     │
                     └──────────┬──────────┘
                                │
                     Shared Jac Server/API
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
          Web Client       Mobile Client       CLI Client
          web/             mobile/             cli/
```

### 1. Server / Core

`core/prep_pilot.jac` contains the application's main data model and business logic.

It defines:

- `PrepProblem`
- `DailyPlanItem`
- Problem library management
- Practice/reflection updates
- Daily-plan generation
- Completion tracking
- Recommendation ranking

The core functions are exposed through Jac's server function mechanism.

### 2. Web

The web client provides the richest user interface.

It calls the shared backend to load and update the planner, while providing pages for:

- Today's plan
- Problem reflection
- Problem library

### 3. Mobile

The mobile client provides a lightweight native interface for viewing today's plan, checking completion, and generating another plan.

It calls the same backend functions as the web application, so users do not need a separate recommendation system for mobile.

### 4. CLI

The CLI provides a terminal-oriented interface for users who prefer working from the command line.

It communicates with the same server through HTTP and supports:

```text
today
complete <problem-number>
```

---

# What Makes This Project Impressive

The main goal of PrepPilot is not simply to display a list of LeetCode problems. It implements a small **closed-loop personal learning system**.

A typical workflow is:

```text
Generate Plan
     ↓
Practice Problem
     ↓
Record Confidence + Result + Notes
     ↓
Update Practice History
     ↓
Generate Another Plan
     ↓
Recommendations Adapt
```

PrepPilot connects planning with reflection: your confidence and practice history influence what you practice next. This makes it useful for revisiting difficult topics and building a more deliberate interview preparation routine.

Each interface supports a different part of that routine. The web application handles detailed planning and reflection, the mobile interface provides quick progress updates, and the CLI keeps the daily plan accessible while working in a terminal.

The project combines persistent Jac graph data, rule-based recommendations, a personal problem library, and shared progress across interfaces in one codebase, so a user's practice history affects future plans regardless of whether they interact with the application through the web, mobile app, or CLI.

---

# Example Workflow

After starting the web application:

```bash
jac run
```

1. Open **Today's Plan**.
2. Review the recommended problems.
3. Open a problem.
4. Practice the problem on LeetCode through "Open problem on LeetCode".
5. Record your confidence, practice result, and notes.
6. Save the reflection.
7. Return to Today's Plan.
8. Mark the problem complete.
9. Generate another plan.
10. The planner uses the updated confidence and practice history when selecting future problems.

For the mobile application:

```bash
jac run mobile
```

1. Open the mobile application.
2. View Today's Plan and the recommended problems.
3. Mark the problem complete if practiced on laptop.
4. Generate another coding plan.

For the CLI:

View today's recommended problems:

```bash
jac run cli -- today
```

To mark a problem as complete (Replace `33` with the ID of a problem in the current plan):

```bash
jac run cli -- complete 33
```

---

## Repository

GitHub:
https://github.com/ClarissaMan/leetcode-preppilot
