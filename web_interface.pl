% ============================================================
%  web_interface.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Main entry point. Starts a SWI-Prolog HTTP server on
%  port 8080 and serves all pages of the web application.
%
%  Run with:  swipl -s web_interface.pl
%  Then open: http://localhost:8080/
% ============================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_redirect)).

% --- Load knowledge base files ---
:- [algorithms].
:- [rules].
:- [complexity].
:- [query_log].

:- dynamic query_log/7.

% ============================================================
%  HTTP ROUTE HANDLERS
% ============================================================

:- http_handler(root(.),       home_page,    []).
:- http_handler(root(select),  select_page,  []).
:- http_handler(root(result),  result_page,  []).
:- http_handler(root(history), history_page, []).
:- http_handler(root(clear),   clear_page,   []).
:- http_handler(root(browse),  browse_page,  []).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).


% ============================================================
%  LOGGING HELPERS
% ============================================================

next_id(ID) :-
    aggregate_all(count, query_log(_, _, _, _, _, _, _), N),
    ID is N + 1.

save_query(ID, PT, DS, Mem, Pri, DO, Algo) :-
    assertz(query_log(ID, PT, DS, Mem, Pri, DO, Algo)).

clear_history :-
    retractall(query_log(_, _, _, _, _, _, _)).


% ============================================================
%  PAGE: HOME
% ============================================================

home_page(_Request) :-
    reply_html_page(title('Algorithm Selection Expert System'), [
        \page_style,
        \navbar(home),
        div([class('hero')], [
            h1('Algorithm Selection Expert System'),
            p([class('subtitle')], 'CM2520 \u00b7 Deductive Reasoning and Logic Programming'),
            div([class('hero-body')], [
                p('This expert system uses Prolog-based rules to recommend the most suitable algorithm for your problem.'),
                p('Describe your problem type, data size, memory constraints, and priorities.'),
                p('The system will reason through the knowledge base and suggest the best algorithm with full explanation.'),
                p('Covers sorting, searching, graph algorithms, dynamic programming, and string matching.')
            ]),
            div([class('hero-btns')], [
                a([href('/select'), class('btn-primary')], 'Find an Algorithm'),
                a([href('/browse'), class('btn-secondary')], 'Browse All Algorithms')
            ])
        ]),
        div([class('categories-section')], [
            h2('Problem Categories'),
            div([class('cat-grid')], [
                \cat_card('Sorting',              'sorting',              'ti-arrows-sort',    '11 algorithms', 'Bubble, Merge, Quick, Heap, Tim...'),
                \cat_card('Searching',            'searching',            'ti-search',         '6 algorithms',  'Binary, Linear, Jump, Interpolation...'),
                \cat_card('Graph',                'graph',                'ti-topology-star',  '9 algorithms',  'BFS, DFS, Dijkstra, A*, Kruskal...'),
                \cat_card('Dynamic Programming',  'dynamic_programming',  'ti-table',          '5 algorithms',  'Memoization, Tabulation, Knapsack...'),
                \cat_card('String Matching',      'string_matching',      'ti-letter-case',    '5 algorithms',  'KMP, Boyer-Moore, Rabin-Karp...')
            ])
        ])
    ]).

cat_card(Label, _Type, Icon, Count, Desc) -->
    html(div([class('cat-card')], [
        i([class(['ti ', Icon, ' cat-icon'])], []),
        h3(Label),
        span([class('cat-count')], Count),
        p([class('cat-desc')], Desc)
    ])).


% ============================================================
%  PAGE: SELECT (problem input form)
% ============================================================

