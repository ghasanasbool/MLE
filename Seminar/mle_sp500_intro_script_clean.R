# ============================================================
# Seminar exercise: Maximum Likelihood Estimation with S&P 500 data
# Dataset: S&P 500 daily close, 2017
# Model: daily log returns are assumed Normal(mu, sigma^2)
# ============================================================

# ------------------------------------------------------------
# 1. Load the data
# ------------------------------------------------------------
# The exercise is designed to work offline if sp500_2017_fred.csv
# is in the same folder as this script. If it is not present,
# the script tries to download the same 2017 SP500 series from FRED.

csv_file <- "sp500_2017_fred.csv"
fred_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?cosd=2017-01-01&coed=2017-12-31&id=SP500"

if (file.exists(csv_file)) {
  sp500_prices <- read.csv(csv_file)
} else {
  message("Local CSV not found. Attempting to download SP500 2017 data from FRED.")
  sp500_prices <- read.csv(fred_url)
}

# FRED downloads sometimes name the date column observation_date.
# We standardise the name to Date so the rest of the script is stable.
if ("observation_date" %in% names(sp500_prices)) {
  names(sp500_prices)[names(sp500_prices) == "observation_date"] <- "Date"
}

# ------------------------------------------------------------
# 2. Clean the data
# ------------------------------------------------------------
# Date should be a Date object, not ordinary text.
# SP500 should be numeric, because we will take logs and differences.

sp500_prices$Date <- as.Date(sp500_prices$Date)
sp500_prices$SP500 <- as.numeric(sp500_prices$SP500)

# Keep only 2017 and remove missing values.
# Missing values usually correspond to non-trading days or holidays.
sp500_prices <- sp500_prices[
  sp500_prices$Date >= as.Date("2017-01-01") &
    sp500_prices$Date <= as.Date("2017-12-31"),
]

sp500_clean <- sp500_prices[!is.na(sp500_prices$SP500), ]

# ------------------------------------------------------------
# 3. Convert prices into daily log returns
# ------------------------------------------------------------
# We model returns rather than price levels.
# A log return is log(P_t) - log(P_{t-1}). Multiplying by 100
# expresses the return in percent.

returns <- 100 * diff(log(sp500_clean$SP500))
return_dates <- sp500_clean$Date[-1]

sp500_returns <- data.frame(
  Date = return_dates,
  Return = returns
)

# ------------------------------------------------------------
# 4. Closed-form MLE under the Normal model
# ------------------------------------------------------------
# Assumption: Return_t ~ Normal(mu, sigma^2)
# For this model, the MLE for mu is the sample mean.
# The MLE for sigma divides by n, not by n - 1.

mu_hat <- mean(returns)
sigma_hat <- sqrt(mean((returns - mu_hat)^2))
annualised_sigma_hat <- sigma_hat * sqrt(252)

cat("Number of price observations:", nrow(sp500_clean), "
")
cat("Number of return observations:", length(returns), "
")
cat("MLE mean daily return (%):", mu_hat, "
")
cat("MLE daily volatility (%):", sigma_hat, "
")
cat("Approx annualised volatility (%):", annualised_sigma_hat, "
")

# ------------------------------------------------------------
# 5. Write the log-likelihood and maximise it numerically
# ------------------------------------------------------------
# optim() minimises by default. MLE maximises the log-likelihood.
# Therefore, we give optim() the negative log-likelihood to minimise.

negative_log_likelihood <- function(par, data) {
  mu <- par[1]
  sigma <- par[2]

  # sigma is a standard deviation, so it must be positive.
  if (sigma <= 0) return(1e10)

  log_likelihood <- sum(dnorm(data, mean = mu, sd = sigma, log = TRUE))
  return(-log_likelihood)
}

fit <- optim(
  par = c(mu = 0, sigma = 1),
  fn = negative_log_likelihood,
  data = returns
)

cat("
Numerical optimisation estimates:
")
print(fit$par)

# ------------------------------------------------------------
# 6. Plot a visual model check
# ------------------------------------------------------------
# The histogram is the empirical distribution of returns.
# The curve is the Normal density fitted by MLE.

hist(
  returns,
  breaks = 25,
  probability = TRUE,
  main = "S&P 500 daily returns with fitted Normal density",
  xlab = "Daily log return (%)"
)

x_grid <- seq(min(returns), max(returns), length.out = 300)
lines(x_grid, dnorm(x_grid, mean = mu_hat, sd = sigma_hat), lwd = 2)
