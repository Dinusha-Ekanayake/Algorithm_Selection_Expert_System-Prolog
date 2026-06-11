% ============================================================
%  web_interface.pl
%  Algorithm Selection Expert System
%
%  Run:  swipl -s web_interface.pl
%  Open: http://localhost:8080/
% ============================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).

:- [algorithms].
:- [rules].
:- [complexity].
:- [query_log].

:- dynamic query_log/7.
:- dynamic custom_algorithm/6.

% These helper predicates span multiple sections of this file.
:- discontiguous render_cat_cards/3.
:- discontiguous render_alternative/5.
:- discontiguous render_comparison_table/5.
:- discontiguous render_manage_page/2.
:- discontiguous render_custom_table/3.
:- discontiguous render_custom_rows/3.
:- discontiguous render_history/3.
:- discontiguous history_rows/3.
:- discontiguous render_clear_btn/3.


% ============================================================
%  HTTP ROUTES
% ============================================================

:- http_handler(root(.),        home_page,        []).
:- http_handler(root(select),   select_page,      []).
:- http_handler(root(result),   result_page,      []).
:- http_handler(root(browse),   browse_page,      []).
:- http_handler(root(history),  history_page,     []).
:- http_handler(root(manage),   manage_page,      []).
:- http_handler(root(add_algo), add_algo_handler, []).
:- http_handler(root(del_algo), del_algo_handler, []).
:- http_handler(root(clear),    clear_page,       []).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).


% ============================================================
%  DYNAMIC KB HELPERS
% ============================================================

next_query_id(ID) :-
    aggregate_all(count, query_log(_, _, _, _, _, _, _), N),
    ID is N + 1.

save_query(ID, PT, DS, Mem, Pri, DO, Algo) :-
    assertz(query_log(ID, PT, DS, Mem, Pri, DO, Algo)).

add_algorithm(Name, Cat, Time, Space, Stab, Desc) :-
    \+ algorithm(Name, _, _, _, _, _),
    assertz(algorithm(Name, Cat, Time, Space, Stab, Desc)),
    assertz(custom_algorithm(Name, Cat, Time, Space, Stab, Desc)).

remove_algorithm(Name) :-
    custom_algorithm(Name, Cat, Time, Space, Stab, Desc),
    retract(algorithm(Name, Cat, Time, Space, Stab, Desc)),
    retract(custom_algorithm(Name, Cat, Time, Space, Stab, Desc)).

clear_history :-
    retractall(query_log(_, _, _, _, _, _, _)).

custom_count(N) :-
    findall(_, custom_algorithm(_, _, _, _, _, _), L),
    length(L, N).

category_stats(StatsList) :-
    findall(Cat, algorithm(_, Cat, _, _, _, _), AllCats),
    sort(AllCats, Cats),
    findall(Cat-Count,
        ( member(Cat, Cats),
          findall(_, algorithm(_, Cat, _, _, _, _), Algos),
          length(Algos, Count) ),
        StatsList).

all_stable_algorithms(StableList) :-
    ( bagof(Name-Cat,
            Time^Space^Desc^algorithm(Name, Cat, Time, Space, stable, Desc),
            StableList)
    -> true ; StableList = [] ).

all_inplace_algorithms(InplaceList) :-
    findall(Name-Cat,
        ( algorithm(Name, Cat, _, Space, _, _),
          member(Space, ['O(1)', 'O(log n)']) ),
        InplaceList).

list_custom_algorithms(List) :-
    findall(row(N,C,T,S,St,D), custom_algorithm(N,C,T,S,St,D), List).

name_taken(Name) :-
    algorithm(Name, _, _, _, _, _), !.

fmt_atom(Atom, Display) :-
    atom_string(Atom, Str),
    split_string(Str, "_", "", Parts),
    atomic_list_concat(Parts, ' ', Display).


% ============================================================
%  PAGE: HOME
% ============================================================

home_page(_Request) :-
    category_stats(Stats),
    findall(_, algorithm(_, _, _, _, _, _), AllA),
    length(AllA, TotalAlgos),
    findall(_, query_log(_, _, _, _, _, _, _), AllQ),
    length(AllQ, TotalQueries),
    custom_count(CustomCount),
    reply_html_page(title('Algorithm Selection Expert System'), [
        \page_style,
        \navbar(home),
        div([class('hero')], [
            h1('Algorithm Selection Expert System'),
            p([class('subtitle')], 'Prolog Based Application for Algorithm Recommendations'),
            div([class('hero-body')], [
                p('Describe your problem constraints and let the Prolog expert system reason through the knowledge base to recommend the best algorithm.'),
                p('The system covers sorting, searching, graph algorithms, dynamic programming, and string matching.'),
                p('Extend the knowledge base at runtime by adding your own custom algorithms via the Manage KB page.')
            ]),
            div([class('hero-btns')], [
                a([href('/select'),  class('btn-primary')],   'Find an Algorithm'),
                a([href('/browse'),  class('btn-secondary')], 'Browse All'),
                a([href('/manage'),  class('btn-outline')],   'Manage Knowledge Base')
            ])
        ]),
        div([class('stats-row')], [
            div([class('stat-card')], [span([class('stat-num')], TotalAlgos),   span([class('stat-lbl')], 'Algorithms in KB')]),
            div([class('stat-card')], [span([class('stat-num')], TotalQueries), span([class('stat-lbl')], 'Queries Made')]),
            div([class('stat-card')], [span([class('stat-num')], CustomCount),  span([class('stat-lbl')], 'Custom Added')]),
            div([class('stat-card')], [span([class('stat-num')], '5'),          span([class('stat-lbl')], 'Categories')])
        ]),
        div([class('categories-section')], [
            h2('Problem Categories'),
            div([class('cat-grid')], \render_cat_cards(Stats))
        ])
    ]).

