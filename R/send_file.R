#' Send a file to Discord
#'
#' @param webhook_url Character string. Discord webhook URL
#' @param file_path Character string. File path.
#' @param message Character string. File description.
#' @param username Character string. Bot username (default: "R Bot")
#'
#' @returns Invisibly returns the httr response object
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
send_discord_file <- function(webhook_url, file_path, message = NULL, username = "R Bot") {

  # Read file
  file_content <- upload_file(file_path)

  # Create body
  body <- list(
    file = file_content
  )

  if (!is.null(message)) {
    body$content <- message
  }

  body$username <- username

  response <- POST(
    url = webhook_url,
    body = body,
    encode = "multipart"
  )

  if (status_code(response) == 200) {
    message("File uploaded successfully to Discord!")
  } else {
    warning("Failed to upload file. Status code: ", status_code(response))
  }

  return(invisible(response))
}
