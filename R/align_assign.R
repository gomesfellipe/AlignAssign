capture <- function() {
  # Get context
  rstudioapi::getActiveDocumentContext()
}

captureArea <- function(capture) {
  # Find range
  range_start <- capture$selection[[1L]]$range$start[[1L]]
  range_end   <- capture$selection[[1L]]$range$end[[1L]]

  # Dump contents and use highlighted lines as names.
  contents        <- capture$contents[range_start:range_end]
  names(contents) <- range_start:range_end
  return(contents)
}

findRegEx <- function(find, where) {

  # Find matches, extract positions, find furthest <-, get rows/cols to align.
  matched.rows <- grep(find, where)
  positions <- regexec(find, where)
  positions <- positions[matched.rows]

  lines.highlighted <- as.integer(names(where))
  matched.cols      <- sapply(positions, `[[`, 1L)
  which.max.col     <- which.max(matched.cols)

  furthest_row    <- lines.highlighted[matched.rows[which.max.col]]
  furthest_column <- max(matched.cols)

  return(list(matched.rows      = matched.rows,
              matched.cols      = matched.cols,
              lines.highlighted = lines.highlighted,
              which.max.col     = which.max.col,
              furthest_column   = furthest_column))
}

assembleInsert <-function(info) {
  # Unload variables
  matched.rows      <- info$matched.rows
  matched.cols      <- info$matched.cols
  lines.highlighted <- info$lines.highlighted
  which.max.col     <- info$which.max.col
  furthest_column   <- info$furthest_column

  # Find the rows to align and the current column position of each regEx match.
  rows_to_align    <- lines.highlighted[matched.rows[-which.max.col]]
  columns_to_align <- matched.cols[-which.max.col]

  # Set location for spaces to be inserted.
  location <- Map(c, rows_to_align, columns_to_align)

  # Find and set the number of spaces to insert on each line.
  text_num <- furthest_column - columns_to_align
  text     <- vapply(text_num,
                     function(x) paste0(rep(" ", x), collapse = ""),
                     character(1))

  return(list(location = location, text = text))
}

insertr <- function(list) {
  rstudioapi::insertText(list[["location"]], list[["text"]])
}

#' Align a highlighted region's assignment operators.
#'
#' @return
#' Aligns the single caret operators (\code{<-}) within a highlighted region.
#' @export
alignAssign <- function() {
  capture <- capture()
  area    <- captureArea(capture)
  loc     <- findRegEx("<-", area)
  insertList <- assembleInsert(loc)
  insertr(insertList)
}

#' Align a highlighted region's assignment operators.
#'
#' @return Aligns the equal sign assignment operators (\code{=}) within a
#' highlighted region.
#' @export
alignAssign2 <- function() {
  capture <- capture()
  area    <- captureArea(capture)
  loc     <- findRegEx("=", area)
  insertList <- assembleInsert(loc)
  insertr(insertList)
}

#' Align a highlighted region's assignment operators.
#'
#' @return Aligns the equal sign assignment operators (\code{=}) within a
#' highlighted region.
#' @export
alignAssign3 <- function() {
  capture <- capture()
  area    <- captureArea(capture)
  loc     <- findRegEx("#", area)
  insertList <- assembleInsert(loc)
  insertr(insertList)
}
