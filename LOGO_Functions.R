## ----setup, include=FALSE-----------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(magick)
library(here)


## -----------------------------------------------------------------------------------------------------------------
CLEARSCREEN <- function () {
  rm(list = ls(envir = LOGO), envir = LOGO)
  new_field()
}


## -----------------------------------------------------------------------------------------------------------------
CS <- function () {
  CLEARSCREEN()
}


## -----------------------------------------------------------------------------------------------------------------
HIDETURTLE <- function () {
  LOGO$turtle <- FALSE
  record_path(turtle = LOGO$turtle)
}


## -----------------------------------------------------------------------------------------------------------------
HT <- function () {
  HIDETURTLE()
}


## -----------------------------------------------------------------------------------------------------------------
SHOWTURTLE <- function () {
  LOGO$turtle <- TRUE
  record_path(turtle = LOGO$turtle)
}


## -----------------------------------------------------------------------------------------------------------------
ST <- function () {
  SHOWTURTLE()
}


## -----------------------------------------------------------------------------------------------------------------
FORWARD <- function (step) {
  angle <- LOGO$path$rad[LOGO$pos] 
  x0 <- LOGO$path$x[LOGO$pos]
  y0 <- LOGO$path$y[LOGO$pos]
  
  max_step <- 1
  
  if (abs(step) > max_step) {
    n_step <- abs(step)%/%(max_step * 1.5) + 1
    Seq0 <- seq(from = 0, to = 1, by = 1/n_step)
    Seq0 <- Seq0[-1]
    steps <- qbeta(Seq0, shape1 = 0.15, shape2 = 0.2)
    steps <- steps * step
  } else {
    steps <- step
  }
  
  x1 <- x0 + cos(angle) * steps
  y1 <- y0 + sin(angle) * steps
  
  record_path(x = x1, y = y1, path_color = LOGO$path_color)
}


## -----------------------------------------------------------------------------------------------------------------
FD <- function (step) {
  FORWARD(step)
}


## -----------------------------------------------------------------------------------------------------------------
BACK <- function (steps) {
  FORWARD(-steps)
}


## -----------------------------------------------------------------------------------------------------------------
BK <- function (steps) {
  BACK(steps)
}


## -----------------------------------------------------------------------------------------------------------------
LEFT <- function (degs) {
  LOGO$heading <- LOGO$heading + degs
  LOGO$heading <- LOGO$heading %% 360
  record_path(rad = LOGO$heading * pi / 180)
}


## -----------------------------------------------------------------------------------------------------------------
LT <- function (degs) {
  LEFT(degs)
}


## -----------------------------------------------------------------------------------------------------------------
RIGHT <- function (degs) {
  LEFT(-degs)
}


## -----------------------------------------------------------------------------------------------------------------
RT <- function (degs) {
  RIGHT(degs)
}


## -----------------------------------------------------------------------------------------------------------------
SETHEADING <- function (deg) {
  LOGO$heading <- deg
  record_path(rad = LOGO$heading * pi / 180)
}


## -----------------------------------------------------------------------------------------------------------------
SH <- function (deg) {
  SETHEADING(deg)
}


## -----------------------------------------------------------------------------------------------------------------
SETPOS <- function (x1, y1) {
  record_path(x = x1, y = y1, path_color = "transparent")
}


## -----------------------------------------------------------------------------------------------------------------
SP <- function (x1, y1) {
  SETPOS(x1, y1)
}


## -----------------------------------------------------------------------------------------------------------------
HOME <- function () {
  SETPOS(x1 = 0, y1 = 0)
}


## -----------------------------------------------------------------------------------------------------------------
SETPOSX <- function (x1) {
  SETPOS(x1, y1 = LOGO$path$y[LOGO$pos])
}


## -----------------------------------------------------------------------------------------------------------------
SPX <- function (x1) {
  SETPOSX(x1)
}


## -----------------------------------------------------------------------------------------------------------------
SETPOSY <- function (y1) {
  SETPOS(x1 = LOGO$path$x[LOGO$pos], y1)
}


## -----------------------------------------------------------------------------------------------------------------
SPY <- function (y1) {
  SETPOSY(y1)
}


## -----------------------------------------------------------------------------------------------------------------
SETPATHCOLOR <- function (path_color) {
  LOGO$path_color <- path_color
  record_path(path_color = LOGO$path_color)
}


## -----------------------------------------------------------------------------------------------------------------
SPC <- function (path_color) {
  SETPATHCOLOR(path_color)
}


