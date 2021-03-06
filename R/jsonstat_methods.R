#' @export
print.jsonstat <- function(x, ...){
    cat("JSON-stat ", x$class, " object v.", x$version, sep = "")
}

#' @export
print.jsonstat_dataset <- function(x, ...){
    NextMethod(x)
    if(!is.null(x$label)) cat("\n", x$label, sep="")
    cat("\ndimensions: ")
    cat(paste(x$id, "(", x$size, ")", sep=""), sep = ", ")
}

#' @export
dim.jsonstat_dataset <- function(x){
    x$size
}

#' @export
dimnames.jsonstat_dataset <- function(x){
    lapply(x$dimension,
           FUN=function(X) {
               if(is.list(X$category$index)){
                   idx <- names(sort(unlist(X$category$index)))
               } else if(is.vector(X$category$index)){
                   idx <- X$category$index
               } else if(is.null(X$category$index)) {
                   idx <- names(X$category$label)
               } else {stop("No dimension index")}
               idx
               })
}

#' @export
`dimnames<-.jsonstat_dataset` <- function (x, value){
    checkmate::assert_set_equal(names(value), names(dimnames(x)), ordered = TRUE)

    for(i in seq_along(names(value))){ # i <- 4
        var_name <- names(value)[i]
        has_label <- !is.null(x$dimension[[var_name]]$category$label)
        has_index <- !is.null(x$dimension[[var_name]]$category$index)

        if(has_index){
            idx <- as.list(0:(length(value[[i]])-1))
            names(idx) <- value[[i]]
            x$dimension[[var_name]]$category$index <- idx
        }
        if(has_label){
            lab_idx <- names(x$dimension[[var_name]]$category$label) %in% value[[i]]
            labs <- x$dimension[[var_name]]$category$label[lab_idx]
            new_labs <- !value[[i]] %in% names(x$dimension[[var_name]]$category$label)
            if(any(new_labs)) {
                extra_lab <- as.list(rep("", sum(new_labs)))
                names(extra_lab) <- value[[i]][new_labs]
                labs <- c(labs, extra_lab)
            }
            x$dimension[[var_name]]$category$label <- labs
        }
    }
    x
}

#' @export
as.array.jsonstat_dataset <- function(x, ...){
    a <- array(data = x$value, dim = rev(x$size), dimnames = dimnames(x)[rev(x$id)])
    aperm(a, length(dim(a)):1)
}

#' @export
`[.jsonstat_dataset` <- function(x, i, ..., drop = FALSE)
{
    jsarray <- as.array(x)
    subs <- array_to_jsonstat_helper(jsarray[i, ..., drop = drop])
    x$size <- subs$size
    x$value <- subs$value
    dimnames(x) <- subs$dimnames
    x
}

#' @export
`[[.jsonstat_dataset` <- function(x, i, ...)
{
    jsarray <- as.array(x)
    jsarray[i, ..., drop=FALSE]
}

array_to_jsonstat_helper <- function(jsa){
    res <- list()
    res$size <- dim(jsa)
    res$value <- as.vector(aperm(jsa, length(dim(jsa)):1))
    res$dimnames <- dimnames(jsa)
    res
}

#' @export
`[<-.jsonstat_dataset` <- function(x, i, ..., value){
    jsarray <- as.array(x)
    jsarray[i, ...] <- value
    subs <- array_to_jsonstat_helper(jsarray)
    x$value <- subs$value
    x
}

#' @export
as.data.frame.jsonstat_dataset <- function(x, row.names = NULL, optional = FALSE, ..., stringsAsFactors = default.stringsAsFactors()){
    df <- parse_dataset(dataset = x, naming = "id", use_factors = stringsAsFactors)
    if(!is.null(row.names)) rownames(df) <- row.names
    df
}

#' @export
as.character.jsonstat <- function(x, ...){
    as.character(as.json(x, ...))
}

#' Convert to jsonlite json object
#'
#' @param x an object to coerce to a json object.
#' @param ... additional arguments to be passed to or from methods.
#'
#' @details Currently only methods for \code{jsonstat} objects are implemented.
#'
#' @export
as.json <- function(x, ...){
    UseMethod("as.json")
}

#' @export
as.json.jsonstat <- function(x, ...){
    jsonlite::toJSON(unbox(x), na = "null", pretty = TRUE, digits = parse_digits(x$value), ...)
}

parse_digits <-function(x){
    l <- strsplit(x = as.character(x), "\\.")
    has_decimals <- unlist(lapply(l, FUN=length)) > 1
    if(any(has_decimals)){
        max(unlist(lapply(l[has_decimals], FUN=function(X) nchar(X[[2]]))))
    } else {
        0
    }
}

#' Unbox generic function
#'
#' @details
#' This is a generic function to unbox more general objects,
#' such as \code{jsonstat} objects.
#' See \code{\link[jsonlite]{unbox}} for mor general information.
#'
#' @param x an object to unbox
#'
#' @seealso \code{\link[jsonlite]{unbox}}
#'
#' @export
unbox <- function(x){
    UseMethod("unbox")
}

#' @export
unbox.default <- function(x){
    jsonlite::unbox(x)
}

#' @export
unbox.jsonstat <- function(x){
    x$version <- unbox(x$version)
    x$class <- unbox(x$class)
    if(!is.null(x$label)) x$label <- unbox(x$label)
    if(!is.null(x$href)) x$href <- unbox(x$href)
    if(!is.null(x$source)) x$source <- unbox(x$source)
    if(!is.null(x$updated)) x$updated <- unbox(x$updated)
    if(!is.null(x$status) && is.list(x$status)){
        x$status <- lapply(x$status, unbox)
    }

    for(i in seq_along(x$dimension)){
        x$dimension[[i]]$label <- unbox(x$dimension[[i]]$label)
        for(j in seq_along(x$dimension[[i]]$category$label)){
            x$dimension[[i]]$category$label[[j]] <- unbox(x$dimension[[i]]$category$label[[j]])
        }
        for(j in seq_along(x$dimension[[i]]$category$index)){
            x$dimension[[i]]$category$index[[j]] <- unbox(x$dimension[[i]]$category$index[[j]])
        }
    }
    x
}

#' @S3method as.vector jsonstat_dataset
as.vector.jsonstat_dataset <- function(x, mode = "any"){
    as.vector(x$value, mode)
}
