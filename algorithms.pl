% ============================================================
%  algorithms.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Knowledge base: all algorithms with their properties.
%  algorithm(Name, Category, TimeComplexity, SpaceComplexity, Stable, Description)
% ============================================================

% ---- SORTING ALGORITHMS ----
algorithm(bubble_sort,    sorting, 'O(n²)',      'O(1)',      stable,   'Simple comparison-based sort. Best for tiny or nearly sorted datasets.').
algorithm(selection_sort, sorting, 'O(n²)',      'O(1)',      unstable, 'Finds the minimum element repeatedly. Simple but inefficient for large data.').
algorithm(insertion_sort, sorting, 'O(n²)',      'O(1)',      stable,   'Builds sorted array one item at a time. Efficient for small or nearly sorted data.').
algorithm(merge_sort,     sorting, 'O(n log n)', 'O(n)',      stable,   'Divide-and-conquer sort. Guaranteed O(n log n). Best when stability is required.').
algorithm(quick_sort,     sorting, 'O(n log n)', 'O(log n)', unstable, 'Fast in practice. Best average-case performance. Avoid on nearly sorted data.').
algorithm(heap_sort,      sorting, 'O(n log n)', 'O(1)',      unstable, 'In-place sort with guaranteed O(n log n). Good when memory is limited.').
algorithm(counting_sort,  sorting, 'O(n + k)',   'O(k)',      stable,   'Non-comparison sort for integers in a known range. Extremely fast when k is small.').
algorithm(radix_sort,     sorting, 'O(nk)',      'O(n + k)', stable,   'Sorts integers digit by digit. Very fast for fixed-length integer keys.').
algorithm(tim_sort,       sorting, 'O(n log n)', 'O(n)',      stable,   'Hybrid of merge and insertion sort. Used in Python and Java. Best all-rounder.').
algorithm(shell_sort,     sorting, 'O(n log² n)','O(1)',      unstable, 'Generalization of insertion sort. Better than O(n²) sorts in practice.').
algorithm(bucket_sort,    sorting, 'O(n + k)',   'O(n)',      stable,   'Distributes elements into buckets. Ideal for uniformly distributed floating-point data.').

% ---- SEARCHING ALGORITHMS ----
algorithm(linear_search,       searching, 'O(n)',       'O(1)',      stable, 'Scans each element. Works on any dataset. Only option for unsorted data.').
algorithm(binary_search,       searching, 'O(log n)',   'O(1)',      stable, 'Halves search space each step. Requires sorted data. Very efficient.').
algorithm(jump_search,         searching, 'O(√n)',      'O(1)',      stable, 'Jumps ahead by fixed steps then linear searches. Good for sorted arrays.').
algorithm(interpolation_search,searching, 'O(log log n)','O(1)',     stable, 'Estimates position like a phone book search. Best for uniformly distributed data.').
algorithm(exponential_search,  searching, 'O(log n)',   'O(1)',      stable, 'Finds range then applies binary search. Best for unbounded or infinite arrays.').
algorithm(ternary_search,      searching, 'O(log₃ n)',  'O(1)',      stable, 'Divides array into three parts. Useful for finding max/min of unimodal functions.').

% ---- GRAPH ALGORITHMS ----
algorithm(bfs,             graph, 'O(V + E)', 'O(V)', stable, 'Breadth-First Search. Finds shortest path in unweighted graphs. Explores level by level.').
algorithm(dfs,             graph, 'O(V + E)', 'O(V)', stable, 'Depth-First Search. Explores as far as possible. Good for cycle detection and topological sort.').
algorithm(dijkstra,        graph, 'O(E log V)','O(V)', stable, 'Finds shortest path in weighted graphs with non-negative weights. Uses a priority queue.').
algorithm(bellman_ford,    graph, 'O(VE)',    'O(V)', stable, 'Shortest path even with negative weights. Detects negative weight cycles.').
algorithm(a_star,          graph, 'O(E)',     'O(V)', stable, 'Heuristic-guided shortest path. Faster than Dijkstra when a good heuristic exists.').
algorithm(floyd_warshall,  graph, 'O(V³)',    'O(V²)',stable, 'All-pairs shortest path. Small dense graphs. Handles negative weights.').
algorithm(kruskal,         graph, 'O(E log E)','O(V)',stable, 'Minimum spanning tree using edge sorting. Best for sparse graphs.').
algorithm(prim,            graph, 'O(E log V)','O(V)',stable, 'Minimum spanning tree using priority queue. Best for dense graphs.').
algorithm(topological_sort,graph, 'O(V + E)', 'O(V)', stable, 'Orders vertices in a DAG. Used in task scheduling and build systems.').

% ---- DYNAMIC PROGRAMMING ----
algorithm(memoization,     dynamic_programming, 'O(n)',  'O(n)', stable, 'Top-down DP with caching. Natural recursive structure. Uses extra memory for cache.').
algorithm(tabulation,      dynamic_programming, 'O(n)',  'O(n)', stable, 'Bottom-up DP. Fills table iteratively. Usually faster than memoization in practice.').
algorithm(knapsack_dp,     dynamic_programming, 'O(nW)', 'O(nW)',stable, 'Solves 0/1 knapsack. Optimises value under weight constraint using DP table.').
algorithm(lcs_dp,          dynamic_programming, 'O(mn)', 'O(mn)',stable, 'Longest Common Subsequence. Used in diff tools and bioinformatics.').
algorithm(lis_dp,          dynamic_programming, 'O(n log n)','O(n)',stable,'Longest Increasing Subsequence. Used in patience sorting and sequence analysis.').

% ---- STRING MATCHING ----
algorithm(naive_string,    string_matching, 'O(mn)',    'O(1)',  stable, 'Checks every position. Simple but slow for large texts.').
algorithm(kmp,             string_matching, 'O(m + n)', 'O(m)', stable, 'Knuth-Morris-Pratt. Never re-examines characters. Best for single pattern search.').
algorithm(rabin_karp,      string_matching, 'O(m + n)', 'O(1)', stable, 'Uses hashing. Best for multiple pattern search in a single pass.').
algorithm(boyer_moore,     string_matching, 'O(mn)',    'O(m)', stable, 'Skips sections of text. Best practical performance for large alphabets.').
algorithm(z_algorithm,     string_matching, 'O(m + n)', 'O(n)', stable, 'Linear time pattern matching using Z-array. Alternative to KMP.').
