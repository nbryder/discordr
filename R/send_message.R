#' Send a message to discord server
#'
#' @param webhook_url Character string. Discord webhook URL.
#' @param message Character string. Message to send.
#' @param username Character string. Bot username (Default: R Bot).
#'
#' @returns Invisibly returns the httr response object.
#' @export
#'
#' @examples
#' \dontrun{
#' webhook_url <- Sys.getenv("DISCORD_WEBHOOK_URL")
#' send_discord_message(webhook_url, "Hello from R!")
#' }
send_discord_message <- function(webhook_url, message, username = "R Bot") {

  payload <- list(
    content = message,
    username = username
  )

  response <- httr::POST(
    url = webhook_url,
    body = jsonlite::toJSON(payload, auto_unbox = TRUE),
    encode = "json",
    content_type_json()
  )

  if (status_code(response) == 204) {
    message("Message sent successfully to Discord!")
  } else {
    warning("Failed to send message. Status code: ", status_code(response))
  }

  return(invisible(response))
}
