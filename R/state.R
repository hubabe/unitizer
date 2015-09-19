#' @include global.R

NULL

.unitizer.valid.state.abbr <-  c("pristine", "noopt", "basic", "off", "safe")

#' Tests and Session State
#'
#' While R generally adheres to a "functional" programming style, there are
#' several aspects of session state that can affect the results of code
#' evaluation.  \code{unitizer} attempts to make tests as reproducible as
#' controlling session state so that it is the same every time a test is run.
#'
#' @section Overview:
#'
#' \code{unitizer} provides functionality to insulate test code from variability
#' in the following:
#'
#' \itemize{
#'   \item Workspace (enabled by default): all tests are evaluated in
#'      environments that are children of a special environment that does not
#'      inherit from \code{.GlobalEnv}.  This prevents objects that are
#'      laying around in your workspace from interfering with your tests.
#'   \item Random Seed (enabled by default): is set to a specific value at the
#'     beginning of each test file so that tests using random values get the
#'     same value at every test iteration. If you change the order of  your
#'     tests, or add a test that uses a random sampling before the end of
#'     the file, that will still affect the random seed.
#'   \item Working Directory (enabled by default): is set to the package
#'     directory if all test files are  in the same sub-directory of a package.
#'   \item Search Path (\bold{disabled} by default): is set to what you would
#'     typically find in a freshly loaded vanilla R session.  This means any non
#'     default packages that are loaded when you run your tests are unloaded
#'     prior to running your tests.  If you want to use the same libraries
#'     across multiple tests you can load them with the \code{pre} argument to
#'     \code{\link{unitize}} or \code{\link{unitizes_dir}}.
#'   \item Options (\bold{disabled} by default): same as search path
#' }
#'
#' State is reset after running each test file when running multiple test
#' files with \code{unitize_dir}, which means state changes in one test file
#' will not affect the next one.
#'
#' @section Search Path and Options:
#'
#' Search path and options state management are turned off by default because
#' in order to work they require the ability to fully unload any non-default
#' packages and namespaces, and there are some packages that cannot be
#' unloaded, or should not be unloaded (e.g.
#' \href{https://github.com/Rdatatable/data.table/issues/990}{data.table}). If
#' you know the packages you typically load in your sessions can be unloaded,
#' you can turn this functionality on by setting
#' \code{options(unitizer.state="pristine")} either in your session, in your
#' \code{.Rprofile} file, or in each call to \code{unitize} or
#' \code{unitize_dir}.  If you have packages that cannot be unloaded, but
#' you still want to enable these features, see the "Search Path and Namespace
#' State Options" section of \code{\link{unitizer.opts}} docs.
#'
#' If you run \code{unitizer} with options and search path tracking and you run
#' into a namespace that cannot be unloaded, or should not be unloaded because
#' it is listed in \code{getOption("unitizer.namespace.keep")}, \code{unitizer}
#' will turn off \code{options} state tracking from that point onwards.
#'
#' @section State Presets:
#'
#' You can use these classes for detailed control of how \code{unitizer} tracks
#' and modifies state during test evaluation and review.  These can be passed
#' as the \code{state} argument to \code{\link{unitize}} and
#' \code{\link{unitize_dir}}.
#'
#' There are several classes defined, though their only purpose is to act as
#' presets since they are identical except for their prototype values:
#' \itemize{
#'   \item \code{unitizerStateSafe} is the default and turns off tracking for
#'     search path and options, which are the two settings most likely to cause
#'     problems with poorly behaved packages
#'   \item \code{unitizerStatePristine} implements the highest level of state
#'     tracking and control
#'   \item \code{unitizerStateNoOpt} turns off options tracking, which makes it
#'     a good choice if you have a lot of packages that are added to
#'     \code{getOption("unitizer.namespace.keep")} so that you do not need to
#'     also add all their options to \code{getOption("unitizer.opts.asis")}
#'   \item \code{unitizerStateBasic} keeps all tracking, but at a less
#'     aggressive level; state is reset between each test file to the state
#'     before you started \code{unitize}ing so that no single test file affects
#'     another, but the state of your workspace, search path, etc. when you
#'     launch \code{unitizer} will affect all the tests (see the Custom Control)
#'     section.
#'   \item \code{unitizerStateOff} state tracking is turned off
#' }
#' Each class has a constructor function of the same name as the class.
#'
#' @section Custom Control:
#'
#' In addition to the preset classes, you can set any of the slots to any valid
#' setting (see examples).  For \code{par.env} that setting is either
#' \code{NULL} or an environment.  for all other slots, the settings are in
#' \code{0:2} and mean:
#' \enumerate{
#'   \item 0 turn off state tracking
#'   \item 1 track, but start with state as it was when \code{unitize} was
#'     called
#'   \item 2 track and set state to what you would typically find in a clean
#'     R session, with the exception of \code{random.seed}, which is
#'     set to \code{\link{getOption("unitizer.seed")}} (of kind "Wichmann-Hill"
#'     as that seed is substantially smaller than the R default).
#' }
#' @note \code{\link{unitize_dir}} and \code{\link{unitize}} can accept
#'   character values instead of the classes here; these are just translated to
#'   the corresponding class defined here.  See the docs for the \code{state}
#'   parameter for those functions.
#' @examples
#' \dontrun{
#' ## use a custom environment as parent env
#' my.env <- new.env()
#' unitize(..., state=unitizerStatePrisitine(par.env=my.env))
#' ## Basic, but do not track options
#' unitize(..., state=unitizerStateBasic(options=0))
#' ## No options tracking, and in `dplyr` package namespace environment
#' unitize(..., state=unitizerStateNoOpt(par.env="dplyr"))
#' }
#' @slot search.path one of \code{\link{0:2}}
#' @slot options one of \code{\link{0:2}}
#' @slot working.directory one of \code{\link{0:2}}
#' @slot random.seed one of \code{\link{0:2}}
#' @slot par.env \code{NULL} to use the special \code{unitizer} parent
#'   environment, or an environment to use as the parent environment, or
#'   the name of a package as a character string to use that packages'
#'   namespace as the parent environment
#'
#' @rdname unitizerState
#' @export unitizerState
#' @name unitizerState
#' @seealso \code{\link{unitize}}, \code{\link{unitizer.opts}}

