Implement a scoring system for a task tracking app.

Rules:
- Score = task points * validation percent / 100
- If task not completed, score is negative task points
- Scores must be accumulated per:
  - User
  - Pair
  - Task
  - Month
- Update score after each validation
- Update progress thermometer