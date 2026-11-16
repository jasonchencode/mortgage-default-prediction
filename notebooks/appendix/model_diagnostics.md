# Appendix: supporting model diagnostics

These checks support the logistic-regression result but are not needed in the
main presentation.

| Diagnostic | Logistic model | Simple baseline | What it supports |
|---|---:|---:|---|
| PR-AUC | 0.723 | 0.174 | The model identifies defaults well even though defaults are less common. Higher is better. |
| Log loss | 0.260 | 0.465 | The model assigns better probabilities and is penalized when it is confidently wrong. Lower is better. |
| Brier score | 0.082 | 0.144 | Predicted probabilities are closer to actual outcomes. Lower is better. |
| Average predicted default probability | 16.55% | 15.15% | The model's average prediction is close to the observed 2016 default rate of 17.42%. |

The calibration check also grouped applicants by predicted risk and compared
predicted probabilities with observed default rates. The groups were generally
close, which supports using the output as a probability rather than only as a
ranking score.

These results were measured on the 2016 validation period. They do not replace
the final evaluation on the untouched 2017–2018 test period. They also do not
determine the rejection threshold; that requires the bank's risk tolerance and
the relative costs of missed defaults and rejected non-defaulting applicants.
