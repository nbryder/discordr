#' Send a ggplot to Discord
#'
#' @param webhook_url Character string. Discord webhook URL
#' @param plot ggplot object. Plot to send
#' @param title Character string. Optional embed title
#' @param message Character string. Optional message
#' @param width Numeric. Plot width in inches (default: 10)
#' @param height Numeric. Plot height in inches (default: 6)
#' @param dpi Numeric. Plot resolution (default: 300)
#'
#' @return Invisibly returns the httr response object
#' @export
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
#' send_discord_plot(webhook_url, p, title = "My Plot")
#' }
send_discord_plot <- function(webhook_url, plot,
                              title = NULL, message = NULL,
                              width = 10, height = 6, dpi = 300) {

  if (missing(webhook_url) || webhook_url == "") {
    stop("webhook_url is required")
  }

  if (missing(plot)) {
    stop("plot is required")
  }

  if (!inherits(plot, "ggplot")) {
    stop("plot must be a ggplot object")
  }

  # Create temporary file
  temp_file <- tempfile(fileext = ".png")

  # Save plot
  ggplot2::ggsave(temp_file, plot = plot, width = width, height = height, dpi = dpi)

  # Prepare body
  body_list <- list(
    file = httr::upload_file(temp_file, type = "image/png")
  )

  # Add message/embed if provided
  if (!is.null(title) || !is.null(message)) {
    payload <- list(username = "R Bot")

    if (!is.null(title)) {
      embed <- list(
        title = title,
        image = list(url = paste0("attachment://", basename(temp_file))),
        color = 3447003
      )
      if (!is.null(message)) {
        embed$description <- message
      }
      payload$embeds <- list(embed)
    } else {
      payload$content <- message
    }

    body_list$payload_json <- jsonlite::toJSON(payload, auto_unbox = TRUE)
  }

  # Send to Discord
  response <- httr::POST(
    url = webhook_url,
    body = body_list,
    encode = "multipart"
  )

  # Clean up temp file
  unlink(temp_file)

  if (httr::status_code(response) == 200) {
    message("Plot sent successfully to Discord!")
  } else {
    warning("Failed to send plot. Status code: ", httr::status_code(response))
  }

  return(invisible(response))
}
