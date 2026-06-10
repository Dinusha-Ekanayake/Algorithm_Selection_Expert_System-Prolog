% ============================================================
%  algorithms.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Knowledge base: built-in algorithm facts (static) +
%  dynamic algorithm facts added at runtime.
%
%  algorithm(Name, Category, TimeComplexity, SpaceComplexity,
%            Stable, Description)
%
%  Dynamic algorithms can be added/removed through the
%  Manage Knowledge Base page at runtime using assertz/retract.
% ============================================================

% --- Declare dynamic so both static and runtime facts coexist ---
:- dynamic algorithm/6.

% ============================================================
%  SORTING ALGORITHMS
% ============================================================
algorithm(bubble_sort,    sorting, 'O(n^2)',      'O(1)',      stable,   'Simple comparison-based sort. Best for tiny or nearly sorted datasets.').
algorithm(selection_sort, sorting, 'O(n^2)',      'O(1)',      unstable, 'Repeatedly finds the minimum element. Simple but inefficient for large data.').
algorithm(insertion_sort, sorting, 'O(n^2)',      'O(1)',      stable,   'Builds sorted array one item at a time. Very efficient for small or nearly sorted data.').
algorithm(merge_sort,     sorting, 'O(n log n)',  'O(n)',      stable,   'Divide-and-conquer sort. Guarantees O(n log n). Best when stability is required.').
algorithm(quick_sort,     sorting, 'O(n log n)',  'O(log n)', unstable, 'Fast in practice. Best average-case. Avoid on nearly sorted data without pivot randomisation.').
algorithm(heap_sort,      sorting, 'O(n log n)',  'O(1)',      unstable, 'In-place sort with guaranteed O(n log n). Ideal when memory is critical.').
algorithm(counting_sort,  sorting, 'O(n + k)',    'O(k)',      stable,   'Non-comparison integer sort. Extremely fast when the value range k is small.').
algorithm(radix_sort,     sorting, 'O(nk)',       'O(n + k)', stable,   'Sorts integers digit by digit. Very fast for fixed-length integer or string keys.').
algorithm(tim_sort,       sorting, 'O(n log n)',  'O(n)',      stable,   'Hybrid merge + insertion sort. Used in Python and Java. Best all-round choice.').
algorithm(shell_sort,     sorting, 'O(n log^2 n)','O(1)',      unstable, 'Generalization of insertion sort with gap sequences. Better than plain O(n^2) sorts.').
algorithm(bucket_sort,    sorting, 'O(n + k)',    'O(n)',      stable,   'Distributes elements into buckets. Ideal for uniformly distributed floating-point data.').

% ============================================================
%  SEARCHING ALGORITHMS
% ============================================================
algorithm(linear_search,        searching, 'O(n)',        'O(1)', stable, 'Scans every element. Works on any dataset. Only viable option for unsorted data.').
algorithm(binary_search,        searching, 'O(log n)',    'O(1)', stable, 'Halves the search space each step. Requires sorted array. Very efficient.').
algorithm(jump_search,          searching, 'O(sqrt n)',   'O(1)', stable, 'Jumps ahead by fixed steps then searches linearly. Good for sorted arrays.').
algorithm(interpolation_search, searching, 'O(log log n)','O(1)', stable, 'Estimates element position like a phonebook. Best for uniformly distributed sorted data.').
algorithm(exponential_search,   searching, 'O(log n)',    'O(1)', stable, 'Finds range then applies binary search. Best for unbounded or infinite arrays.').
algorithm(ternary_search,       searching, 'O(log3 n)',   'O(1)', stable, 'Divides array into thirds. Useful for finding maximum of unimodal functions.').

% ============================================================
%  GRAPH ALGORITHMS
% ============================================================
algorithm(bfs,             graph, 'O(V + E)',  'O(V)',  stable, 'Breadth-First Search. Finds shortest path in unweighted graphs. Explores level by level.').
algorithm(dfs,             graph, 'O(V + E)',  'O(V)',  stable, 'Depth-First Search. Good for cycle detection, topological sort, and connected components.').
algorithm(dijkstra,        graph, 'O(E log V)','O(V)',  stable, 'Shortest path in weighted graphs with non-negative weights. Uses a priority queue.').
algorithm(bellman_ford,    graph, 'O(VE)',     'O(V)',  stable, 'Shortest path even with negative weight edges. Detects negative weight cycles.').
algorithm(a_star,          graph, 'O(E)',      'O(V)',  stable, 'Heuristic-guided shortest path. Faster than Dijkstra when a good heuristic is available.').
algorithm(floyd_warshall,  graph, 'O(V^3)',    'O(V^2)',stable, 'All-pairs shortest path for small dense graphs. Handles negative weights.').
algorithm(kruskal,         graph, 'O(E log E)','O(V)',  stable, 'Minimum spanning tree by sorting edges. Best for sparse graphs.').
algorithm(prim,            graph, 'O(E log V)','O(V)',  stable, 'Minimum spanning tree using a priority queue. Best for dense graphs.').
algorithm(topological_sort,graph, 'O(V + E)',  'O(V)',  stable, 'Orders vertices in a DAG. Used in build systems, task scheduling, and course prereqs.').

% ============================================================
%  DYNAMIC PROGRAMMING
% ============================================================
algorithm(memoization, dynamic_programming, 'O(n)',   'O(n)',  stable, 'Top-down DP with caching. Natural recursive structure. Uses extra memory for the cache.').
algorithm(tabulation,  dynamic_programming, 'O(n)',   'O(n)',  stable, 'Bottom-up DP. Fills a table iteratively. Faster than memoization in most cases.').
algorithm(knapsack_dp, dynamic_programming, 'O(n*W)', 'O(n*W)',stable, '0/1 Knapsack via DP table. Optimises value under a weight/budget constraint.').
algorithm(lcs_dp,      dynamic_programming, 'O(m*n)', 'O(m*n)',stable, 'Longest Common Subsequence. Used in diff tools, DNA alignment, plagiarism detection.').
algorithm(lis_dp,      dynamic_programming, 'O(n log n)','O(n)',stable,'Longest Increasing Subsequence. Used in patience sorting and stock price analysis.').

% ============================================================
%  STRING MATCHING
% ============================================================
algorithm(naive_string, string_matching, 'O(m*n)',   'O(1)', stable, 'Checks every position in the text. Simple but slow for large texts.').
algorithm(kmp,          string_matching, 'O(m + n)', 'O(m)', stable, 'Knuth-Morris-Pratt. Never re-examines characters. Best for single pattern search.').
algorithm(rabin_karp,   string_matching, 'O(m + n)', 'O(1)', stable, 'Uses rolling hash. Best for searching multiple patterns in a single pass.').
algorithm(boyer_moore,  string_matching, 'O(m*n)',   'O(m)', stable, 'Skips large sections of text. Best practical speed for large alphabet text search.').
algorithm(z_algorithm,  string_matching, 'O(m + n)', 'O(n)', stable, 'Linear time matching using Z-array. Clean alternative to KMP in competitive programming.').