render_cat_cards([]) --> [].
render_cat_cards([Cat-Count|Rest]) -->
    { fmt_atom(Cat, CatDisplay) },
    html(div([class('cat-card')], [
        h3(CatDisplay),
        span([class('cat-count')], [Count, ' algorithms'])
    ])),
    render_cat_cards(Rest).


% ============================================================
%  PAGE: SELECT
% ============================================================

select_page(_Request) :-
    reply_html_page(title('Find an Algorithm'), [
        \page_style,
        \navbar(select),
        div([class('form-container')], [
            h2('Describe Your Problem'),
            p([class('form-intro')], 'Select your constraints. The expert system will fire matching Prolog rules and recommend the best algorithm.'),
            form([action('/result'), method('GET'), class('select-form')], [

                div([class('form-section')], [
                    h3('1. What type of problem are you solving?'),
                    div([class('radio-grid')], [
                        \radio_card(problem_type, sorting,             'Sorting',            'Arrange elements in order'),
                        \radio_card(problem_type, searching,           'Searching',          'Find an element in data'),
                        \radio_card(problem_type, graph,               'Graph',              'Paths, trees, networks'),
                        \radio_card(problem_type, dynamic_programming, 'Dynamic Programming','Optimisation with overlapping subproblems'),
                        \radio_card(problem_type, string_matching,     'String Matching',    'Find a pattern in text')
                    ])
                ]),

                div([class('form-section')], [
                    h3('2. How large is your dataset?'),
                    div([class('radio-grid')], [
                        \radio_card(data_size, small,  'Small',  'Under 1,000 elements'),
                        \radio_card(data_size, medium, 'Medium', '1,000 to 1,000,000 elements'),
                        \radio_card(data_size, large,  'Large',  'Over 1,000,000 elements')
                    ])
                ]),

                div([class('form-section')], [
                    h3('3. What are your memory constraints?'),
                    div([class('radio-grid')], [
                        \radio_card(memory, low,      'Low',      'Very limited RAM'),
                        \radio_card(memory, moderate, 'Moderate', 'Some extra memory is fine'),
                        \radio_card(memory, high,     'High',     'Memory is not a concern')
                    ])
                ]),

                div([class('form-section')], [
                    h3('4. What is your main priority?'),
                    div([class('radio-grid')], [
                        \radio_card(priority, speed,      'Speed',      'Fastest execution time'),
                        \radio_card(priority, stability,  'Stability',  'Preserve order of equal elements'),
                        \radio_card(priority, simplicity, 'Simplicity', 'Easy to implement'),
                        \radio_card(priority, memory,     'Low Memory', 'Minimise memory usage')
                    ])
                ]),

                div([class('form-section')], [
                    h3('5. What best describes your data?'),
                    div([class('radio-grid')], [
                        \radio_card(data_order, random,             'Random',             'No particular ordering'),
                        \radio_card(data_order, nearly_sorted,      'Nearly Sorted',      'Mostly in order already'),
                        \radio_card(data_order, sorted,             'Already Sorted',     'Fully sorted array'),
                        \radio_card(data_order, unsorted,           'Unsorted',           'No ordering at all'),
                        \radio_card(data_order, integer_small_range,'Integer Small Range','Integers in a known small range'),
                        \radio_card(data_order, integer_large_range,'Integer Large Range','Integers with large value range'),
                        \radio_card(data_order, float_uniform,      'Float Uniform',      'Floats uniformly distributed'),
                        \radio_card(data_order, unweighted,         'Unweighted Graph',   'All edges equal weight'),
                        \radio_card(data_order, weighted_positive,  'Weighted Positive',  'Non-negative edge weights'),
                        \radio_card(data_order, weighted_negative,  'Has Negative Weights','Graph may have negative weights'),
                        \radio_card(data_order, heuristic,          'Heuristic Available','You have a distance estimate'),
                        \radio_card(data_order, all_pairs,          'All-Pairs Shortest', 'Shortest path between all nodes'),
                        \radio_card(data_order, cycle_detection,    'Cycle Detection',    'Need to detect cycles'),
                        \radio_card(data_order, topological,        'Topological Order',  'DAG with dependency ordering'),
                        \radio_card(data_order, sparse_mst,         'Sparse MST',         'Minimum spanning tree, sparse graph'),
                        \radio_card(data_order, dense_mst,          'Dense MST',          'Minimum spanning tree, dense graph'),
                        \radio_card(data_order, knapsack,           'Knapsack Problem',   'Optimise value under a constraint'),
                        \radio_card(data_order, lcs,                'Common Subsequence', 'Longest common subsequence'),
                        \radio_card(data_order, lis,                'Increasing Sequence','Longest increasing subsequence'),
                        \radio_card(data_order, multi_pattern,      'Multiple Patterns',  'Search for many patterns at once'),
                        \radio_card(data_order, single_pattern,     'Single Pattern',     'Search for one pattern in text'),
                        \radio_card(data_order, unbounded,          'Unbounded Array',    'No fixed size limit'),
                        \radio_card(data_order, uniform_sorted,     'Uniform Sorted',     'Sorted and uniformly distributed'),
                        \radio_card(data_order, unimodal,           'Unimodal Function',  'Function increases then decreases')
                    ])
                ]),

                div([class('form-actions')], [
                    input([type(submit), value('Find Best Algorithm'), class('btn-primary')])
                ])
            ])
        ])
    ]).

radio_card(Name, Value, Label, Desc) -->
    { atom_concat(Name, Value, CardId) },
    html(label([class('radio-card'), for(CardId)], [
        input([type(radio), name(Name), value(Value), id(CardId)]),
        span([class('rc-label')], Label),
        span([class('rc-desc')],  Desc)
    ])).


% ============================================================
%  PAGE: RESULT
% ============================================================

