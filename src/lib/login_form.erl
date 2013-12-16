-module(login_form, [InitialData, Errors]).
-compile(export_all).

form_fields() ->
    [
     {username, [{type, char_field},
                 {label, "Username"},
                 {required, true},
                 {html_options, [{class, "input-block-level"},
                                {placeholder, "Email address"}]}]},
     {password, [{type, char_field},
                 {widget, password_input},
                 {label, "Password"},
                 {required, true},
                 {html_options, [{class, "input-block-level"},
                                {placeholder, "Password"}]}]},
     {remember_me, [{type, boolean_field},
                    {label, "Remember me"}]}
    ].



%% Proxies
data() ->
    InitialData.

errors() ->
    Errors.

fields() ->
    boss_form:fields(form_fields(), InitialData).

as_table() ->
    boss_form:as_table(form_fields(), InitialData, Errors).


%% Validators
validate_password(_Options, RequestData) ->
    case string:len(proplists:get_value("password", RequestData, "")) > 5 of
        true -> ok;
        false -> {error, "Password is too short"}
    end.
