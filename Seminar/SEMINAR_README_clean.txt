MLE seminar exercise package
============================

This package is a cleaned seminar companion to the MLE lecture HTML.

Files
-----
- seminar_mle_sp500_formal.html
  Main student-facing interactive seminar page. Open this in a browser.

- mle_sp500_intro_seminar_clean.Rmd
  R Markdown source for students/instructors who want to run the full exercise in RStudio.

- mle_sp500_intro_script_clean.R
  Plain R script version of the same exercise.

- sp500_2017_fred.csv
  Offline CSV used by the R script and R Markdown file.

Teaching sequence
-----------------
1. Students complete the lecture HTML on MLE fundamentals.
2. In seminar, they use this exercise to apply MLE to daily S&P 500 log returns.
3. The aim is to connect likelihood notation to actual R code.

Model note
----------
The Normal model is used as a simple first model. It is intentionally easy to estimate and interpret, but students should discuss its weaknesses for financial returns.
