# ============================================================
# Great British Bake Off full_cln_dat models and validation
# ============================================================
# Purpose:
#   1. Build episode-level risk sets for Star Baker and elimination.
#   2. Fit conditional logistic regression models.
#   3. Estimate round-specific associations using round interactions.
#   4. Validate predictions using leave-one-episode-out cross-validation.
#   5. Summarise final-winner predictions and simple descriptive patterns.
# ============================================================

# ------------------------------------------------------------
# 0. Setup
# ------------------------------------------------------------

set.seed(489)
options(digits = 3)

library(tidyverse)
library(survival)
library(yardstick)
library(knitr)

theme_set(theme_bw())


# ------------------------------------------------------------
# 1. Load and prepare data
# ------------------------------------------------------------

full_cln_dat <- readr::read_csv(
  "data/full_cln_gbbo.csv",
  col_types = readr::cols(
    episode = readr::col_character(),
    .default = readr::col_guess()
  )
)

full_cln_dat_summary <- full_cln_dat %>%
  summarise(
    n_rows = n(),
    n_series = n_distinct(series),
    n_episodes = n_distinct(episode),
    n_bakers = n_distinct(baker_id)
  )

full_cln_dat_summary

# Star Baker risk sets: use rounds 1-10 because round 10 Star Baker is the winner.
full_cln_dat_sb <- full_cln_dat %>%
  filter(round <= 10, !is.na(star_baker)) %>%
  group_by(episode) %>%
  filter(n() > 1, sum(star_baker, na.rm = TRUE) == 1) %>%
  ungroup() %>%
  mutate(round_c = round - 1)

# Elimination risk sets: exclude round 10 because the final is not a normal elimination.
full_cln_dat_elim <- full_cln_dat %>%
  filter(round <= 9, !is.na(eliminated)) %>%
  group_by(episode) %>%
  filter(n() > 1, sum(eliminated, na.rm = TRUE) == 1) %>%
  ungroup() %>%
  mutate(round_c = round - 1)


# ------------------------------------------------------------
# 2. Conditional logistic models
# ------------------------------------------------------------
# Episode strata force within-episode comparisons.

fit_clogit_model <- function(outcome, dat, rhs) {
  fml <- as.formula(paste0(outcome, " ~ ", rhs, " + strata(episode)"))
  clogit(fml, data = dat, method = "exact")
}

rhs_base <- "sig_sum + showstopper_sum + tech_rank"

rhs_interact <- paste(
  rhs_base,
  "sig_sum:round_c + showstopper_sum:round_c + tech_rank:round_c",
  sep = " + "
)

fit_sb_clogit <- fit_clogit_model(
  outcome = "star_baker",
  dat = full_cln_dat_sb,
  rhs = rhs_base
)

fit_elim_clogit <- fit_clogit_model(
  outcome = "eliminated",
  dat = full_cln_dat_elim,
  rhs = rhs_base
)

fit_sb_round_interact <- fit_clogit_model(
  outcome = "star_baker",
  dat = full_cln_dat_sb,
  rhs = rhs_interact
)

fit_elim_round_interact <- fit_clogit_model(
  outcome = "eliminated",
  dat = full_cln_dat_elim,
  rhs = rhs_interact
)

summary(fit_sb_clogit)
summary(fit_elim_clogit)
summary(fit_sb_round_interact)
summary(fit_elim_round_interact)


# ------------------------------------------------------------
# 3. Round-specific odds-ratio helpers
# ------------------------------------------------------------
# With round_c = round - 1, main effects correspond to round 1 associations.

get_round_slopes <- function(fit, dat) {
  coef_fit <- coef(fit)
  vcov_fit <- vcov(fit)
  
  round_grid <- tibble(
    round = sort(unique(dat$round)),
    round_c = round - 1
  )
  
  get_one_slope <- function(main, interaction, label, invert = FALSE, multiplier = 1) {
    beta <- coef_fit[[main]]
    gamma <- coef_fit[[interaction]]
    
    var_beta <- vcov_fit[main, main]
    var_gamma <- vcov_fit[interaction, interaction]
    cov_bg <- vcov_fit[main, interaction]
    
    round_grid %>%
      mutate(
        term = label,
        slope_raw = beta + round_c * gamma,
        slope = multiplier * if_else(invert, -slope_raw, slope_raw),
        se_raw = sqrt(var_beta + round_c^2 * var_gamma + 2 * round_c * cov_bg),
        se = multiplier * se_raw,
        lower = slope - 1.96 * se,
        upper = slope + 1.96 * se,
        exp_slope = exp(slope),
        exp_lower = exp(lower),
        exp_upper = exp(upper)
      )
  }
  
  bind_rows(
    get_one_slope("sig_sum", "sig_sum:round_c", "Signature"),
    get_one_slope("showstopper_sum", "showstopper_sum:round_c", "Showstopper"),
    get_one_slope(
      "tech_rank",
      "tech_rank:round_c",
      "Technical rank improvement\n2 slots",
      invert = TRUE,
      multiplier = 2
    )
  )
}

