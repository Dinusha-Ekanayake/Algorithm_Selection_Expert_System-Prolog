% ============================================================
%  rules.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Core recommendation rules using:
%  - Cuts (!) for deterministic selection
%  - If-then-else (-> ;) for conditional branching
%  - findall/3 to collect all matching candidates
%  - member/2 to test category membership
%  - Negation-as-failure (\+) for constraint checking
%
%  recommend(+ProblemType, +DataSize, +Memory,
%            +Priority, +DataOrder, -Algorithm)
% ============================================================

% ============================================================
%  SORTING RULES
% ============================================================

% Tiny data — simplicity always wins regardless of other factors
recommend(sorting, small, _, simplicity, _, insertion_sort) :- !.

% Nearly sorted input — insertion sort is provably optimal
recommend(sorting, _, _, _, nearly_sorted, insertion_sort) :- !.

% Stability required + large data → merge sort (guaranteed stable O(n log n))
recommend(sorting, large, _, stability, _, merge_sort) :- !.

% Stability required + medium data → tim sort (best practical stable sort)
recommend(sorting, medium, _, stability, _, tim_sort) :- !.

% Memory is critical + any size → heap sort (only O(1) space with O(n log n))
recommend(sorting, _, low, _, _, heap_sort) :- !.

% Integer data in a known small range → counting sort (O(n+k))
recommend(sorting, _, _, speed, integer_small_range, counting_sort) :- !.

% Integer data in large range → radix sort (digit-by-digit)
recommend(sorting, _, _, speed, integer_large_range, radix_sort) :- !.

% Floating-point uniformly distributed → bucket sort
recommend(sorting, _, _, _, float_uniform, bucket_sort) :- !.

% Speed priority + large data → quick sort (best average case)
recommend(sorting, large, _, speed, _, quick_sort) :- !.

% Speed priority + medium data → quick sort
recommend(sorting, medium, _, speed, _, quick_sort) :- !.

% Fallback: tim sort is the safest all-round choice
recommend(sorting, _, _, _, _, tim_sort).


% ============================================================
%  SEARCHING RULES
% ============================================================

% Unsorted data — linear search is the only correct option
recommend(searching, _, _, _, unsorted, linear_search) :- !.

% Unbounded or infinite array → exponential search (finds range first)
recommend(searching, _, _, _, unbounded, exponential_search) :- !.

% Uniformly distributed sorted data → interpolation search
recommend(searching, _, _, speed, uniform_sorted, interpolation_search) :- !.

% Unimodal function (find peak/minimum) → ternary search
recommend(searching, _, _, _, unimodal, ternary_search) :- !.

% Large sorted data, speed priority → binary search
recommend(searching, large, _, speed, sorted, binary_search) :- !.

% Medium sorted data → binary search
recommend(searching, medium, _, _, sorted, binary_search) :- !.

% Small sorted, memory tight → jump search
recommend(searching, small, low, _, sorted, jump_search) :- !.

% Fallback
recommend(searching, _, _, _, _, binary_search).


% ============================================================
%  GRAPH RULES
% ============================================================

% Unweighted graph + shortest path → BFS (provably optimal)
recommend(graph, _, _, _, unweighted, bfs) :- !.

% Cycle detection or exhaustive exploration → DFS
recommend(graph, _, _, _, cycle_detection, dfs) :- !.

% Dependency ordering (build systems, course prereqs) → topological sort
recommend(graph, _, _, _, topological, topological_sort) :- !.

% Positive weighted, heuristic available → A* (beats Dijkstra with good heuristic)
recommend(graph, _, _, _, heuristic, a_star) :- !.

% Negative weights present → Bellman-Ford (only correct option)
recommend(graph, _, _, _, weighted_negative, bellman_ford) :- !.

% All-pairs shortest path, small dense graph → Floyd-Warshall
recommend(graph, small, _, _, all_pairs, floyd_warshall) :- !.

