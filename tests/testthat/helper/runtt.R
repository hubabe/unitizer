# This used to be directly in `runtt.R`, but made it impossible to see any
# output from test failures.  So now we source this

# Install test packages, and set them up for removal, here in package name
# =dirname format

local({
  library(methods)
  library(unitizer)

  cat("setup packages\n")
  tmp.pkgs <- c(
    unitizerdummypkg1="unitizerdummypkg1",
    unitizerdummypkg2="unitizerdummypkg2",
    utzflm="flm0"
  )
  if(
    any(which.inst <- names(tmp.pkgs) %in% rownames(installed.packages()))
  ) {
    stop(
      "Packages\n",
      paste0(
        deparse(names(tmp.pkgs)[which.inst], width.cutoff=500), collapse=""
      ),
      "\nalready installed; cannot proceed with tests"
  ) }
  tmp.lib <- file.path(tempfile(), 'utz-tmp-lib')
  if(!isTRUE(dir.create(tmp.lib, recursive=TRUE))) {
    stop("Unable to create temp library directory")
  }
  old.opt.1 <- options(
    useFancyQuotes=FALSE, unitizer.tmp.lib.loc=tmp.lib,
    stringsAsFactors=TRUE, unitizer.restarts.ok=TRUE
  )
  on.exit({
    for(i in names(tmp.pkgs)) {
      try(detach(sprintf("package:%s", i)), silent=TRUE)
      try(unloadNamespace(i), silent=TRUE)
    }
    suppressWarnings(remove.packages(names(tmp.pkgs), lib=tmp.lib))
    unlink(tmp.lib, recursive=TRUE)
    options(old.opt.1)
  })
  unitizer.dir <- system.file(package="unitizer")
  pkg.dirs <- file.path(unitizer.dir, "expkg", tmp.pkgs)

  # install.packages does not work within R CMD check, and it does not
  # appear to be by design?
  old.val <- Sys.getenv("R_TESTS")
  Sys.setenv(R_TESTS="")
  pkg.inst <- try(
    for(pkg in pkg.dirs)
      install.packages(pkg, repos=NULL, type='src', lib=tmp.lib)
  )
  Sys.setenv(R_TESTS=old.val)
  if(inherits(pkg.inst, "try-error")) stop("install error")
  cat("setup demos\n")

  # Setup the demo files used by a number of tests

  .unitizer.fastlm <- copy_fastlm_to_tmpdir()
  test.dir <- file.path(.unitizer.fastlm, "tests", "unitizer")
  .unitizer.test.file <- file.path(test.dir,  "fastlm1.R")
  .unitizer.test.store <- file.path(test.dir,  "fastlm1.unitizer")

  # Ensure same behavior interactive and non-interactive

  old.opt.2 <- if(isTRUE(getOption("showErrorCalls")))
     options(showErrorCalls=FALSE) else list()
  old.opt.2 <- c(
    old.opt.2, options(unitizer.state='recommended', diffobj.pager='off')
  )
  # A dummy class we use to test coercion errors

  setClass("uhtsdfoqiuerhzb", slots=c(a='integer'))

  on.exit(
    {
      options(old.opt.2)
      unitizer_cleanup_demo()
    },
    add=TRUE
  )
  # Run tests

  test.filt <- paste(sep="|",
    "browse",
    "capture",
    "change",
    "demo",
    "error",

    "exec",
    "get",
    "global",
    "handledruns",
    "inpkg",
    "ischecks",
    "item",

    "list",
    "misc",

    "options",
    "parse",
    "prompt",
    "rename",

    "repairenvs",
    "random",
    "search",
    "section",
    "shim",

    "state",
    "text",
    "translate",
    "utz1",
    "utz2",
    "upgrade",
    "zzrunlast",
    "not_a_real_test_file"
  )
  # test.filt <- 'state'
  test.res <- if(packageVersion('testthat') > "1.0.2") {
    test_dir(
      "testthat",
      # reporter="check",
      env=environment(),
      filter=test.filt,
      wrap=FALSE
    )
  } else {
    test_dir("testthat", reporter="check", env=environment(), filter=test.filt)
  }
  # Check for failures and throw error if they exist since test_dir does not
  # do so on its own

  # # comment out since with "check" reporter this is moot
  # with(
  #   as.data.frame(test.res), {
  #     fail <- sum(failed)
  #     err <- sum(error)
  #     if(fail != 0 || err) stop("Errors: ", err, " Failures: ", fail)
  # })
})