result_page(Request) :-
    http_parameters(Request, [
        problem_type(PT,  [atom, default(sorting)]),
        data_size(DS,     [atom, default(medium)]),
        memory(Mem,       [atom, default(moderate)]),
        priority(Pri,     [atom, default(speed)]),
        data_order(DO,    [atom, default(random)])
    ]),
    ( recommend(PT, DS, Mem, Pri, DO, Algo) ->
        next_query_id(ID),
        save_query(ID, PT, DS, Mem, Pri, DO, Algo),
        algorithm(Algo, _, Time, Space, Stability, Desc),
        ( use_case(Algo, UseCase)    -> true ; UseCase  = 'No use case recorded.' ),
        ( avoid_when(Algo, AvoidMsg) -> true ; AvoidMsg = 'No specific warnings.' ),
        ( alternative(PT, Algo, AltAlgo) -> true ; AltAlgo = none ),
        findall(N, algorithm(N, PT, _, _, _, _), AllInCat),
        length(AllInCat, CatCount),
        ( bagof(N, T^S^D^algorithm(N, PT, T, S, stable, D), StableList)
        -> length(StableList, StableCount) ; StableCount = 0 ),
        all_inplace_algorithms(PT, InplaceList),
        length(InplaceList, InplaceCount),
        % --- RECURSION: score_all + rank + filter + build comparison ---
        rank_algorithms(PT, DS, Mem, Pri, DO, Ranked),
        filter_by_score(Ranked, 5, TopCandidates),
        build_comparison(TopCandidates, 5, CompList),
        fmt_atom(Algo, AlgoDisplay),
        fmt_atom(PT,   PTDisplay),
        fmt_atom(DS,   DSDisplay),
        fmt_atom(Mem,  MemDisplay),
        fmt_atom(Pri,  PriDisplay),
        fmt_atom(DO,   DODisplay),
        reply_html_page(title('Recommendation'), [
            \page_style,
            \navbar(select),
            div([class('result-container')], [
                h2('Algorithm Recommendation'),
                div([class('rec-banner')], [
                    div([class('rec-algo-name')], AlgoDisplay),
                    div([class('rec-tagline')], 'Recommended by the Prolog expert system')
                ]),
                div([class('input-summary')], [
                    h3([class('summary-label')], 'Your selections:'),
                    div([class('tag-row')], [
                        span([class('tag tag-type')],  ['Problem: ',  PTDisplay]),
                        span([class('tag tag-size')],  ['Size: ',     DSDisplay]),
                        span([class('tag tag-mem')],   ['Memory: ',   MemDisplay]),
                        span([class('tag tag-pri')],   ['Priority: ', PriDisplay]),
                        span([class('tag tag-data')],  ['Data: ',     DODisplay])
                    ])
                ]),
                div([class('complexity-grid')], [
                    div([class('cx-card')], [span([class('cx-label')], 'Time Complexity'),  span([class('cx-val cx-time')],  Time)]),
                    div([class('cx-card')], [span([class('cx-label')], 'Space Complexity'), span([class('cx-val cx-space')], Space)]),
                    div([class('cx-card')], [span([class('cx-label')], 'Stability'),        span([class('cx-val cx-stab')],  Stability)])
                ]),
                div([class('insight-row')], [
                    div([class('insight-card')], [span([class('ins-num')], CatCount),    span([class('ins-lbl')], 'algorithms in this category')]),
                    div([class('insight-card')], [span([class('ins-num')], StableCount), span([class('ins-lbl')], 'stable options available')]),
                    div([class('insight-card')], [span([class('ins-num')], InplaceCount),span([class('ins-lbl')], 'in-place options available')])
                ]),
                div([class('info-card')], [
                    h3([class('info-title')], 'Why this algorithm?'),
                    p(Desc)
                ]),
                div([class('info-card info-use')], [
                    h3([class('info-title')], 'Real-world use cases'),
                    p(UseCase)
                ]),
                div([class('info-card info-warn')], [
                    h3([class('info-title')], 'When to avoid'),
                    p(AvoidMsg)
                ]),
                \render_alternative(PT, AltAlgo),
                % Ranked comparison table — built by recursive build_comparison/3
                \render_comparison_table(CompList, Algo),
                div([class('form-actions')], [
                    a([href('/select'),  class('btn-primary')],   'Try Another'),
                    a([href('/history'), class('btn-secondary')], 'View History'),
                    a([href('/browse'),  class('btn-outline')],   'Browse All Algorithms')
                ])
            ])
        ])
    ;
        reply_html_page(title('No Match'), [
            \page_style,
            \navbar(select),
            div([class('result-container')], [
                h2('No Exact Match Found'),
                div([class('no-match-box')], [
                    p('The expert system could not match your exact constraint combination.'),
                    p('Please go back and adjust your selections.'),
                    a([href('/select'), class('btn-primary')], 'Try Again')
                ])
            ])
        ])
    ).

render_alternative(_, none) --> [].
render_alternative(PT, AltAlgo) -->
    {
        fmt_atom(AltAlgo, AltDisplay),
        algorithm(AltAlgo, _, AltTime, AltSpace, _, AltDesc),
        format(atom(Link), '/browse?category=~w&highlight=~w', [PT, AltAlgo])
    },
    html(div([class('info-card info-alt')], [
        h3([class('info-title')], 'Alternative to consider'),
        div([class('alt-name')], AltDisplay),
        p(['Time: ', AltTime, ' / Space: ', AltSpace]),
        p(AltDesc),
        a([href(Link), class('btn-outline')], 'View details')
    ])).


% ============================================================
%  COMPARISON TABLE
%  Renders the ranked list built by recursive build_comparison/3.
%  Each row highlights the recommended algorithm.
% ============================================================

render_comparison_table([], _) --> [].
render_comparison_table(CompList, Recommended) -->
    html(div([class('info-card')], [
        h3([class('info-title')], 'Ranked comparison for this category'),
        p([style('font-size:0.82rem;color:#888;margin-bottom:0.8rem;')],
          'Scored recursively by the expert system based on your constraints. Higher score = better fit.'),
        table([class('comp-table')], [
            thead(tr([th('Algorithm'), th('Time'), th('Space'), th('Stable'), th('Fit')])),
            tbody(\comp_rows(CompList, Recommended))
        ])
    ])).

