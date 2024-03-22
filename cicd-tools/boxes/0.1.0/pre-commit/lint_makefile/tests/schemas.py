"""Schema test fixtures."""

one_simple_rule = {
    "version": "0.1.0",
    "rules": [{
        "name": "basic rule 1",
        "operation": "assert_blank",
    },],
}

two_simple_rules = {
    "version":
        "0.1.0",
    "rules":
        [
            {
                "name": "basic rule 1",
                "operation": "assert_blank",
            },
            {
                "name": "basic rule 2",
                "operation": "assert_blank",
            },
        ],
}

three_simple_rules = {
    "version":
        "0.1.0",
    "rules":
        [
            {
                "name": "basic rule 1",
                "operation": "assert_blank",
            },
            {
                "name": "basic rule 2",
                "operation": "assert_equal",
                "expected": "match me",
            },
            {
                "name": "basic rule 3",
                "operation": "until_eof",
            },
        ],
}

invalid_operation = {
    "version": "0.1.0",
    "rules": [
        {
        "name": "invalid operation example",
        "operation": "invalid_operation",
        },
    ],
}


key_error = {
    "version": "0.1.0",
    "rules": [
        {
        "name": "key error example",
        "operation_wrong_field": "assert_equal",
        },
    ],
}


type_error = {
    "version": "0.1.0",
    "rules": [
        {
        "name": "type error example",
        "operation": "assert_equal",
        "wrong_field": "invalid_field"
        },
    ],
}