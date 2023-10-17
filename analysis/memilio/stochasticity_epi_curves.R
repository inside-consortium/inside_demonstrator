library(dplyr)
library(ggplot2)
library(patchwork)

load_console_output <- function(indir, list) {
  fn <- list.files(indir, pattern = "*console_output.csv", full.names = TRUE)
  
  for (i in seq_along(fn)) {
    temp <- read.csv(fn[i], header = FALSE, sep = " ")
    list[[i]] <- temp
  }
  
  return(list)
}

process_output <- function(cat) {
  dir <- paste0("../memilio-main/output/", cat)
  out_list <- load_console_output(dir, list())
  out_list <- lapply(out_list, function(x) x[-1, -10]) 
  out_df <- bind_rows(out_list, .id = "id")
  out_df <- out_df %>% mutate_if(is.character, as.numeric)
  
  names(out_df) <- c("Run", "Day", "S", "E", "I_NoSym", "I_Sym", "I_Sev", "I_Crit", "R", "D")
  out_df$totalInf <- out_df$I_NoSym + out_df$I_Sym + out_df$I_Sev + out_df$I_Crit
  out_df$Run <- as.factor(out_df$Run)
  
  plotA <- ggplot(data = out_df, aes(x = Day, y = totalInf, color = Run, group = Run)) +
    geom_line() + ylab("Total # of Prevalent Infections") + 
    scale_y_continuous(expand = c(0,0), limits = c(0, 90)) + scale_x_continuous(expand = c(0,0)) +
    guides(color = "none") 
  
  out_df_sum <- out_df %>% group_by(Day) %>% 
    summarise(minInf = min(totalInf), maxInf = max(totalInf), meanInf = mean(totalInf), 
              q025Inf = quantile(totalInf, probs = 0.025), q975Inf = quantile(totalInf, probs = 0.975))
  
  plotB <- ggplot(data = out_df_sum, aes(x = Day, y = q025Inf)) +
    geom_ribbon(data = out_df_sum, aes(ymin = q025Inf, ymax = q975Inf), fill = "dodgerblue4", alpha = 0.5) +
    geom_line(aes(y = meanInf), color = "dodgerblue4") + ylab("Total # of Prevalent Infections") + 
    scale_y_continuous(expand = c(0,0), limits = c(0, 90)) + scale_x_continuous(expand = c(0,0)) 
  
  out_df_sum$cat <- rep(cat, nrow(out_df_sum))
  
  return(list(plotA = plotA, plotB = plotB, out_df_sum = out_df_sum))
}

plot1 <- process_output("const_seed")
plot1a <- plot1$plotA + labs(title = "Location & Infection Initialization Fixed")
plot1b <- plot1$plotB + labs(title = "Location & Infection Initialization Fixed")

plot2 <- process_output("rand_seed_inf")
plot2a <- plot2$plotA + labs(title = "Infection Initialization Varying Only")
plot2b <- plot2$plotB + labs(title = "Infection Initialization Varying Only")

plot3 <- process_output("rand_seed_loc")
plot3a <- plot3$plotA + labs(title = "Location Initialization Varying Only")
plot3b <- plot3$plotB + labs(title = "Location Initialization Varying Only")

plot4 <- process_output("rand_seed")
plot4a <- plot4$plotA + labs(title = "Location & Infection Initialization Varying")
plot4b <- plot4$plotB + labs(title = "Location & Infection Initialization Varying")

combined1 <- plot1a + plot2a + plot3a + plot4a
combined1 + plot_layout(nrow = 2)
ggsave("Figure1.tiff", width = 12, height = 12, units = "in", dpi=300, compression = 'lzw')

combined2 <- plot1b + plot2b + plot3b + plot4b
combined2 + plot_layout(nrow = 2)
ggsave("Figure2.tiff", width = 12, height = 12, units = "in", dpi=300, compression = 'lzw')

# Plot All Intervals on 1 Graph -------------------------------------------

out_df_sum <- rbind(plot1$out_df_sum, plot2$out_df_sum, plot3$out_df_sum, plot4$out_df_sum)
ggplot(data = out_df_sum, aes(x = Day, y = q025Inf, group = cat, color = cat, fill = cat)) +
  geom_ribbon(data = out_df_sum, aes(ymin = q025Inf, ymax = q975Inf, fill = cat), alpha = 0.3) +
  ylab("Total # of Prevalent Infections") + 
  scale_fill_manual(labels = c("Both Fixed", "Both Random", "Init Inf Random", "Init Loc Random"), 
                    values = c("dodgerblue4", "darkgreen", "red", "darkorchid4"), name = NULL) +
  scale_color_manual(values = c("dodgerblue4", "darkgreen", "red", "darkorchid4"), guide = NULL) +
  scale_y_continuous(expand = c(0,0)) + scale_x_continuous(expand = c(0,0))
ggsave("Figure3.tiff", width = 12, height = 12, units = "in", dpi=300, compression = 'lzw')