select_page(_Request) :-
    reply_html_page(title('Select Your Problem'), [
        \page_style,
        \navbar(select),
        div([class('form-container')], [
            h2('Describe Your Problem'),
            p([class('form-intro')], 'Answer the questions below and the expert system will recommend the best algorithm.'),
            form([action('/result'), method('GET'), class('select-form')], [

                % --- Problem Type ---
                div([class('form-section')], [
                    h3('1. What type of problem are you solving?'),
                    div([class('radio-grid')], [
                        \radio_card(problem_type, sorting,             'Sorting',             'Arrange data in order'),
                        \radio_card(problem_type, searching,           'Searching',           'Find an element in data'),
                        \radio_card(problem_type, graph,               'Graph',               'Paths, trees, networks'),
                        \radio_card(problem_type, dynamic_programming, 'Dynamic Programming', 'Optimisation with overlapping subproblems'),
                        \radio_card(problem_type, string_matching,     'String Matching',     'Find a pattern in text')
                    ])
                ]),

                % --- Data Size ---
                div([class('form-section')], [
                    h3('2. How large is your dataset?'),
                    div([class('radio-grid')], [
                        \radio_card(data_size, small,  'Small',  'Less than 1,000 elements'),
                        \radio_card(data_size, medium, 'Medium', '1,000 to 1,000,000 elements'),
                        \radio_card(data_size, large,  'Large',  'More than 1,000,000 elements')
                    ])
                ]),

                % --- Memory ---
                div([class('form-section')], [
                    h3('3. What are your memory constraints?'),
                    div([class('radio-grid')], [
                        \radio_card(memory, low,      'Low',      'Very limited RAM available'),
                        \radio_card(memory, moderate, 'Moderate', 'Some extra memory is fine'),
                        \radio_card(memory, high,     'High',     'Memory is not a concern')
                    ])
                ]),

                % --- Priority ---
                div([class('form-section')], [
                    h3('4. What is your main priority?'),
                    div([class('radio-grid')], [
                        \radio_card(priority, speed,      'Speed',      'Fastest possible execution time'),
                        \radio_card(priority, stability,  'Stability',  'Equal elements keep original order'),
                        \radio_card(priority, simplicity, 'Simplicity', 'Easy to understand and implement'),
                        \radio_card(priority, memory,     'Memory',     'Minimise memory usage')
                    ])
                ]),

                % --- Data Characteristics ---
                div([class('form-section')], [
                    h3('5. What best describes your data / problem?'),
                    div([class('radio-grid')], [
                        \radio_card(data_order, random,            'Random',              'Data in no particular order'),
                        \radio_card(data_order, nearly_sorted,     'Nearly Sorted',       'Data is mostly in order'),
                        \radio_card(data_order, sorted,            'Already Sorted',      'Data is fully sorted'),
                        \radio_card(data_order, unsorted,          'Unsorted Array',      'Array with no ordering'),
                        \radio_card(data_order, integer_small_range,'Integer Small Range', 'Integers in a known small range'),
                        \radio_card(data_order, integer_large_range,'Integer Large Range', 'Integers with large range'),
                        \radio_card(data_order, float_uniform,     'Float Uniform',       'Floating-point, uniformly distributed'),
                        \radio_card(data_order, unweighted,        'Unweighted Graph',    'All edges have equal weight'),
                        \radio_card(data_order, weighted_positive, 'Weighted (Positive)', 'Edges have non-negative weights'),
                        \radio_card(data_order, weighted_negative, 'Weighted (Negative)', 'Graph may have negative weights'),
                        \radio_card(data_order, heuristic,         'Heuristic Available', 'You have an estimate of distance'),
                        \radio_card(data_order, all_pairs,         'All-Pairs Shortest',  'Need shortest path between all nodes'),
                        \radio_card(data_order, cycle_detection,   'Cycle Detection',     'Need to detect cycles'),
                        \radio_card(data_order, topological,       'Topological Order',   'DAG with dependency ordering'),
                        \radio_card(data_order, sparse_mst,        'Sparse MST',          'Minimum spanning tree, sparse graph'),
                        \radio_card(data_order, dense_mst,         'Dense MST',           'Minimum spanning tree, dense graph'),
                        \radio_card(data_order, knapsack,          'Knapsack / Budget',   'Optimise value under a weight/cost constraint'),
                        \radio_card(data_order, lcs,               'Common Subsequence',  'Find longest common subsequence'),
                        \radio_card(data_order, lis,               'Increasing Sequence', 'Find longest increasing subsequence'),
                        \radio_card(data_order, multi_pattern,     'Multiple Patterns',   'Search for many patterns at once'),
                        \radio_card(data_order, single_pattern,    'Single Pattern',      'Search for one pattern in text'),
                        \radio_card(data_order, unbounded,         'Unbounded Array',     'Array has no fixed size limit'),
                        \radio_card(data_order, uniform_sorted,    'Uniform Sorted',      'Sorted and uniformly distributed'),
                        \radio_card(data_order, unimodal,          'Unimodal Function',   'Function increases then decreases')
                    ])
                ]),

                div([class('form-actions')], [
                    input([type(submit), value('Find Best Algorithm \u2192'), class('btn-primary')])
                ])
            ])
        ])
    ]).