## -----------------------------------------------------------------------------------------------------------------
SETTURTLECOLOR <- function (turtle_color) {
  LOGO$turtle_color <- turtle_color
  record_path(turtle_color = LOGO$turtle_color)
}


## -----------------------------------------------------------------------------------------------------------------
STC <- function (turtle_color) {
  SETTURTLECOLOR(turtle_color)
}


## -----------------------------------------------------------------------------------------------------------------
SETNEWCHUNK <- function () {
  LOGO$chunk <- LOGO$chunk + 1
  record_path(chunk = LOGO$chunk)
}


## -----------------------------------------------------------------------------------------------------------------
SNC <- function () {
  SETNEWCHUNK()
}


## -----------------------------------------------------------------------------------------------------------------
UNDOCHUNK <- function () {
  last_chunk <- max(LOGO$path$chunk)
  if (last_chunk > 2) {
    Range <- range(which(LOGO$path$chunk == last_chunk))
    del_pos <- seq(Range[1],Range[2])
    n <- length(del_pos)
    LOGO$path[del_pos,] <- empty_path(n)
    
    LOGO$pos <- Range[1] - 1
    LOGO$chunk <- LOGO$chunk -1
    LOGO$heading <- LOGO$path$rad[LOGO$pos] * 180 / pi
    LOGO$turtle <- LOGO$path$turtle[LOGO$pos]
    LOGO$turtle_color <- LOGO$path$turtle_color[LOGO$pos]
    
    last_pos <- LOGO$pos 
    while (LOGO$path$path_color[last_pos] == "transparent" && last_pos > 0) {
      last_pos <- last_pos - 1
    }
    if (last_pos == 0) {
      LOGO$path_color <- "blue"
    } else {
      LOGO$path_color <- LOGO$path$path_color[last_pos]
    }
  } 
  LOGO$size <-10
  REPLOT()
}


## -----------------------------------------------------------------------------------------------------------------
UNDO <- function () {
  UNDOCHUNK()
}


## -----------------------------------------------------------------------------------------------------------------
SETSPEED <- function (speed) {
  speed <- pmax(speed, 1)
  speed <- round(speed)
  LOGO$speed <- speed
}


## -----------------------------------------------------------------------------------------------------------------
SPEED <- function (speed) {
  SETSPEED(speed)
}


## -----------------------------------------------------------------------------------------------------------------
REPLOT <- function (chunk = FALSE) {
  PLOT(chunk)
}


## -----------------------------------------------------------------------------------------------------------------
SAVESCREEN <- function (name) {
  name_gif <- paste0(name, ".gif")
  REPLOT()
  file.copy(from = file.path(tempdir(), "Logo_Output.gif"), 
            to = here( name_gif), 
            overwrite = TRUE)
}


## -----------------------------------------------------------------------------------------------------------------
SAVE <- function (name) {
  SAVESCREEN(name)
}


## -----------------------------------------------------------------------------------------------------------------
QUITLOGO <- function () {
  if (exists("LOGO", envir = .GlobalEnv)) {
  rm(LOGO, envir = .GlobalEnv)
}
}


## -----------------------------------------------------------------------------------------------------------------
QUIT <- function () {
  QUITLOGO()
}


## -----------------------------------------------------------------------------------------------------------------
clean_prompt <- function (Prompt) {
  Prompt <- gsub("([^a-zA-Z0-9])", " \\1 ", Prompt)
  Prompt <- gsub("\\s+", " ", Prompt)
  Prompt <- gsub("-\\s+(?=\\d)", "-", Prompt, perl = TRUE)
  Prompt <- gsub("\\s*\\.\\s*", ".", Prompt)
  Prompt <- gsub("\\s*_\\s*", "_", Prompt)
  Prompt <- trimws(Prompt)
  Prompt
}