comp_rows([], _) --> [].
comp_rows([algo(Name, Time, Space, Stab)|Rest], Recommended) -->
    {
        ( atom(Name) -> fmt_atom(Name, NameDisplay) ; atom_string(Name, NameDisplay) ),
        ( Name = Recommended ->
            RowClass = 'comp-row comp-best',
            BadgeHTML = [span([class('best-badge')], 'recommended')]
        ;
            RowClass = 'comp-row',
            BadgeHTML = []
        ),
        append([NameDisplay], BadgeHTML, NameCell)
    },
    html(tr([class(RowClass)], [
        td([class('comp-name')], NameCell),
        td([class('comp-time')],  Time),
        td([class('comp-space')], Space),
        td([class('comp-stab')],  Stab)
    ])),
    comp_rows(Rest, Recommended).

all_inplace_algorithms(Category, InplaceList) :-
    findall(Name-Category,
        ( algorithm(Name, Category, _, Space, _, _),
          member(Space, ['O(1)', 'O(log n)']) ),
        InplaceList).


% ============================================================
%  PAGE: MANAGE KNOWLEDGE BASE
% ============================================================

manage_page(Request) :-
    ( member(method(post), Request) ->
        http_parameters(Request, [
            name(NameStr,    [default("")]),
            category(CatStr, [default("")]),
            time(TimeStr,    [default("")]),
            space(SpaceStr,  [default("")]),
            stable(StabStr,  [default("stable")]),
            desc(DescStr,    [default("")])
        ]),
        ( ( NameStr = "" ; CatStr = "" ; TimeStr = "" ; SpaceStr = "" ; DescStr = "" ) ->
            render_manage_page("error", "All fields are required.")
        ;
            atom_string(NameAtom, NameStr),
            atom_string(CatAtom,  CatStr),
            atom_string(StabAtom, StabStr),
            ( name_taken(NameAtom) ->
                render_manage_page("error", "An algorithm with that name already exists.")
            ;
                add_algorithm(NameAtom, CatAtom, TimeStr, SpaceStr, StabAtom, DescStr),
                render_manage_page("success", "Algorithm added to the knowledge base.")
            )
        )
    ;
        render_manage_page("", "")
    ).

render_manage_page(MsgType, Msg) :-
    list_custom_algorithms(CustomList),
    length(CustomList, CustomCount),
    findall(_, algorithm(_, _, _, _, _, _), AllA),
    length(AllA, TotalCount),
    reply_html_page(title('Manage Knowledge Base'), [
        \page_style,
        \navbar(manage),
        div([class('manage-container')], [
            h2('Manage Knowledge Base'),
            p([class('form-intro')],
              'Add or remove algorithms from the knowledge base at runtime using assertz/1 and retract/1.'),
            \render_msg(MsgType, Msg),
            div([class('kb-stats')], [
                div([class('kb-stat')], [span([class('kb-num')], TotalCount),  span([class('kb-lbl')], 'total algorithms')]),
                div([class('kb-stat')], [span([class('kb-num')], CustomCount), span([class('kb-lbl')], 'added this session')])
            ]),
            div([class('add-form-wrap')], [
                h3('Add a New Algorithm'),
                p([class('add-note')], 'Uses assertz/1 to insert the algorithm into the live knowledge base immediately.'),
                form([action('/manage'), method('POST'), class('add-form')], [
                    div([class('field-grid')], [
                        div([class('field-group')], [
                            label('Algorithm Name:'),
                            input([name(name), placeholder('e.g. my_sort'), class('field-input')])
                        ]),
                        div([class('field-group')], [
                            label('Category:'),
                            select([name(category), class('field-input')], [
                                option([value(sorting)],             'Sorting'),
                                option([value(searching)],           'Searching'),
                                option([value(graph)],               'Graph'),
                                option([value(dynamic_programming)], 'Dynamic Programming'),
                                option([value(string_matching)],     'String Matching'),
                                option([value(other)],               'Other')
                            ])
                        ]),
                        div([class('field-group')], [
                            label('Time Complexity:'),
                            input([name(time), placeholder('e.g. O(n log n)'), class('field-input')])
                        ]),
                        div([class('field-group')], [
                            label('Space Complexity:'),
                            input([name(space), placeholder('e.g. O(1)'), class('field-input')])
                        ]),
                        div([class('field-group')], [
                            label('Stability:'),
                            select([name(stable), class('field-input')], [
                                option([value(stable)],   'Stable'),
                                option([value(unstable)], 'Unstable')
                            ])
                        ]),
                        div([class('field-group field-full')], [
                            label('Description:'),
                            textarea([name(desc), rows('3'),
                                      placeholder('Brief description of the algorithm...'),
                                      class('field-input')], '')
                        ])
                    ]),
                    div([class('form-actions')], [
                        input([type(submit), value('Add to Knowledge Base'), class('btn-primary')])
                    ])
                ])
            ]),
            h3([style('margin-top:2rem; color:#1a237e;')], 'Custom Algorithms (Added This Session)'),
            \render_custom_table(CustomList)
        ])
    ]).

render_msg("", _) --> [].
render_msg("success", Msg) -->
    html(div([class('msg msg-success')], Msg)).
render_msg("error", Msg) -->
    html(div([class('msg msg-error')], Msg)).

render_custom_table([]) -->
    html(div([class('empty-state')], [p('No custom algorithms added yet this session.')])).
render_custom_table(List) -->
    html(table([class('history-table')], [
        thead(tr([th('Name'), th('Category'), th('Time'), th('Space'), th('Stable'), th('Remove')])),
        tbody(\render_custom_rows(List))
    ])).

render_custom_rows([]) --> [].
render_custom_rows([row(N,C,T,S,St,_)|Rest]) -->
    {
        fmt_atom(N, ND),
        fmt_atom(C, CD),
        format(atom(DelLink), '/del_algo?name=~w', [N])
    },
    html(tr([
        td([class('td-name')], ND),
        td([class('td-type')], CD),
        td(T), td(S), td(St),
        td(a([href(DelLink), class('btn-danger'),
              onclick('return confirm("Remove this algorithm?");')], 'Remove'))
    ])),
    render_custom_rows(Rest).


