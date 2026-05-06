# *The Great British Stats Off*: A Statistical Look at *The Great British Bake Off*, Series 5–13 on Netflix

---

> **What actually matters in the tent?**

> **Who were the strongest contenders?**

These are the kinds of questions I had after watching Series 5–13 of *The Great British Bake Off* on Netflix. I wanted to see whether my general impressions about specific events, like Jürgen being eliminated or Jasmine winning the final over Tom, and broader judging patterns, like Showstopper performance seeming to dominate star baker selection, were also supported by the data and maybe discover some new insights into one of my favorite shows

Using data prepared by [Nathan Giusti](https://github.com/nathangiusti/BakeOff), I focus on four questions:

1. Which parts of the competition are most associated with Star Baker?
2. Which parts are most associated with avoiding elimination?
3. How well can simple within-episode models predict judging decisions?
4. Which bakers and seasons stand out after adjustment?

The basic idea is that *Bake Off* is not a collection of independent scores. Each week, the relevant comparison is among the bakers still competing in that episode, not across unrelated weeks or seasons. That structure matters: a baker can have a good week and still be in danger if several others were better, or survive a mediocre week if someone else had a worse one.

I treat judging as a within-episode comparison problem. The weekly Star Baker and elimination decisions are modeled with conditional logistic regression stratified by episode. The adjusted baker summaries come from a linear mixed-effects model with baker and episode random intercepts and fixed effects for series and component type.

The cleaned analysis dataset contains **678 baker-episode rows**, **9 Netflix-era series**, **90 episodes**, and **108 baker-season entries**.

---

## Question 1: How Well Can We Predict Star Baker and Elimination?

The conditional-logit models perform reasonably well at predicting who will be Star Baker or eliminated in a given episode using leave-one-episode-out cross-validation. For elimination, Round 10 is excluded because the final is structurally different: the non-winners are eliminated, so elimination is not the same kind of one-person weekly selection problem. This leaves **73 elimination episodes** out of the full **90 Star Baker episodes**.

<p align="center"><strong>Prediction accuracy: leave-one-episode-out cross-validation</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="24%">Outcome</th>
      <th align="center" width="14%">Episodes</th>
      <th align="center">Top-1 Accuracy</th>
      <th align="center">Top-2 Accuracy</th>
      <th align="center">Top-3 Accuracy</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Star Baker</td>
      <td align="center">90</td>
      <td align="center"><strong>68.9%</strong></td>
      <td align="center"><strong>88.9%</strong></td>
      <td align="center"><strong>98.9%</strong></td>
    </tr>
    <tr>
      <td align="left">Elimination</td>
      <td align="center">73</td>
      <td align="center"><strong>61.6%</strong></td>
      <td align="center"><strong>82.2%</strong></td>
      <td align="center"><strong>94.5%</strong></td>
    </tr>
  </tbody>
</table>

The main prediction results are straightforward:

- For Star Baker, the model ranks the actual Star Baker first in **68.9%** of held-out episodes, in the top two in **88.9%**, and in the top three in **98.9%**.
- For elimination, excluding Round 10, the model ranks the eliminated baker first in **61.6%** of held-out episodes, in the top two in **82.2%**, and in the top three in **94.5%**.
- Restricting to the nine finale episodes, the cross-validated model predicts the eventual series winner as the top finalist in **6 out of 9** seasons, or **66.7%** of the time.


<p align="center"><strong>Final episode winner predictions</strong></p>

<table align="center" cellpadding="10" cellspacing="0" width="98%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35; font-size: 0.95em;">
  <thead>
    <tr>
      <th align="center">Series</th>
      <th align="center">Finalists</th>
      <th align="left">Predicted Winner</th>
      <th align="left">Actual Winner</th>
      <th align="center">Actual Winner Rank</th>
      <th align="center">Actual Winner Probability</th>
      <th align="center">Top-1 Correct?</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">5</td><td align="center">3</td><td align="left">Kate</td><td align="left">Sophie</td><td align="center">2</td><td align="center">0.452</td><td align="center">No</td></tr>
    <tr><td align="center">6</td><td align="center">3</td><td align="left">Rahul</td><td align="left">Rahul</td><td align="center">1</td><td align="center">0.761</td><td align="center">Yes</td></tr>
    <tr><td align="center">7</td><td align="center">3</td><td align="left">David</td><td align="left">David</td><td align="center">1</td><td align="center">0.707</td><td align="center">Yes</td></tr>
    <tr><td align="center">8</td><td align="center">3</td><td align="left">Peter</td><td align="left">Peter</td><td align="center">1</td><td align="center">0.931</td><td align="center">Yes</td></tr>
    <tr><td align="center">9</td><td align="center">3</td><td align="left">Chigs</td><td align="left">Giuseppe</td><td align="center">2</td><td align="center">0.331</td><td align="center">No</td></tr>
    <tr><td align="center">10</td><td align="center">3</td><td align="left">Syabira</td><td align="left">Syabira</td><td align="center">1</td><td align="center">0.995</td><td align="center">Yes</td></tr>
    <tr><td align="center">11</td><td align="center">3</td><td align="left">Matty</td><td align="left">Matty</td><td align="center">1</td><td align="center">0.573</td><td align="center">Yes</td></tr>
    <tr><td align="center">12</td><td align="center">3</td><td align="left">Georgie</td><td align="left">Georgie</td><td align="center">1</td><td align="center">0.962</td><td align="center">Yes</td></tr>
    <tr><td align="center">13</td><td align="center">3</td><td align="left">Tom</td><td align="left">Jasmine</td><td align="center">2</td><td align="center">0.200</td><td align="center">No</td></tr>
  </tbody>
</table>

The three mismatches are Series 5, Series 9, and Series 13. In all three cases, the actual winner was still ranked second by the model, so the finale misses were not random collapses. The model identified the eventual winner as a serious contender, but it put another finalist slightly ahead based on the final episode alone.

The Series 13 final is the clearest example of the distinction between season-long strength and final-episode prediction. Jasmine id the highest-rated baker in the adjusted baker-effect model (below in q4), consistent with her being the strongest baker across the season. But using only the final episode performances, the conditional-logit prediction model ranked Tom as the most likely winner and Jasmine second, with Jasmine assigned a predicted probability of 0.200. That lines up with the common reaction to the finale: Tom looked stronger on the day, while Jasmine's win is easier to defend as a season-long body-of-work decision. In other words, this is not just a model mistake; it reflects a real ambiguity between "best final" and "best overall baker."

Discrimination is also strong. In this setup, Top-1 accuracy is the same as sensitivity because each episode contributes one selected baker.

<p align="center"><strong>Discrimination metrics</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="22%">Outcome</th>
      <th align="center" width="13%">Sensitivity</th>
      <th align="center">Specificity</th>
      <th align="center">PPV</th>
      <th align="center">AUROC</th>
      <th align="center">AUPRC</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Star Baker</td>
      <td align="center">0.689</td>
      <td align="center">0.952</td>
      <td align="center">0.689</td>
      <td align="center"><strong>0.945</strong></td>
      <td align="center"><strong>0.701</strong></td>
    </tr>
    <tr>
      <td align="left">Elimination</td>
      <td align="center">0.616</td>
      <td align="center">0.945</td>
      <td align="center">0.616</td>
      <td align="center"><strong>0.923</strong></td>
      <td align="center"><strong>0.599</strong></td>
    </tr>
  </tbody>
</table>

AUROC has a direct ranking interpretation here: it is the probability that the model assigns a higher predicted probability to a randomly selected true event case than to a randomly selected non-event case. So for Star Baker, AUROC asks whether actual Star Bakers tend to be ranked above non-Star Bakers by predicted Star Baker probability. For elimination, it asks whether eliminated bakers tend to be ranked above non-eliminated bakers by predicted elimination probability.

The ranking metrics are the most natural evaluation criteria here. The question is episode-specific: among the bakers still competing in a given week, who is most likely to be selected?

---

## Question 2: Which Challenges Matter Most for Star Baker?

The baseline Star Baker model uses all 90 episodes. The model is a conditional logistic regression with episode strata, so each comparison is within the relevant weekly risk set.

<p align="center"><strong>Baseline Star Baker model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="22%">Predictor</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="44%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center"><strong>2.046</strong></td>
      <td align="center">1.550 to 2.701</td>
      <td align="left">+1 signature point nearly doubles Star Baker odds.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center"><strong>5.599</strong></td>
      <td align="center">3.282 to 9.552</td>
      <td align="left">+1 showstopper point multiplies Star Baker odds by about 5.6.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center"><strong>0.673</strong></td>
      <td align="center">0.576 to 0.786</td>
      <td align="left">Moving one rank worse lowers Star Baker odds; equivalently, moving one rank better multiplies odds by about 1.49.</td>
    </tr>
  </tbody>
</table>

The result is straightforward: **the Showstopper dominates Star Baker selection** under this model.

Signature and Showstopper sums are on the same component-score scale. Each is the sum of bake, flavor, and appearance-style component scores, so a one-point increase means one additional judged component point. On that common scale, the Showstopper association is much larger: a one-point Showstopper improvement is associated with more than five times the odds of Star Baker, while a one-point Signature improvement is associated with about twice the odds.

Technical rank is different because it is an ordinal within-episode placement. The model reports the effect of moving one rank worse. Reversing the direction, moving one rank better has odds ratio

$$
1/0.673 \approx 1.486,
$$

and moving two ranks better has odds ratio

$$
1.486^2 \approx 2.208.
$$

So technical performance matters, but a one-point Showstopper improvement is still larger than moving several places up in the Technical ranking.

We can also interact each main effect with round, allowing the judging associations to change over the season. The fitted coefficients from this interacted model are below.

<p align="center"><strong>Round-interacted Star Baker model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="98%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35; font-size: 0.95em;">
  <thead>
    <tr>
      <th align="left" width="24%">Predictor</th>
      <th align="center" width="14%">Log-Odds Coef.</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="28%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center">+1.249</td>
      <td align="center"><strong>3.486</strong></td>
      <td align="center">1.727 to 7.039</td>
      <td align="left">Round 1 association; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center">+1.945</td>
      <td align="center"><strong>6.995</strong></td>
      <td align="center">2.337 to 20.940</td>
      <td align="left">Round 1 association; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center">−0.336</td>
      <td align="center">0.714</td>
      <td align="center">0.564 to 0.906</td>
      <td align="left">Round 1 association for moving one Technical rank worse; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Signature × Round</td>
      <td align="center">−0.103</td>
      <td align="center">0.903</td>
      <td align="center">0.799 to 1.019</td>
      <td align="left">Signature association decreases by about 9% per round on the odds-ratio scale.</td>
    </tr>
    <tr>
      <td align="left">Showstopper × Round</td>
      <td align="center">−0.046</td>
      <td align="center">0.955</td>
      <td align="center">0.786 to 1.162</td>
      <td align="left">Showstopper association changes little by round under this fitted model.</td>
    </tr>
    <tr>
      <td align="left">Technical rank × Round</td>
      <td align="center">−0.030</td>
      <td align="center">0.970</td>
      <td align="center">0.910 to 1.035</td>
      <td align="left">Worse Technical rank changes little across rounds under this fitted model.</td>
    </tr>
  </tbody>
</table>

Because this model includes interactions and round is centered at Round 1, the main-effect rows are Round 1 associations. The interaction rows describe how those associations change per additional round. The substantive quantities are the round-specific odds ratios shown in the plot.

<p align="center">
  <img src="results/sb_mod_plot.png" alt="Star Baker round-specific odds ratios" width="760">
</p>

The round-interacted Star Baker plot compares three directionally aligned improvements:

- **Signature:** +1 Signature score point.
- **Showstopper:** +1 Showstopper score point.
- **Technical:** improvement by two technical ranks.

The Showstopper curve is highest throughout the season, which means it remains the strongest predictor of Star Baker selection across rounds. Signature starts strong but declines over the season. The two-rank Technical improvement increases over time and crosses Signature around the middle of the season, but it does not catch the Showstopper. This supports the interpretation that Star Baker is mainly a high-end performance award: the baker who stands out most, especially in the Showstopper, is usually the favorite.

As a simple gut check, among episodes where we look at the group of bakers tied for the highest Showstopper sum, that group contains the actual Star Baker in **80 of 90 episodes**, or **88.9%** of the time. That is very high for such a simple rule.

---

## Question 3: Which Challenges Matter Most for Avoiding Elimination?

The baseline elimination model uses **579 baker-episode rows** and **73 elimination events**. Round 10 is excluded. Again, the model is stratified by episode, so the coefficients compare bakers within the same weekly risk set.

<p align="center"><strong>Baseline elimination model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="22%">Predictor</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="44%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center"><strong>0.487</strong></td>
      <td align="center">0.381 to 0.624</td>
      <td align="left">+1 signature point is associated with lower elimination odds.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center"><strong>0.458</strong></td>
      <td align="center">0.362 to 0.579</td>
      <td align="left">+1 showstopper point is associated with lower elimination odds.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center"><strong>1.553</strong></td>
      <td align="center">1.312 to 1.838</td>
      <td align="left">Moving one rank worse is associated with higher elimination odds.</td>
    </tr>
  </tbody>
</table>

Better Signature, Showstopper, and Technical performances are all associated with lower elimination risk. Signature and Showstopper are directly comparable because they are on the same summed component-score scale. A one-point increase in Signature corresponds to odds ratio **0.487**, and a one-point increase in Showstopper corresponds to odds ratio **0.458**.

Technical rank needs to be interpreted in the opposite direction. The model reports that moving one rank worse has odds ratio **1.553**. Therefore, moving one rank better has odds ratio

$$
1/1.553 \approx 0.644,
$$

or about **36% lower odds** of elimination. Moving two ranks better has odds ratio

$$
0.644^2 \approx 0.415,
$$

or about **59% lower odds** of elimination. By comparison, a two-point improvement in Signature has odds ratio

$$
0.487^2 \approx 0.237,
$$

and a two-point improvement in Showstopper has odds ratio

$$
0.458^2 \approx 0.210.
$$

So technical placement clearly matters, but a few points of improvement in Signature or Showstopper scores correspond to larger changes in elimination odds than moving a few places up in the Technical ranking.

Again, we can interact the main effects with round, allowing the elimination associations to change over the season. The fitted coefficients from this interacted model are below.

<p align="center"><strong>Round-interacted elimination model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="98%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35; font-size: 0.95em;">
  <thead>
    <tr>
      <th align="left" width="24%">Predictor</th>
      <th align="center" width="14%">Log-Odds Coef.</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="28%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center">−0.823</td>
      <td align="center"><strong>0.439</strong></td>
      <td align="center">0.275 to 0.702</td>
      <td align="left">Round 1 association; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center">−0.815</td>
      <td align="center"><strong>0.443</strong></td>
      <td align="center">0.291 to 0.674</td>
      <td align="left">Round 1 association; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center">+0.294</td>
      <td align="center">1.342</td>
      <td align="center">1.085 to 1.660</td>
      <td align="left">Round 1 association for moving one Technical rank worse; used with the round interaction for later rounds.</td>
    </tr>
    <tr>
      <td align="left">Signature × Round</td>
      <td align="center">+0.015</td>
      <td align="center">1.015</td>
      <td align="center">0.914 to 1.127</td>
      <td align="left">Signature protection changes little by round under this fitted model.</td>
    </tr>
    <tr>
      <td align="left">Showstopper × Round</td>
      <td align="center">−0.004</td>
      <td align="center">0.996</td>
      <td align="center">0.908 to 1.093</td>
      <td align="left">Showstopper protection is fairly stable across rounds.</td>
    </tr>
    <tr>
      <td align="left">Technical rank × Round</td>
      <td align="center">+0.075</td>
      <td align="center">1.078</td>
      <td align="center">0.999 to 1.164</td>
      <td align="left">The penalty for worse Technical rank increases by about 8% per round on the odds-ratio scale.</td>
    </tr>
  </tbody>
</table>

Because this model includes interactions and round is centered at Round 1, the main-effect rows are Round 1 associations. The interaction rows describe how those associations change per additional round. The substantive quantities are the round-specific odds ratios shown in the plot.

<p align="center">
  <img src="results/elim_mod_plot.png" alt="Elimination round-specific odds ratios" width="760">
</p>

The round-interacted elimination plot again compares directionally aligned improvements:

- **Signature:** +1 Signature score point.
- **Showstopper:** +1 Showstopper score point.
- **Technical:** improvement by two technical ranks.

All plotted odds ratios are coded so lower values mean stronger protection against elimination. The pattern is different from Star Baker. Early in the season, one-point Signature and Showstopper improvements are more protective than a two-rank Technical improvement. Around roughly Round 3, the two-rank Technical improvement becomes more protective than a one-point Showstopper or Signature improvement. Signature and Showstopper are fairly stable across rounds, while Technical protection strengthens as the field narrows.

This distinction makes sense. Star Baker is a high-end award: it rewards standing out.

For elimination, Technical performance appears most consequential in later rounds. Because elimination is a lower-tail selection problem, the model is asking which baker falls into the weakest part of the episode-specific risk set. As the risk set shrinks, poor Technical placement becomes harder to hide and can be especially damaging when Signature and Showstopper scores do not clearly separate another baker as weaker.

So the two judging models tell a coherent story:

- For Star Baker, the Showstopper is the dominant signal.
- For elimination, Signature, Showstopper, and Technical all matter, but the relative importance shifts across rounds.
- The Technical is not just noise: moving up two ranks can be substantively meaningful, especially for avoiding elimination.

A useful diagnostic is whether Signature and Showstopper scores become more compressed as the field narrows. The episode-level spread summaries suggest some compression by Round 9, especially in the range and IQR. That is consistent with the idea that, late in the season, the remaining bakers are closer on prepared bakes, so the Technical can become more consequential for sorting the lower tail.

<p align="center"><strong>Score spread by round, Rounds 1–9</strong></p>

<table align="center" cellpadding="10" cellspacing="0" width="98%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35; font-size: 0.95em;">
  <thead>
    <tr>
      <th align="center">Round</th>
      <th align="center">Episodes</th>
      <th align="center">Mean Bakers</th>
      <th align="center">Sig. SD</th>
      <th align="center">Sig. IQR</th>
      <th align="center">Sig. Range</th>
      <th align="center">Show SD</th>
      <th align="center">Show IQR</th>
      <th align="center">Show Range</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">1</td><td align="center">9</td><td align="center">12.00</td><td align="center">1.79</td><td align="center">2.83</td><td align="center">5.11</td><td align="center">1.76</td><td align="center">2.56</td><td align="center">4.78</td></tr>
    <tr><td align="center">2</td><td align="center">9</td><td align="center">11.11</td><td align="center">1.79</td><td align="center">2.58</td><td align="center">4.89</td><td align="center">1.54</td><td align="center">2.28</td><td align="center">4.11</td></tr>
    <tr><td align="center">3</td><td align="center">9</td><td align="center">9.89</td><td align="center">1.58</td><td align="center">2.11</td><td align="center">4.67</td><td align="center">1.86</td><td align="center">2.64</td><td align="center">5.22</td></tr>
    <tr><td align="center">4</td><td align="center">9</td><td align="center">9.00</td><td align="center">1.64</td><td align="center">2.61</td><td align="center">4.33</td><td align="center">1.87</td><td align="center">2.33</td><td align="center">5.33</td></tr>
    <tr><td align="center">5</td><td align="center">9</td><td align="center">8.33</td><td align="center">1.70</td><td align="center">2.72</td><td align="center">4.22</td><td align="center">1.62</td><td align="center">1.78</td><td align="center">4.56</td></tr>
    <tr><td align="center">6</td><td align="center">9</td><td align="center">7.00</td><td align="center">1.96</td><td align="center">2.50</td><td align="center">5.00</td><td align="center">1.90</td><td align="center">2.50</td><td align="center">4.78</td></tr>
    <tr><td align="center">7</td><td align="center">9</td><td align="center">6.00</td><td align="center">1.60</td><td align="center">2.03</td><td align="center">4.00</td><td align="center">1.66</td><td align="center">2.14</td><td align="center">4.11</td></tr>
    <tr><td align="center">8</td><td align="center">9</td><td align="center">5.00</td><td align="center">1.74</td><td align="center">2.11</td><td align="center">4.11</td><td align="center">1.66</td><td align="center">1.67</td><td align="center">4.00</td></tr>
    <tr><td align="center">9</td><td align="center">9</td><td align="center">4.00</td><td align="center">1.27</td><td align="center">1.44</td><td align="center">2.78</td><td align="center">1.44</td><td align="center">1.61</td><td align="center">3.11</td></tr>
  </tbody>
</table>

## Using the Elimination and Star Baker Models to Think About the Competition Path

The Star Baker and elimination models target different parts of the judging process. The Star Baker model asks who is most likely to stand out at the top of the weekly risk set. The elimination model asks who is most likely to fall to the bottom of that same risk set. These are not the same question. A baker can avoid elimination without being close to Star Baker, and a baker can be a plausible Star Baker candidate while still not having the strongest season-long path to winning.

Still, putting the two models together gives a useful descriptive way to think about the path to becoming the eventual winner.

A reasonable interpretation is that the competition has something like three phases:

1. **Early rounds: avoid early damage through solid Signature bakes while also avoiding a poor Technical placement.**  
   In the early episodes, the risk set is large. There are many bakers, and the judges are often sorting out who is consistently competent versus who is immediately vulnerable. In the interacted elimination model, Signature starts as strongly protective, while its protection weakens over rounds. That suggests early Signature performance may matter because it prevents a baker from starting the episode in a weak position. A poor Signature bake early can put someone behind before the Technical and Showstopper have a chance to rescue them.

2. **Middle and late pre-final rounds: survive by avoiding poor Technical placement.**  
   As the field narrows, the remaining bakers are more selected and tend to perform better on Signature and Showstopper bakes as a whole; they are less likely to be separated by obvious failures in the prepared bakes alone. The elimination interaction plot suggests that Technical performance becomes increasingly consequential for avoiding elimination, especially by the middle-to-late rounds. This makes sense because the Technical is a common task under more standardized conditions. When the remaining bakers are closer in Signature and Showstopper scores, a poor Technical rank becomes harder to hide.

3. **Final: win by producing a standout Showstopper.**  
   The final is structurally different from the earlier elimination rounds. It is not just about avoiding last place; it is about being selected as the winner from a very small set of finalists. That makes it closer to a high-end selection problem than a routine elimination problem. The Star Baker model strongly suggests that high-end weekly recognition is most associated with Showstopper performance. The simple Showstopper gut check points in the same direction: the group tied for the highest Showstopper sum contains the actual Star Baker in 80 of 90 episodes, or 88.9% of the time. So if the final behaves more like a top-end selection decision, then a standout Showstopper is plausibly the decisive signal.

Taken as a descriptive competition heuristic, the models suggest:

> **Do not get exposed early in Signature, do not fall behind in Technical as the field narrows, and distinguish yourself in the final Showstopper.**

This is not a formally estimated winner model. It is a synthesis of the weekly Star Baker and elimination models. A direct winner model would need to treat the competition as a sequential process: survive each weekly risk set, then win among the finalists. With only nine Netflix-era winners, that model would be fragile, so the three-phase interpretation is best treated as a descriptive summary rather than a definitive strategy.

## Question 4: Which Bakers and Series Stand Out?

The second model is a linear mixed-effects model fit to stacked component scores. Because each baker appears in multiple episodes, their weekly scores are not independent. The baker random intercept accounts for this repeated-measures structure by allowing scores from the same baker to share a baker-specific tendency. The episode random intercept accounts for shared week-level conditions, since all bakers in the same episode face the same broad judging context.

The model also adjusts for component type and series. The resulting baker random effects provide adjusted season-long performance summaries, not raw averages or definitive ability rankings. The technical challenge enters through a scaled technical rank so that higher values represent stronger performance and lower values represent weaker performance.

The fitted baker random effect is a shrunken adjusted performance summary. It is not a raw average and not a definitive all-time ranking. It is a model-based estimate of whether a baker tended to score above or below expectation after adjusting for series, episode, and component type.

A few points matter:

- These are season-long summaries, not winner labels.
- Early eliminees have less information, so their effects are less stable.
- Later-round observations are selected: finalists are already a stronger surviving group.

---

### Strongest Fitted Baker Effects

<p align="center"><strong>Top 10 bakers by fitted baker effect</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="center" width="8%">#</th>
      <th align="left" width="30%">Baker</th>
      <th align="center" width="14%">Series</th>
      <th align="center">Effect</th>
      <th align="center">Finish</th>
    </tr>
  </thead>
    <tbody>
    <tr><td align="center">1</td><td align="left">Jasmine</td><td align="center">13</td><td align="center">+0.366</td><td align="center">Winner</td></tr>
    <tr><td align="center">2</td><td align="left">Sophie</td><td align="center">5</td><td align="center">+0.333</td><td align="center">Winner</td></tr>
    <tr><td align="center">3</td><td align="left">Giuseppe</td><td align="center">9</td><td align="center">+0.322</td><td align="center">Winner</td></tr>
    <tr><td align="center">4</td><td align="left">Syabira</td><td align="center">10</td><td align="center">+0.303</td><td align="center">Winner</td></tr>
    <tr><td align="center">5</td><td align="left">Crystelle</td><td align="center">9</td><td align="center">+0.291</td><td align="center">Final</td></tr>
    <tr><td align="center">6</td><td align="left">Steph</td><td align="center">7</td><td align="center">+0.287</td><td align="center">Final</td></tr>
    <tr><td align="center">7</td><td align="left">Jürgen</td><td align="center">9</td><td align="center">+0.248</td><td align="center">Semi-final</td></tr>
    <tr><td align="center">8</td><td align="left">Peter</td><td align="center">8</td><td align="center">+0.245</td><td align="center">Winner</td></tr>
    <tr><td align="center">9</td><td align="left">Chigs</td><td align="center">9</td><td align="center">+0.245</td><td align="center">Final</td></tr>
    <tr><td align="center">10</td><td align="left">Josh</td><td align="center">11</td><td align="center">+0.240</td><td align="center">Final</td></tr>
  </tbody>
</table>

This mixed-model ranking is not the same as a simple “who lasted longest” ranking. It is based on adjusted component-level scoring tendencies with partial pooling. The top ten is dominated by winners, finalists, and semifinalists, which is a useful sanity check. But it still is not simply a placement ranking: Crystelle, Steph, Jürgen, Chigs, and Josh rank very highly despite not winning, while some winners rank below strong non-winners from their own or nearby seasons.


---

### Season Balance

The fitted baker random effects also give a useful way to compare how concentrated or balanced each series was at the top. The table is sorted by **Top 3 Spread**, so the first rows are the seasons where the three strongest fitted bakers were closest together.

<p align="center"><strong>Season balance based on fitted baker effects</strong></p>

<table align="center" cellpadding="9" cellspacing="0" width="100%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.30; font-size: 0.82em;">
  <thead>
    <tr>
      <th align="center">Series</th>
      <th align="left">Winner</th>
      <th align="center">Winner Effect</th>
      <th align="center">Winner Rank</th>
      <th align="left">Best Non-Winner</th>
      <th align="center">Best Non-Winner Effect</th>
      <th align="center">Best Non-Winner Rank</th>
      <th align="center">Winner - Best Non-Winner</th>
      <th align="center">Top 3 Spread</th>
      <th align="center">SD Effect</th>
      <th align="center">Full Range</th>
      <th align="center">Top 4 - Bottom 4</th>
    </tr>
  </thead>
    <tbody>
    <tr>
      <td align="center">9</td>
      <td align="left">Giuseppe</td>
      <td align="center">+0.322</td>
      <td align="center">1 of 12</td>
      <td align="left">Crystelle</td>
      <td align="center">+0.291</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.031</td>
      <td align="center">0.074</td>
      <td align="center">0.221</td>
      <td align="center">0.591</td>
      <td align="center">0.497</td>
    </tr>
    <tr>
      <td align="center">6</td>
      <td align="left">Rahul</td>
      <td align="center">+0.231</td>
      <td align="center">1 of 12</td>
      <td align="left">Kim-Joy</td>
      <td align="center">+0.220</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.011</td>
      <td align="center">0.082</td>
      <td align="center">0.138</td>
      <td align="center">0.400</td>
      <td align="center">0.302</td>
    </tr>
    <tr>
      <td align="center">8</td>
      <td align="left">Peter</td>
      <td align="center">+0.245</td>
      <td align="center">1 of 12</td>
      <td align="left">Dave</td>
      <td align="center">+0.166</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.079</td>
      <td align="center">0.108</td>
      <td align="center">0.151</td>
      <td align="center">0.492</td>
      <td align="center">0.326</td>
    </tr>
    <tr>
      <td align="center">12</td>
      <td align="left">Georgie</td>
      <td align="center">+0.069</td>
      <td align="center">5 of 11</td>
      <td align="left">Gill</td>
      <td align="center">+0.190</td>
      <td align="center">1 of 11</td>
      <td align="center">−0.121</td>
      <td align="center">0.113</td>
      <td align="center">0.155</td>
      <td align="center">0.587</td>
      <td align="center">0.257</td>
    </tr>
    <tr>
      <td align="center">7</td>
      <td align="left">David</td>
      <td align="center">+0.174</td>
      <td align="center">2 of 13</td>
      <td align="left">Steph</td>
      <td align="center">+0.287</td>
      <td align="center">1 of 13</td>
      <td align="center">−0.113</td>
      <td align="center">0.126</td>
      <td align="center">0.155</td>
      <td align="center">0.518</td>
      <td align="center">0.350</td>
    </tr>
    <tr>
      <td align="center">11</td>
      <td align="left">Matty</td>
      <td align="center">−0.003</td>
      <td align="center">7 of 12</td>
      <td align="left">Josh</td>
      <td align="center">+0.240</td>
      <td align="center">1 of 12</td>
      <td align="center">−0.243</td>
      <td align="center">0.151</td>
      <td align="center">0.151</td>
      <td align="center">0.490</td>
      <td align="center">0.319</td>
    </tr>
    <tr>
      <td align="center">10</td>
      <td align="left">Syabira</td>
      <td align="center">+0.303</td>
      <td align="center">1 of 12</td>
      <td align="left">Maxy</td>
      <td align="center">+0.155</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.148</td>
      <td align="center">0.152</td>
      <td align="center">0.177</td>
      <td align="center">0.563</td>
      <td align="center">0.367</td>
    </tr>
    <tr>
      <td align="center">5</td>
      <td align="left">Sophie</td>
      <td align="center">+0.333</td>
      <td align="center">1 of 12</td>
      <td align="left">Steven</td>
      <td align="center">+0.164</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.169</td>
      <td align="center">0.277</td>
      <td align="center">0.147</td>
      <td align="center">0.535</td>
      <td align="center">0.292</td>
    </tr>
    <tr>
      <td align="center">13</td>
      <td align="left">Jasmine</td>
      <td align="center">+0.366</td>
      <td align="center">1 of 12</td>
      <td align="left">Tom</td>
      <td align="center">+0.193</td>
      <td align="center">2 of 12</td>
      <td align="center">+0.173</td>
      <td align="center">0.301</td>
      <td align="center">0.151</td>
      <td align="center">0.539</td>
      <td align="center">0.294</td>
    </tr>
  </tbody>
</table>

- Series 9 is the clearest “stacked top” season. Giuseppe is ranked first, Crystelle second, and the top-three spread is only **0.074**, the smallest in the table. But the full range is **0.591** and the top-four-minus-bottom-four gap is **0.497**, both large. So Series 9 was not compressed overall; rather, it had a very strong top group that separated sharply from the lower end.

- Series 6 is also very tight at the top. Rahul and Kim-Joy are nearly tied under the fitted model, with a winner-versus-best-nonwinner gap of only **+0.011** and a top-three spread of **0.082**. Unlike Series 9, though, its full range is only **0.400**, the smallest in the table. This looks more like a genuinely compressed season overall.

- Series 8 is intermediate. Peter is ranked first and Dave second, with a larger winner gap than Series 6 or 9 but still a modest top-three spread. That suggests Peter was the fitted leader, but not in the same dominant way as Sophie or Syabira.

- Series 12, Series 7, and Series 11 are the main mismatch seasons. In all three, the fitted model ranks a non-winner first. Gill ranks above Georgie in Series 12, Steph ranks above David in Series 7, and Josh ranks well above Matty in Series 11. Series 11 is the largest mismatch: Matty is only **7th of 12** by fitted baker effect, and the winner-versus-best-nonwinner gap is **−0.243**.

- Series 10, Series 5, and Series 13 are the clearest winner-dominance seasons. Syabira leads Maxy by **+0.148**, Sophie leads Steven by **+0.169**, and Jasmine leads Tom by **+0.173**. Series 13 has the largest top-three spread, **0.301**, suggesting Jasmine was more separated from the rest of the top group than the winners in the more balanced seasons.

Overall, the table separates three patterns:

- **Tight but winner-led seasons:** Series 6, Series 8, and Series 9.
- **Mismatch seasons where a non-winner had the strongest fitted profile:** Series 7, Series 11, and Series 12.
- **Dominant-winner seasons:** Series 5, Series 10, and Series 13.

This is exactly why the random-effect ranking should not be read as a replacement for the actual outcome. It summarizes adjusted season-long scoring, while the show is a sequential competition that ultimately turns on survival and final-week performance.

---

### Winners and Their Season-Long Rankings

<p align="center"><strong>Series winners by fitted effect and within-season rank</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="center" width="14%">Series</th>
      <th align="left" width="30%">Winner</th>
      <th align="center" width="24%">Estimated Effect</th>
      <th align="center" width="32%">Within-Season Rank</th>
    </tr>
  </thead>
    <tbody>
    <tr><td align="center">5</td><td align="left">Sophie</td><td align="center">+0.333</td><td align="center"><strong>1st of 12</strong></td></tr>
    <tr><td align="center">6</td><td align="left">Rahul</td><td align="center">+0.231</td><td align="center"><strong>1st of 12</strong></td></tr>
    <tr><td align="center">7</td><td align="left">David</td><td align="center">+0.174</td><td align="center">2nd of 13</td></tr>
    <tr><td align="center">8</td><td align="left">Peter</td><td align="center">+0.245</td><td align="center"><strong>1st of 12</strong></td></tr>
    <tr><td align="center">9</td><td align="left">Giuseppe</td><td align="center">+0.322</td><td align="center"><strong>1st of 12</strong></td></tr>
    <tr><td align="center">10</td><td align="left">Syabira</td><td align="center">+0.303</td><td align="center"><strong>1st of 12</strong></td></tr>
    <tr><td align="center">11</td><td align="left">Matty</td><td align="center">−0.003</td><td align="center">7th of 12</td></tr>
    <tr><td align="center">12</td><td align="left">Georgie</td><td align="center">+0.069</td><td align="center">5th of 11</td></tr>
    <tr><td align="center">13</td><td align="left">Jasmine</td><td align="center">+0.366</td><td align="center"><strong>1st of 12</strong></td></tr>
  </tbody>
</table>

The mixed model makes an important point: winning the final and having the strongest season-long adjusted scoring profile are related, but they are not identical targets. Sophie, Rahul, Peter, Giuseppe, Syabira, and Jasmine are ranked first within their seasons, while David is second. Matty and Georgie are lower in their within-season adjusted rankings, which reflects the fact that the model summarizes the full observed competition path rather than only the final.

This distinction is useful because *Bake Off* is not awarded to the best fitted random intercept across all weeks. It is a sequential competition with a final. A baker can be very strong season-long and lose the final; a baker can have a less dominant season-long profile and peak at the right moment.

---

### Strong Non-Winner Profiles

These are the cases where adjusted season-long performance and the final outcome diverge most clearly.

<p align="center"><strong>High-ranked non-winners by fitted effect</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="center" width="14%">Series</th>
      <th align="left" width="34%">Baker</th>
      <th align="center" width="22%">Effect</th>
      <th align="center" width="30%">Finish</th>
    </tr>
  </thead>
    <tbody>
    <tr><td align="center">9</td><td align="left">Crystelle</td><td align="center">+0.291</td><td align="center">Final</td></tr>
    <tr><td align="center">7</td><td align="left">Steph</td><td align="center">+0.287</td><td align="center">Final</td></tr>
    <tr><td align="center">9</td><td align="left">Jürgen</td><td align="center">+0.248</td><td align="center">Semi-final</td></tr>
    <tr><td align="center">9</td><td align="left">Chigs</td><td align="center">+0.245</td><td align="center">Final</td></tr>
    <tr><td align="center">11</td><td align="left">Josh</td><td align="center">+0.240</td><td align="center">Final</td></tr>
    <tr><td align="center">6</td><td align="left">Kim-Joy</td><td align="center">+0.220</td><td align="center">Final</td></tr>
    <tr><td align="center">11</td><td align="left">Tasha</td><td align="center">+0.210</td><td align="center">Semi-final</td></tr>
    <tr><td align="center">13</td><td align="left">Tom</td><td align="center">+0.193</td><td align="center">Final</td></tr>
    <tr><td align="center">12</td><td align="left">Gill</td><td align="center">+0.190</td><td align="center">Semi-final</td></tr>
    <tr><td align="center">8</td><td align="left">Dave</td><td align="center">+0.166</td><td align="center">Final</td></tr>
  </tbody>
</table>

Crystelle is the strongest adjusted non-winner by this model, despite not winning Series 9. Steph is nearly tied with her and ranks ahead of Series 7 winner David. Jürgen and Chigs are also strong Series 9 profiles behind Giuseppe, which matches the sense that Series 9 had several high-performing contenders. Tom is the strongest non-winner in Series 13 behind Jasmine. Gill remains the key Series 12 mismatch: she has the largest fitted baker effect in that season, while Georgie won. Josh and Tasha remain strong Series 11 examples of high season-long adjusted performance without winning.

These estimates are model-based summaries, not historical verdicts. They depend on the score construction, partial pooling, and the fact that later-round observations come from a selected group of survivors.

---

## Limitations and Technical Notes

- The analysis is observational. The models estimate associations between performance and judging outcomes, not causal effects.

- The data depend on score-coding decisions. A different cleaned version of the data could lead to different estimates. Technical performance is originally a rank, not an absolute score. Scaling the technical rank helps make it comparable across episodes, but it remains a transformed relative measure.

- The conditional-logit Star Baker and elimination models correctly compare bakers within the episode-specific risk set. However, they do not explicitly model the fact that survival to later rounds is itself informative. A baker appearing in Round 8 is not exchangeable with a baker appearing only in Round 1; survival is already a selection process.

- The prediction evaluation is cross-validated by episode, not by series. It tests whether the model generalizes to held-out episodes within the same data set, not whether it generalizes to a completely unseen GBBO season. A stricter future check would use leave-one-series-out cross-validation or genuinely held-out newer seasons.

- The latent baker-ability model treats each baker's random intercept as static. It summarizes each baker with one average adjusted performance effect and does not model improvement, fatigue, adaptation, pressure effects, or round-specific trajectories.

- The baker random effects should be interpreted cautiously because later-round observations come from a selected sample of stronger bakers. The model estimates adjusted scoring tendency from the observed competition path, not a fully selection-adjusted latent ability parameter.

**Model 1: conditional logistic regression**

- Compares bakers within each episode's risk set.
- Models weekly Star Baker and elimination decisions.
- Excludes the finale from elimination models because final elimination is structurally different.
- Uses Signature and Showstopper scores formed from bake, flavor, and appearance-style components.
- Treats raw Technical rank carefully because lower rank means better technical performance.
- Uses round interactions to allow judging associations to change over the season.

**Model 2: linear mixed-effects model**

- Uses individual scoring components stacked in long format.
- Includes fixed effects for component type and series.
- Includes random intercepts for baker and episode.
- Uses scaled technical rank so technical performance is directionally comparable with component scores.
- Produces the fitted baker effects used as season-long adjusted performance summaries.

**Cross-validation**

- Uses leave-one-episode-out cross-validation.
- Predicts each held-out episode using a model trained on all other episodes.
- Evaluates ranking accuracy within episode-specific risk sets.
- A stricter leave-one-series-out evaluation would ask whether the model generalizes to a completely unseen season.

**Requirements**

- R 4.0+
- `tidyverse`
- `survival`
- `lme4`
- `broom`
- `broom.mixed`
- `ggplot2`