## -----------------------------------------------------------------------------------------------------------------
breakup_String <- function(String) {
  cl_String <- clean_prompt(String)
  split_String <- strsplit(cl_String, " ")[[1]]
  df <- data.frame(Code = split_String)
  
  n_func <- 0
  df$ID_Func <- rep(0, nrow(df))
  
  n_par <- 0
  df$ID_Par <- rep(0, nrow(df))
  
  ID <- 1
  df$ID_Repeat <- rep(0, nrow(df))
  
  brakets <- data.frame(ID = ID,
                        Status = TRUE,
                        n = 1)
  
  level <- brakets$ID[max(which(brakets$Status == TRUE))]
  
  df$n_Repeat <- rep(1, nrow(df))
  
  is_par_braket <- FALSE
  
  i <- 1
  imax <- nrow(df) + 1
  
  while ( i < imax ) {
    
    if (df$Code[i] == "[") {
        n_par <- n_par + 1
        is_par_braket <- TRUE
        i <- i + 1
        next
    }
    
    if (is_par_braket) {
      
      if (df$Code[i] == "]") {
        is_par_braket <- FALSE
        i <- i + 1
        next
      }
      
      if ( !grepl("[A-Za-z]", df$Code[i])) {
        df$ID_Func[i] <- n_func
        df$ID_Par[i] <- n_par
        df$ID_Repeat[i] <- brakets$ID[brakets$ID == level]
        df$n_Repeat[i] <- brakets$n[brakets$ID == level]
        i <- i + 1
        next
      } else {
        inLower <- tolower(df$Code[i])
        if (inLower == "n") {
          df$Code[i] <- paste0("(",inLower,")")
        } else if (inLower %in% colors()) {
          df$Code[i] <- paste0("'",inLower,"'")
        } else if (exists(inLower)) {
          df$Code[i] <- inLower
        }  else {
          df$Code[i] <- paste0("'",df$Code[i],"'")
        }
        df$ID_Func[i] <- n_func
        df$ID_Par[i] <- n_par
        df$ID_Repeat[i] <- brakets$ID[brakets$ID == level]
        df$n_Repeat[i] <- brakets$n[brakets$ID == level]
        i <- i + 1
        next
      }
      
    } else {
      
      if (df$Code[i] == "]") {
      brakets$Status[brakets$ID == level] <- FALSE
      level <- brakets$ID[max(which(brakets$Status == TRUE))]
      i <- i + 1
      next
      }
      
      if ( !grepl("[A-Za-z]", df$Code[i]) ) {
        n_par <- n_par + 1
        df$ID_Func[i] <- n_func
        df$ID_Par[i] <- n_par
        df$ID_Repeat[i] <- brakets$ID[brakets$ID == level]
        df$n_Repeat[i] <- brakets$n[brakets$ID == level]
        i <- i + 1
        next
      } else {
        inCaps <- toupper(df$Code[i])
        
        is_LOGO_func <- exists(inCaps) && is.function(get(inCaps))
        if (is_LOGO_func) {
          n_func <- n_func + 1
          df$Code[i] <- inCaps
        }
      
        is_repeat <- inCaps == "REPEAT"
        if (is_repeat) {
          n_func <- n_func + 1
          ID <- ID + 1
          i = i + 2
          df$Code[i] <- inCaps
          brakets <- rbind(brakets,
                           data.frame(ID = ID, 
                                      Status = TRUE, 
                                      n = round(as.numeric(df$Code[i - 1]))))
          level <- brakets$ID[max(which(brakets$Status == TRUE))]
        }
        df$ID_Func[i] <- n_func
        df$ID_Repeat[i] <- brakets$ID[brakets$ID == level]
        df$n_Repeat[i] <- brakets$n[brakets$ID == level]
        i <- i + 1
        next
      }
    }

  }
  return(df[df$ID_Func != 0,])
}

## -----------------------------------------------------------------------------------------------------------------
create_Calls <- function (splited) {
  Calls <- splited %>%
    group_by(ID_Func, ID_Par) %>%
    mutate(Func_Par = ifelse(ID_Par > 0,1,0),
           Code = ifelse(first(ID_Par) > 0, 
                         paste0(Code, collapse = ""),
                         Code)) %>%
    ungroup() %>%
    distinct(Code, ID_Func, ID_Par, Func_Par, .keep_all = TRUE) %>%
    
    group_by(ID_Func, Func_Par) %>%
    mutate(Code = ifelse(first(Func_Par) > 0, 
                         paste0(Code, collapse = ", "), 
                         Code)) %>%
    ungroup() %>%
    distinct(Code, ID_Func, Func_Par, .keep_all = TRUE) %>%
  
    group_by(ID_Func) %>%
    mutate(Code = ifelse(n() > 1,
                         paste0(Code, collapse = "("),
                         paste0(Code, "(")),
           Code = paste0(Code, ")")) %>%
    ungroup() %>%
    distinct(Code, ID_Func, .keep_all = TRUE) %>%
    rename(Call = Code, ID = ID_Repeat, n = n_Repeat ) %>%
    select(Call,ID, n)
  
  first_call <- data.frame(Call = "", ID = 1, n = 1)
  last_call <- data.frame(Call = "", ID = 1, n = 1)
  
  if ( !any(grepl("^UNDO|SPEED|SAVE|QUIT", Calls$Call)) ) {
    first_call <- data.frame(Call = "SETNEWCHUNK()", ID = 1, n = 1)
    last_call <- data.frame(Call = "PLOT()", ID = 1, n = 1)
  } 
  Calls <- rbind(first_call, Calls, last_call)
  Calls
}