find_crossings <- function(dat, reference_term, reference_label) {
  ref <- dat %>%
    filter(term == reference_term) %>%
    select(round, ref_exp_slope = exp_slope)
  
  dat %>%
    filter(term != reference_term) %>%
    left_join(ref, by = "round") %>%
    group_by(term) %>%
    arrange(round, .by_group = TRUE) %>%
    mutate(
      diff = exp_slope - ref_exp_slope,
      diff_next = lead(diff),
      round_next = lead(round),
      exp_slope_next = lead(exp_slope),
      crosses_ref = diff == 0 | diff * diff_next < 0,
      cross_round = round +
        (0 - diff) * (round_next - round) / (diff_next - diff),
      cross_exp_slope = exp_slope +
        (cross_round - round) *
        (exp_slope_next - exp_slope) / (round_next - round),
      direction = if_else(diff_next < 0, "below", "above")
    ) %>%
    filter(crosses_ref) %>%
    ungroup() %>%
    mutate(
      reference = reference_term,
      crossing_type = paste(reference_label, direction, sep = ": ")
    )
}

make_crossing_points <- function(round_slopes) {
  bind_rows(
    find_crossings(
      round_slopes,
      reference_term = "Showstopper",
      reference_label = "Crosses Showstopper"
    ),
    find_crossings(
      round_slopes,
      reference_term = "Technical rank improvement\n2 slots",
      reference_label = "Crosses Technical"
    )
  ) %>%
    mutate(
      crossing_type = factor(
        crossing_type,
        levels = c(
          "Crosses Showstopper: below",
          "Crosses Showstopper: above",
          "Crosses Technical: below",
          "Crosses Technical: above"
        )
      )
    )
}

plot_round_slopes <- function(round_slopes, cross_pts, max_round, title) {
  ggplot(round_slopes, aes(x = round, y = exp_slope)) +
    geom_hline(yintercept = 1, linetype = "dashed") +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_point(
      data = cross_pts,
      aes(x = cross_round, y = cross_exp_slope, color = crossing_type),
      size = 3,
      inherit.aes = FALSE
    ) +
    scale_color_manual(
      values = c(
        "Crosses Showstopper: below" = "darkred",
        "Crosses Showstopper: above" = "salmon",
        "Crosses Technical: below" = "darkorange3",
        "Crosses Technical: above" = "moccasin"
      ),
      name = "Crossing direction"
    ) +
    facet_wrap(~ term) +
    scale_x_continuous(breaks = seq_len(max_round)) +
    labs(
      x = "Round",
      y = "Round-specific odds ratio",
      title = title,
      subtitle = "Signature/showstopper are +1 score point; technical is improvement by 2 ranks"
    ) +
    theme_minimal(base_size = 13) +
    theme(legend.position = "bottom")
}

round_slopes_sb <- get_round_slopes(fit_sb_round_interact, full_cln_dat_sb)
round_slopes_elim <- get_round_slopes(fit_elim_round_interact, full_cln_dat_elim)

cross_pts_sb <- make_crossing_points(round_slopes_sb)
cross_pts_elim <- make_crossing_points(round_slopes_elim)

plot_round_slopes(
  round_slopes = round_slopes_sb,
  cross_pts = cross_pts_sb,
  max_round = 10,
  title = "Round-specific associations with Star Baker"
)

plot_round_slopes(
  round_slopes = round_slopes_elim,
  cross_pts = cross_pts_elim,
  max_round = 9,
  title = "Round-specific associations with elimination"
)


# ------------------------------------------------------------
# 4. Prediction helpers
# ------------------------------------------------------------

softmax_by_episode <- function(data, lp, outcome) {
  data %>%
    mutate(lp = {{ lp }}) %>%
    group_by(episode) %>%
    mutate(
      pred_prob = exp(lp - max(lp, na.rm = TRUE)) /
        sum(exp(lp - max(lp, na.rm = TRUE)), na.rm = TRUE),
      pred_rank = rank(-pred_prob, ties.method = "first"),
      actual = as.integer(.data[[outcome]])
    ) %>%
    ungroup()
}

predict_episode_probs <- function(model, data, outcome) {
  softmax_by_episode(
    data = data,
    lp = as.numeric(predict(model, newdata = data, type = "lp")),
    outcome = outcome
  )
}