unitizerState <- setClass(
  "unitizerState",
  slots=c(
    search.path="integer",
    options="integer",
    working.directory="integer",
    random.seed="integer",
    par.env="environmentOrNULL"
  ),
  prototype=list(
    search.path=0L, options=0L, working.directory=0L, random.seed=0L,
    par.env=NULL
  ),
  validity=function(object) {
    # seemingly superflous used to make sure this object is in concordance with
    # the various others that are similar
    if(
      !identical(
        slotNames(object),
        c(.unitizer.global.settings.names, "par.env")
      )
    )
      paste0(
        "Invalid state object, slots must be ",
        deparse(.unitizer.global.settings.names, width=500)
      )
    for(i in .unitizer.global.settings.names) {
      slot.val <- slot(object, i)
      if(
        !is.integer(slot.val) || !length(slot.val) == 1L || is.na(slot.val) ||
        !slot.val %in% 0L:2L
      )
        return(paste0("Slot `", i, "` must be integer(1L) and in 0:2"))
    }
    if(
      identical(object@options, 2L) &&
      !identical(object@search.path, 2L)
    )
      return(
        paste0(
          "Argument `reproducible.state` has an invalid state: 'options' is set ",
          "to 2, but 'search.path' is not"
      ) )
    if(identical(object@random.seed, 2L)) {
      prev.seed <- mget(
        ".Random.seed", envir=.GlobalEnv, ifnotfound=list(NULL)
      )[[1L]]
      seed.dat <- getOption("unitizer.seed")
      msg <- ""
      if(inherits(try(do.call(set.seed, seed.dat)), "try-error")) {
        msg <- paste0(
          "Unable to set random seed; make sure `getOption('unitizer.seed')` ",
          "is a list of possible arguments to `set.seed`, or set `seed` slot ",
          "to be less than 2L."
      ) }
      if(is.null(prev.seed) && exists(".Random.seed", envir=.GlobalEnv))
        rm(".Random.seed", envir=.GlobalEnv) else
          assign(".Random.seed", prev.seed, envir=.GlobalEnv)
      if(nchar(msg)) return(msg)
    }
    TRUE
  }
)
setMethod("initialize", "unitizerState",
  function(.Object, ...) {
    dots <- list(...)
    dots.base <- dots[!names(dots) %in% "par.env"]
    for(i in names(dots.base))
      if(is.numeric(dots.base[[i]])) dots[[i]] <- as.integer(dots.base[[i]])
    if("par.env" %in% names(dots))
      dots[["par.env"]] <- try(getNamespace(dots[["par.env"]]))
    if(inherits(dots[["par.env"]], "try-error"))
      stop(
        "Argument `par.env` must resolve to a package namespace if supplied as ",
        "character(1L)"
      )
    do.call(callNextMethod, c(.Object, dots))
} )
#' @export unitizerStatePristine
#' @rdname unitizerState

unitizerStatePristine <- setClass(
  "unitizerStatePristine", contains="unitizerState",
  prototype=list(
    search.path=2L, options=2L, working.directory=2L, random.seed=2L,
    par.env=NULL
  )
)
#' @export unitizerStateSafe
#' @rdname unitizerState

unitizerStateSafe <- setClass(
  "unitizerStateSafe", contains="unitizerState",
  prototype=list(
    search.path=0L, options=0L, working.directory=2L, random.seed=2L,
    par.env=NULL
  )
)
#' @export unitizerStateNoOpt
#' @rdname unitizerState

unitizerStateNoOpt <- setClass(
  "unitizerStateNoOpt", contains="unitizerState",
  prototype=list(
    search.path=2L, options=0L, working.directory=2L, random.seed=2L,
    par.env=NULL
  )
)
#' @export unitizerStateBasic
#' @rdname unitizerState

unitizerStateBasic <- setClass(
  "unitizerStateBasic", contains="unitizerState",
  prototype=list(
    search.path=1L, options=1L, working.directory=1L, random.seed=1L,
    par.env=NULL
  )
)
#' @export unitizerStateOff
#' @rdname unitizerState

unitizerStateOff <- setClass(
  "unitizerStateOff", contains="unitizerState",
  prototype=list(
    search.path=0L, options=0L, working.directory=0L, random.seed=0L,
    par.env=.GlobalEnv
  )
)
setMethod(
  "show", "unitizerState",
  function(object) {
    sn <- slotNames(object)
    sv <- sapply(sn, slot, object=object, simplify=FALSE)
    par.env.null <- is.null(sv[["par.env"]])
    sv[["par.env"]] <- if(par.env.null) "<auto>" else
      env_name(sv[["par.env"]])
    print(data.frame(Settings=sn, Values=unlist(sv)))
    word_cat(
      "-----", "0: off", "1: track starting with initial state",
      "2: track starting with clean state",
      if(par.env.null) "<auto>: use special unitizer environment as 'par.env'",
      "See `?unitizerState` for more details.",
      sep="\n"
    )
  }
)
