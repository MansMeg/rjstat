context("subset")

test_that("subset do not distort ams.json", {
    x1 <- as.jsonstat("ams.json")
    x1_labs <- lapply(x1$dimension, function(X) names(X$category))
    x2 <- x1[1,,,,,]
    x2_labs <- lapply(x2$dimension, function(X) names(X$category))
    expect_equal(x1_labs, x2_labs)
})


test_that("subset do not distort ams2.json", {
    x <- x1 <- as.jsonstat("ams2.json")
    x1_labs <- lapply(x1$dimension, function(X) names(X$category))
    x2 <- x1[1,,,,,]
    x2_labs <- lapply(x2$dimension, function(X) names(X$category))
    x1$dimension$timepoint$category
    x2$dimension$timepoint$category
    expect_equal(x1_labs, x2_labs)
})
