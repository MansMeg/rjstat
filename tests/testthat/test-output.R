context("Output")

test_that("single-dimension input gives correct output", {
    txt <- "{\"version\":\"2.0\",\"class\":\"dataset\",\"id\":[\"V1\"],\"size\":[1],\"value\":[1],\"dimension\":{\"V1\":{\"category\":{\"index\":[\"a\"]}}}}"
    expect_identical(toJSONstat(data.frame(V1 = "a", value = 1)),
                     structure(txt, class = "json"))
})

test_that("sparse cubes give correct output", {
    txt <- "{\"version\":\"2.0\",\"class\":\"dataset\",\"id\":[\"V1\",\"V2\"],\"size\":[2,2],\"value\":{\"0\":1,\"3\":2},\"dimension\":{\"V1\":{\"category\":{\"index\":[\"a\",\"b\"]}},\"V2\":{\"category\":{\"index\":[\"A\",\"B\"]}}}}"
    expect_identical(toJSONstat(data.frame(V1 = c("a", "b"), V2 = c("A", "B"),
                                           value = 1:2)),
                     structure(txt, class = "json"))
    expect_equal(fromJSONstat(txt),
                 data.frame(V1 = c("a", "a", "b", "b"),
                            V2 = c("A", "B", "A", "B"),
                            value = c(1, NA, NA, 2),
                            stringsAsFactors = FALSE))
    txt2 <- "{\"version\":\"2.0\",\"class\":\"dataset\",\"id\":[\"V1\",\"V2\"],\"size\":[2,2],\"value\":{\"0\":true,\"3\":false},\"dimension\":{\"V1\":{\"category\":{\"index\":[\"a\",\"b\"]}},\"V2\":{\"category\":{\"index\":[\"A\",\"B\"]}}}}"
    expect_identical(toJSONstat(data.frame(V1 = c("a", "b"), V2 = c("A", "B"),
                                           value = c(TRUE, FALSE))),
                     structure(txt2, class = "json"))
    expect_equal(fromJSONstat(txt2),
                 data.frame(V1 = c("a", "a", "b", "b"),
                            V2 = c("A", "B", "A", "B"),
                            value = c(TRUE, NA, NA, FALSE),
                            stringsAsFactors = FALSE))
})

test_that("value objects give correct output", {
    df1 <- data.frame(V1 = factor(letters[1], letters), value = 1)
    txt1 <- toJSONstat(df1)
    expect_equal(fromJSONstat(txt1, use_factors = TRUE),
                 data.frame(V1 = letters,
                            value = c(1, rep(NA, 25))))
    df2 <- data.frame(V1 = factor(letters[1:2], letters), value = 1:2)
    txt2 <- toJSONstat(df2)
    expect_equal(fromJSONstat(txt2, use_factors = TRUE),
                 data.frame(V1 = letters,
                            value = c(1:2, rep(NA, 24))))
})

test_that("named and unnamed lists give the same output", {
    d <- cbind(expand.grid(letters, LETTERS), value = seq_len(676))
    expect_equal(toJSONstat(list(d)), toJSONstat(list(d = d)))
})
