all: ebin/cli.beam cli

ebin/cli.beam:
	@./rebar compile

cli:
	@./rebar escriptize

clean:
	@./rebar clean