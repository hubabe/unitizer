# `unitizer` NEWS

## v1.2.0

* [#168](https://github.com/brodieG/unitizer/issues/168): Failing tests now will
  output all output and conditions
* [#171](https://github.com/brodieG/unitizer/issues/171): Flush warnings in
  `unitizer` REPL
* Improved integration of object diffs via `.DIFF` and `.diff`
* Display improvements, including:
    * Cleaner separation of `unitizer` meta-output vs. test or command line
    * [#164](https://github.com/brodieG/unitizer/issues/164), 
      [#176](https://github.com/brodieG/unitizer/issues/176): Streamline state
      difference display.
* Assorted bugfixes ([#175](https://github.com/brodieG/unitizer/issues/175),
   [#173](https://github.com/brodieG/unitizer/issues/173),
   [#170](https://github.com/brodieG/unitizer/issues/170))

## v1.1.0

### Improvement / Changes:

* [#161](https://github.com/brodieG/unitizer/issues/161): Compare objects with `diffobj::diffObj`
* [#166](https://github.com/brodieG/unitizer/issues/166): More systematic
  handling of `library`/`attach`/`detach`

### Bugfixes:

* Several unitizer prompt issues:
    * No longer capture prompt evals so `debug` is usable again
    * Parse errors reported correctly
    * [#165](https://github.com/brodieG/unitizer/issues/165): Confusing Help
      Prompt
* Reference state properly preserved (previously would incorrectly use new state
  for reference tests kept in store)
* Internal shimming of library/detach/attach more robust
* Updated tests for changes in testthat, R

## v1.0.0-1.0.9

### Improvement / Changes:

* More comprehensive state tracking and resetting:
    * options, random.seed, and wd are tracked in addition to search path
    * state is reset when reviewing tests as well as when executing them
    * you are alerted off state differences between new and reference tests
      on error
    * State control parameters are streamlined; API breaking
* Whether an expression is ignored or not is now a function of whether the
  expression returns visibly or not
* Pre and post test scripts
    * 'helper' directory renamed '_pre'
    * Can now use a '_post' directory to run cleanup
* Interactive environment cleanup
    * Display tweaks
    * Contextual help tweaks
* Vignette updates
* Demo update
* Added `Rdiff_obj` to run a `tools::Rdiff` directly on two R objects

### Internal:

* Reduced storage requirements for the `unitizer` stores
    * No longer storing assignments both as test value and object in environment
    * Calls recorded deparsed instead of as call objects
* Shimming used for search path tracking is more lightweight
* Text capture much more robust

### Issues Fixed:
  107, 106, 104, 103, 101, 99, 98, 94, 93, 90, 85, 84, 77, 74, 71, 67, 127, 115,
  132, 134

## v0.9.0

### Improvements / Changes:

* Complete restructure of internal test management to allow for much more robust
  `unitize_dir` behavior (#51)
* Added `testthat` -> `unitizer` translation utilities
  (see `?testthat_translate_file`)
* Can now pre-load objects before unitizing; `unitize_dir` and `unitize` by
  default auto-preload files in subdir 'helper'
* Renamed arg `env.clean` to `par.env` (technically API breaking, but since no
  one is using this package yet...)
* Many usability fixes (#48, #68, #82, #83), and improved text display
* Improved path inference to better guess desired unitizer based on partiallly
  specified file names (#72)

### Other

* `unitize_dir` works with empty dirs (#78)
* Better management of file locations and names (#35, #75)

## v0.8.1

### Bugfixes

* `review` now properly infers unitizer locations

## v0.8.0

### Improvements:

* Added ability to accept multiple tests at once (Issue #45, use wisely...)
* `unitize` can now infer partially specified test file names (in particular,
  will know to look in `pkgname/tests/unitizer`; see `?infer_unitizer_location`)
* `parse_with_comments` no longer run in non-interactive mode (#63)
* Test call now part of output of test object `show` method (#54)

### Bugfixes:

* Comments inside `unitizer_sect` preserved (#64)
* Ignored tests assigned to first non-ignored test section (#57)
* Prompt display issues (#65, #66)

### Internal:

* `search_path_cleanup` more robust (#59)
* `get_text_capture` tests added (#60)

## v0.7.1

### Improvements:

* Reduced test execution and parsing overhead
* Better handling of call recording for traceback and condition calls
* `editFunNames` becomes `editCalls` and provides more comprehensive editing of
  calls (Issue #52)

### Bufixes:

* Comment handling in calls (Issues #56, #58)
* Comment deparsing (Issues #39, #47, #52)

## v0.7.0

### Improvements:

* Failed tests now automatically output a snippet of new and reference objects
  (Issue #34)
* Text handling generally improved (better wrapping, etc. Issue #38)
* Parsing speed improved (Issue #15)
* Got rid of `get*` functions, instead, access test details with `.NEW`/`.REF`
  (Issue #29)
* Implemented `editFunNames` to allow user to modify stored calls in `unitizer`
  so that tests can be re-used even if function names are changed

## v0.6.5

Doc updates; should have been part of 0.6.4, but was too rushed to push...

## v0.6.4

### Improvements:

* Comment parsing faster (issue #15)

### Bugfixes:

* Reference section logic improved (assume fixes #36 until there is evidence
  against)
* Several parse errors fixed

### Other:

* Now depends on R 3.1.2 (not really, but that's what we are developing on and
  don't have bandwidth to test against multiple R versions)

## v0.6.3

### Bugfixes:

* stderr now show in `review` mode (issue #43)
* package startup messages suppressed (issue #23)
* small demo bug

## v0.6.2

### Bugfixes:

* Better whitespace wrapping in terminal mode (partially addresses #38)
* Can now drop all items in review mode (issue #37)
* Workaround an R parse bug (issue #41)
* `traceback()` now works for `stop(simpleError(...))` type stops

Behavior changes:

* History is only subbed out if you need to type input (issue #40)

#### v0.6.1

Minor release, no substantive changes.

### Bugfixes:

* Loading a `unitizer` no longer automatically modifies it through `upgrade`
* `upgrade` cleaned up and has tests now
* calling functions in form `pkg::fun` or `pkg:::fun` no longer causes problems
  when checking for ignoredness

### Behavior changes:

* `get` no longer warns if `unitizer` ids don't match

## v0.6.0

### New Features:

* Added a demo (`demo(unitizer)`)
* Broke up and updated vignettes
* `unitize_dir` allows you to run all tests in a directory (issue #24)
* `review` allows you to review and drop tests from an existing `unitizer` store
  (issue #21)
* Test navigation mechanism improved (issue #26)
    * Typing R at the unitizer prompt now allows you to review all tests
    * You can skip ahead too
* `unitize(..., force.update=TRUE)` will overwrite unitizer even if there were
  no changes recorded (issue #19)

### Behavior changes:

* `unitize` now runs with `search.path.clean=TRUE` by default

### Bugfixes:

* Comparison function warnings not captured (issue #14)
* Search path restoration error messages fixed (issue #22)
* Navigation regressions fixed (issue #30)

### Other:

Summary titles cleaned up, interative prompts made clearer, package reload warn
conflicts quieted (d2fe594c747, #23)

## v0.5.0

### New Features:

* Can now run tests in clean environment (i.e. objects from .GlobalEnv will not
  be visible) (issue #13)
* Can now run tests with clean search path (i.e. only the basic R libraries are
  loaded) (also issue #13), use `unitize(..., search.path.clean=TRUE)`
* New vignette "Reproducible Tests" discusses the above features

### Bugfixes:

* Expressions printed as tests evaluated now truncated corretly (issue #4)
* Incorrect displaying/hiding of ignored tests in some circumstances fixed

### Other Improvements:

* Summary no longer includes "removed" tests in matrix, since those are section-
  less
* Other minor clean-up of the interactive environment prompting

## v0.4.3

### Many interactive use bug fixes:

* LBB now parsed properly (issue #5)
* Non interactive parse (issue #11)
* Review and Back behavior consistent now in interactive use (issue #3)
* Other interactive use cleanup (issues #6, 12, 10, 9)
* Vignette now done properly

## v0.4.2

* Fixed setOldClass conflicts with RJSONIO (issue #1)
* Fixed run_ls not finding base env under certain circumstances (issue #2)
* Fixed conditionLists looping issue introduced when fixing issue #1