## -----------------------------------------------------------------------------------------------------------------

expand_Repeats <- function (Calls) {
  IDmax <- max(Calls$ID)
  if (IDmax == 1) {
    return(as.vector(Calls$Call))
  } 
  while (IDmax > 1){
    
    dfm <- data.frame(
      Call = character(),
      ID = integer(),
      n = integer(),
      stringsAsFactors = FALSE
      )
    
    rID <- range(which(Calls$ID == IDmax))
    n <- Calls$n[rID[1]] 
    middle <- (rID[1] + 1):rID[2]
    
    for (i in 1:n) {
      dfm_sub <- Calls[middle, ] %>%
        mutate(Call = gsub("\\(n\\)", i, Call))
      dfm <- rbind(dfm,dfm_sub)
      }
    dfm$ID <- Calls$ID[rID[1]-1]
    dfm$n <- Calls$n[rID[1]-1]
    
    before <- 1:(rID[1] - 1)
    dfb <- Calls[before, ]
    
    after <- (rID[2] + 1):nrow(Calls)
    dfa <- Calls[after, ]
    
    Calls <- rbind(dfb,dfm,dfa)
    IDmax <- max(Calls$ID)
  }
  return(as.vector(Calls$Call[Calls$Call != ""]))
}


## -----------------------------------------------------------------------------------------------------------------
run_prompt <- function (Prompt) {
  Prompt_splited <- breakup_String(Prompt)
  Callshort <- create_Calls(Prompt_splited)
  Calls <- expand_Repeats(Callshort)
  for (i in 1:length(Calls)){
    eval(parse(text = as.character(Calls[i])))
    }
}


## -----------------------------------------------------------------------------------------------------------------
empty_path <- function(n) {
  path <- data.frame(
    chunk = rep(0, n),
    x = rep(NA_real_, n),
    y = rep(NA_real_, n),
    rad = rep(NA_real_, n),
    path_color = rep(NA_character_, n),
    turtle = rep(NA, n),
    turtle_color = rep(NA_character_, n),
    stringsAsFactors = FALSE)
  path
}

## -----------------------------------------------------------------------------------------------------------------
extend_path <- function(n = 20000) {
  new_rows <- empty_path(n)
  
  if (!("path" %in% names(LOGO)) || is.null(LOGO$path)) {
    LOGO$path <- new_rows
  } else {
    new_pos <- seq_len(n) + nrow(LOGO$path)
    LOGO$path[new_pos, ] <- new_rows
  }
}

## -----------------------------------------------------------------------------------------------------------------
new_field <- function (size = 10) {
  # LOGO$field_name = "LOGO"
  # LOGO$field_dir = here()
  LOGO$size = abs(size)
  LOGO$chunk <- 1
  LOGO$pos <- 1
  LOGO$heading <- 0
  LOGO$turtle <- TRUE
  LOGO$turtle_color <- "red"
  LOGO$path_color <- "blue"
  LOGO$speed <- 50
  
  extend_path()
  
  LOGO$path[1, ] <- list(
    chunk = 1,
    x = 0,
    y = 0,
    rad = 0,
    path_color = "transparent",
    turtle = FALSE,
    turtle_color = "red")
  
  SHOWTURTLE()
  SETNEWCHUNK()
  
}



## -----------------------------------------------------------------------------------------------------------------
 record_path <- function (chunk = NULL,
                          x = NULL, 
                          y = NULL, 
                          rad = NULL, 
                          path_color = NULL, 
                          turtle = NULL,
                          turtle_color = NULL) {
   
   n <- max(length(x), length(y), 1)
   template <- LOGO$path[LOGO$pos, ]
   
   if (n > 1) {
     newrows <- template[rep(1,n), ]
     new_pos <- LOGO$pos + (1:n)
   } else {
     newrows <- template
     new_pos <- LOGO$pos + 1
   }
   
   
   if (!is.null(chunk)) newrows$chunk <- chunk
   if (!is.null(x)) newrows$x <- x
   if (!is.null(y)) newrows$y <- y
   if (!is.null(rad)) newrows$rad <- rad
   if (!is.null(path_color)) newrows$path_color <- path_color
   if (!is.null(turtle)) newrows$turtle <- turtle
   if (!is.null(turtle_color)) newrows$turtle_color <- turtle_color
   
   LOGO$path[new_pos,] <- newrows
   LOGO$pos <- LOGO$pos + n

}