% ============================================================
%  HANDLERS: ADD / REMOVE
% ============================================================

add_algo_handler(Request) :-
    member(method(post), Request), !,
    http_parameters(Request, [
        name(NameStr,    [default("")]),
        category(CatStr, [default("")]),
        time(TimeStr,    [default("")]),
        space(SpaceStr,  [default("")]),
        stable(StabStr,  [default("stable")]),
        desc(DescStr,    [default("")])
    ]),
    ( NameStr \= "", CatStr \= "", TimeStr \= "", SpaceStr \= "", DescStr \= "" ->
        atom_string(NameAtom, NameStr),
        atom_string(CatAtom,  CatStr),
        atom_string(StabAtom, StabStr),
        ( name_taken(NameAtom) ->
            reply_html_page(title('Error'), [
                \page_style, \navbar(manage),
                \alert_then_redirect('That algorithm name already exists!', '/manage')
            ])
        ;
            add_algorithm(NameAtom, CatAtom, TimeStr, SpaceStr, StabAtom, DescStr),
            reply_html_page(title('Added'), [
                \page_style, \navbar(manage),
                \alert_then_redirect('Algorithm added successfully!', '/manage')
            ])
        )
    ;
        reply_html_page(title('Error'), [
            \page_style, \navbar(manage),
            \alert_then_redirect('Please fill in all fields.', '/manage')
        ])
    ).
add_algo_handler(_Request) :-
    reply_html_page(title('Error'), [
        \page_style, \navbar(manage),
        \alert_then_redirect('Invalid request.', '/manage')
    ]).

del_algo_handler(Request) :-
    http_parameters(Request, [name(NameStr, [default("")])]),
    ( NameStr \= "" ->
        atom_string(NameAtom, NameStr),
        ( custom_algorithm(NameAtom, _, _, _, _, _) ->
            remove_algorithm(NameAtom),
            reply_html_page(title('Removed'), [
                \page_style, \navbar(manage),
                \alert_then_redirect('Algorithm removed.', '/manage')
            ])
        ;
            reply_html_page(title('Error'), [
                \page_style, \navbar(manage),
                \alert_then_redirect('Only custom algorithms can be removed.', '/manage')
            ])
        )
    ;
        reply_html_page(title('Error'), [
            \page_style, \navbar(manage),
            \alert_then_redirect('No name given.', '/manage')
        ])
    ).


% ============================================================
%  PAGE: BROWSE
% ============================================================

browse_page(Request) :-
    http_parameters(Request, [
        category(Cat, [atom, default(all)]),
        highlight(HL, [atom, default(none)])
    ]),
    ( Cat = all ->
        findall(A-C-T-S-St-D, algorithm(A, C, T, S, St, D), Algos)
    ;
        findall(A-Cat-T-S-St-D, algorithm(A, Cat, T, S, St, D), Algos)
    ),
    length(Algos, Count),
    all_stable_algorithms(StableAll),
    length(StableAll, StableCount),
    reply_html_page(title('Browse Algorithms'), [
        \page_style,
        \navbar(browse),
        div([class('browse-container')], [
            div([class('browse-header')], [
                h2('All Algorithms'),
                p([class('browse-sub')],
                  ['Showing ', Count, ' algorithms | ',
                   StableCount, ' stable total in knowledge base']),
                div([class('filter-row')], [
                    \filter_link(all,                'All',                Cat),
                    \filter_link(sorting,            'Sorting',            Cat),
                    \filter_link(searching,          'Searching',          Cat),
                    \filter_link(graph,              'Graph',              Cat),
                    \filter_link(dynamic_programming,'Dynamic Programming',Cat),
                    \filter_link(string_matching,    'String Matching',    Cat)
                ])
            ]),
            div([class('algo-grid')], \render_algo_cards(Algos, HL))
        ])
    ]).

filter_link(Val, Label, Active) -->
    {
        ( Val = Active -> Class = 'filter-btn active' ; Class = 'filter-btn' ),
        format(atom(Link), '/browse?category=~w', [Val])
    },
    html(a([href(Link), class(Class)], Label)).

render_algo_cards([], _) --> [].
render_algo_cards([A-Cat-Time-Space-Stab-Desc|Rest], HL) -->
    {
        fmt_atom(A,   ADisplay),
        fmt_atom(Cat, CatDisplay),
        ( A = HL -> CardClass = 'algo-card highlighted' ; CardClass = 'algo-card' ),
        ( use_case(A, UC) -> true ; UC = 'No use case on record.' ),
        ( custom_algorithm(A, _, _, _, _, _) -> IsCustom = true ; IsCustom = false )
    },
    html(div([class(CardClass)], [
        div([class('algo-card-header')], [
            span([class('algo-name')], ADisplay),
            div([style('display:flex;gap:6px;align-items:center;flex-wrap:wrap;')], [
                span([class('algo-cat')], CatDisplay),
                \custom_badge(IsCustom)
            ])
        ]),
        div([class('algo-complexities')], [
            span([class('cx-pill cx-t')],  ['T: ', Time]),
            span([class('cx-pill cx-s')],  ['S: ', Space]),
            span([class('cx-pill cx-st')], Stab)
        ]),
        p([class('algo-desc')], Desc),
        p([class('algo-use')],  ['Use: ', UC])
    ])),
    render_algo_cards(Rest, HL).

custom_badge(true)  --> html(span([class('custom-badge')], 'custom')).
custom_badge(false) --> [].


% ============================================================
%  PAGE: HISTORY
% ============================================================