radio_card(Name, Value, Label, Desc) -->
    {atom_concat(Name, Value, CardId)},
    html(label([class('radio-card'), for(CardId)], [
        input([type(radio), name(Name), value(Value), id(CardId)]),
        span([class('rc-label')], Label),
        span([class('rc-desc')], Desc)
    ])).


% ============================================================
%  PAGE: RESULT
% ============================================================

result_page(Request) :-
    http_parameters(Request, [
        problem_type(PT,   [atom, default(sorting)]),
        data_size(DS,      [atom, default(medium)]),
        memory(Mem,        [atom, default(moderate)]),
        priority(Pri,      [atom, default(speed)]),
        data_order(DO,     [atom, default(random)])
    ]),
    ( recommend(PT, DS, Mem, Pri, DO, Algo) ->
        next_id(ID),
        save_query(ID, PT, DS, Mem, Pri, DO, Algo),
        algorithm(Algo, _, Time, Space, Stability, Desc),
        use_case(Algo, UseCase),
        ( avoid_when(Algo, AvoidReason) -> true ; AvoidReason = 'No specific warnings for this configuration.' ),
        ( alternative(PT, Algo, AltAlgo) -> true ; AltAlgo = none ),
        reply_html_page(title('Recommendation'), [
            \page_style,
            \navbar(select),
            \result_view(PT, DS, Mem, Pri, DO, Algo, Time, Space, Stability, Desc, UseCase, AvoidReason, AltAlgo)
        ])
    ;
        reply_html_page(title('No Match'), [
            \page_style,
            \navbar(select),
            div([class('result-container')], [
                h2('No Exact Match Found'),
                div([class('no-match-box')], [
                    p('The expert system could not find a rule matching your exact combination of constraints.'),
                    p('Please try adjusting your selections.'),
                    a([href('/select'), class('btn-primary')], '\u2190 Try Again')
                ])
            ])
        ])
    ).


result_view(PT, DS, Mem, Pri, DO, Algo, Time, Space, Stability, Desc, UseCase, AvoidReason, AltAlgo) -->
    {
        atom_string(Algo, AlgoStr),
        % Format algo name for display: replace underscores with spaces
        split_string(AlgoStr, "_", "", Parts),
        atomic_list_concat(Parts, ' ', AlgoDisplay),
        atom_string(PT,  PTStr),  split_string(PTStr,  "_", "", PTParts),  atomic_list_concat(PTParts,  ' ', PTDisplay),
        atom_string(DS,  DSStr),  split_string(DSStr,  "_", "", DSParts),  atomic_list_concat(DSParts,  ' ', DSDisplay),
        atom_string(Mem, MemStr), split_string(MemStr, "_", "", MemParts), atomic_list_concat(MemParts, ' ', MemDisplay),
        atom_string(Pri, PriStr), split_string(PriStr, "_", "", PriParts), atomic_list_concat(PriParts, ' ', PriDisplay),
        atom_string(DO,  DOStr),  split_string(DOStr,  "_", "", DOParts),  atomic_list_concat(DOParts,  ' ', DODisplay)
    },
    html(
        div([class('result-container')], [
            h2('Algorithm Recommendation'),

            % --- Summary banner ---
            div([class('rec-banner')], [
                div([class('rec-algo-name')], AlgoDisplay),
                div([class('rec-tagline')], 'Best match for your constraints')
            ]),

            % --- Input summary ---
            div([class('input-summary')], [
                h3('Your selections'),
                div([class('tag-row')], [
                    span([class('tag tag-type')],  ['Problem: ', PTDisplay]),
                    span([class('tag tag-size')],  ['Size: ',    DSDisplay]),
                    span([class('tag tag-mem')],   ['Memory: ',  MemDisplay]),
                    span([class('tag tag-pri')],   ['Priority: ',PriDisplay]),
                    span([class('tag tag-data')],  ['Data: ',    DODisplay])
                ])
            ]),

            % --- Complexity cards ---
            div([class('complexity-grid')], [
                div([class('cx-card')], [
                    span([class('cx-label')], 'Time Complexity'),
                    span([class('cx-val cx-time')], Time)
                ]),
                div([class('cx-card')], [
                    span([class('cx-label')], 'Space Complexity'),
                    span([class('cx-val cx-space')], Space)
                ]),
                div([class('cx-card')], [
                    span([class('cx-label')], 'Stability'),
                    span([class('cx-val cx-stab')], Stability)
                ])
            ]),

            % --- Why this algorithm ---
            div([class('info-card')], [
                h3([class('info-title')], '\u2713 Why this algorithm?'),
                p(Desc)
            ]),

            % --- Real world use case ---
            div([class('info-card info-use')], [
                h3([class('info-title')], '\ud83c\udf0d Real-world use cases'),
                p(UseCase)
            ]),

            % --- Warning ---
            div([class('info-card info-warn')], [
                h3([class('info-title')], '\u26a0 When to avoid'),
                p(AvoidReason)
            ]),

            % --- Alternative ---
            \render_alternative(PT, AltAlgo),

            div([class('form-actions')], [
                a([href('/select'),  class('btn-primary')],   '\u2190 Try Another'),
                a([href('/history'), class('btn-secondary')], 'View History'),
                a([href('/browse'),  class('btn-outline')],   'Browse All Algorithms')
            ])
        ])
    ).