## -----------------------------------------------------------------------------------------------------------------
plot_field <- function (stat) {
  maxpath <- ceiling(max(abs(LOGO$path[1:stat,c("x","y")])) * 1.11)
  LOGO$size <- max(c(LOGO$size, maxpath), na.rm = TRUE)

  par(mar = c(0, 0, 0, 0),
      xaxs = "i", yaxs = "i")
  plot.new()
  plot.window(xlim = c(-LOGO$size, LOGO$size),
              ylim = c(-LOGO$size, LOGO$size),
              asp = 1)
  box()
}


## -----------------------------------------------------------------------------------------------------------------
plot_path <- function (stat) {
  if (stat > 1) {
    path_stat <- LOGO$path[1:stat,]
    segments(x0 = path_stat$x[-stat], 
             y0 = path_stat$y[-stat],
             x1 = path_stat$x[-1], 
             y1 = path_stat$y[-1],
             col = path_stat$path_color[-1], 
             lwd = 2)
  }
}


## -----------------------------------------------------------------------------------------------------------------
plot_turtle <- function (stat) {
  show <-  LOGO$path$turtle[stat]
  if (show) {
    pos_x <- LOGO$path$x[stat]
    pos_y <- LOGO$path$y[stat]
    symbols(x = pos_x,
            y = pos_y,
            circles = 0.02 * LOGO$size,
            inches = FALSE,
            fg = NA,
            bg = LOGO$path$turtle_color[stat],
            add = TRUE)
    arrow_length <- 0.1 * LOGO$size
    angle <- LOGO$path$rad[stat]
    arrows(pos_x,
           pos_y,
           pos_x + cos(angle) * arrow_length,
           pos_y + sin(angle) * arrow_length,
           col = LOGO$path$turtle_color[stat],
           code = 2,
           length = 0.1,
           angle = 20,
           lwd = 2)
  }
}


## -----------------------------------------------------------------------------------------------------------------
plot_stat <- function (stat = NULL) {
  if(is.null(stat)) stat <- LOGO$pos
  
  tmpfile <- tempfile(fileext = ".png")
  png(filename = tmpfile, width = 600, height = 600, res = 150)
  
  plot_field(stat)
  plot_path(stat)
  plot_turtle(stat)
  
  dev.off()
  img <- image_read(tmpfile)
  
  unlink(tmpfile)

  img

}


## -----------------------------------------------------------------------------------------------------------------
PLOT <- function (chunk = TRUE) {
  if (chunk) {
    Range <- range(which(LOGO$path$chunk == max(LOGO$chunk)))
    rmin <- max(2,Range[1])
    rmax <- Range[2]
    } else {
      rmin <- 2
      rmax <- LOGO$pos
    }
  
  step <- LOGO$speed/(rmax-rmin)
  step <- pmin(pmax(step, 1/200), 1)
  Seq0 <- seq(from = 0, to = 1, by = step)
  plot_seq <- qbeta(Seq0, shape1 = 0.15, shape2 = 0.2)
  plot_seq <- (rmax - rmin) * plot_seq + rmin
  plot_seq <- round(plot_seq)
  plot_seq <- unique(plot_seq)
  
  img_list <- lapply(plot_seq, function(i) plot_stat(i))
  Logo_Output <- image_animate(image_join(img_list), 
                             fps = 10, loop = 1,
                             optimize = TRUE) 
  
  gif_path <- file.path(tempdir(), "Logo_Output.gif")
  image_write(Logo_Output, path = gif_path)
  
  print(Logo_Output)
}


## -----------------------------------------------------------------------------------------------------------------
run_LOGO <- function(string) {
  if (!exists("LOGO", envir = .GlobalEnv)) {
    assign("LOGO", new.env(), envir = .GlobalEnv)
    LOGO <- get("LOGO", envir = .GlobalEnv)
    new_field(5)
  } else {
    LOGO <- get("LOGO", envir = .GlobalEnv)
  }
  run_prompt(string)
}