history_page(_Request) :-
    findall(row(ID,PT,DS,Mem,Pri,DO,Algo),
            query_log(ID, PT, DS, Mem, Pri, DO, Algo), Rows),
    length(Rows, Total),
    ( bagof(PT, ID^DS^Mem^Pri^DO^Algo^query_log(ID,PT,DS,Mem,Pri,DO,Algo), PTList)
    -> sort(PTList, UniqTypes), length(UniqTypes, TypeCount)
    ;  TypeCount = 0 ),
    reply_html_page(title('Query History'), [
        \page_style,
        \navbar(history),
        div([class('history-container')], [
            div([class('history-header')], [
                h2('Query History'),
                \render_clear_btn(Total)
            ]),
            div([class('history-stats')], [
                span([class('hs-item')], [Total, ' total queries']),
                span([class('hs-item')], [TypeCount, ' problem types tried'])
            ]),
            \render_history(Rows)
        ])
    ]).

render_clear_btn(Total) -->
    { Total > 0 }, !,
    html(a([href('/clear'), class('btn-danger'),
            onclick('return confirm("Clear all history?");')], 'Clear All')).
render_clear_btn(_) --> [].

render_history([]) -->
    html(div([class('empty-state')], [
        p('No queries made yet.'),
        a([href('/select'), class('btn-primary')], 'Find your first algorithm')
    ])).
render_history(Rows) -->
    html(table([class('history-table')], [
        thead(tr([th('#'), th('Problem Type'), th('Size'),
                  th('Memory'), th('Priority'), th('Data'), th('Recommended')])),
        tbody(\history_rows(Rows))
    ])).

history_rows([]) --> [].
history_rows([row(ID,PT,DS,Mem,Pri,DO,Algo)|Rest]) -->
    {
        fmt_atom(Algo, AD),
        fmt_atom(PT,   PTD),
        fmt_atom(DS,   DSD),
        fmt_atom(DO,   DOD)
    },
    html(tr([
        td(ID),
        td([class('td-type')], PTD),
        td(DSD), td(Mem), td(Pri),
        td([class('td-char')], DOD),
        td(span([class('algo-badge')], AD))
    ])),
    history_rows(Rest).


% ============================================================
%  PAGE: CLEAR
% ============================================================

clear_page(_Request) :-
    clear_history,
    reply_html_page(title('Cleared'), [
        \page_style, \navbar(history),
        \alert_then_redirect('History cleared!', '/history')
    ]).


% ============================================================
%  SHARED COMPONENTS
% ============================================================

alert_then_redirect(Message, URL) -->
    html(script(type('text/javascript'), [
        'alert("', Message, '"); window.location.href = "', URL, '";'
    ])).

navbar(Active) -->
    html(nav([class('navbar')], [
        \nav_link('/',        'Home',           Active, home),
        \nav_link('/select',  'Find Algorithm', Active, select),
        \nav_link('/browse',  'Browse All',     Active, browse),
        \nav_link('/manage',  'Manage KB',      Active, manage),
        \nav_link('/history', 'History',        Active, history)
    ])).

nav_link(Href, Label, Active, Key) -->
    { ( Active = Key -> Class = 'nav-btn active' ; Class = 'nav-btn' ) },
    html(a([href(Href), class(Class)], Label)).


% ============================================================
%  GLOBAL CSS
% ============================================================