% Positive weighted + speed priority → Dijkstra
recommend(graph, _, _, speed, weighted_positive, dijkstra) :- !.

% Sparse minimum spanning tree → Kruskal
recommend(graph, _, _, _, sparse_mst, kruskal) :- !.

% Dense minimum spanning tree → Prim
recommend(graph, _, _, _, dense_mst, prim) :- !.

% Fallback
recommend(graph, _, _, _, _, bfs).


% ============================================================
%  DYNAMIC PROGRAMMING RULES
% ============================================================

% Weight/value optimisation under constraint → Knapsack DP
recommend(dynamic_programming, _, _, _, knapsack, knapsack_dp) :- !.

% Sequence alignment, diff tools → LCS DP
recommend(dynamic_programming, _, _, _, lcs, lcs_dp) :- !.

% Longest increasing subsequence → LIS DP
recommend(dynamic_programming, _, _, _, lis, lis_dp) :- !.

% Memory tight → tabulation (no recursive call stack overhead)
recommend(dynamic_programming, _, low, _, _, tabulation) :- !.

% Speed priority → tabulation (avoids function call overhead)
recommend(dynamic_programming, _, _, speed, _, tabulation) :- !.

% Natural recursion, moderate memory → memoization
recommend(dynamic_programming, _, moderate, _, _, memoization) :- !.

% Fallback
recommend(dynamic_programming, _, _, _, _, memoization).


% ============================================================
%  STRING MATCHING RULES
% ============================================================

% Multiple patterns in one scan → Rabin-Karp (rolling hash)
recommend(string_matching, _, _, _, multi_pattern, rabin_karp) :- !.

% Large text + large alphabet + speed → Boyer-Moore (skips most chars)
recommend(string_matching, large, _, speed, _, boyer_moore) :- !.

% Single pattern, guaranteed linear time → KMP
recommend(string_matching, _, _, _, single_pattern, kmp) :- !.

% Memory tight → Z-algorithm (single array, no hash)
recommend(string_matching, _, low, _, _, z_algorithm) :- !.

% Small text + simplicity → naive
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
%  HELPER: find all algorithms that match a category
%  Uses findall/3 and member/2 — required Prolog constructs
% ============================================================

% all_in_category(+Category, -List)
all_in_category(Category, List) :-
    findall(Name, algorithm(Name, Category, _, _, _, _), List).

% algorithm_exists(+Name)
algorithm_exists(Name) :-
    algorithm(Name, _, _, _, _, _).

% category_exists(+Category)
category_exists(Category) :-
    algorithm(_, Category, _, _, _, _), !.

% count_in_category(+Category, -Count)
count_in_category(Category, Count) :-
    findall(_, algorithm(_, Category, _, _, _, _), List),
    length(List, Count).

% all_categories(-Categories)
all_categories(Categories) :-
    findall(C, algorithm(_, C, _, _, _, _), Raw),
    sort(Raw, Categories).

% stable_algorithms_in(+Category, -List)
stable_algorithms_in(Category, List) :-
    findall(Name,
        ( algorithm(Name, Category, _, _, Stab, _),
          member(Stab, [stable]) ),
        List).

% fast_algorithms(+Category, -List)
fast_algorithms(Category, List) :-
    findall(Name,
        ( algorithm(Name, Category, Time, _, _, _),
          \+ sub_string(Time, _, _, _, "n^2") ),
        List).

% inplace_algorithms(+Category, -List)
inplace_algorithms(Category, List) :-
    findall(Name,
        algorithm(Name, Category, _, 'O(1)', _, _),
        List).


% ============================================================
%  SCORING: how well does an algorithm match the constraints?
%  score_algorithm(+Algo, +DS, +Mem, +Pri, +DO, -Score)
%
%  Each matched constraint adds points.
%  Used by rank_algorithms to sort candidates.
% ============================================================