make_test_design <- function(rhs, test, coef_names) {
  x_test <- model.matrix(as.formula(paste0("~ ", rhs)), data = test)
  x_test <- x_test[, colnames(x_test) != "(Intercept)", drop = FALSE]
  
  missing_cols <- setdiff(coef_names, colnames(x_test))
  
  if (length(missing_cols) > 0) {
    x_test <- cbind(
      x_test,
      matrix(
        0,
        nrow = nrow(x_test),
        ncol = length(missing_cols),
        dimnames = list(NULL, missing_cols)
      )
    )
  }
  
  x_test[, coef_names, drop = FALSE]
}

loo_episode_predict <- function(data, outcome, rhs) {
  form <- as.formula(paste0(outcome, " ~ ", rhs, " + strata(episode)"))
  
  map_dfr(sort(unique(data$episode)), function(ep) {
    train <- filter(data, episode != ep)
    test <- filter(data, episode == ep)
    
    fit <- clogit(form, data = train, method = "exact")
    beta_hat <- coef(fit)
    beta_hat <- beta_hat[!is.na(beta_hat)]
    
    x_test <- make_test_design(rhs, test, names(beta_hat))
    
    softmax_by_episode(
      data = test,
      lp = as.numeric(x_test %*% beta_hat),
      outcome = outcome
    )
  })
}


# ------------------------------------------------------------
# 5. In-sample and leave-one-episode-out predictions
# ------------------------------------------------------------

pred_sb_in_sample <- predict_episode_probs(
  model = fit_sb_clogit,
  data = full_cln_dat_sb,
  outcome = "star_baker"
)

pred_elim_in_sample <- predict_episode_probs(
  model = fit_elim_clogit,
  data = full_cln_dat_elim,
  outcome = "eliminated"
)

pred_sb_loo_interact <- loo_episode_predict(
  data = full_cln_dat_sb,
  outcome = "star_baker",
  rhs = rhs_interact
)

pred_elim_loo_interact <- loo_episode_predict(
  data = full_cln_dat_elim,
  outcome = "eliminated",
  rhs = rhs_interact
)


# ------------------------------------------------------------
# 6. Cross-validated prediction summaries
# ------------------------------------------------------------

make_binary_prediction_data <- function(pred_data) {
  pred_data %>%
    mutate(
      truth = factor(if_else(actual == 1, "yes", "no"), levels = c("yes", "no")),
      pred_class = factor(if_else(pred_rank == 1, "yes", "no"), levels = c("yes", "no"))
    )
}

summarise_predictions <- function(pred_data) {
  ranking_metrics <- pred_data %>%
    group_by(episode) %>%
    summarise(
      actual_rank = pred_rank[actual == 1],
      actual_prob = pred_prob[actual == 1],
      top1_correct = actual_rank == 1,
      top2_correct = actual_rank <= 2,
      top3_correct = actual_rank <= 3,
      log_loss = -log(actual_prob),
      .groups = "drop"
    ) %>%
    summarise(
      n_episodes = n(),
      top1_acc = mean(top1_correct),
      top2_acc = mean(top2_correct),
      top3_acc = mean(top3_correct),
      mean_log_loss = mean(log_loss),
      median_actual_rank = median(actual_rank),
      mean_actual_prob = mean(actual_prob),
      .groups = "drop"
    )
  
  binary_data <- make_binary_prediction_data(pred_data)
  
  binary_metrics <- binary_data %>%
    summarise(
      sensitivity = sens_vec(truth, pred_class, event_level = "first"),
      specificity = spec_vec(truth, pred_class, event_level = "first"),
      ppv = ppv_vec(truth, pred_class, event_level = "first"),
      auroc = roc_auc_vec(truth, pred_prob, event_level = "first"),
      auprc = pr_auc_vec(truth, pred_prob, event_level = "first"),
      .groups = "drop"
    )
  
  bind_cols(ranking_metrics, binary_metrics)
}

ranking_metric_table <- bind_rows(
  summarise_predictions(pred_sb_loo_interact) %>% mutate(outcome = "Star Baker"),
  summarise_predictions(pred_elim_loo_interact) %>% mutate(outcome = "Elimination")
) %>%
  select(
    outcome,
    n_episodes,
    top1_acc,
    top2_acc,
    top3_acc,
    sensitivity,
    specificity,
    ppv,
    auroc,
    auprc,
    mean_log_loss,
    median_actual_rank,
    mean_actual_prob
  )

ranking_metric_table
ranking_metric_table %>% select(-mean_log_loss, -median_actual_rank, -mean_actual_prob)


# ------------------------------------------------------------
# 7. Final-winner validation
# ------------------------------------------------------------
# In round 10, Star Baker is the series winner.

