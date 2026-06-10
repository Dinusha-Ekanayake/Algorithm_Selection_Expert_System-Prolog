% ============================================================
%  rules.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Core recommendation rules.
%
%  Prolog constructs used:
%  :- discontiguous  -- allows a predicate to be defined across sections
%  :-                -- rule operator (Head :- Body means "Head if Body")
%  !                 -- cut, prevents backtracking past this clause
%  -> ;              -- if-then-else conditional
%  \+                -- negation-as-failure
%  findall/3         -- collect all solutions into a list
%  bagof/3           -- collect solutions grouped by free variables
%  member/2          -- check/generate list membership
%  forall/2          -- verify a condition holds for all solutions
% ============================================================

% Tell Prolog that recommend/6 clauses are spread across multiple
% sections of this file. Without this, SWI-Prolog warns that the
% predicate is defined in multiple places.
:- discontiguous recommend/6.


% ============================================================
%  SORTING RULES
% ============================================================

% Tiny data - simplicity wins no matter what
recommend(sorting, small, _, simplicity, _, insertion_sort) :- !.

% Nearly sorted - insertion sort is provably best
recommend(sorting, _, _, _, nearly_sorted, insertion_sort) :- !.

% Stability required + large data -> merge sort
recommend(sorting, large, _, stability, _, merge_sort) :- !.

% Stability required + medium data -> tim sort
recommend(sorting, medium, _, stability, _, tim_sort) :- !.

% Memory is critical + any size -> heap sort (only O(1) space O(n log n) sort)
recommend(sorting, _, low, _, _, heap_sort) :- !.

% Integer data in a known small range -> counting sort O(n+k)
recommend(sorting, _, _, speed, integer_small_range, counting_sort) :- !.

% Integer data in large range -> radix sort (digit-by-digit)
recommend(sorting, _, _, speed, integer_large_range, radix_sort) :- !.

% Floating-point uniformly distributed -> bucket sort
recommend(sorting, _, _, _, float_uniform, bucket_sort) :- !.

% Speed priority + large data -> quick sort (best average case)
recommend(sorting, large, _, speed, _, quick_sort) :- !.

% Speed priority + medium data -> quick sort
recommend(sorting, medium, _, speed, _, quick_sort) :- !.

% Fallback: tim sort is the safest all-round choice
recommend(sorting, _, _, _, _, tim_sort).


% ============================================================
%  SEARCHING RULES
% ============================================================

% Unsorted data - linear search is the only correct option
recommend(searching, _, _, _, unsorted, linear_search) :- !.

% Unbounded or infinite array -> exponential search
recommend(searching, _, _, _, unbounded, exponential_search) :- !.

% Uniformly distributed sorted data -> interpolation search
recommend(searching, _, _, speed, uniform_sorted, interpolation_search) :- !.

% Unimodal function (find peak or minimum) -> ternary search
recommend(searching, _, _, _, unimodal, ternary_search) :- !.

% Large sorted data, speed priority -> binary search
recommend(searching, large, _, speed, sorted, binary_search) :- !.

% Medium sorted data -> binary search
recommend(searching, medium, _, _, sorted, binary_search) :- !.

% Small sorted, memory tight -> jump search
recommend(searching, small, low, _, sorted, jump_search) :- !.

% Fallback
recommend(searching, _, _, _, _, binary_search).


% ============================================================
%  GRAPH RULES
% ============================================================

% Unweighted graph + shortest path -> BFS
recommend(graph, _, _, _, unweighted, bfs) :- !.

% Cycle detection or exhaustive exploration -> DFS
recommend(graph, _, _, _, cycle_detection, dfs) :- !.

% Dependency ordering (build systems, course prereqs) -> topological sort
recommend(graph, _, _, _, topological, topological_sort) :- !.

% Positive weighted, heuristic available -> A*
recommend(graph, _, _, _, heuristic, a_star) :- !.

% Negative weights present -> Bellman-Ford (only correct option)
recommend(graph, _, _, _, weighted_negative, bellman_ford) :- !.

% All-pairs shortest path, small dense graph -> Floyd-Warshall
recommend(graph, small, _, _, all_pairs, floyd_warshall) :- !.

% Positive weighted + speed priority -> Dijkstra
recommend(graph, _, _, speed, weighted_positive, dijkstra) :- !.

% Sparse minimum spanning tree -> Kruskal
recommend(graph, _, _, _, sparse_mst, kruskal) :- !.

% Dense minimum spanning tree -> Prim
recommend(graph, _, _, _, dense_mst, prim) :- !.

% Fallback
recommend(graph, _, _, _, _, bfs).


% ============================================================
%  DYNAMIC PROGRAMMING RULES
% ============================================================

