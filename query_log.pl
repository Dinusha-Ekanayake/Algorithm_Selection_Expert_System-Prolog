% ============================================================
%  query_log.pl
%  Algorithm Selection Expert System
%
%  Dynamic knowledge base: stores the history of all
%  queries and all runtime-added algorithms.
%
%  query_log(ID, ProblemType, DataSize, Memory,
%            Priority, DataOrder, RecommendedAlgorithm)
%
%  custom_algorithm(Name, Category, TimeComplexity,
%                   SpaceComplexity, Stable, Description)
%  Tracks which algorithms were added by the user at runtime
%  so they can be individually removed.
% ============================================================

:- dynamic query_log/7.
:- dynamic custom_algorithm/6.
