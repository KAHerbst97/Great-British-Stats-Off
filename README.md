# Great British Bake Off: What Really Matters in the Tent?

> **Does what matters for winning Star Baker differ from what matters for avoiding elimination? Who were the strongest bakers?**

This project is a statistical look at Netflix-era *Great British Bake Off* Series 5–13. The basic question is simple: do the judging patterns people argue about while watching the show actually show up in the data?

Using data prepared by [Nathan Giusti](https://github.com/nathangiusti/BakeOff), I focus on four questions:

1. Which parts of the competition are most associated with Star Baker?
2. Which parts are most associated with avoiding elimination?
3. How well can we predict weekly judging decisions within an episode?
4. Which bakers and seasons stand out after adjustment?

The cleaned dataset contains **678 baker-episode rows**, **9 Netflix-era series**, **90 episodes**, and **108 baker-season entries**.

<p align="center">
  <img src="results/gbbo_one_pager.png" alt="One-page summary of Great British Bake Off statistical analysis" width="950">
</p>

---

## Judge's Priorities: A Recipe

<div align="center">
<table cellpadding="12" cellspacing="0" width="90%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.45; border: 1px solid #c9a46a; background-color: #fff8e8;">
  <tbody>
    <tr>
      <td align="left">
        <strong>1. Star Baker is a high-end award.</strong> The Showstopper dominates through all rounds.<br><br>
        <strong>2. Elimination is a lower-tail problem.</strong> Signature and Showstopper matter similarly throughout, but Technical performance becomes more protective later.<br><br>
        <strong>3. Season-long strength helps.</strong> But the winner is not always the strongest pre-finale baker.
      </td>
    </tr>
  </tbody>
</table>
</div>

The practical takeaway:

> **Stay safe early, survive Technical pressure late, and win with the Showstopper.**

That is the statistical version of how the show often feels. Star Baker is about the high point of the week. Elimination is about who gives the judges the weakest case for staying. Those are not mirror-image decisions.

---

## Methods in one paragraph

The Star Baker and elimination models are **conditional logit models with episode strata**. That matters because each judging decision is made within an episode-specific risk set: the judges choose among the bakers still standing that week, not among every baker in the Netflix era. The main predictors are Signature sum, Showstopper sum, and Technical rank. Signature and Showstopper are summed component scores on the same scale, while Technical is a within-episode rank, so Technical effects are easiest to interpret as moving one or two ranks better or worse.

I use the judging models in two ways:

- **Inferential/descriptive:** fit to all eligible episodes to summarize judging patterns.
- **Predictive:** refit under leave-one-episode-out CV and sequential episode CV to check how well the patterns identify actual weekly decisions.

A separate linear mixed-effects model estimates adjusted season-long baker strength using baker random intercepts, with adjustment for series, episode, and component type.

---

## Weekly prediction accuracy

The conditional logit models work well as weekly ranking systems. Each held-out episode is ranked by predicted probability, and the question is whether the actual Star Baker or eliminated baker is near the top of that episode-specific ranking.

<p align="center"><strong>Leave-one-episode-out cross-validation</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="24%">Outcome</th>
      <th align="center" width="14%">Episodes</th>
      <th align="center">Top-1 Accuracy</th>
      <th align="center">Top-2 Accuracy</th>
      <th align="center">Top-3 Accuracy</th>
      <th align="center">AUROC</th>
      <th align="center">AUPRC</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Star Baker</td>
      <td align="center">90</td>
      <td align="center"><strong>68.9%</strong></td>
      <td align="center"><strong>88.9%</strong></td>
      <td align="center"><strong>98.9%</strong></td>
      <td align="center"><strong>0.945</strong></td>
      <td align="center"><strong>0.701</strong></td>
    </tr>
    <tr>
      <td align="left">Elimination</td>
      <td align="center">73</td>
      <td align="center"><strong>61.6%</strong></td>
      <td align="center"><strong>82.2%</strong></td>
      <td align="center"><strong>94.5%</strong></td>
      <td align="center"><strong>0.923</strong></td>
      <td align="center"><strong>0.599</strong></td>
    </tr>
  </tbody>
</table>

Leave-one-episode-out CV is useful, but it still lets the model learn from future episodes in other seasons. A stricter check is **sequential episode CV**, where the model is trained only on episodes that came before the episode being predicted.

<p align="center"><strong>LOOCV versus sequential episode CV</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left">CV Scheme</th>
      <th align="left">Outcome</th>
      <th align="center">Top-1</th>
      <th align="center">Top-2</th>
      <th align="center">Top-3</th>
      <th align="center">AUROC</th>
      <th align="center">AUPRC</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="left">LOOCV</td><td align="left">Star Baker</td><td align="center">0.689</td><td align="center">0.889</td><td align="center">0.989</td><td align="center">0.945</td><td align="center">0.701</td></tr>
    <tr><td align="left">LOOCV</td><td align="left">Elimination</td><td align="center">0.616</td><td align="center">0.822</td><td align="center">0.945</td><td align="center">0.923</td><td align="center">0.599</td></tr>
    <tr><td align="left">Sequential CV</td><td align="left">Star Baker</td><td align="center">0.675</td><td align="center">0.912</td><td align="center">0.988</td><td align="center">0.950</td><td align="center">0.739</td></tr>
    <tr><td align="left">Sequential CV</td><td align="left">Elimination</td><td align="center">0.571</td><td align="center">0.841</td><td align="center">0.921</td><td align="center">0.897</td><td align="center">0.538</td></tr>
  </tbody>
</table>

Sequential CV does not wreck the model. Star Baker prediction is fairly stable. Elimination gets harder, which makes sense: elimination is a lower-tail decision, and later episodes are smaller, more selected risk sets.

---

## Finale predictions

The final is different from the rest of the show. In Round 10, “Star Baker” is effectively the overall winner, and there is no ordinary weekly elimination. For that reason, the standard Star Baker and elimination models are fit on Rounds 1–9, and finale prediction is treated separately.

Using episode LOOCV, the final-episode model picked the eventual winner in **6 of 9 finals**. In all three misses, the true winner was ranked second.

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

The Series 13 final is the clearest example of why weekly prediction and season-long strength are different targets. The final-episode model favored Tom. The season-long fitted baker model ranks Jasmine first overall. That is not a contradiction. It is the difference between “best final episode signal” and “strongest full-season profile.”

---

## What matters for Star Baker?

<p align="center"><strong>Baseline Star Baker model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="24%">Performance improvement</th>
      <th align="center" width="18%">Odds Ratio</th>
      <th align="left" width="58%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">+1 Signature point</td>
      <td align="center"><strong>2.046</strong></td>
      <td align="left">A one-point Signature gain roughly doubles Star Baker odds.</td>
    </tr>
    <tr>
      <td align="left">+1 Showstopper point</td>
      <td align="center"><strong>5.599</strong></td>
      <td align="left">A one-point Showstopper gain multiplies Star Baker odds by about 5.6.</td>
    </tr>
    <tr>
      <td align="left">2 Technical ranks better</td>
      <td align="center"><strong>2.208</strong></td>
      <td align="left">Moving two Technical places better roughly doubles Star Baker odds.</td>
    </tr>
  </tbody>
</table>

The main result is blunt:

> **The Showstopper dominates Star Baker selection.**

Signature and Showstopper are on the same scoring scale, so the comparison is direct. A one-point Showstopper improvement is associated with a much larger change in Star Baker odds than a one-point Signature improvement. Technical helps, but it does not catch the Showstopper.

<p align="center">
  <img src="results/sb_mod_plot.png" alt="Star Baker round-specific odds ratios" width="760">
</p>

The round-interacted model shows the same basic story. Showstopper stays strongest across the season. Signature starts useful but weakens. Technical improvement matters, but Star Baker remains a high-end award: the baker who produces the clearest standout bake is usually the one in the conversation.

As a simple check, the group tied for best Showstopper score contains the actual Star Baker in **80 of 90 episodes**, or **88.9%** of the time.

---

## What matters for avoiding elimination?

<p align="center"><strong>Baseline elimination model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="24%">Performance improvement</th>
      <th align="center" width="18%">Odds Ratio</th>
      <th align="left" width="58%">Interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">+1 Signature point</td>
      <td align="center"><strong>0.487</strong></td>
      <td align="left">A better Signature lowers elimination odds by about 51%.</td>
    </tr>
    <tr>
      <td align="left">+1 Showstopper point</td>
      <td align="center"><strong>0.458</strong></td>
      <td align="left">A better Showstopper lowers elimination odds by about 54%.</td>
    </tr>
    <tr>
      <td align="left">2 Technical ranks better</td>
      <td align="center"><strong>0.415</strong></td>
      <td align="left">Moving two Technical places better lowers elimination odds by about 59%.</td>
    </tr>
  </tbody>
</table>

For elimination, the story is more balanced. Signature, Showstopper, and Technical all matter.

<p align="center">
  <img src="results/elim_mod_plot.png" alt="Elimination round-specific odds ratios" width="760">
</p>

The round-interacted model shows the key change over the season:

- Early on, Signature and Showstopper are strongly protective.
- As the field gets smaller, Technical performance becomes more important.
- By the middle and later rounds, a bad Technical can be especially damaging.

This makes sense. Early in the competition, there are many bakers and large differences in prepared bakes. Later, the remaining bakers are stronger and closer together. A bad Technical then has fewer weak performances to hide behind.

---

## Score compression by round

Signature and Showstopper scores become more compressed near the end of the season. That helps explain why Technical rank becomes more consequential later.

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

By Round 9, there are fewer bakers and the score ranges are smaller. The remaining bakers are closer together, so Technical rank has more room to become decisive. That is the statistical version of “the standards go up.”

---

## Strongest adjusted baker profiles

The second part of the analysis estimates adjusted season-long baker performance. These are not raw averages. They account for episode, series, component type, and repeated observations for each baker.

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

The top 10 is mostly winners, finalists, and semifinalists. That is a useful sanity check. But it is not just a placement ranking. Crystelle, Steph, Jürgen, Chigs, and Josh rate highly despite not winning.

---

## Winners and season-long rankings

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

Most winners rank near the top of their own season. But not all winners rank first.

That is the point: *Bake Off* is not awarded to the baker with the best full-season average. It is a survival competition with a final. The winner won the competition structure. The adjusted baker effect summarizes observed strength across the season.

---

## Season balance

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
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">9</td><td align="left">Giuseppe</td><td align="center">+0.322</td><td align="center">1 of 12</td><td align="left">Crystelle</td><td align="center">+0.291</td><td align="center">2 of 12</td><td align="center">+0.031</td><td align="center">0.074</td></tr>
    <tr><td align="center">6</td><td align="left">Rahul</td><td align="center">+0.231</td><td align="center">1 of 12</td><td align="left">Kim-Joy</td><td align="center">+0.220</td><td align="center">2 of 12</td><td align="center">+0.011</td><td align="center">0.082</td></tr>
    <tr><td align="center">8</td><td align="left">Peter</td><td align="center">+0.245</td><td align="center">1 of 12</td><td align="left">Dave</td><td align="center">+0.166</td><td align="center">2 of 12</td><td align="center">+0.079</td><td align="center">0.108</td></tr>
    <tr><td align="center">12</td><td align="left">Georgie</td><td align="center">+0.069</td><td align="center">5 of 11</td><td align="left">Gill</td><td align="center">+0.190</td><td align="center">1 of 11</td><td align="center">−0.121</td><td align="center">0.113</td></tr>
    <tr><td align="center">7</td><td align="left">David</td><td align="center">+0.174</td><td align="center">2 of 13</td><td align="left">Steph</td><td align="center">+0.287</td><td align="center">1 of 13</td><td align="center">−0.113</td><td align="center">0.126</td></tr>
    <tr><td align="center">11</td><td align="left">Matty</td><td align="center">−0.003</td><td align="center">7 of 12</td><td align="left">Josh</td><td align="center">+0.240</td><td align="center">1 of 12</td><td align="center">−0.243</td><td align="center">0.151</td></tr>
    <tr><td align="center">10</td><td align="left">Syabira</td><td align="center">+0.303</td><td align="center">1 of 12</td><td align="left">Maxy</td><td align="center">+0.155</td><td align="center">2 of 12</td><td align="center">+0.148</td><td align="center">0.152</td></tr>
    <tr><td align="center">5</td><td align="left">Sophie</td><td align="center">+0.333</td><td align="center">1 of 12</td><td align="left">Steven</td><td align="center">+0.164</td><td align="center">2 of 12</td><td align="center">+0.169</td><td align="center">0.277</td></tr>
    <tr><td align="center">13</td><td align="left">Jasmine</td><td align="center">+0.366</td><td align="center">1 of 12</td><td align="left">Tom</td><td align="center">+0.193</td><td align="center">2 of 12</td><td align="center">+0.173</td><td align="center">0.301</td></tr>
  </tbody>
</table>

This separates the seasons into three rough groups:

- **Tight but winner-led:** Series 6, 8, and 9.
- **Mismatch seasons:** Series 7, 11, and 12, where the strongest fitted baker was not the winner.
- **Dominant-winner seasons:** Series 5, 10, and 13.

Series 9 has the tightest top group. Giuseppe ranked first, but Crystelle, Jürgen, and Chigs were all very strong. Series 13 is the opposite: Jasmine is more clearly separated from the rest of the top group.

---

## How to read the results as a viewer

The model should not be read as a claim that the judges follow a formula. They do not. It is better read as a structured summary of the patterns left behind by their decisions.

The viewer-facing interpretation is:

- **Star Baker is a high-point award.** The Showstopper is where the model sees the clearest separation.
- **Elimination is a risk decision.** A baker does not need to be the worst at everything; they just need the weakest overall case for staying.
- **The Technical matters more when the tent gets smaller.** Once the remaining bakers are all strong, rank-based separation becomes harder to ignore.
- **Winning the season is not the same as having the strongest adjusted season profile.** The show is sequential: survive each week, then win the final.

That is why this project uses both weekly prediction and season-long adjusted profiles. One explains episode decisions. The other summarizes the broader arc of each baker and season.

---

## Limitations

This is a descriptive and predictive analysis, not a causal one. It shows which performances are associated with judging outcomes, not what mechanically caused the judges’ decisions.

Important cautions:

- The results depend on how the scores were cleaned and coded.
- Technical rank is a ranking, not an absolute score.
- Later-round bakers are already a selected group.
- The baker rankings summarize observed performance, not true underlying ability.
- The models do not capture improvement, fatigue, pressure, editing, narrative, or judge deliberation.

So the results should be read as structured evidence about judging patterns, not as a final verdict on who “really” deserved to win.

---

## Requirements

- R 4.0+
- `tidyverse`
- `survival`
- `lme4`
- `broom`
- `broom.mixed`
- `ggplot2`
