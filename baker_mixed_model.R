# ============================================================
# GBBO latent baker ability and season balance model
# ============================================================
# Purpose:
#   1. Load cleaned GBBO judging data.
#   2. Stack judged component scores into long format.
#   3. Fit a linear mixed-effects model for adjusted baker performance.
#   4. Extract baker, series, and episode effects.
#   5. Summarise season balance using fitted baker effects.
# ============================================================


# ------------------------------------------------------------
# 0. Setup
# ------------------------------------------------------------

set.seed(489)
options(digits = 3)

library(tidyverse)
library(lme4)
library(knitr)
library(kableExtra)

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

judging <- full_cln_dat

judging_summary <- judging %>%
  summarise(
    n_rows = n(),
    n_series = n_distinct(series),
    n_episodes = n_distinct(episode),
    n_bakers = n_distinct(baker_id)
  )

judging_summary


# ------------------------------------------------------------
# 2. Stack score components into long format
# ------------------------------------------------------------

score_long <- judging %>%
  ungroup() %>%
  mutate(
    series = factor(series),
    round = as.numeric(round),
    round_std = as.numeric(scale(round)),
    episode = factor(episode),
    
    # Keep technical direction aligned with judged component scores:
    # higher values mean stronger performance.
    tech_rank_scaled = (1 / 3) * tech_rank_scaled
  ) %>%
  pivot_longer(
    cols = c(
      signature_bake,
      signature_flavor,
      signature_looks,
      showstopper_bake,
      showstopper_flavor,
      showstopper_looks,
      tech_rank_scaled
    ),
    names_to = "component",
    values_to = "score"
  ) %>%
  mutate(
    component = factor(component),
    score = as.numeric(score),
    score_ord = ordered(score)
  ) %>%
  filter(!is.na(score)) %>%
  arrange(series, round, contestant, component)


# ------------------------------------------------------------
# 3. Fit mixed-effects model
# ------------------------------------------------------------
# Baker random intercepts estimate adjusted average performance.
# Episode random intercepts absorb episode-level scoring context.
# Series and component are fixed effects.

fit_score_lmm_series_fixed <- lmer(
  score ~ 1 + component + series +
    (1 | baker_id) +
    (1 | episode),
  data = score_long
)

summary(fit_score_lmm_series_fixed)

random_effects <- ranef(fit_score_lmm_series_fixed)


# ------------------------------------------------------------
# 4. Baker effects
# ------------------------------------------------------------

baker_lookup <- judging %>%
  select(
    baker_id,
    contestant,
    series,
    series_winner,
    eliminated_round
  ) %>%
  distinct(baker_id, .keep_all = TRUE)

baker_effects_freq <- random_effects$baker_id %>%
  as.data.frame() %>%
  rownames_to_column("baker_id") %>%
  rename(theta_hat = `(Intercept)`) %>%
  left_join(baker_lookup, by = "baker_id") %>%
  mutate(
    series = as.integer(series),
    series_winner = as.integer(series_winner),
    theta_hat = as.numeric(theta_hat)
  ) %>%
  arrange(desc(theta_hat))

baker_effects_freq


# ------------------------------------------------------------
# 5. Series fixed effects
# ------------------------------------------------------------
# The first series is the reference level, so its effect is set to 0.

series_effects_freq <- fixef(fit_score_lmm_series_fixed) %>%
  enframe(name = "term", value = "estimate") %>%
  filter(term == "(Intercept)" | str_detect(term, "^series")) %>%
  mutate(
    series = case_when(
      term == "(Intercept)" ~ levels(score_long$series)[1],
      TRUE ~ str_remove(term, "^series")
    ),
    series = as.integer(series),
    series_effect_hat = if_else(term == "(Intercept)", 0, estimate)
  ) %>%
  select(series, series_effect_hat) %>%
  arrange(desc(series_effect_hat))

series_effects_freq


# ------------------------------------------------------------
# 6. Episode effects
# ------------------------------------------------------------
# These are less stable than baker effects because there are many episodes
# relative to the amount of information per episode.

episode_lookup <- score_long %>%
  mutate(episode = as.character(episode)) %>%
  distinct(episode, series, round)

episode_effects_freq <- random_effects$episode %>%
  as.data.frame() %>%
  rownames_to_column("episode") %>%
  rename(episode_effect_hat = `(Intercept)`) %>%
  mutate(episode = as.character(episode)) %>%
  left_join(episode_lookup, by = "episode") %>%
  arrange(episode_effect_hat)

