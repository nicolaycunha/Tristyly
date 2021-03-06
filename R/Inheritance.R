#' Inheritance
#'
#' @name Inheritance
NULL

#' @describeIn Inheritance Create a matrix summaring gametes produced
#'     by each genotype, allowing for arbitrary recombination between
#'     the S and M loci.
#' @param r numeric(1) recombination rate, between 0 (complete
#'     linkage) and 1 (free recombination).
#' @examples
#' G(0)
#' G(1)
#' G(.1)
#' @export
G <- function(r = 0) {
    stopifnot(is.numeric(r), length(r) == 1L, !is.na(r), r >= 0, r <= 1)
    (1 - r) * G0 + r * G1
}

#' @describeIn Inheritance Create initial, approximately isoplethic,
#'     genotype frequencies in standard form.
#' @param N missing or integer(1). When missing, return genotype
#'     frequencies in populations at approximate isoplethic
#'     equilibirum. Otherwise, return a sample of size \code{n} drawn
#'     from a poualation at approximate isoplethy.
#' @return A vector of genotype frequencies (i.e., non-negative values
#'     summing to 1)
#' @examples
#' isoplethy()     # approximate isoplethy
#' isoplethy(100)  # sample from isoplethic population
#' @export
isoplethy <- function(N) {
    gtype <- setNames(
        c(0.333333333333333, 0.309401076758503, 0.0239322565748303,
          0.122008467928146, 0.122008467928146, 0.0446581987385205,
          0.0446581987385205, 0, 0, 0),
        genetics$Genotype)
    if (!missing(N))
        gtype <- .sample(gtype, N)
    gtype
}

.sample <- function(gtype, N)
    rmultinom(1L, N, gtype)[, 1L]

#' @describeIn Inheritance Create a vector of genotype frequencies in
#'     standard form.
#' @param gtype named numeric() vector of genotype frequencies. The
#'     vector must have at least one positive value; it cannot contain
#'     NAs. The names of the vector correspond to the \code{Genotype}
#'     column of the \code{genetics} data object; names cannot be
#'     duplicated. If missing, genotypes are set to approximate
#'     isoplethy under complete disassortative mating.
#' @export
as_genotype <- function(gtype) {
    .stopifnot_is_gtype(gtype)
    .as_genotype(gtype)
}

.as_genotype <- function(gtype) {
    ## place frequencies in standard form
    result <- setNames(numeric(nrow(genetics)), genetics$Genotype)
    result[names(gtype)] <- gtype
    result / sum(result)
}

.stopifnot_is_gtype <- function(gtype) {
    stopifnot(
        is.numeric(gtype), length(gtype) != 0, !anyNA(gtype),
        !is.null(names(gtype)), !anyDuplicated(names(gtype)),
        all(names(gtype) %in% genetics$Genotype),
        all(gtype >= 0),
        sum(gtype) > 0)
}

.gamete_frequency <- function(gtype, G)
    G * gtype

.gamete_frequency_by_morph <- function(gtype, G) {
    gametes <- .gamete_frequency(gtype, G)
    rowsum(gametes, genetics$Morph, reorder=FALSE)
}
