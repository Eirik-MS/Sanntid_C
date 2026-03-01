module assigner_bridge;

extern(C):

import core.stdc.stdlib : malloc, free;
import core.stdc.string : memcpy;
//import core.stdc.stddef : size_t;

import std.conv : to;
import optimal_hall_requests;
import elevator_state;
import config;
import jsonx;

struct Input {
    bool[][] hallRequests;
    LocalElevatorState[string] states;
}

// ---- helpers ----
private size_t cstrlen(const char* s)
{
    size_t n = 0;
    if (s is null) return 0;
    while (s[n] != 0) n++;
    return n;
}

private char* dupToMalloc(string s)
{
    auto n = s.length;
    auto p = cast(char*)malloc(n + 1);
    if (p is null) return null;
    memcpy(p, s.ptr, n);
    p[n] = 0;
    return p;
}

// ---- C API ----

// Same input as your D program expects (JSON string), returns JSON string.
// Caller must free with hall_request_assign_free().
char* hall_request_assign_json(const char* input_json_c)
{
    if (input_json_c is null) return null;

    auto n = cstrlen(input_json_c);
    auto slice = (cast(const(char)*)input_json_c)[0 .. n];
    string input_str = slice.idup; // makes an owned immutable copy

    Input i = input_str.jsonDecode!Input;

    auto resultJson = optimalHallRequests(i.hallRequests.to!(bool[2][]), i.states).jsonEncode;

    return dupToMalloc(resultJson);
}

void hall_request_assign_free(char* p)
{
    if (p !is null) free(p);
}

// Optional: allow C to change the config globals used by the algorithm.
void hall_request_assign_set_doorOpenDuration(int v) { doorOpenDuration = v; }
void hall_request_assign_set_travelDuration(int v)   { travelDuration   = v; }
void hall_request_assign_set_includeCab(int v)       { includeCab       = (v != 0); }

// clearRequestType type depends on config.d. If it’s a string, this works.
// If it’s an enum, we can map strings->enum instead.
void hall_request_assign_set_clearRequestType_int(int v)
{
    clearRequestType = cast(ClearRequestType) v;
}