# The Great British Bake Off - A Statistical Analysis (Preliminary Results, WIP)

> **What actually matters in the tent? Does it change for overall winner, star baker and elimination?**

> **Who were the strongest contenders?**

These are the kinds of questions I had while watching Series 5–13 of *The Great British Bake Off* on Netflix. I wanted to see whether my general impressions about specific events, like Jürgen being eliminated or Jasmine winning the final over Tom, and broader judging patterns, like Showstopper performance seeming to dominate star baker selection, were also supported by the data and maybe discover some new insights into one of my favorite shows.

Using data prepared by [Nathan Giusti](https://github.com/nathangiusti/BakeOff), I focus on four questions:

1. Which parts of the competition are most associated with Star Baker?
2. Which parts are most associated with avoiding elimination?
3. How well can we predict judging decisions within a particular episode?
4. Which bakers and seasons stand out after adjustment?

The cleaned dataset contains **678 baker-episode rows**, **9 Netflix-era series**, **90 episodes**, and **108 baker-season entries**.

---

## Main Takeaways

The main findings are simple:

> **Showstopper performance is the strongest signal for Star Baker.**  
> **Technical rank becomes more important for avoiding elimination as the field narrows.**  

The (conditional logit) model performs well as a weekly ranking system:

- It ranked the actual **Star Baker first in 68.9%** of episodes.
- It ranked the actual **Star Baker in the top two in 88.9%** of episodes.
- It ranked the actual **eliminated baker first in 61.6%** of eligible elimination episodes.
- It ranked the actual **eliminated baker in the top two in 82.2%** of eligible elimination episodes.
- It picked the eventual winner in **6 of 9 finals**; in all three misses, the true winner was ranked second.
  - Jasmine, Sophie and Giuseppe were not favored to win by the model solely given their performance during their finales 


The practical takeaway:

> **Stay safe early, survive Technical pressure late, and win with the Showstopper.**

For viewers, this matches a lot of the show's logic. Star Baker is usually about who produced the most memorable high point that week. Elimination is more about who gave the judges enough reason to send them home. Those are not mirror-image decisions. A baker can be too inconsistent to win Star Baker but still safe. A baker can have a quiet week and survive. But if the field is small and the Technical goes badly, there are fewer people left to hide behind.

## Weekly prediction accuracy

The (conditional logit) models were evaluated with leave-one-episode-out cross-validation. Each episode is left out, the model is trained on the rest, and the held-out episode is ranked by predicted probability.

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

In each episode, the question is not simply “is this baker good?” The question is:

> **Where does this baker rank among the people still competing this week?**

That is also how the show feels as a viewer. The judges are not comparing a current baker to every Netflix-era contestant. They are comparing that baker to the people standing beside them. This is why top-2 and top-3 accuracy are useful: even when the model misses the exact decision, it usually identifies the small group the episode is really about.

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

---

## Finale predictions

The model picked the eventual winner in **6 of 9 finals** using episode LOOCV. In the three misses, the actual winner was still ranked second.

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

The Series 13 final shows why both weekly prediction and season-long strength are useful. The final-episode model favored Tom, but the season-long baker model ranks Jasmine first overall. That matches the distinction between “best final episode” and “strongest full-season profile.”

That distinction matters for how people argue about the show. Some winners look like they won because they were the strongest baker all season. Others look more like they survived long enough and then delivered when it counted. The final is not a lifetime achievement award. It is one episode with three people left.

---

## What matters for Star Baker?

<p align="center"><strong>Baseline Star Baker model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="22%">Predictor</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="44%">Plain-English interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center"><strong>2.046</strong></td>
      <td align="center">1.550 to 2.701</td>
      <td align="left">A one-point Signature gain nearly doubles Star Baker odds.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center"><strong>5.599</strong></td>
      <td align="center">3.282 to 9.552</td>
      <td align="left">A one-point Showstopper gain multiplies Star Baker odds by about 5.6.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center"><strong>0.673</strong></td>
      <td align="center">0.576 to 0.786</td>
      <td align="left">Moving one Technical rank worse lowers Star Baker odds; moving one rank better multiplies odds by about 1.49.</td>
    </tr>
  </tbody>
</table>

The main result is blunt:

> **The Showstopper dominates Star Baker selection.**

Signature and Showstopper scores are on the same scale, so the comparison is direct. A one-point Showstopper improvement is associated with a much larger change in Star Baker odds than a one-point Signature improvement.

<p align="center">
  <img src="results/sb_mod_plot.png" alt="Star Baker round-specific odds ratios" width="760">
</p>

The plot shows how those signals change over the season. Showstopper stays strongest across the season. Signature starts useful but weakens. Technical improvement matters, but it does not catch Showstopper as the clearest Star Baker signal.

For the show's audience, this is the clearest result: if you want Star Baker, the Showstopper is usually where the decision gets made. Signature can put someone in the conversation, and a strong Technical helps, but the final table presentation carries the biggest signal. That is not surprising, but the size of the gap is the point. The model says the Showstopper is not just slightly more important; it is the dominant Star Baker signal.

As a simple check, the group tied for best Showstopper score contains the actual Star Baker in **80 of 90 episodes**, or **88.9%** of the time.

---

## What matters for avoiding elimination?

<p align="center"><strong>Baseline elimination model</strong></p>

<table align="center" cellpadding="12" cellspacing="0" width="95%" style="border-collapse: collapse; margin: 0 auto 1.25rem auto; line-height: 1.35;">
  <thead>
    <tr>
      <th align="left" width="22%">Predictor</th>
      <th align="center" width="14%">Odds Ratio</th>
      <th align="center" width="20%">95% CI</th>
      <th align="left" width="44%">Plain-English interpretation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="left">Signature sum</td>
      <td align="center"><strong>0.487</strong></td>
      <td align="center">0.381 to 0.624</td>
      <td align="left">A better Signature lowers elimination risk.</td>
    </tr>
    <tr>
      <td align="left">Showstopper sum</td>
      <td align="center"><strong>0.458</strong></td>
      <td align="center">0.362 to 0.579</td>
      <td align="left">A better Showstopper lowers elimination risk.</td>
    </tr>
    <tr>
      <td align="left">Technical rank</td>
      <td align="center"><strong>1.553</strong></td>
      <td align="center">1.312 to 1.838</td>
      <td align="left">Moving one Technical rank worse raises elimination odds.</td>
    </tr>
  </tbody>
</table>

For elimination, the story is more balanced. Signature, Showstopper, and Technical all matter.

<p align="center">
  <img src="results/elim_mod_plot.png" alt="Elimination round-specific odds ratios" width="760">
</p>

The plot shows the key change over the season:

- Early on, Signature and Showstopper are strongly protective.
- As the field gets smaller, Technical performance becomes more important.
- By the middle and later rounds, a bad Technical can be especially damaging.

That makes practical sense. Early in the competition, there are many bakers and large differences in prepared bakes. Later, the remaining bakers are stronger and closer together, so Technical placement can separate the lower end of the group.

This also explains a common viewer reaction: early eliminations often feel like they are based on a clearly weak overall week, while later eliminations can feel harsher. By the later rounds, everyone is good. The margins shrink. A bad Technical can become harder to overlook because there are fewer obvious weak performances elsewhere.

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

By Round 9, there are fewer bakers and the score ranges are smaller. The remaining bakers are closer together, so Technical rank has more room to become decisive.

That is the statistical version of “the standards go up.” It is not necessarily that the judges suddenly care only about the Technical. It is that the remaining bakers are harder to separate on Signature and Showstopper alone. When the visible score spread compresses, a bad rank in the blind challenge becomes a cleaner way to identify who had the weakest week.

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

This is where the season-long model is useful for fans. It gives a way to separate “made it far” from “looked strong after accounting for the episodes and score components.” Those usually agree, but not always. Some finalists look strong because they were consistently strong. Others look more like survivors of a particular season path.

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

That is the main point: *Bake Off* is not awarded to the baker with the best full-season average. It is a survival competition with a final.

So when a winner is not ranked first by the season-long model, that does not automatically mean the model thinks the result was wrong. It means the title and the full-season profile are measuring different things. The winner won the competition structure. The adjusted baker effect summarizes observed strength across the season.

---

## Strong non-winner profiles

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

Series 9 stands out: Crystelle, Jürgen, and Chigs all appear among the strongest non-winner profiles. That supports the view that Series 9 had an unusually strong top group.

Steph, Josh, Gill, and Tom are also clear examples of bakers whose season-long profile looks stronger than their final placement alone would suggest. This is the useful part of the adjusted ranking: it can recover the bakers viewers remember as genuinely strong even if the final result or elimination order does not fully capture that.

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

This table separates the seasons into three rough groups:

- **Tight but winner-led:** Series 6, 8, and 9.
- **Mismatch seasons:** Series 7, 11, and 12, where the strongest fitted baker was not the winner.
- **Dominant-winner seasons:** Series 5, 10, and 13.

Series 9 has the tightest top group. Giuseppe ranked first, but Crystelle, Jürgen, and Chigs were all very strong. Series 13 is the opposite: Jasmine is more clearly separated from the rest of the top group.

For viewers, this gives a more precise way to talk about season strength. Some seasons are close because the top bakers are tightly packed. Some seasons are messy because the eventual winner is not the strongest adjusted profile. Some seasons are cleaner because the winner also separates from the field. Those are different stories, and the model lets them be separated instead of flattened into one winner list.

---

## How to read the results as a viewer

The model should not be read as a claim that the judges follow a formula. They do not. It is better read as a structured summary of the patterns left behind by their decisions.

The main viewer-facing interpretation is:

- **Star Baker is a high-point award.** The Showstopper is where the model sees the clearest separation.
- **Elimination is a risk decision.** A baker does not need to be the worst at everything; they just need the weakest overall case for staying.
- **The Technical matters more when the tent gets smaller.** Once the remaining bakers are all strong, rank-based separation becomes harder to ignore.
- **Winning the season is not the same as having the strongest adjusted season profile.** The show is sequential: survive each week, then win the final. This line of questions opens up models for predicting the overall winner that have mild separation in the rounds 1-9 but a large bump; in the importance at round 10 (you could win just by winning that finale like david or you could lose the finale and still win like jasmine)

That is why this project uses both weekly prediction and season-long adjusted profiles. One explains the episode decisions. The other summarizes the broader arc of each baker and season.

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
