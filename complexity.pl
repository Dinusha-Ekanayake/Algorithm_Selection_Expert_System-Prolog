% ============================================================
%  complexity.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Supplementary facts: real-world use cases and warning
%  conditions for every algorithm in the knowledge base.
%  These are loaded by web_interface.pl at startup and
%  used on the result page to explain the recommendation.
% ============================================================

% Declare discontiguous so use_case/2 and avoid_when/2 facts
% can be defined in separate sections without SWI-Prolog warnings.
:- discontiguous use_case/2.
:- discontiguous avoid_when/2.


% ============================================================
%  USE CASES
%  use_case(+AlgorithmName, -Description)
%  Maps each algorithm to its real-world applications.
% ============================================================

use_case(bubble_sort,     'Teaching sorting concepts; detecting one swap needed in a nearly sorted list.').
use_case(selection_sort,  'When write operations are expensive - it minimises total swaps.').
use_case(insertion_sort,  'Online sorting where elements arrive one at a time; small hand-sorted card decks.').
use_case(merge_sort,      'External sorting of large disk files; sorting linked lists where random access is costly.').
use_case(quick_sort,      'General-purpose in-memory sorting; used in C standard library qsort.').
use_case(heap_sort,       'Real-time systems needing guaranteed O(n log n) with strict O(1) space.').
use_case(counting_sort,   'Sorting exam scores, age groups, grades, or any small-range integer keys.').
use_case(radix_sort,      'Sorting IP addresses, phone numbers, fixed-length strings, or large integers.').
use_case(tim_sort,        'Python built-in sort(); Java Arrays.sort() for objects; any mixed real-world data.').
use_case(shell_sort,      'Embedded systems with limited memory needing better-than-insertion-sort performance.').
use_case(bucket_sort,     'Sorting floating-point numbers uniformly distributed in [0, 1].').

use_case(linear_search,        'Searching unsorted or small lists; linked lists where indexing is not possible.').
use_case(binary_search,        'Dictionary lookups; database index searches; finding in sorted arrays.').
use_case(jump_search,          'Sorted arrays where binary search overhead is undesirable.').
use_case(interpolation_search, 'Sorted phone books, dictionaries, or uniformly spaced data.').
use_case(exponential_search,   'Searching in unbounded sorted arrays or data streams.').
use_case(ternary_search,       'Finding the peak in unimodal functions; mathematical optimisation.').

use_case(bfs,             'Shortest path in unweighted graphs; level-order tree traversal; web crawlers.').
use_case(dfs,             'Maze solving; topological sort; detecting cycles; connected components.').
use_case(dijkstra,        'GPS navigation; network routing protocols; map applications.').
use_case(bellman_ford,    'Currency arbitrage detection; routing with potentially negative edge costs.').
use_case(a_star,          'Game AI pathfinding; robotics navigation; map routing with heuristic estimates.').
use_case(floyd_warshall,  'Network delay analysis; all-pairs shortest path in small dense graphs.').
use_case(kruskal,         'Network cable layout minimisation; sparse graph minimum spanning trees.').
use_case(prim,            'Dense network MST; infrastructure design with many connections.').
use_case(topological_sort,'Build systems (Make, Gradle); task scheduling; course prerequisite ordering.').

use_case(memoization, 'Fibonacci; recursive tree problems; any top-down DP with natural recursion.').
use_case(tabulation,  'Grid path counting; bottom-up DP where all subproblem states are needed.').
use_case(knapsack_dp, 'Resource allocation; investment portfolio optimisation; cargo loading problems.').
use_case(lcs_dp,      'Git diff; DNA sequence alignment; document similarity; plagiarism detection.').
use_case(lis_dp,      'Patience sorting; analysing monotone subsequences in stock prices.').

use_case(naive_string, 'Simple pattern matching in very short texts or as a teaching baseline.').
use_case(kmp,          'Text editors; DNA sequence search; searching for a single pattern efficiently.').
use_case(rabin_karp,   'Plagiarism detection; searching for multiple patterns simultaneously.').
use_case(boyer_moore,  'Text editors like grep; searching large English documents with big alphabets.').
use_case(z_algorithm,  'Efficient pattern matching; widely used in competitive programming.').


% ============================================================
%  AVOID CONDITIONS
%  avoid_when(+AlgorithmName, -Reason)
%  Encodes conditions under which an algorithm should NOT be used.
% ============================================================

avoid_when(bubble_sort,    'Data is large - O(n^2) becomes impractically slow beyond a few thousand elements.').
avoid_when(selection_sort, 'Data is large or stability is required - O(n^2) and not stable.').
avoid_when(insertion_sort, 'Data is large and random - O(n^2) worst case.').
avoid_when(quick_sort,     'Data is nearly sorted - degrades to O(n^2) without randomised pivot selection.').
avoid_when(counting_sort,  'The value range k is much larger than n - wastes time and memory initialising the count array.').
avoid_when(radix_sort,     'Data is not integer or fixed-length keys - not applicable.').
avoid_when(bucket_sort,    'Data is not uniformly distributed - creates heavily unbalanced buckets.').
avoid_when(merge_sort,     'Memory is very tight - requires O(n) extra space for the merge step.').
avoid_when(heap_sort,      'Cache performance matters - poor cache locality compared to quick sort.').

avoid_when(binary_search,        'Data is unsorted - requires sorted array as a strict precondition.').
avoid_when(interpolation_search, 'Data is not uniformly distributed - degrades to O(n).').
avoid_when(ternary_search,       'Function is not unimodal - produces incorrect results.').
avoid_when(exponential_search,   'Array is bounded and small - binary search is simpler and equivalent.').

avoid_when(dijkstra,      'Graph has negative weight edges - produces incorrect shortest paths.').
avoid_when(floyd_warshall,'Graph is large or sparse - O(V^3) time and O(V^2) space become prohibitive.').
avoid_when(bfs,           'Graph is very deep or wide - high memory usage for the frontier queue.').
avoid_when(a_star,        'No admissible heuristic is available - falls back to Dijkstra performance.').
avoid_when(bellman_ford,  'Graph is large and dense - O(VE) is too slow; use Dijkstra instead.').

avoid_when(memoization, 'Recursion depth is very large - risk of stack overflow errors.').
avoid_when(tabulation,  'Only a few subproblems are needed - memoization avoids computing unnecessary states.').
avoid_when(knapsack_dp, 'Weights are large floating-point values - the DP table becomes impractical.').

avoid_when(naive_string,  'Text or pattern is large - O(m*n) is too slow.').
avoid_when(rabin_karp,    'Hash collisions occur frequently - may degrade to O(m*n) worst case.').
avoid_when(boyer_moore,   'Pattern is very short or alphabet is very small - skip heuristics do not fire.').