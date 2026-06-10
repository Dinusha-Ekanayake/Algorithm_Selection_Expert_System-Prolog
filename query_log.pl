% ============================================================
%  query_log.pl
%  Algorithm Selection Expert System
%  CM2520 - Deductive Reasoning and Logic Programming
%  Author: Fernando P S R
%
%  Dynamic knowledge base: stores the history of all
%  queries made during the session using assertz/1.
%
%  Format: query_log(ID, ProblemType, DataSize,
%                    Memory, Priority, DataOrder, Result)
% ============================================================

:- dynamic query_log/7.