% Weight/value optimisation under constraint -> Knapsack DP
recommend(dynamic_programming, _, _, _, knapsack, knapsack_dp) :- !.

% Sequence alignment, diff tools -> LCS DP
recommend(dynamic_programming, _, _, _, lcs, lcs_dp) :- !.

% Longest increasing subsequence -> LIS DP
recommend(dynamic_programming, _, _, _, lis, lis_dp) :- !.

% Memory tight -> tabulation (no recursive call stack overhead)
recommend(dynamic_programming, _, low, _, _, tabulation) :- !.

% Speed priority -> tabulation
recommend(dynamic_programming, _, _, speed, _, tabulation) :- !.

% Natural recursion, moderate memory -> memoization
recommend(dynamic_programming, _, moderate, _, _, memoization) :- !.

% Fallback
recommend(dynamic_programming, _, _, _, _, memoization).


% ============================================================
%  STRING MATCHING RULES
% ============================================================

% Multiple patterns in one scan -> Rabin-Karp
recommend(string_matching, _, _, _, multi_pattern, rabin_karp) :- !.

% Large text + large alphabet + speed -> Boyer-Moore
recommend(string_matching, large, _, speed, _, boyer_moore) :- !.

% Single pattern, guaranteed linear time -> KMP
recommend(string_matching, _, _, _, single_pattern, kmp) :- !.

% Memory tight -> Z-algorithm (single array, no hash)
recommend(string_matching, _, low, _, _, z_algorithm) :- !.

% Small text + simplicity -> naive
recommend(string_matching, small, _, simplicity, _, naive_string) :- !.

% Fallback
recommend(string_matching, _, _, _, _, kmp).


% ============================================================
%  ALTERNATIVE SUGGESTIONS
%  alternative(+ProblemType, +Recommended, -Alternative)
% ============================================================

alternative(sorting, merge_sort,     quick_sort).
alternative(sorting, quick_sort,     merge_sort).
alternative(sorting, heap_sort,      merge_sort).
alternative(sorting, tim_sort,       merge_sort).
alternative(sorting, insertion_sort, bubble_sort).
alternative(sorting, counting_sort,  radix_sort).
alternative(sorting, radix_sort,     counting_sort).
alternative(sorting, bucket_sort,    counting_sort).

alternative(searching, binary_search,        jump_search).
alternative(searching, interpolation_search, binary_search).
alternative(searching, linear_search,        binary_search).
alternative(searching, exponential_search,   binary_search).
alternative(searching, ternary_search,       binary_search).

alternative(graph, dijkstra,       a_star).
alternative(graph, a_star,         dijkstra).
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
alternative(dynamic_programming, lis_dp,      tabulation).

alternative(string_matching, kmp,         boyer_moore).
alternative(string_matching, boyer_moore, kmp).
alternative(string_matching, rabin_karp,  kmp).
alternative(string_matching, naive_string,kmp).
alternative(string_matching, z_algorithm, kmp).


% ============================================================
%  HELPER PREDICATES
%  Uses: findall/3, bagof/3, member/2, forall/2, \+
% ============================================================

% all_in_category(+Category, -List)
% Collects all algorithm names in a given category.
all_in_category(Category, List) :-
    findall(Name, algorithm(Name, Category, _, _, _, _), List).

% algorithm_exists(+Name)
% Succeeds if the algorithm is in the knowledge base.
algorithm_exists(Name) :-
    algorithm(Name, _, _, _, _, _).

% category_exists(+Category)
% Succeeds if at least one algorithm exists in the category.
category_exists(Category) :-
    algorithm(_, Category, _, _, _, _), !.

% count_in_category(+Category, -Count)
% Counts how many algorithms exist in a given category.
count_in_category(Category, Count) :-
    findall(_, algorithm(_, Category, _, _, _, _), List),
    length(List, Count).

% all_categories(-Categories)
% Returns a sorted deduplicated list of all categories.
all_categories(Categories) :-
    findall(C, algorithm(_, C, _, _, _, _), Raw),
    sort(Raw, Categories).

% stable_algorithms_in(+Category, -List)
% Returns only stable algorithms in a category.
stable_algorithms_in(Category, List) :-
    findall(Name,
        ( algorithm(Name, Category, _, _, Stab, _),
          member(Stab, [stable]) ),
        List).

% fast_algorithms(+Category, -List)
% Returns algorithms whose time complexity does not contain n^2.
fast_algorithms(Category, List) :-
    findall(Name,
        ( algorithm(Name, Category, Time, _, _, _),
          \+ sub_string(Time, _, _, _, "n^2") ),
        List).

% inplace_algorithms(+Category, -List)
% Returns algorithms with O(1) space complexity.
inplace_algorithms(Category, List) :-
    findall(Name,
        algorithm(Name, Category, _, 'O(1)', _, _),
        List).