episode_effects_freq


# ------------------------------------------------------------
# 7. Season balance from baker effects
# ------------------------------------------------------------
# This is descriptive. It is not a causal measure of cast strength.
# It summarizes how separated the strongest adjusted bakers were within series.

season_balance <- baker_effects_freq %>%
  group_by(series) %>%
  arrange(desc(theta_hat), .by_group = TRUE) %>%
  mutate(
    within_season_rank = row_number(),
    n_bakers = n()
  ) %>%
  summarise(
    n_bakers = first(n_bakers),
    
    prop_positive_effect = mean(theta_hat > 0, na.rm = TRUE),
    sd_effect = sd(theta_hat, na.rm = TRUE),
    
    top_baker = contestant[which.max(theta_hat)],
    top_effect = max(theta_hat, na.rm = TRUE),
    
    second_baker = contestant[order(theta_hat, decreasing = TRUE)[2]],
    second_effect = theta_hat[order(theta_hat, decreasing = TRUE)[2]],
    
    third_baker = contestant[order(theta_hat, decreasing = TRUE)[3]],
    third_effect = theta_hat[order(theta_hat, decreasing = TRUE)[3]],
    
    winner = contestant[series_winner == 1][1],
    winner_effect = theta_hat[series_winner == 1][1],
    winner_rank = within_season_rank[series_winner == 1][1],
    
    best_nonwinner = contestant[series_winner == 0][
      which.max(theta_hat[series_winner == 0])
    ],
    best_nonwinner_effect = max(theta_hat[series_winner == 0], na.rm = TRUE),
    best_nonwinner_rank = within_season_rank[series_winner == 0][
      which.max(theta_hat[series_winner == 0])
    ],
    
    winner_vs_best_nonwinner_gap =
      winner_effect - best_nonwinner_effect,
    
    top3_spread = top_effect - third_effect,
    
    full_range =
      max(theta_hat, na.rm = TRUE) - min(theta_hat, na.rm = TRUE),
    
    top4_minus_bottom4 =
      mean(head(theta_hat, 4), na.rm = TRUE) -
      mean(tail(theta_hat, 4), na.rm = TRUE),
    
    .groups = "drop"
  ) %>%
  arrange(desc(winner_vs_best_nonwinner_gap))

season_balance


# ------------------------------------------------------------
# 8. Display version of season balance table
# ------------------------------------------------------------

season_balance_display <- season_balance %>%
  mutate(
    winner_rank = paste0(winner_rank, " of ", n_bakers),
    best_nonwinner_rank = paste0(best_nonwinner_rank, " of ", n_bakers),
    
    prop_positive_effect = sprintf("%.1f%%", 100 * prop_positive_effect),
    sd_effect = sprintf("%.3f", sd_effect),
    
    top_effect = sprintf("%+.3f", top_effect),
    winner_effect = sprintf("%+.3f", winner_effect),
    best_nonwinner_effect = sprintf("%+.3f", best_nonwinner_effect),
    winner_vs_best_nonwinner_gap = sprintf("%+.3f", winner_vs_best_nonwinner_gap),
    
    top3_spread = sprintf("%.3f", top3_spread),
    full_range = sprintf("%.3f", full_range),
    top4_minus_bottom4 = sprintf("%.3f", top4_minus_bottom4)
  ) %>%
  arrange(top3_spread) %>%
  select(
    Series = series,
    Winner = winner,
    `Winner Effect` = winner_effect,
    `Winner Rank` = winner_rank,
    `Best Non-Winner` = best_nonwinner,
    `Best Non-Winner Effect` = best_nonwinner_effect,
    `Best Non-Winner Rank` = best_nonwinner_rank,
    `Winner - Best Non-Winner` = winner_vs_best_nonwinner_gap,
    `% Positive Effects` = prop_positive_effect,
    `SD Effect` = sd_effect,
    `Top 3 Spread` = top3_spread,
    `Full Range` = full_range,
    `Top 4 - Bottom 4` = top4_minus_bottom4
  )

season_balance_display


# ------------------------------------------------------------
# 9. Formatted table
# ------------------------------------------------------------

knitr::kable(
  season_balance_display,
  align = c("c", "c", "l", "c", "l", "c", "c", "l", "c", "c", "c", "c", "c"),
  caption = "Season balance based on fitted baker effects"
) %>%
  kableExtra::kable_styling(
    full_width = FALSE,
    position = "center",
    bootstrap_options = c("striped", "hover", "condensed")
  )