score_algorithm(Algo, DS, Mem, Pri, DO, Score) :-
    algorithm(Algo, _, _, Space, Stab, _),
    % +30 if this is the primary recommendation
    ( recommend(_, DS, Mem, Pri, DO, Algo) -> P1 = 30 ; P1 = 0 ),
    % +20 if algorithm is stable and stability is the priority
    ( Pri = stability, Stab = stable     -> P2 = 20 ; P2 = 0 ),
    % +15 if algorithm is in-place and memory is tight
    ( Mem = low,  member(Space, ['O(1)', 'O(log n)']) -> P3 = 15 ; P3 = 0 ),
    % +10 if data order matches a known preference
    ( member(DO, [nearly_sorted, integer_small_range, float_uniform,
                  unweighted, weighted_negative, knapsack, lcs, lis,
                  multi_pattern, single_pattern]) -> P4 = 10 ; P4 = 0 ),
    % +5 if data size is large (rewards scalable algorithms)
    ( DS = large -> P5 = 5 ; P5 = 0 ),
    Score is P1 + P2 + P3 + P4 + P5.


% ============================================================
%  RECURSION 1: rank_algorithms/5
%
%  Recursively scores every algorithm in a category and
%  builds a list of Score-Name pairs, then sorts descending.
%
%  rank_algorithms(+Category, +DS, +Mem, +Pri, +DO, -Ranked)
%  Ranked = list of (Score-AlgoName) sorted best first.
% ============================================================

rank_algorithms(Category, DS, Mem, Pri, DO, Ranked) :-
    all_in_category(Category, Algos),
    score_all(Algos, DS, Mem, Pri, DO, Scored),
    msort(Scored, Ascending),
    reverse(Ascending, Ranked).

% score_all/6 — recursive base case: empty list
score_all([], _, _, _, _, []).

% score_all/6 — recursive step: score head, recurse on tail
score_all([Algo|Rest], DS, Mem, Pri, DO, [Score-Algo|ScoredRest]) :-
    score_algorithm(Algo, DS, Mem, Pri, DO, Score),
    score_all(Rest, DS, Mem, Pri, DO, ScoredRest).


% ============================================================
%  RECURSION 2: collect_warnings/3
%
%  Recursively walks a list of algorithms and collects
%  avoid_when/2 warnings for each one into a flat list.
%
%  collect_warnings(+AlgoList, -Warnings)
%  Warnings = list of AlgoName-WarningMessage pairs.
% ============================================================

% Base case: empty list → no warnings
collect_warnings([], []).

% Step: if avoid_when exists for head, prepend it, then recurse
collect_warnings([Algo|Rest], [Algo-Warning|MoreWarnings]) :-
    avoid_when(Algo, Warning), !,
    collect_warnings(Rest, MoreWarnings).

% Step: no warning for this algorithm, just recurse
collect_warnings([_|Rest], Warnings) :-
    collect_warnings(Rest, Warnings).


% ============================================================
%  RECURSION 3: filter_by_score/4
%
%  Recursively filters a scored list keeping only entries
%  whose score is at or above a given threshold.
%
%  filter_by_score(+ScoredList, +Threshold, -Filtered)
% ============================================================

% Base case
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
%  Recursively builds a comparison list of
%  algo(Name, Time, Space, Stab) terms from a scored list.
%  Used to render the comparison table on the result page.
%
%  build_comparison(+ScoredList, +Max, -CompList)
%  Max = max number of entries to include (limits table rows)
% ============================================================

% Base case: max reached
build_comparison(_, 0, []) :- !.

% Base case: empty list
build_comparison([], _, []).

% Step: fetch algorithm details, recurse on rest
build_comparison([_Score-Algo|Rest], Max, [algo(Algo,Time,Space,Stab)|More]) :-
    algorithm(Algo, _, Time, Space, Stab, _),
    Next is Max - 1,
    build_comparison(Rest, Next, More).