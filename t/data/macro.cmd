# Test of macro debugger command
set max width 80
set highlight off
info macro
macro foo
macro foo sub { 'list' }
foo
info macro
macro bar sub($count ) { ['list ' . $count] }
bar .
info macro
info macro *
quit!
