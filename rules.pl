% ============================================================
%  rules.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Core recommendation rules. Each rule fires when a
%  combination of problem_type, data_size, memory, priority,
%  and data characteristics matches a known pattern.
%
%  recommend(+ProblemType, +DataSize, +Memory,
%            +Priority, +DataOrder, -Algorithm)
% ============================================================


% ============================================================
%  SORTING RULES
% ============================================================

% Tiny data — simplicity wins
recommend(sorting, small, _, simplicity, _, insertion_sort) :- !.

% Nearly sorted — insertion sort dominates
recommend(sorting, _, _, _, nearly_sorted, insertion_sort) :- !.

% Need stability + large data → merge sort
recommend(sorting, large, _, stability, _, merge_sort) :- !.

% Need stability + medium data → tim sort (best all-rounder)
recommend(sorting, medium, _, stability, _, tim_sort) :- !.

% Memory is tight + large data → heap sort (in-place, O(n log n))
recommend(sorting, large, low, _, _, heap_sort) :- !.

% Memory is tight + any size → heap sort
recommend(sorting, _, low, _, _, heap_sort) :- !.

% Integer data + small range → counting sort
recommend(sorting, _, _, speed, integer_small_range, counting_sort) :- !.

% Integer data + large range → radix sort
recommend(sorting, _, _, speed, integer_large_range, radix_sort) :- !.

% Float data uniformly distributed → bucket sort
recommend(sorting, _, _, _, float_uniform, bucket_sort) :- !.

% Speed priority + large data → quick sort
recommend(sorting, large, _, speed, _, quick_sort) :- !.

% Speed priority + medium data → quick sort
recommend(sorting, medium, _, speed, _, quick_sort) :- !.

% General fallback for sorting
recommend(sorting, _, _, _, _, tim_sort).


% ============================================================
%  SEARCHING RULES
% ============================================================

% Unsorted data — only linear search works
recommend(searching, _, _, _, unsorted, linear_search) :- !.

% Unbounded / infinite array → exponential search
recommend(searching, _, _, _, unbounded, exponential_search) :- !.

% Uniformly distributed sorted data → interpolation search
recommend(searching, _, _, speed, uniform_sorted, interpolation_search) :- !.

% Large sorted data, speed priority → binary search
recommend(searching, large, _, speed, sorted, binary_search) :- !.

% Medium sorted data → binary search
recommend(searching, medium, _, _, sorted, binary_search) :- !.

% Small sorted data, memory tight → jump search
recommend(searching, small, low, _, sorted, jump_search) :- !.

% Unimodal function (find max/min) → ternary search
recommend(searching, _, _, _, unimodal, ternary_search) :- !.

% General fallback for searching
recommend(searching, _, _, _, _, binary_search).


% ============================================================
%  GRAPH RULES
% ============================================================

% Find shortest path, unweighted graph → BFS
recommend(graph, _, _, _, unweighted, bfs) :- !.

% Detect cycles or need topological order → DFS
recommend(graph, _, _, _, cycle_detection, dfs) :- !.

% Topological ordering of tasks → topological sort
recommend(graph, _, _, _, topological, topological_sort) :- !.

% Shortest path, weighted, non-negative, need speed → Dijkstra
recommend(graph, _, _, speed, weighted_positive, dijkstra) :- !.

% Shortest path, has negative weights → Bellman-Ford
recommend(graph, _, _, _, weighted_negative, bellman_ford) :- !.

% Shortest path with heuristic (e.g. map navigation) → A*
recommend(graph, _, _, _, heuristic, a_star) :- !.

% All-pairs shortest path, small dense graph → Floyd-Warshall
recommend(graph, small, _, _, all_pairs, floyd_warshall) :- !.

% Minimum spanning tree, sparse graph → Kruskal
recommend(graph, _, _, _, sparse_mst, kruskal) :- !.

% Minimum spanning tree, dense graph → Prim
recommend(graph, _, _, _, dense_mst, prim) :- !.

% General graph fallback
recommend(graph, _, _, _, _, bfs).


% ============================================================
%  DYNAMIC PROGRAMMING RULES
% ============================================================

% Knapsack / weight-value optimisation
recommend(dynamic_programming, _, _, _, knapsack, knapsack_dp) :- !.

% Longest common subsequence (diff, DNA)
recommend(dynamic_programming, _, _, _, lcs, lcs_dp) :- !.

% Longest increasing subsequence
recommend(dynamic_programming, _, _, _, lis, lis_dp) :- !.

% Memory is tight → tabulation (no call stack overhead)
recommend(dynamic_programming, _, low, _, _, tabulation) :- !.

% Natural recursion, moderate memory → memoization
recommend(dynamic_programming, _, moderate, _, _, memoization) :- !.

% Speed priority → tabulation
recommend(dynamic_programming, _, _, speed, _, tabulation) :- !.

% Fallback
recommend(dynamic_programming, _, _, _, _, memoization).


% ============================================================
%  STRING MATCHING RULES
% ============================================================

% Multiple patterns in one pass → Rabin-Karp
recommend(string_matching, _, _, _, multi_pattern, rabin_karp) :- !.

% Large text, large alphabet → Boyer-Moore
recommend(string_matching, large, _, speed, _, boyer_moore) :- !.

% Single pattern, need guaranteed linear time → KMP
recommend(string_matching, _, _, _, single_pattern, kmp) :- !.

% Alternative linear time with Z-array
recommend(string_matching, _, low, _, _, z_algorithm) :- !.

% Simple small text → naive
recommend(string_matching, small, _, simplicity, _, naive_string) :- !.

% Fallback
recommend(string_matching, _, _, _, _, kmp).


% ============================================================
%  ALTERNATIVE SUGGESTIONS
% ============================================================

% For each primary recommendation, suggest alternatives.
% alternative(ProblemType, Recommended, Alternative)

alternative(sorting, merge_sort,     quick_sort).
alternative(sorting, quick_sort,     merge_sort).
alternative(sorting, heap_sort,      merge_sort).
alternative(sorting, tim_sort,       merge_sort).
alternative(sorting, insertion_sort, bubble_sort).
alternative(sorting, counting_sort,  radix_sort).
alternative(sorting, bucket_sort,    counting_sort).

alternative(searching, binary_search,        jump_search).
alternative(searching, interpolation_search, binary_search).
alternative(searching, linear_search,        binary_search).
alternative(searching, exponential_search,   binary_search).

alternative(graph, dijkstra,       a_star).
alternative(graph, bellman_ford,   dijkstra).
alternative(graph, bfs,            dfs).
alternative(graph, dfs,            bfs).
alternative(graph, kruskal,        prim).
alternative(graph, prim,           kruskal).
alternative(graph, floyd_warshall, dijkstra).

alternative(dynamic_programming, memoization, tabulation).
alternative(dynamic_programming, tabulation,  memoization).
alternative(dynamic_programming, knapsack_dp, tabulation).
alternative(dynamic_programming, lcs_dp,      memoization).

alternative(string_matching, kmp,         boyer_moore).
alternative(string_matching, boyer_moore, kmp).
alternative(string_matching, rabin_karp,  kmp).
alternative(string_matching, naive_string,kmp).
alternative(string_matching, z_algorithm, kmp).