page_style -->
    html(style([type('text/css')], ['
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: "Segoe UI", Arial, sans-serif; background: #f4f4f4; color: #2c3e50; line-height: 1.6; }

        .navbar { background:#fff; padding:12px 28px; display:flex; align-items:center; gap:10px; border-bottom:1px solid #ddd; box-shadow:0 2px 4px rgba(0,0,0,0.07); flex-wrap:wrap; }
        .nav-btn { text-decoration:none; color:#fff; background:#2196f3; padding:8px 16px; border-radius:4px; font-size:0.9rem; border:1px solid #2196f3; transition:background 0.2s; }
        .nav-btn:hover  { background:#1976d2; }
        .nav-btn.active { background:#0d47a1; border-color:#0d47a1; }

        .btn-primary   { display:inline-block; background:#2196f3; color:#fff; padding:11px 26px; border-radius:5px; text-decoration:none; border:none; font-size:1rem; cursor:pointer; transition:background 0.2s; margin-top:0.4rem; }
        .btn-primary:hover   { background:#1976d2; }
        .btn-secondary { display:inline-block; background:#fff; color:#2196f3; padding:11px 26px; border-radius:5px; text-decoration:none; border:1px solid #2196f3; font-size:1rem; cursor:pointer; margin-left:10px; margin-top:0.4rem; }
        .btn-secondary:hover { background:#e3f2fd; }
        .btn-outline   { display:inline-block; background:transparent; color:#2196f3; padding:9px 20px; border-radius:5px; text-decoration:none; border:1px solid #2196f3; font-size:0.95rem; margin-left:10px; margin-top:0.4rem; }
        .btn-outline:hover   { background:#e3f2fd; }
        .btn-danger    { display:inline-block; background:#e53935; color:#fff; padding:8px 16px; border-radius:4px; text-decoration:none; border:none; font-size:0.88rem; cursor:pointer; }
        .btn-danger:hover    { background:#b71c1c; }

        .hero { text-align:center; padding:52px 24px 36px; max-width:860px; margin:0 auto; }
        .hero h1 { font-size:2.1rem; color:#1a237e; margin-bottom:0.4rem; }
        .subtitle { color:#2196f3; font-size:0.9rem; margin-bottom:1.3rem; font-weight:bold; display:block; }
        .hero-body p { font-size:1rem; color:#003366; font-weight:bold; margin-bottom:0.5rem; }
        .hero-btns   { margin-top:1.4rem; }

        .stats-row { display:flex; gap:16px; justify-content:center; flex-wrap:wrap; max-width:700px; margin:0 auto 36px; padding:0 24px; }
        .stat-card { background:#fff; border:1px solid #ddd; border-radius:8px; padding:16px 24px; text-align:center; min-width:130px; }
        .stat-num  { display:block; font-size:1.9rem; font-weight:bold; color:#1a237e; }
        .stat-lbl  { display:block; font-size:0.78rem; color:#888; margin-top:2px; }

        .categories-section { max-width:900px; margin:0 auto 48px; padding:0 24px; }
        .categories-section h2 { color:#1a237e; margin-bottom:1.2rem; font-size:1.3rem; }
        .cat-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:14px; }
        .cat-card { background:#fff; border:1px solid #ddd; border-radius:8px; padding:18px 14px; text-align:center; transition:box-shadow 0.2s; }
        .cat-card:hover { box-shadow:0 4px 12px rgba(33,150,243,0.15); }
        .cat-card h3 { color:#1a237e; font-size:0.9rem; margin-bottom:4px; }
        .cat-count { font-size:0.8rem; color:#2196f3; font-weight:bold; }

        .form-container { max-width:920px; margin:36px auto; padding:0 24px; }
        .form-container h2 { color:#1a237e; font-size:1.5rem; margin-bottom:0.4rem; text-align:center; }
        .form-intro { text-align:center; color:#555; margin-bottom:1.8rem; font-size:0.95rem; }
        .form-section { background:#fff; border:1px solid #ddd; border-radius:8px; padding:18px 22px; margin-bottom:1.1rem; }
        .form-section h3 { color:#1a237e; font-size:0.95rem; margin-bottom:0.9rem; }
        .radio-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(190px,1fr)); gap:9px; }
        .radio-card { display:flex; flex-direction:column; border:1.5px solid #ddd; border-radius:6px; padding:9px 13px; cursor:pointer; transition:border-color 0.15s,background 0.15s; }
        .radio-card:hover { border-color:#2196f3; background:#f0f8ff; }
        .radio-card input[type=radio] { display:none; }
        .radio-card:has(input:checked) { border-color:#2196f3; background:#e3f2fd; }
        .rc-label { font-weight:bold; font-size:0.88rem; color:#2c3e50; margin-bottom:2px; }
        .rc-desc  { font-size:0.76rem; color:#888; }
        .form-actions { text-align:center; margin-top:1.4rem; }

        .result-container { max-width:780px; margin:36px auto; padding:0 24px; }
        .result-container h2 { color:#1a237e; font-size:1.5rem; margin-bottom:1.1rem; text-align:center; }
        .rec-banner { background:#1a237e; color:#fff; border-radius:10px; padding:22px 30px; text-align:center; margin-bottom:1.4rem; }
        .rec-algo-name { font-size:1.9rem; font-weight:bold; text-transform:capitalize; margin-bottom:4px; }
        .rec-tagline   { font-size:0.9rem; color:#90caf9; }

        .input-summary { background:#fff; border:1px solid #ddd; border-radius:8px; padding:14px 18px; margin-bottom:1.1rem; }
        .summary-label { font-size:0.85rem; color:#888; margin-bottom:8px; font-weight:normal; }
        .tag-row { display:flex; flex-wrap:wrap; gap:7px; margin-top:6px; }
        .tag  { padding:3px 11px; border-radius:20px; font-size:0.8rem; font-weight:bold; }
        .tag-type { background:#e3f2fd; color:#0d47a1; }
        .tag-size { background:#e8f5e9; color:#1b5e20; }
        .tag-mem  { background:#fff3e0; color:#e65100; }
        .tag-pri  { background:#f3e5f5; color:#4a148c; }
        .tag-data { background:#fce4ec; color:#880e4f; }

        .complexity-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:11px; margin-bottom:1.1rem; }
        .cx-card  { background:#fff; border:1px solid #ddd; border-radius:8px; padding:13px 14px; text-align:center; }
        .cx-label { display:block; font-size:0.75rem; color:#888; margin-bottom:5px; }
        .cx-val   { display:block; font-size:1.15rem; font-weight:bold; font-family:monospace; }
        .cx-time  { color:#0d47a1; }
        .cx-space { color:#1b5e20; }
        .cx-stab  { color:#6a1b9a; text-transform:capitalize; }

        .insight-row { display:grid; grid-template-columns:repeat(3,1fr); gap:11px; margin-bottom:1.1rem; }
        .insight-card { background:#f8f9fa; border:1px solid #e0e0e0; border-radius:8px; padding:12px; text-align:center; }
        .ins-num { display:block; font-size:1.5rem; font-weight:bold; color:#2196f3; }
        .ins-lbl { display:block; font-size:0.75rem; color:#666; }

        .info-card  { background:#fff; border:1px solid #ddd; border-left:4px solid #2196f3; border-radius:6px; padding:15px 18px; margin-bottom:0.9rem; }
        .info-use   { border-left-color:#43a047; }
        .info-warn  { border-left-color:#fb8c00; }
        .info-alt   { border-left-color:#8e24aa; }
        .info-title { font-size:0.9rem; margin-bottom:7px; color:#2c3e50; font-weight:bold; }
        .alt-name   { font-size:1.05rem; font-weight:bold; color:#1a237e; margin-bottom:5px; text-transform:capitalize; }

        .no-match-box { background:#fff; border:1px solid #ddd; border-radius:8px; padding:30px; text-align:center; margin-top:2rem; }
        .no-match-box p { margin-bottom:1rem; color:#555; }

        .browse-container { max-width:1080px; margin:36px auto; padding:0 24px; }
        .browse-header h2 { color:#1a237e; font-size:1.5rem; margin-bottom:0.6rem; }
        .browse-sub { color:#888; font-size:0.88rem; margin-bottom:0.9rem; }
        .filter-row { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:1.4rem; }
        .filter-btn { padding:5px 14px; border-radius:20px; font-size:0.85rem; text-decoration:none; color:#2196f3; border:1px solid #2196f3; transition:background 0.15s; }
        .filter-btn:hover,.filter-btn.active { background:#2196f3; color:#fff; }
        .algo-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:14px; }
        .algo-card { background:#fff; border:1px solid #ddd; border-radius:8px; padding:16px 18px; transition:box-shadow 0.2s; }
        .algo-card:hover { box-shadow:0 4px 12px rgba(0,0,0,0.1); }
        .algo-card.highlighted { border:2px solid #8e24aa; box-shadow:0 0 0 3px rgba(142,36,170,0.1); }
        .algo-card-header { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:9px; }
        .algo-name { font-size:0.95rem; font-weight:bold; color:#1a237e; text-transform:capitalize; }
        .algo-cat  { font-size:0.72rem; color:#888; text-align:right; text-transform:capitalize; }
        .algo-complexities { display:flex; gap:5px; flex-wrap:wrap; margin-bottom:9px; }
        .cx-pill   { padding:2px 8px; border-radius:12px; font-size:0.75rem; font-family:monospace; }
        .cx-t  { background:#e3f2fd; color:#0d47a1; }
        .cx-s  { background:#e8f5e9; color:#1b5e20; }
        .cx-st { background:#f3e5f5; color:#4a148c; text-transform:capitalize; }
        .algo-desc { font-size:0.82rem; color:#444; margin-bottom:5px; }
        .algo-use  { font-size:0.78rem; color:#888; }
        .custom-badge { background:#fff3e0; color:#e65100; border:1px solid #e65100; padding:2px 8px; border-radius:10px; font-size:0.72rem; font-weight:bold; }

        .manage-container { max-width:860px; margin:36px auto; padding:0 24px; }
        .manage-container h2 { color:#1a237e; font-size:1.5rem; margin-bottom:0.4rem; text-align:center; }
        .kb-stats { display:flex; gap:14px; justify-content:center; margin:1.2rem 0; }
        .kb-stat  { background:#fff; border:1px solid #ddd; border-radius:8px; padding:14px 22px; text-align:center; }
        .kb-num   { display:block; font-size:1.6rem; font-weight:bold; color:#1a237e; }
        .kb-lbl   { display:block; font-size:0.78rem; color:#888; }
        .add-form-wrap { background:#fff; border:1px solid #ddd; border-radius:8px; padding:22px 24px; margin-bottom:1.4rem; }
        .add-form-wrap h3 { color:#1a237e; margin-bottom:0.4rem; font-size:1rem; }
        .add-note  { font-size:0.82rem; color:#888; margin-bottom:1rem; font-style:italic; }
        .field-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
        .field-full { grid-column:1 / -1; }
        .field-group { display:flex; flex-direction:column; gap:4px; }
        .field-group label { font-size:0.85rem; font-weight:bold; color:#2c3e50; }
        .field-input { padding:8px 10px; border:1px solid #ccc; border-radius:5px; font-size:0.9rem; font-family:inherit; width:100%; }
        .field-input:focus { outline:none; border-color:#2196f3; box-shadow:0 0 0 2px rgba(33,150,243,0.15); }
        .msg { padding:11px 16px; border-radius:6px; margin-bottom:1rem; font-size:0.95rem; }
        .msg-success { background:#d4edda; color:#155724; border:1px solid #c3e6cb; }
        .msg-error   { background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; }

        .history-container { max-width:1060px; margin:36px auto; padding:0 24px; }
        .history-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem; }
        .history-header h2 { color:#1a237e; font-size:1.5rem; }
        .history-stats { display:flex; gap:18px; margin-bottom:1.1rem; }
        .hs-item { font-size:0.88rem; color:#888; }
        .history-table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 2px 6px rgba(0,0,0,0.07); }
        .history-table th, .history-table td { padding:11px 13px; text-align:left; border-bottom:1px solid #f0f0f0; font-size:0.88rem; }
        .history-table thead { background:#1a237e; color:#fff; }
        .history-table tbody tr:hover { background:#f5f5f5; }
        .td-type { text-transform:capitalize; color:#0d47a1; font-weight:bold; }
        .td-name { font-weight:bold; color:#1a237e; text-transform:capitalize; }
        .td-char { text-transform:capitalize; }
        .algo-badge { background:#e3f2fd; color:#0d47a1; padding:3px 10px; border-radius:12px; font-size:0.8rem; font-weight:bold; text-transform:capitalize; }

        .empty-state { text-align:center; padding:50px 0; color:#888; }
        .empty-state p { font-size:1.1rem; margin-bottom:1rem; }
        h2 { text-align:center; }

        .comp-table { width:100%; border-collapse:collapse; font-size:0.87rem; margin-top:0.4rem; }
        .comp-table th { background:#1a237e; color:#fff; padding:8px 12px; text-align:left; font-weight:normal; }
        .comp-table td { padding:8px 12px; border-bottom:1px solid #f0f0f0; }
        .comp-row:hover { background:#f5f5f5; }
        .comp-best { background:#e8f5e9 !important; }
        .comp-best:hover { background:#c8e6c9 !important; }
        .comp-name { font-weight:bold; text-transform:capitalize; color:#1a237e; }
        .comp-time  { font-family:monospace; color:#0d47a1; }
        .comp-space { font-family:monospace; color:#1b5e20; }
        .comp-stab  { text-transform:capitalize; color:#6a1b9a; }
        .best-badge { background:#43a047; color:#fff; font-size:0.7rem; padding:1px 7px; border-radius:10px; margin-left:7px; font-weight:bold; vertical-align:middle; }

        @media(max-width:700px) {
            .complexity-grid,.insight-row { grid-template-columns:1fr 1fr; }
            .field-grid { grid-template-columns:1fr; }
            .cat-grid { grid-template-columns:repeat(2,1fr); }
            .stats-row { gap:10px; }
            .history-table { font-size:0.76rem; }
        }
    '])).


% ============================================================
%  SERVER STARTUP
% ============================================================

:- initialization(start).

start :-
    Port = 8080,
    format('~n=============================================~n'),
    format('  Algorithm Selection Expert System~n'),
    format('  CM2520 - Logic Programming~n'),
    format('  Server running on port ~w~n', [Port]),
    format('  Open: http://localhost:~w/~n', [Port]),
    format('=============================================~n~n'),
    start_server(Port).