render_alternative(_, none) --> [].
render_alternative(PT, AltAlgo) -->
    {
        atom_string(AltAlgo, AltStr),
        split_string(AltStr, "_", "", AltParts),
        atomic_list_concat(AltParts, ' ', AltDisplay),
        algorithm(AltAlgo, _, AltTime, AltSpace, _, AltDesc),
        format(atom(BrowseLink), '/browse?highlight=~w&category=~w', [AltAlgo, PT])
    },
    html(div([class('info-card info-alt')], [
        h3([class('info-title')], '\ud83d\udd04 Alternative to consider'),
        div([class('alt-name')], AltDisplay),
        p(['Time: ', AltTime, ' \u00b7 Space: ', AltSpace]),
        p(AltDesc),
        a([href(BrowseLink), class('btn-outline')], 'View details')
    ])).


% ============================================================
%  PAGE: BROWSE ALL ALGORITHMS
% ============================================================

browse_page(Request) :-
    http_parameters(Request, [
        category(Cat, [atom, default(all)]),
        highlight(HL,  [atom, default(none)])
    ]),
    ( Cat = all ->
        findall(A-C-T-S-St-D, algorithm(A, C, T, S, St, D), Algos)
    ;
        findall(A-Cat-T-S-St-D, algorithm(A, Cat, T, S, St, D), Algos)
    ),
    reply_html_page(title('Browse Algorithms'), [
        \page_style,
        \navbar(browse),
        div([class('browse-container')], [
            div([class('browse-header')], [
                h2('All Algorithms'),
                div([class('filter-row')], [
                    \filter_link('all',                'All',                Cat),
                    \filter_link('sorting',            'Sorting',            Cat),
                    \filter_link('searching',          'Searching',          Cat),
                    \filter_link('graph',              'Graph',              Cat),
                    \filter_link('dynamic_programming','Dynamic Programming',Cat),
                    \filter_link('string_matching',    'String Matching',    Cat)
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
        atom_string(A, AStr),
        split_string(AStr, "_", "", AParts),
        atomic_list_concat(AParts, ' ', ADisplay),
        atom_string(Cat, CatStr),
        split_string(CatStr, "_", "", CatParts),
        atomic_list_concat(CatParts, ' ', CatDisplay),
        ( A = HL -> CardClass = 'algo-card highlighted' ; CardClass = 'algo-card' ),
        use_case(A, UseCase)
    },
    html(div([class(CardClass)], [
        div([class('algo-card-header')], [
            span([class('algo-name')], ADisplay),
            span([class('algo-cat')],  CatDisplay)
        ]),
        div([class('algo-complexities')], [
            span([class('cx-pill cx-t')], ['T: ', Time]),
            span([class('cx-pill cx-s')], ['S: ', Space]),
            span([class('cx-pill cx-st')], Stab)
        ]),
        p([class('algo-desc')], Desc),
        p([class('algo-use')],  ['Use: ', UseCase])
    ])),
    render_algo_cards(Rest, HL).


% ============================================================
%  PAGE: HISTORY
% ============================================================

history_page(_Request) :-
    findall(row(ID,PT,DS,Mem,Pri,DO,Algo),
            query_log(ID, PT, DS, Mem, Pri, DO, Algo), Rows),
    reply_html_page(title('Query History'), [
        \page_style,
        \navbar(history),
        div([class('history-container')], [
            div([class('history-header')], [
                h2('Query History'),
                a([href('/clear'), class('btn-danger'),
                   onclick('return confirm("Clear all history?");')],
                  'Clear All')
            ]),
            \render_history(Rows)
        ])
    ]).

render_history([]) -->
    html(div([class('empty-state')], [
        p('No queries made yet.'),
        a([href('/select'), class('btn-primary')], 'Find your first algorithm')
    ])).
render_history(Rows) -->
    html(table([class('history-table')], [
        thead(tr([
            th('#'), th('Problem Type'), th('Data Size'),
            th('Memory'), th('Priority'), th('Data / Char.'), th('Recommended')
        ])),
        tbody(\history_rows(Rows))
    ])).

history_rows([]) --> [].
history_rows([row(ID,PT,DS,Mem,Pri,DO,Algo)|Rest]) -->
    {
        atom_string(Algo, AStr),
        split_string(AStr, "_", "", AParts),
        atomic_list_concat(AParts, ' ', ADisplay),
        atom_string(PT, PTStr),  split_string(PTStr,  "_", "", PTP), atomic_list_concat(PTP,  ' ', PTD),
        atom_string(DS, DSStr),  split_string(DSStr,  "_", "", DSP), atomic_list_concat(DSP,  ' ', DSD),
        atom_string(DO, DOStr),  split_string(DOStr,  "_", "", DOP), atomic_list_concat(DOP,  ' ', DOD)
    },
    html(tr([
        td(ID),
        td([class('td-type')],  PTD),
        td(DSD),
        td(Mem),
        td(Pri),
        td([class('td-char')],  DOD),
        td(span([class('algo-badge')], ADisplay))
    ])),
    history_rows(Rest).


% ============================================================
%  PAGE: CLEAR
% ============================================================

clear_page(_Request) :-
    clear_history,
    reply_html_page(title('Cleared'), [
        \page_style,
        \navbar(history),
        \alert_script('History cleared!'),
        \redirect_script('/history')
    ]).

redirect_script(URL) -->
    html(script(type('text/javascript'),
        ['window.location.href = "', URL, '";'])).

alert_script(Message) -->
    html(script(type('text/javascript'),
        ['alert("', Message, '");'])).


% ============================================================
%  SHARED COMPONENTS
% ============================================================

navbar(Active) -->
    html(nav([class('navbar')], [
        \nav_link('/',        'Home',       Active, home),
        \nav_link('/select',  'Find Algorithm', Active, select),
        \nav_link('/browse',  'Browse All', Active, browse),
        \nav_link('/history', 'History',    Active, history)
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
        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f4f4f4;
            color: #2c3e50;
            line-height: 1.6;
        }

        /* NAV */
        .navbar {
            background: #fff;
            padding: 12px 28px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #ddd;
            box-shadow: 0 2px 4px rgba(0,0,0,0.07);
        }
        .nav-btn {
            text-decoration: none;
            color: #fff;
            background: #2196f3;
            padding: 8px 18px;
            border-radius: 4px;
            font-size: 0.95rem;
            border: 1px solid #2196f3;
            transition: background 0.2s;
        }
        .nav-btn:hover  { background: #1976d2; }
        .nav-btn.active { background: #0d47a1; border-color: #0d47a1; }

        /* BUTTONS */
        .btn-primary {
            display: inline-block;
            background: #2196f3;
            color: #fff;
            padding: 12px 28px;
            border-radius: 5px;
            text-decoration: none;
            border: none;
            font-size: 1rem;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 0.5rem;
        }
        .btn-primary:hover { background: #1976d2; }
        .btn-secondary {
            display: inline-block;
            background: #fff;
            color: #2196f3;
            padding: 12px 28px;
            border-radius: 5px;
            text-decoration: none;
            border: 1px solid #2196f3;
            font-size: 1rem;
            cursor: pointer;
            margin-left: 10px;
            margin-top: 0.5rem;
            transition: background 0.2s;
        }
        .btn-secondary:hover { background: #e3f2fd; }
        .btn-outline {
            display: inline-block;
            background: transparent;
            color: #2196f3;
            padding: 10px 22px;
            border-radius: 5px;
            text-decoration: none;
            border: 1px solid #2196f3;
            font-size: 0.95rem;
            margin-left: 10px;
            margin-top: 0.5rem;
        }
        .btn-outline:hover { background: #e3f2fd; }
        .btn-danger {
            display: inline-block;
            background: #e53935;
            color: #fff;
            padding: 8px 18px;
            border-radius: 4px;
            text-decoration: none;
            border: none;
            font-size: 0.9rem;
            cursor: pointer;
        }
        .btn-danger:hover { background: #b71c1c; }

        /* HERO */
        .hero {
            text-align: center;
            padding: 56px 24px 36px;
            max-width: 860px;
            margin: 0 auto;
        }
        .hero h1 { font-size: 2.2rem; color: #1a237e; margin-bottom: 0.4rem; }
        .subtitle { color: #2196f3; font-size: 0.95rem; margin-bottom: 1.5rem; font-weight: bold; }
        .hero-body p { font-size: 1.05rem; color: #003366; font-weight: bold; margin-bottom: 0.5rem; }
        .hero-btns { margin-top: 1.5rem; }

        /* CATEGORY CARDS */
        .categories-section {
            max-width: 960px;
            margin: 0 auto 48px;
            padding: 0 24px;
        }
        .categories-section h2 { color: #1a237e; margin-bottom: 1.2rem; font-size: 1.4rem; }
        .cat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 16px;
        }
        .cat-card {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px 16px;
            text-align: center;
            transition: box-shadow 0.2s;
        }
        .cat-card:hover { box-shadow: 0 4px 12px rgba(33,150,243,0.15); }
        .cat-icon { font-size: 2rem; color: #2196f3; display: block; margin-bottom: 8px; }
        .cat-card h3 { color: #1a237e; font-size: 0.95rem; margin-bottom: 4px; }
        .cat-count { font-size: 0.8rem; color: #2196f3; font-weight: bold; display: block; margin-bottom: 6px; }
        .cat-desc { font-size: 0.8rem; color: #666; }

        /* FORM */
        .form-container {
            max-width: 900px;
            margin: 36px auto;
            padding: 0 24px;
        }
        .form-container h2 { color: #1a237e; font-size: 1.6rem; margin-bottom: 0.4rem; text-align: center; }
        .form-intro { text-align: center; color: #555; margin-bottom: 2rem; }
        .form-section {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px 24px;
            margin-bottom: 1.2rem;
        }
        .form-section h3 { color: #1a237e; font-size: 1rem; margin-bottom: 1rem; }
        .radio-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
        }
        .radio-card {
            display: flex;
            flex-direction: column;
            border: 1.5px solid #ddd;
            border-radius: 6px;
            padding: 10px 14px;
            cursor: pointer;
            transition: border-color 0.15s, background 0.15s;
        }
        .radio-card:hover { border-color: #2196f3; background: #f0f8ff; }
        .radio-card input[type=radio] { display: none; }
        .radio-card input[type=radio]:checked + .rc-label { color: #0d47a1; }
        .radio-card:has(input:checked) { border-color: #2196f3; background: #e3f2fd; }
        .rc-label { font-weight: bold; font-size: 0.9rem; color: #2c3e50; margin-bottom: 2px; }
        .rc-desc  { font-size: 0.78rem; color: #888; }
        .form-actions { text-align: center; margin-top: 1.5rem; }

        /* RESULT */
        .result-container {
            max-width: 780px;
            margin: 36px auto;
            padding: 0 24px;
        }
        .result-container h2 { color: #1a237e; font-size: 1.6rem; margin-bottom: 1.2rem; text-align: center; }
        .rec-banner {
            background: #1a237e;
            color: #fff;
            border-radius: 10px;
            padding: 24px 32px;
            text-align: center;
            margin-bottom: 1.5rem;
        }
        .rec-algo-name { font-size: 2rem; font-weight: bold; text-transform: capitalize; margin-bottom: 4px; }
        .rec-tagline { font-size: 0.95rem; color: #90caf9; }

        .input-summary { background: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 16px 20px; margin-bottom: 1.2rem; }
        .input-summary h3 { font-size: 0.9rem; color: #555; margin-bottom: 10px; }
        .tag-row { display: flex; flex-wrap: wrap; gap: 8px; }
        .tag { padding: 4px 12px; border-radius: 20px; font-size: 0.82rem; font-weight: bold; }
        .tag-type  { background: #e3f2fd; color: #0d47a1; }
        .tag-size  { background: #e8f5e9; color: #1b5e20; }
        .tag-mem   { background: #fff3e0; color: #e65100; }
        .tag-pri   { background: #f3e5f5; color: #4a148c; }
        .tag-data  { background: #fce4ec; color: #880e4f; }

        .complexity-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; margin-bottom: 1.2rem; }
        .cx-card {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 14px 16px;
            text-align: center;
        }
        .cx-label { display: block; font-size: 0.78rem; color: #888; margin-bottom: 6px; }
        .cx-val   { display: block; font-size: 1.2rem; font-weight: bold; font-family: monospace; }
        .cx-time  { color: #0d47a1; }
        .cx-space { color: #1b5e20; }
        .cx-stab  { color: #6a1b9a; text-transform: capitalize; }

        .info-card {
            background: #fff;
            border: 1px solid #ddd;
            border-left: 4px solid #2196f3;
            border-radius: 6px;
            padding: 16px 20px;
            margin-bottom: 1rem;
        }
        .info-use  { border-left-color: #43a047; }
        .info-warn { border-left-color: #fb8c00; }
        .info-alt  { border-left-color: #8e24aa; }
        .info-title { font-size: 0.95rem; margin-bottom: 8px; color: #2c3e50; }
        .alt-name { font-size: 1.1rem; font-weight: bold; color: #1a237e; margin-bottom: 6px; text-transform: capitalize; }

        .no-match-box {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 32px;
            text-align: center;
            margin-top: 2rem;
        }
        .no-match-box p { margin-bottom: 1rem; color: #555; }

        /* BROWSE */
        .browse-container { max-width: 1080px; margin: 36px auto; padding: 0 24px; }
        .browse-header { margin-bottom: 1.5rem; }
        .browse-header h2 { color: #1a237e; font-size: 1.6rem; margin-bottom: 1rem; }
        .filter-row { display: flex; flex-wrap: wrap; gap: 8px; }
        .filter-btn {
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 0.88rem;
            text-decoration: none;
            color: #2196f3;
            border: 1px solid #2196f3;
            transition: background 0.15s;
        }
        .filter-btn:hover, .filter-btn.active { background: #2196f3; color: #fff; }
        .algo-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 16px;
        }
        .algo-card {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 18px 20px;
            transition: box-shadow 0.2s;
        }
        .algo-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .algo-card.highlighted { border: 2px solid #8e24aa; box-shadow: 0 0 0 3px rgba(142,36,170,0.1); }
        .algo-card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px; }
        .algo-name { font-size: 1rem; font-weight: bold; color: #1a237e; text-transform: capitalize; }
        .algo-cat  { font-size: 0.75rem; color: #888; text-align: right; text-transform: capitalize; max-width: 100px; }
        .algo-complexities { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 10px; }
        .cx-pill { padding: 2px 8px; border-radius: 12px; font-size: 0.78rem; font-family: monospace; }
        .cx-t  { background: #e3f2fd; color: #0d47a1; }
        .cx-s  { background: #e8f5e9; color: #1b5e20; }
        .cx-st { background: #f3e5f5; color: #4a148c; }
        .algo-desc { font-size: 0.85rem; color: #444; margin-bottom: 6px; }
        .algo-use  { font-size: 0.8rem; color: #888; }

        /* HISTORY */
        .history-container { max-width: 1060px; margin: 36px auto; padding: 0 24px; }
        .history-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.2rem; }
        .history-header h2 { color: #1a237e; font-size: 1.6rem; }
        .history-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 6px rgba(0,0,0,0.07); }
        .history-table th, .history-table td { padding: 11px 14px; text-align: left; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; }
        .history-table thead { background: #1a237e; color: #fff; }
        .history-table tbody tr:hover { background: #f5f5f5; }
        .td-type { text-transform: capitalize; color: #0d47a1; font-weight: bold; }
        .td-char { text-transform: capitalize; }
        .algo-badge { background: #e3f2fd; color: #0d47a1; padding: 3px 10px; border-radius: 12px; font-size: 0.82rem; font-weight: bold; text-transform: capitalize; }

        .empty-state { text-align: center; padding: 60px 0; color: #888; }
        .empty-state p { font-size: 1.2rem; margin-bottom: 1rem; }

        h2 { text-align: center; }

        @media (max-width: 700px) {
            .complexity-grid { grid-template-columns: 1fr 1fr; }
            .cat-grid { grid-template-columns: repeat(2, 1fr); }
            .navbar { flex-wrap: wrap; }
            .history-table { font-size: 0.78rem; }
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
