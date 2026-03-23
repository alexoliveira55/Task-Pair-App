Pub Package Cache
=================

This folder is used by Pub to store cached packages used in Dart / Flutter
projects.

The contents of this folder should only be modified using the `dart pub` and
`flutter pub` commands.

Modifying this folder manually can lead to inconsistent behavior.

For details on how manage the `PUB_CACHE`, see:
https://dart.dev/go/pub-cache

## AI Development Instructions

This repository is developed using AI Agents coordinated by an Orchestrator.

Project:
Task Pair App – A task tracking, scoring and reward system for pairs.

Tech Stack:
- Flutter (web, desktop, mobile)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Riverpod
- GoRouter
- Clean Architecture

Architecture:
Feature-first + Clean Architecture + Repository Pattern.

Main Concepts:
- Users
- Pairs
- Tasks
- Recurrence
- Task Occurrences
- Task Execution
- Task Validation
- Score System
- Rewards
- Dashboard with thermometer progress

Agents are located in /ai/agents.
Prompts are located in /ai/prompts.

Development must be orchestrated by the Orchestrator Agent.
Each agent has a specific responsibility and must not implement outside its scope.