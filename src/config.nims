--define:useRealtimeGC
--define:vmExecHooks
--threads:on
--tlsEmulation:off
--threadAnalysis:off

if project_name() == "enu":
  --app:lib
  --noMain

switch("path", this_dir())
switch("path", this_dir() & "/../generated")
