# ⚽ UEFA Football Data Analysis Using SQL

## 📌 Project Overview

This project focuses on analyzing structured football data from UEFA competitions using **SQL**. By importing and querying five interconnected datasets (Goals, Matches, Players, Stadiums, Teams), the goal is to answer real-world analytical questions related to team performance, player stats, goal distribution, and stadium usage.

The project simulates a real-world sports analytics scenario, where insights are drawn using advanced SQL queries and database design principles.

---

## 📁 Dataset Description

The project uses 5 CSV files, each representing a key component of UEFA competitions:

| Dataset   | Description |
|-----------|-------------|
| `Goals`   | Records of all goals scored, including player ID and match ID |
| `Matches` | Information on each match: home team, away team, season, date |
| `Players` | Player details: name, nationality, birth year, player ID |
| `Stadiums`| Stadiums used in the competition, along with their countries |
| `Teams`   | Team details: team ID, name, and country |

---

## 🎯 Objective

To write optimized and meaningful SQL queries that answer key analytical questions, such as:

- Who scored the most goals in each season?
- Which teams had the most wins or losses?
- How are goals distributed across countries and stadiums?
- Which players have the highest scoring efficiency?

---

## 🧠 Problem Statement

The data was available in multiple raw CSV files, but there was **no single source of truth** to query for team performance, player impact, or match statistics. The challenge was to:

- Clean and structure the data in a relational format.
- Write **modular, efficient SQL queries** that enable detailed analysis.
- Extract insights that could support team strategy, scouting, and performance review.

---

## ⚙️ Tools & Technologies

- **PostgreSQL / MySQL**
- **pgAdmin / DBeaver / MySQL Workbench**
- **SQL (JOINs, CTEs, Subqueries, Aggregates, Window Functions)**

---

## 🛠️ What I Did

- Created SQL tables from CSV files and inserted cleaned data.
- Wrote and executed over **55 SQL queries** covering various insights such as:
  - Top scorers by season and nationality
  - Goal distribution by stadium and country
  - Head-to-head team win/loss records
  - Country hosting analysis based on stadiums used
- Applied:
  - `JOIN`, `LEFT JOIN`, `INNER JOIN`
  - `WITH` clauses (CTEs) for reusable logic
  - `UNION ALL` for multi-season comparisons
  - `ROW_NUMBER`, `RANK`, `DENSE_RANK` for ranking analysis
  - Date and string formatting functions for better readability

---
