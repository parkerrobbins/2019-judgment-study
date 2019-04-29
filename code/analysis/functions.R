# This function creates unique subject ids by combining the hash of
# participants' IP addresses and the time that results were received. Use of
# this script depends on the setup created by "parse_ibex_results.sh".

get_subject_id <- function(dataframe) {
  dataframe[, "MD5.hash.of.participants.IP.address"] <-
    as.character(dataframe[, "MD5.hash.of.participants.IP.address"])
  dataframe[, "Time.results.were.received"] <-
    as.integer(dataframe[, "Time.results.were.received"])
  dataframe <-
    unite_(
      dataframe,
      "subjectid",
      c(
        "MD5.hash.of.participants.IP.address",
        "Time.results.were.received"
      ),
      sep = ""
    )
  return(dataframe)
}

# Find the instruction condition to which participants were assigned. 
get_instruction_condition <-
  function(file = "table-02_aggregated.csv") {
    instruction_condition <- read.csv(file)
    instruction_condition <- get_subject_id(instruction_condition)
    instruction_condition <-
      instruction_condition[instruction_condition$Value == "Start",]
    instruction_condition <-
      instruction_condition[, c("subjectid",
                                "Instruction")]
    return(instruction_condition)
  }

# Find participants' responses to the attention check question.
get_instruction_check <-
  function(file = "table-03_aggregated.csv") {
    instruction_check <- read.csv(file)
    instruction_check <- get_subject_id(instruction_check)
    instruction_check <-
      instruction_check[instruction_check$Parameter == "Selection", ]
    instruction_check <-
      instruction_check[, c("subjectid",
                            "Value")]
    colnames(instruction_check)[which(names(instruction_check) == "Value")] <-
      "instruction_check_response"
    return(instruction_check)
  }

# Find participants' responses to the attention check trials.
get_catch_trials <- function(file = "table-04_aggregated.csv") {
  catch_trials <- read.csv(file)
  catch_trials <- get_subject_id(catch_trials)
  catch_trials <- catch_trials[catch_trials$Type == "catch", ]
  catch_trials <-
    catch_trials[catch_trials$Parameter == "Selection", ]
  catch_trials[, "sentence1"] <-
    as.character(catch_trials[, "sentence1"])
  catch_trials <-
    catch_trials[, c("subjectid",
                     "Value",
                     "sentence1")]
  catch_trials$sentence1[catch_trials$sentence1 == "If you're reading this please select this sentence."] <-
    "catch_trial_1"
  catch_trials$sentence1[catch_trials$sentence1 == "If you're reading this do not select the other sentence select this one."] <-
    "catch_trial_2"
  catch_trials <- catch_trials %>% spread(sentence1, Value)
  catch_trials$catch_trial_1 <-
    as.character(catch_trials$catch_trial_1)
  catch_trials$catch_trial_2 <-
    as.character(catch_trials$catch_trial_2)
  return(catch_trials)
}

get_unique_id <- function(file = "table-06_aggregated.csv") {
  uniqueid <- read.csv(file)
  uniqueid <- get_subject_id(uniqueid)
  uniqueid <- uniqueid[uniqueid$Value == "Start", ]
  uniqueid <-
    uniqueid[, c("subjectid",
                 "uniqueid")]
  return(uniqueid)
}