finalist_predictions <- pred_sb_loo_interact %>%
  filter(round == 10) %>%
  group_by(series, episode) %>%
  arrange(pred_rank, .by_group = TRUE) %>%
  mutate(
    predicted_winner = pred_rank == 1,
    actual_winner = actual == 1
  ) %>%
  select(series, episode, contestant, pred_rank, pred_prob, predicted_winner, actual_winner) %>%
  ungroup()

final_episode_metrics <- finalist_predictions %>%
  group_by(series, episode) %>%
  summarise(
    n_finalists = n(),
    predicted_winner = contestant[predicted_winner],
    actual_winner = contestant[actual_winner],
    actual_winner_rank = pred_rank[actual_winner],
    actual_winner_prob = pred_prob[actual_winner],
    top1_correct = actual_winner_rank == 1,
    top2_correct = actual_winner_rank <= 2,
    top3_correct = actual_winner_rank <= 3,
    log_loss = -log(actual_winner_prob),
    .groups = "drop"
  )

final_winner_summary <- final_episode_metrics %>%
  summarise(
    n_finals = n(),
    n_correct = sum(top1_correct),
    percent_right = 100 * mean(top1_correct),
    top1_acc = mean(top1_correct),
    top2_acc = mean(top2_correct),
    top3_acc = mean(top3_correct),
    mean_log_loss = mean(log_loss),
    median_actual_rank = median(actual_winner_rank),
    mean_actual_prob = mean(actual_winner_prob),
    .groups = "drop"
  )

final_winner_summary
final_episode_metrics
finalist_predictions


# ------------------------------------------------------------
# 8. Confusion matrices
# ------------------------------------------------------------

make_confusion_matrix_table <- function(pred_data, outcome_label) {
  make_binary_prediction_data(pred_data) %>%
    conf_mat(truth = truth, estimate = pred_class) %>%
    pluck("table") %>%
    as_tibble() %>%
    mutate(outcome = outcome_label, .before = 1)
}

confusion_matrix_table <- bind_rows(
  make_confusion_matrix_table(pred_sb_loo_interact, "Star Baker"),
  make_confusion_matrix_table(pred_elim_loo_interact, "Elimination")
)

confusion_matrix_table

knitr::kable(
  confusion_matrix_table,
  caption = "Leave-one-episode-out confusion matrices"
)


# ------------------------------------------------------------
# 9. Descriptive checks
# ------------------------------------------------------------

best_score_flags <- full_cln_dat_sb %>%
  group_by(series, round) %>%
  mutate(
    best_showstopper_sum = as.integer(
      showstopper_sum == max(showstopper_sum, na.rm = TRUE)
    ),
    best_sig_sum = as.integer(
      sig_sum == max(sig_sum, na.rm = TRUE)
    )
  ) %>%
  ungroup()

showstopper_group_contains_star_baker <- best_score_flags %>%
  group_by(series, round) %>%
  summarise(
    n_best_showstopper_sum = sum(best_showstopper_sum),
    star_baker_in_best_showstopper_group = any(
      best_showstopper_sum == 1 & star_baker == 1
    ),
    .groups = "drop"
  )

showstopper_group_summary <- showstopper_group_contains_star_baker %>%
  summarise(
    n_episodes = n(),
    n_contained_star_baker = sum(star_baker_in_best_showstopper_group),
    prop_contained_star_baker = mean(star_baker_in_best_showstopper_group)
  )

showstopper_group_summary

score_spread_by_episode <- full_cln_dat %>%
  filter(round <= 9) %>%
  group_by(series, round, episode) %>%
  summarise(
    n_bakers = n(),
    sig_sd = sd(sig_sum, na.rm = TRUE),
    sig_iqr = IQR(sig_sum, na.rm = TRUE),
    sig_range = max(sig_sum, na.rm = TRUE) - min(sig_sum, na.rm = TRUE),
    show_sd = sd(showstopper_sum, na.rm = TRUE),
    show_iqr = IQR(showstopper_sum, na.rm = TRUE),
    show_range = max(showstopper_sum, na.rm = TRUE) - min(showstopper_sum, na.rm = TRUE),
    .groups = "drop"
  )

spread_by_round <- score_spread_by_episode %>%
  group_by(round) %>%
  summarise(
    n_episodes = n(),
    mean_n_bakers = mean(n_bakers, na.rm = TRUE),
    mean_sig_sd = mean(sig_sd, na.rm = TRUE),
    mean_sig_iqr = mean(sig_iqr, na.rm = TRUE),
    mean_sig_range = mean(sig_range, na.rm = TRUE),
    mean_show_sd = mean(show_sd, na.rm = TRUE),
    mean_show_iqr = mean(show_iqr, na.rm = TRUE),
    mean_show_range = mean(show_range, na.rm = TRUE),
    .groups = "drop"
  )

spread_by_round
