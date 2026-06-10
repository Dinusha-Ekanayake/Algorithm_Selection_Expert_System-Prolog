% ============================================================
%  complexity.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Supplementary facts: use cases, when to avoid,
%  and real-world applications for each algorithm.
% ============================================================

% use_case(AlgorithmName, UseCase)
use_case(bubble_sort,     'Teaching sorting concepts and small classroom examples').
use_case(selection_sort,  'When write operations are costly (minimizes swaps)').
use_case(insertion_sort,  'Online sorting where elements arrive one at a time').
use_case(merge_sort,      'External sorting of large files, linked list sorting').
use_case(quick_sort,      'General-purpose in-memory sorting, used in C stdlib qsort').
use_case(heap_sort,       'Real-time systems needing guaranteed O(n log n) and O(1) space').
use_case(counting_sort,   'Sorting exam scores, age groups, or small integer keys').
use_case(radix_sort,      'Sorting IP addresses, phone numbers, fixed-length strings').
use_case(tim_sort,        'Python built-in sort, Java Arrays.sort for objects').
use_case(shell_sort,      'Embedded systems with limited memory and moderate data').
use_case(bucket_sort,     'Sorting floating-point numbers uniformly distributed in [0,1]').

use_case(linear_search,        'Searching unsorted lists, small datasets, linked lists').
use_case(binary_search,        'Dictionary lookups, database indexing, sorted arrays').
use_case(jump_search,          'Sorted arrays where binary search is too complex to implement').
use_case(interpolation_search, 'Searching through sorted phone books or dictionaries').
use_case(exponential_search,   'Searching in unbounded sorted arrays or streams').
use_case(ternary_search,       'Finding peak in unimodal functions, optimization problems').

use_case(bfs,             'Shortest path in unweighted graphs, level-order traversal, web crawlers').
use_case(dfs,             'Maze solving, topological sort, connected components, backtracking').
use_case(dijkstra,        'GPS navigation, network routing, map applications').
use_case(bellman_ford,    'Currency arbitrage detection, routing with negative costs').
use_case(a_star,          'Game AI pathfinding, robotics navigation, map routing').
use_case(floyd_warshall,  'Network delay analysis, transitive closure, small road networks').
use_case(kruskal,         'Network cable layout, sparse graph MST problems').
use_case(prim,            'Dense graph MST, network design with many connections').
use_case(topological_sort,'Build systems, task scheduling, course prerequisite ordering').

use_case(memoization,     'Fibonacci, recursive tree problems, top-down DP problems').
use_case(tabulation,      'Fibonacci, grid problems, bottom-up DP where all states needed').
use_case(knapsack_dp,     'Resource allocation, budget optimisation, cargo loading').
use_case(lcs_dp,          'Git diff, DNA sequence alignment, plagiarism detection').
use_case(lis_dp,          'Patience sorting, stock price analysis, sequence problems').

use_case(naive_string,    'Simple pattern matching in short texts or for teaching').
use_case(kmp,             'Text editors, DNA sequence search, single pattern matching').
use_case(rabin_karp,      'Plagiarism detection, searching for multiple patterns at once').
use_case(boyer_moore,     'Text editors like grep, large English text search').
use_case(z_algorithm,     'Efficient pattern matching, alternative to KMP in competitive programming').


% avoid_when(AlgorithmName, Reason)
avoid_when(bubble_sort,    'Data is large — O(n²) becomes impractically slow').
avoid_when(selection_sort, 'Data is large or stability is required').
avoid_when(insertion_sort, 'Data is large and random — O(n²) worst case').
avoid_when(quick_sort,     'Data is nearly sorted — degrades to O(n²) without pivot randomization').
avoid_when(counting_sort,  'The range of values (k) is much larger than n').
avoid_when(radix_sort,     'Data is not integer or fixed-length — not applicable').
avoid_when(bucket_sort,    'Data is not uniformly distributed — creates unbalanced buckets').

avoid_when(binary_search,        'Data is unsorted — requires sorted array as precondition').
avoid_when(interpolation_search, 'Data is not uniformly distributed — degrades to O(n)').
avoid_when(ternary_search,       'Function is not unimodal — produces wrong results').

avoid_when(dijkstra,      'Graph contains negative weight edges — gives incorrect results').
avoid_when(floyd_warshall,'Graph is large and sparse — O(V³) becomes too slow').
avoid_when(bfs,           'Graph is very deep — high memory usage for the queue').
avoid_when(dfs,           'Need shortest path in unweighted graph — use BFS instead').

avoid_when(memoization,   'Stack depth is very large — risk of stack overflow').
avoid_when(knapsack_dp,   'Weights are very large floating-point — table becomes impractical').

avoid_when(naive_string,  'Text or pattern is large — O(mn) is too slow').
avoid_when(rabin_karp,    'Hash collisions are likely — may need many verification steps').
