--define:useRealtimeGC
--define:vmExecHooks
--define:enu_simulate
--noMain
--app:lib
--threads:on
--tlsEmulation:off
--threadAnalysis:off
--define:vmExecHooks
--define:nimPreviewHashRef
--path:"$projectDir/../../src"
--path:"$projectDir/../../generated"
switch("out", "app/_dlls/enu-test.dylib")
switch("out", this_dir() & "/app/_dlls/enu-test.dylib")
