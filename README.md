
<!-- README.md is generated from README.Rmd. Please edit that file -->

# discordr <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/nbryder/discordr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nbryder/discordr/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**discordr** makes it easy to send messages, embeds, files, and plots
from R directly to Discord channels using webhooks. Perfect for
monitoring long-running analyses, sharing results with collaborators, or
getting notified when your code finishes (or breaks!).

## Installation

You can install the development version of discordr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("nbryder/discordr")
```

## Setup

### 1. Create a Discord Webhook

1.  Open Discord and navigate to your server
2.  Go to **Server Settings** → **Integrations** → **Webhooks**
3.  Click **New Webhook** (or **Create Webhook**)
4.  Give your webhook a name (e.g., “R Bot”)
5.  Select the channel where messages should appear
6.  Click **Copy Webhook URL**

### 2. Store Your Webhook URL

**Recommended:** Store it in your `.Renviron` file for security:

``` r
# Edit your .Renviron file
usethis::edit_r_environ()

# Add this line (paste your actual webhook URL):
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK/URL

# Restart R for changes to take effect
```

Alternatively, set it for the current session:

``` r
webhook_url <- "https://discord.com/api/webhooks/YOUR/WEBHOOK/URL"
```

## Quick Start

``` r
library(discordr)

# Get your webhook URL from environment variable
webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")

# Send a simple message
send_discord_message(webhook_url, "Hello from R! 👋")
```

## Usage

### Send Messages

``` r
# Simple text message
send_discord_message(webhook_url, "Analysis complete!")

# With custom username
send_discord_message(
  webhook_url, 
  "Data processing finished", 
  username = "Data Bot"
)
```

### Send Rich Embeds

Embeds provide better formatting and visual appeal:

``` r
# Basic embed
send_discord_embed(
  webhook_url,
  title = "Analysis Complete",
  description = "Your analysis has finished successfully",
  color = discord_colors$green
)

# Embed with fields
send_discord_embed(
  webhook_url,
  title = "📊 Analysis Summary",
  description = "Monthly report completed",
  color = discord_colors$blue,
  fields = list(
    list(name = "Records Processed", value = "10,000", inline = TRUE),
    list(name = "Duration", value = "2.5 minutes", inline = TRUE),
    list(name = "Status", value = "✅ Success", inline = FALSE)
  )
)
```

### Available Colors

``` r
discord_colors$green    # 3066993  - Success
discord_colors$yellow   # 16776960 - Warning
discord_colors$red      # 15158332 - Error
discord_colors$blue     # 3447003  - Info
discord_colors$purple   # 10181046 - General
discord_colors$orange   # 15105570 - Alert
discord_colors$black    # 2303786  - Neutral
```

### Send Files

``` r
# Send a CSV file
write.csv(mtcars, "results.csv")
send_discord_file(webhook_url, "results.csv", message = "Here are the results!")

# Send any file type
send_discord_file(webhook_url, "report.pdf", message = "📄 Final report attached")
```

### Send Plots

``` r
library(ggplot2)

# Create a plot
p <- ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) + 
  geom_point(size = 3) +
  theme_minimal() +
  labs(
    title = "Fuel Efficiency vs Weight",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon",
    color = "Cylinders"
  )

# Send directly to Discord (no need to save to disk!)
send_discord_plot(
  webhook_url, 
  plot = p,
  title = "Analysis Results",
  message = "Weight negatively correlates with fuel efficiency"
)

# Customize plot dimensions
send_discord_plot(
  webhook_url,
  plot = p,
  width = 12,
  height = 8,
  dpi = 300
)
```

## Real-World Examples

### Monitor Long-Running Analysis

``` r
webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")

# Notify when starting
send_discord_message(webhook_url, "🚀 Starting analysis...")

# Run your analysis
start_time <- Sys.time()
results <- your_long_analysis()
duration <- difftime(Sys.time(), start_time, units = "mins")

# Notify when complete
send_discord_embed(
  webhook_url,
  title = "✅ Analysis Complete",
  description = sprintf("Finished in %.1f minutes", duration),
  color = discord_colors$green
)
```

### Error Notifications

``` r
tryCatch({
  # Your code here
  risky_operation()
  
  send_discord_message(webhook_url, "✅ Operation successful!")
  
}, error = function(e) {
  send_discord_embed(
    webhook_url,
    title = "❌ Error Occurred",
    description = paste("Error:", e$message),
    color = discord_colors$red
  )
  stop(e)
})
```

### Progress Updates

``` r
n_iterations <- 100

for (i in 1:n_iterations) {
  # Do work
  process_item(i)
  
  # Send update every 25 iterations
  if (i %% 25 == 0) {
    pct <- round(100 * i / n_iterations)
    send_discord_message(
      webhook_url,
      sprintf("Progress: %d%% complete (%d/%d)", pct, i, n_iterations)
    )
  }
}

