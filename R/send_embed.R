#' Send an Embed to Discord
#'
#' @param webhook_url Character string. Discord webhook URL
#' @param title Character string. Embed title
#' @param description Character string. Embed description
#' @param color Integer. Color code (default: 3447003 for blue)
#' @param fields List of lists. Optional fields to add
#' @param username Character string. Bot username (default: "R Bot")
#'
#' @return Invisibly returns the httr response object
#' @export
#'
#' @examples
#' \dontrun{
#' webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")
#' send_discord_embed(
#'   webhook_url,
#'   title = "Analysis Complete",
#'   description = "Results are ready"
#' )
#' }
send_discord_embed <- function(webhook_url, title, description,
                               color = 3447003, fields = NULL,
                               username = "R Bot") {

  if (missing(webhook_url) || webhook_url == "") {
    stop("webhook_url is required")
  }

  embed <- list(
    title = title,
    description = description,
    color = color,
    timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    footer = list(text = "R Analysis Bot")
  )

  if (!is.null(fields)) {
    embed$fields <- fields
  }

  payload <- list(
    username = username,
    embeds = list(embed)
  )

  response <- httr::POST(
    url = webhook_url,
    body = jsonlite::toJSON(payload, auto_unbox = TRUE),
    encode = "json",
    httr::content_type_json()
  )

  if (httr::status_code(response) == 204) {
    message("Embed sent successfully to Discord!")
  } else {
    warning("Failed to send embed. Status code: ", httr::status_code(response))
  }

  return(invisible(response))
}
