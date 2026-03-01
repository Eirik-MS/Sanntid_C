#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Returns malloc()'d JSON string. Free with hall_request_assign_free().
char* hall_request_assign_json(const char* input_json);

// Free result from hall_request_assign_json().
void hall_request_assign_free(char* p);

// Optional config setters (match config.d globals)
void hall_request_assign_set_doorOpenDuration(int v);
void hall_request_assign_set_travelDuration(int v);
void hall_request_assign_set_includeCab(int v);
void hall_request_assign_set_clearRequestType(int v);

#ifdef __cplusplus
}
#endif