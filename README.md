# Algorithm Selection Expert System (Prolog-based Web Application)

This is a web-based Algorithm Selection Expert System developed using SWI-Prolog. It uses a rule-based expert system to recommend the most suitable algorithm for a given problem, based on problem type, data size, memory constraints, and priorities.

## 🔧 Features

- 🧠 **Intelligent Algorithm Recommendation**: Describe your problem and constraints — the system reasons through Prolog rules to recommend the best algorithm.
- 📊 **Complexity Analysis**: Every recommendation includes time complexity, space complexity, and stability classification.
- 💡 **Detailed Explanations**: Understand *why* the algorithm was chosen, its real-world use cases, and when to avoid it.
- 🔄 **Alternative Suggestions**: The system always suggests an alternative algorithm to consider.
- 📚 **Browse All Algorithms**: Explore all 36 algorithms in the knowledge base, filterable by category.
- 📜 **Query History**: All past queries are stored at runtime using a dynamic knowledge base (`assertz/1`).

---

## 📁 Project Structure

| File | Description |
|---|---|
| `web_interface.pl` | Main file — starts the HTTP server and contains all page handlers |
| `algorithms.pl` | Knowledge base — 36 algorithms with time/space complexity and descriptions |
| `rules.pl` | Recommendation rules — Prolog rules mapping constraints to algorithms |
| `complexity.pl` | Use cases and avoid-when facts for each algorithm |
| `query_log.pl` | Dynamic knowledge base — stores query history at runtime |

---

## 🧠 Problem Categories & Algorithms Covered

| Category | Algorithms |
|---|---|
| **Sorting** | Bubble, Selection, Insertion, Merge, Quick, Heap, Counting, Radix, Tim, Shell, Bucket |
| **Searching** | Linear, Binary, Jump, Interpolation, Exponential, Ternary |
| **Graph** | BFS, DFS, Dijkstra, Bellman-Ford, A\*, Floyd-Warshall, Kruskal, Prim, Topological Sort |
| **Dynamic Programming** | Memoization, Tabulation, Knapsack DP, LCS DP, LIS DP |
| **String Matching** | Naive, KMP, Rabin-Karp, Boyer-Moore, Z-Algorithm |

---

## 🔬 How the Rules Work

The expert system fires rules based on five inputs:

| Input | Options |
|---|---|
| Problem Type | sorting, searching, graph, dynamic_programming, string_matching |
| Data Size | small, medium, large |
| Memory | low, moderate, high |
| Priority | speed, stability, simplicity, memory |
| Data Characteristics | random, nearly_sorted, sorted, unweighted, weighted_positive, knapsack, ... |

**Example rule:**
```prolog
% Need stability + large data → merge sort
recommend(sorting, large, _, stability, _, merge_sort) :- !.

% Memory is tight → heap sort (in-place, O(n log n))
recommend(sorting, _, low, _, _, heap_sort) :- !.

% Shortest path with negative weights → Bellman-Ford
recommend(graph, _, _, _, weighted_negative, bellman_ford) :- !.
```

---

## 🚀 Getting Started

### 🛠 Prerequisites

- Install [SWI-Prolog](https://www.swi-prolog.org/Download.html) on your system.

### ▶️ Running the Application

1. Open your terminal or command prompt.
2. Navigate to the directory containing the Prolog files.
3. Run the following command:

   ```bash
   swipl -s web_interface.pl
   ```

4. Once the server has started, open your web browser and go to:

   ```
   http://localhost:8080/
   ```

---

## 🤖 UI

![Homepage Screenshot](screenshots/1.png)
![Select Problem Screenshot](screenshots/2.png)
![Result Screenshot](screenshots/3.png)
