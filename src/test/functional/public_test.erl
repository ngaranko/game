-module(public_test).
-compile(export_all).
 
start() ->
    %% Test public route
    boss_web_test:get_request("/", [], [fun boss_assert:http_ok/1,
                                        fun(Res) -> boss_assert:tag_with_text("strong", 
                                                                              "Rahm says hello!", Res) end
                                       ], []),
    %% Initial test
    boss_web_test:get_request("/public/index", [], [fun boss_assert:http_ok/1,
                                                    fun(Res) -> boss_assert:tag_with_text("strong", 
                                                                                          "Rahm says hello!", Res) end
                                                   ], []).