get_demographics <- function(file = "table-05_aggregated.csv") {
  demographics <- read.csv(file)
  demographics <- get_subject_id(demographics)
  # Get rid of unnecessary rows and columns.
  demographics <-
    demographics[demographics$PennElementName == "demographics form", ]
  demographics <-
    demographics[, c("subjectid", "PennElementName", "Parameter", "Value")]
  # Reset value names.
  demographics$Value <- as.character(demographics$Value)
  demographics$Value[demographics$Value == "entry.199788844"] <-
    "Age"
  demographics$Value[demographics$Value == "entry.520109694.other_option_response"] <-
    "Gender"
  demographics$Value[demographics$Value == "entry.1512699209.other_option_response"] <-
    "Native_Lang"
  demographics$Value[demographics$Value == "entry.2041701843.other_option_response"] <-
    "Education"
  demographics$Value[demographics$Value == "entry.1032518118.other_option_response"] <-
    "Parent_Education"
  # Reset parameter names.
  demographics$Parameter <- as.character(demographics$Parameter)
  demographics$Parameter[demographics$Parameter == "entry.79932629"] <-
    "Ling_Course"
  demographics$Parameter[demographics$Parameter == "entry.520109694"] <-
    "Gender"
  demographics$Parameter[demographics$Parameter == "entry.1512699209"] <-
    "Native_Lang"
  demographics$Parameter[demographics$Parameter == "entry.2041701843"] <-
    "Education"
  demographics$Parameter[demographics$Parameter == "entry.1032518118"] <-
    "Parent_Education"
  # Switch age and value
  values <-
    c("Age",
      "Gender",
      "Native_Lang",
      "Education",
      "Parent_Education")
  
  for (i in 1:length(values)) {
    demographics <-
      demographics %>% mutate(Value = ifelse(Value == values[[i]],
                                             Parameter, Value))
    demographics <-
      demographics %>% mutate(Parameter = ifelse(Value == Parameter,
                                                 values[[i]],
                                                 Parameter))
  }
  # Delete other responses unless they contain text.
  demographics <- demographics %>%
    mutate_if(is.character, list(~ na_if(., "")))
  demographics <- demographics %>%
    mutate_if(is.character, list(~ na_if(., "__other_option__")))
  # make wide
  demographics <- demographics %>% drop_na(Value)
  demographics <- demographics %>% spread(Parameter, Value)
  return(demographics)
}

get_tables_merged <- function(dataframe_name = "tables_merged_df") {
  instruction_check_df <- get_instruction_check()
  instruction_condition_df <- get_instruction_condition()
  catch_trials_df <- get_catch_trials()
  unique_id_df <- get_unique_id()
  demographics_df <- get_demographics()
  dataframe_name <-
    join_all(
      list(
        instruction_check_df,
        instruction_condition_df,
        catch_trials_df,
        unique_id_df,
        demographics_df
      ),
      by = "subjectid",
      type = 'full'
    )
  return(dataframe_name)
}

get_accept_reject <- function(dataframe_name = "tables_merged") {
  dataframe_name <- get_tables_merged()
  dataframe_name$Accept <- NA
  # Catch trials
  dataframe_name <- dataframe_name %>% mutate(
    Accept = ifelse(
      instruction_check_response == "choice2" &
        catch_trial_1  == "sentence1" &
        catch_trial_2 == "sentence1",
      1,
      0
    )
  )
  # Exclude non-native English speakers.
  dataframe_name <- dataframe_name %>% mutate(
    Accept = ifelse(
      Native_Lang == "English only" |
        Native_Lang  == "English and one or more other languages",
      Accept,
      0
    )
  )
  # Remove anyone under 18
  dataframe_name$Age <- as.integer(dataframe_name$Age)
  dataframe_name <-
    dataframe_name %>% mutate(Accept = ifelse(Age >= 18 |
                                                is.na(Age) == TRUE,
                                              Accept,
                                              0))
  # Excluse people with linguistics experience.
  dataframe_name <-
    dataframe_name %>% mutate(Accept = ifelse(Ling_Course == "Yes",
                                              0,
                                              Accept))
  
  return(dataframe_name)
}

get_crit_data <- function(file = "table-04_aggregated.csv") {
  crit_data <- read.csv(file)
  crit_data <- get_subject_id(crit_data)
  crit_data <- crit_data[crit_data$Type != "catch", ]
  crit_data <- crit_data[crit_data$Type != "filler", ]
  crit_data <- crit_data[crit_data$Parameter == "Selection", ]
  all_stim <-
    read.csv("../../../all_stim_final.csv", stringsAsFactors = FALSE)
  all_stim <-
    unite_(all_stim,
           "trial_label",
           c("type",
             "trial_label"),
           sep = "")
  crit_data[, "sentence1"] <- as.character(crit_data[, "sentence1"])
  all_stim$VersionA -> all_stim$sentence1
  crit_data <- left_join(crit_data, all_stim, "sentence1")
  # 1 response if prescriptivist
  crit_data$Response <- NA
  crit_data <-
    crit_data %>% mutate(Response = ifelse(Value == "sentence1",
                                           0,
                                           1))
  # Remove unnecessary columns.
  crit_data <-
    crit_data[, c("subjectid", "Type", "Value", "trial_label", "Response")]
  return(crit_data)
}