send_discord_message(webhook_url, "✅ Processing complete!")
```

### Share Analysis Results

``` r
# Run analysis
model <- lm(mpg ~ wt + hp + cyl, data = mtcars)
r2 <- summary(model)$r.squared

# Create diagnostic plots
p1 <- ggplot(mtcars, aes(x = wt, y = mpg)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  theme_minimal()

p2 <- ggplot(data.frame(residuals = residuals(model)), aes(x = residuals)) +
  geom_histogram(bins = 20, fill = "steelblue") +
  theme_minimal()

# Send summary
send_discord_embed(
  webhook_url,
  title = "📊 Regression Results",
  description = "Linear model: mpg ~ wt + hp + cyl",
  fields = list(
    list(name = "R²", value = round(r2, 3), inline = TRUE),
    list(name = "Observations", value = nrow(mtcars), inline = TRUE),
    list(name = "Model", value = "Linear Regression", inline = FALSE)
  ),
  color = discord_colors$blue
)

# Send plots
send_discord_plot(webhook_url, p1, title = "Fitted vs Actual")
Sys.sleep(1)  # Avoid rate limiting
send_discord_plot(webhook_url, p2, title = "Residual Distribution")
```

### Daily Reports

``` r
# Create daily summary function
send_daily_report <- function() {
  webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")
  
  # Get today's data
  data <- get_daily_data()
  
  # Summary statistics
  send_discord_embed(
    webhook_url,
    title = "📅 Daily Report",
    description = format(Sys.Date(), "%B %d, %Y"),
    fields = list(
      list(name = "Records", value = format(nrow(data), big.mark = ","), inline = TRUE),
      list(name = "Mean Value", value = round(mean(data$value), 2), inline = TRUE),
      list(name = "Status", value = "✅ All systems operational", inline = FALSE)
    ),
    color = discord_colors$green
  )
  
  # Send visualization
  p <- ggplot(data, aes(x = date, y = value)) +
    geom_line(color = "steelblue", size = 1) +
    theme_minimal() +
    labs(title = "Daily Trend")
  
  send_discord_plot(webhook_url, p, title = "Trend Analysis")
}

# Run it
send_daily_report()

# Or schedule it (requires cronR or taskscheduleR)
```

## Tips

### Rate Limiting

Discord webhooks have rate limits. If sending multiple messages:

``` r
send_discord_message(webhook_url, "Message 1")
Sys.sleep(1)  # Wait 1 second
send_discord_message(webhook_url, "Message 2")
```

### Security

- Never commit webhook URLs to public repositories
- Use `.Renviron` for storing sensitive information
- Add `.Renviron` to your `.gitignore`

### Best Practices

``` r
# ✅ Good: Use environment variable
webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")

# ❌ Bad: Hardcode webhook URL
webhook_url <- "https://discord.com/api/webhooks/123/abc"

# ✅ Good: Check if webhook exists
if (Sys.getenv("DISCORD_WEBHOOK_URL") != "") {
  send_discord_message(Sys.getenv("DISCORD_WEBHOOK_URL"), "Hello!")
}

# ✅ Good: Use tryCatch for error handling
tryCatch({
  send_discord_message(webhook_url, "Test")
}, error = function(e) {
  message("Could not send to Discord: ", e$message)
})
```

## Function Reference

| Function                 | Description                       |
|--------------------------|-----------------------------------|
| `send_discord_message()` | Send a simple text message        |
| `send_discord_embed()`   | Send a rich embed with formatting |
| `send_discord_file()`    | Upload a file to Discord          |
| `send_discord_plot()`    | Send a ggplot directly from R     |
| `discord_colors`         | List of color codes for embeds    |

## Troubleshooting

### “webhook_url is required”

Make sure you’ve set your webhook URL:

``` r
# Check if it's set
Sys.getenv("DISCORD_WEBHOOK_URL")

# If empty, add it to .Renviron
usethis::edit_r_environ()
```

### “Failed to send message. Status code: 404”

Your webhook URL may be invalid or the webhook was deleted. Create a new
webhook in Discord.

### “Failed to send message. Status code: 429”

You’re being rate limited. Add `Sys.sleep(1)` between messages.

### Plots not showing

Make sure `ggplot2` is installed:

``` r
install.packages("ggplot2")
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT © Nicklas Bryder

## Acknowledgments

- Built with [{httr}](https://httr.r-lib.org/) and
  [{jsonlite}](https://jeroen.r-universe.dev/jsonlite)
- Inspired by the need for real-time R notifications
- Thanks to the Discord API for webhook support