% all_exist(+AlgoList)
% Verifies that every algorithm in a list exists in the KB.
all_exist(AlgoList) :-
    forall(member(A, AlgoList), algorithm(A, _, _, _, _, _)).


% ============================================================
%  SCORING ENGINE
%  score_algorithm(+Algo, +DS, +Mem, +Pri, +DO, -Score)
%
%  Awards points based on how well an algorithm fits the
%  given constraints. Used by rank_algorithms/6.
% ============================================================

score_algorithm(Algo, DS, Mem, Pri, DO, Score) :-
    algorithm(Algo, _, _, Space, Stab, _),
    % +30 if this is the primary recommendation for these constraints
    ( recommend(_, DS, Mem, Pri, DO, Algo) -> P1 = 30 ; P1 = 0 ),
    % +20 if stability is the priority and the algorithm is stable
    ( Pri = stability, Stab = stable     -> P2 = 20 ; P2 = 0 ),
    % +15 if memory is low and the algorithm is in-place
    ( Mem = low, member(Space, ['O(1)', 'O(log n)']) -> P3 = 15 ; P3 = 0 ),
    % +10 if the data characteristic is a known high-specificity condition
    ( member(DO, [nearly_sorted, integer_small_range, float_uniform,
                  unweighted, weighted_negative, knapsack, lcs, lis,
                  multi_pattern, single_pattern]) -> P4 = 10 ; P4 = 0 ),
    % +5 if the dataset is large (rewards scalable algorithms)
    ( DS = large -> P5 = 5 ; P5 = 0 ),
    Score is P1 + P2 + P3 + P4 + P5.


% ============================================================
%  RECURSION 1: rank_algorithms/6
%
%  Scores every algorithm in a category recursively and
%  returns them sorted from best to worst fit.
%
%  rank_algorithms(+Category, +DS, +Mem, +Pri, +DO, -Ranked)
% ============================================================

rank_algorithms(Category, DS, Mem, Pri, DO, Ranked) :-
    all_in_category(Category, Algos),
    score_all(Algos, DS, Mem, Pri, DO, Scored),
    msort(Scored, Ascending),
    reverse(Ascending, Ranked).

% Base case: empty list produces empty scored list
score_all([], _, _, _, _, []).

% Recursive case: score the head, prepend result, recurse on tail
score_all([Algo|Rest], DS, Mem, Pri, DO, [Score-Algo|ScoredRest]) :-
    score_algorithm(Algo, DS, Mem, Pri, DO, Score),
    score_all(Rest, DS, Mem, Pri, DO, ScoredRest).


% ============================================================
%  RECURSION 2: collect_warnings/2
%
%  Walks a list of algorithms and collects avoid_when/2
%  warnings for each one that has a warning defined.
%
%  collect_warnings(+AlgoList, -Warnings)
% ============================================================

% Base case: empty list, no warnings
collect_warnings([], []).

% If avoid_when exists for the head, include it and recurse
collect_warnings([Algo|Rest], [Algo-Warning|MoreWarnings]) :-
    avoid_when(Algo, Warning), !,
    collect_warnings(Rest, MoreWarnings).

% If no warning for the head, skip it and recurse
collect_warnings([_|Rest], Warnings) :-
    collect_warnings(Rest, Warnings).


% ============================================================
%  RECURSION 3: filter_by_score/3
%
%  Walks a scored list and keeps only entries at or above
%  a given score threshold.
%
%  filter_by_score(+ScoredList, +Threshold, -Filtered)
% ============================================================

% Base case: empty list
filter_by_score([], _, []).

% Keep head if score >= threshold, recurse on tail
filter_by_score([Score-Algo|Rest], Threshold, [Score-Algo|Kept]) :-
    Score >= Threshold, !,
    filter_by_score(Rest, Threshold, Kept).

% Skip head if below threshold, recurse on tail
filter_by_score([_|Rest], Threshold, Kept) :-
    filter_by_score(Rest, Threshold, Kept).


% ============================================================
%  RECURSION 4: build_comparison/3
%
%  Builds a list of algo/4 compound terms from a scored list.
%  Stops when the list is empty or the max row count is reached.
%
%  build_comparison(+ScoredList, +Max, -CompList)
% ============================================================

% Base case: max rows reached
build_comparison(_, 0, []) :- !.

% Base case: list is empty
build_comparison([], _, []).

% Recursive case: fetch details, build term, decrement Max, recurse
build_comparison([_Score-Algo|Rest], Max, [algo(Algo,Time,Space,Stab)|More]) :-
    algorithm(Algo, _, Time, Space, Stab, _),
    Next is Max - 1,
    build_comparison(Rest, Next, More).