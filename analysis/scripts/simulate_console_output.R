create_console_output <- function(df_fn) {
  
  df <- read.table(file = df_fn, header = TRUE, sep = "")
  
  df$S_start <- ifelse(df$S == 0, Inf, 0)
  df$E_start <- ifelse(df$E == 0, Inf, df$S)
  df$I_ns_start <- ifelse(df$I_ns == 0, Inf, df$S + df$E)
  df$I_sy_start <- ifelse(df$I_sy == 0, Inf, df$S + df$E + df$I_ns)
  df$I_sev_start <- ifelse(df$I_sev == 0, Inf, df$S + df$E + df$I_ns + df$I_sy)
  df$I_cri_start <- ifelse(df$I_cri == 0, Inf, df$S + df$E + df$I_ns + df$I_sy + df$I_sev)
  df$R_start <- ifelse(df$R == 0, Inf, df$S + df$E + df$I_ns + df$I_sy + df$I_sev + df$I_cri)
  df$D_start <- ifelse(df$D == 0, Inf, df$S + df$E + df$I_ns + df$I_sy + df$I_sev + df$I_cri + df$R)
  
  my_df <- data.frame(ts = 0:336, numS = rep(NA, 337), numE = rep(NA, 337), numI_ns = rep(NA, 337),
                      numI_sy = rep(NA, 337), numI_sev = rep(NA, 337), numI_cri = rep(NA, 337), 
                      numR = rep(NA, 337), numD = rep(NA, 337))
  for (i in 1:337) {
    ts <- my_df$ts[i]
    my_df$numS[i] <- nrow(df[df$S_start <= ts & df$E_start > ts, ])
    my_df$numE[i] <- nrow(df[df$E_start <= ts & df$I_ns_start > ts, ])
    my_df$numI_ns[i] <- nrow(df[df$I_ns_start <= ts & df$I_sy_start > ts & df$R_start > ts, ])
    my_df$numI_sy[i] <- nrow(df[df$I_sy_start <= ts & df$I_sev_start > ts & df$R_start > ts, ])
    my_df$numI_sev[i] <- nrow(df[df$I_sev_start <= ts & df$I_cri_start > ts & df$R_start > ts, ])
    my_df$numI_cri[i] <- nrow(df[df$I_cri_start <= ts & df$R_start > ts & df$D_start > ts, ])
    my_df$numR[i] <- nrow(df[df$R_start <= ts, ])
    my_df$numD[i] <- nrow(df[df$D_start <= ts, ])
  }
  
  my_df$ts <- my_df$ts / 24
  
  return(my_df)
}

dir <- "../memilio/pycode/examples/simulation/ABM Demonstrator/output"
fns <- list.files(dir, pattern = "*infection_paths.txt", full.names = TRUE)

for (i in 1:250) {
  temp <- create_console_output(fns[i])
  write.csv(temp, file = paste0(substring(fns[i], 63, 65), "_console_output.csv"))
  print(i)
}