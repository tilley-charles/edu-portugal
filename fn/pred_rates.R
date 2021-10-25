# CTilley 20211024

# function to calculate statistics on predictions
pred_rates <- function(prediction, reference) {

  df <- tibble(p = as.numeric(prediction==T), r = as.numeric(reference==T)) %>%
        mutate(match = as.numeric(p==r))

  # accuracy
  acc  <- mean(df$match)

  # sensitivity
  sens <- mean(df %>% filter(r==1) %>% pull(match))

  # specificity
  spec <- mean(df %>% filter(r==0) %>% pull(match))

  # precision
  prec <- mean(df %>% filter(p==1) %>% pull(match))

  return(list(acc  = acc,
              sens = sens,
              spec = spec,
              prec = prec))

}
