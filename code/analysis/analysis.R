# Load required packages.
library("plyr")
library("tidyverse")
library("lme4")
library("sjPlot")

# setwd("~/gtd/courses/Honors-Thesis/data/")
setwd("~/gtd/courses/Honors-Thesis/data/")
source("../code/analysis/clean_load/functions.R")

# For each round of data collection, identify rejected participants and create a new data frame.
setwd("./round1/results/tables_aggregated/")
round_1_df <- get_accept_reject()
round_1_crit_data <- get_crit_data()

setwd("../../../round2/results/tables_aggregated/")
round_2_df <- get_accept_reject()
round_2_crit_data <- get_crit_data()

setwd("../../../round3/results/tables_aggregated/")
round_3_df <- get_accept_reject()
round_3_crit_data <- get_crit_data()

setwd("../../../round4/results/tables_aggregated/")
round_4_df <- get_accept_reject()
round_4_crit_data <- get_crit_data()

setwd("../../../round5/results/tables_aggregated/")
round_5_df <- get_accept_reject()
round_5_crit_data <- get_crit_data()

# Combine data frames to form one data frame.
all_rounds_initial_df <-
  bind_rows(list(round_1_df, round_2_df, round_3_df, round_4_df, round_5_df))
all_rounds_df <-
  all_rounds_initial_df[all_rounds_initial_df$Accept == "1",]
all_rounds_instructions <-
  subset(all_rounds_df, select = c("subjectid", "Instruction"))
all_rounds_crit <-
  bind_rows(
    list(
      round_1_crit_data,
      round_2_crit_data,
      round_3_crit_data,
      round_4_crit_data,
      round_5_crit_data
    )
  )

# Separate prepositional and particle data for analysis.
crit_data <-
  full_join(all_rounds_crit, all_rounds_instructions, "subjectid")
crit_data <- crit_data %>% drop_na(Instruction)
crit_data$Instruction <- factor(crit_data$Instruction)
crit_data_prep <- crit_data[crit_data$Type == "prepositional", ]
crit_data_particle <- crit_data[crit_data$Type == "particle", ]

# Analyze the prepositional data.
prep_model <-
  glmer(
    Response ~ Instruction + (1 |
                                subjectid),
    data = crit_data_prep,
    family = binomial(link = "logit")
  )
summary(prep_model)

# Analyze the particle data.
particle_model <-
  glmer(
    Response ~ Instruction + (1 |
                                subjectid),
    data = crit_data_particle,
    family = binomial(link = "logit")
  )
summary(particle_model)
