-module(game_public_controller, [Req, SessionId]).
-compile(export_all).

index('GET', []) ->
    case boss_session:get_session_data(SessionId, user) of
        undefined ->
            {redirect, [{action, "login"}]};
        User ->
            io:format("User ~p~n", [User]),
            {ok, [{user, User}]}
    end.

login('GET', []) ->
    Form = boss_form:new(login_form, []),
    {ok, [{form, Form}]};

login('POST', []) ->
    Form = boss_form:new(login_form, []),
    case boss_form:validate(Form, Req:post_params()) of
        {ok, ValidatedData} ->
            boss_session:set_session_data(SessionId, user, ValidatedData),
            {redirect, [{controller, "public"}, {action, "index"}]};
        {error, FormWithErrors} ->
            {ok, [{form, FormWithErrors}]}
    end.

