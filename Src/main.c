#include <stdio.h>
#include <stdlib.h>

#include "lib/assigner.h" 

int main(void) {

    const char *input_json =
        "{"
        "\"hallRequests\":[[false,false],[true,false],[false,false],[false,true]],"
        "\"states\":{"
            "\"one\":{"
                "\"behaviour\":\"moving\","
                "\"floor\":2,"
                "\"direction\":\"up\","
                "\"cabRequests\":[false,false,true,true]"
            "},"
            "\"two\":{"
                "\"behaviour\":\"idle\","
                "\"floor\":0,"
                "\"direction\":\"stop\","
                "\"cabRequests\":[false,false,false,false]"
            "}"
        "}"
        "}";

    // Optional: set config if you exposed setters (safe to omit)
    // hall_request_assign_set_doorOpenDuration(3);
    // hall_request_assign_set_travelDuration(2);
    // hall_request_assign_set_includeCab(0);
    // hall_request_assign_set_clearRequestType("something");

    char *out_json = hall_request_assign_json(input_json);
    if (!out_json) {
        fprintf(stderr, "hall_request_assign_json returned NULL\n");
        return 1;
    }

    // Print output JSON (string)
    printf("%s\n", out_json);

    // Free memory allocated on the D side
    hall_request_assign_free(out_json);

    return 0;
}