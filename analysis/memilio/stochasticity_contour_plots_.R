library(dplyr)
library(ggplot2)
library(patchwork)
library(viridis)
library(data.table)

epi_curve_one_loc <- function(row) {
  loc_id <- row[1]
  ts <- as.numeric(row[2])
  
  out <- data.frame(LocationID = rep(loc_id, ts), timepoint = 0:(ts - 1), 
                    n_agents = rep(NA, ts), n_inf = rep(NA, ts))
  
  timestep_col_id <- 3
  
  for (t in 1:ts) {
    timepoint <- row[timestep_col_id]
    
    if (is.na(timepoint)) {
      break 
    } else {
      n_agents = as.numeric(row[timestep_col_id + 1])
      agent_ids <- c()
      transmission_times <- c()
      if (n_agents > 0) {
        for (i in 1:n_agents) {
          agent_id = row[timestep_col_id + 1 + 1 + (i - 1) * 2]
          agent_ids <- c(agent_ids, agent_id)
          
          transmission_time <- row[timestep_col_id + 1 + 2 + (i - 1) * 2]
          transmission_times <- c(transmission_times, transmission_time)
        }
      }
      
      out[t, 3] <- n_agents
      
      transmission_times <- transmission_times[which(transmission_times != -1)]
      out[t, 4] <- length(transmission_times)
      
      timestep_col_id <- timestep_col_id + 2 + n_agents*2
    }
  }
  
  return(out)
}

epi_curve_all_loc <- function(out_df) {
  out <- data.frame(LocationID = character(), timepoint = numeric(), n_agents = numeric(), n_inf = numeric())
  
  for (i in seq_len(nrow(out_df))) {
    row <- as.character(out_df[i, ])
    temp <- epi_curve_one_loc(row)
    out <- rbind(out, temp)
    # print(paste0("Done with location #", i))
  }
  
  return(out)
}


process_one_sim <- function(fn, ind) {
  
  num_col <- max(count.fields(fn, sep = " "))
  
  temp <- NULL
  try(temp <- fread(fn, sep = " ", header = FALSE, col.names = as.character(1:num_col), fill = TRUE), TRUE)
  if (is.null(temp)) {
    temp <- read.table(file = fn, header = FALSE, sep = "", col.names = as.character(1:num_col), fill = TRUE)
  }
  print(paste0("Loaded File #", ind))
  
  epi_curve <- epi_curve_all_loc(temp)
  epi_curve$run <- ind
  
  return(epi_curve)
}

process_one_cat <- function(cat, max_ind) {
  
  dir <- paste0("../memilio-main/output/", cat)
  fns <- list.files(dir, pattern = "*output.txt", full.names = TRUE)
  
  list <- list()
  for (i in seq_len(max_ind)) {
    fn <- fns[i]
    df <- process_one_sim(fn, i)
    list[[i]] <- df
  }
  
  df <- bind_rows(list)
  
  df$prev <- ifelse(df$n_agents == 0, NA, df$n_inf / df$n_agents)
  df$run <- as.factor(df$run)
  
  df2 <- df %>% group_by(LocationID, timepoint) %>% 
    summarise(meanInf = mean(n_inf), meanPrev = mean(prev, na.rm = TRUE),
              minInf = min(n_inf), minPrev = min(prev, na.rm = TRUE),
              maxInf = max(n_inf), maxPrev = max(prev, na.rm = TRUE))
  df2$rangeInf <- df2$maxInf - df2$minInf
  df2$rangePrev <- df2$maxPrev - df2$minPrev
  df2[sapply(df2, is.infinite)] <- NA
  
  return(df2)
} 

createPlots <- function(df) {
  
  plotB <- ggplot(df, aes(timepoint, LocationID)) +
    geom_raster(aes(fill = meanPrev), interpolate = TRUE) +
    theme_minimal() +
    scale_x_discrete(expand = c(0, 0)) +
    scale_y_discrete(breaks = c("I00100", "I00198", "I00312", "I00411", "I0054", "I1000")) + 
    labs(x = "Hour", y = "Location ID") +
    scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1, name = "", limits = c(0, 1)) + 
    theme(legend.title=element_blank())
  
  plotD <- ggplot(df, aes(timepoint, LocationID)) +
    geom_raster(aes(fill = rangePrev), interpolate = TRUE) +
    theme_minimal() +
    scale_x_discrete(expand = c(0, 0)) +
    scale_y_discrete(breaks = c("I00100", "I00198", "I00312", "I00411", "I0054", "I1000")) + 
    labs(x = "Hour", y = "Location ID") +
    scale_fill_viridis(discrete = FALSE, alpha = 1, option = "D", direction = 1, name = "", limits = c(0, 1)) + 
    theme(legend.title=element_blank())
  
  return(list(plotB = plotB, plotD = plotD))
}


df1 <- process_one_cat("const_seed", 250)
plot1 <- createPlots(df1)
plot1b <- plot1$plotB + labs(title = "Location & Infection Initialization Fixed")
plot1d <- plot1$plotD + labs(title = "Location & Infection Initialization Fixed")

df2 <- process_one_cat("rand_seed_inf", 250)
plot2 <- createPlots(df2)
plot2b <- plot2$plotB + labs(title = "Infection Initialization Varying Only")
plot2d <- plot2$plotD + labs(title = "Infection Initialization Varying Only")

df3 <- process_one_cat("rand_seed_loc", 250)
plot3 <- createPlots(df3)
plot3b <- plot3$plotB + labs(title = "Location Initialization Varying Only")
plot3d <- plot3$plotD + labs(title = "Location Initialization Varying Only")

df4 <- process_one_cat("rand_seed", 250)
plot4 <- createPlots(df4)
plot4b <- plot4$plotB + labs(title = "Location & Infection Initialization Varying")
plot4d <- plot4$plotD + labs(title = "Location & Infection Initialization Varying")

combined1 <- plot1b + plot2b + plot3b + plot4b
combined1 + plot_layout(nrow = 2, guides = "collect")
ggsave("Figure4.tiff", width = 12, height = 12, units = "in", dpi=300, compression = 'lzw')

combined2 <- plot1d + plot2d + plot3d + plot4d
combined2 + plot_layout(nrow = 2, guides = "collect")
ggsave("Figure5.tiff", width = 12, height = 12, units = "in", dpi=300, compression = 'lzw')

