# install.packages("data.table")  # run once
> suppressPackageStartupMessages(library(data.table))
> 
> inspect_csv_schema_dt <- function(
+   file_path,
+   delimiter = ",",
+   has_header = TRUE,
+   sample_n = 200000,      # adjust up/down for speed vs. accuracy
+   na_strings = c("", "NA", "NaN", "NULL", "null"),
+   write_report_path = NULL
+ ) {
+   # Normalize path & basic checks
+   file_path <- normalizePath(file_path, winslash = "/", mustWork = TRUE)
+   if (!file.exists(file_path)) stop("File not found: ", file_path)
+   message("File: ", file_path)
+   message("Size: ", format(file.info(file_path)$size, big.mark = ","))
+ 
+   # 1) Read header only to get column names (no data pulled)
+   header_dt <- tryCatch(
+     fread(file = file_path, sep = delimiter, nrows = 0L, header = has_header),
+     error = function(e) stop("Failed to read header: ", e$message)
+   )
+   col_names <- names(header_dt)
+ 
+   # 2) Read a sample of rows to infer types
+   sample_dt <- tryCatch(
+     fread(
+       file = file_path,
+       sep = delimiter,
+       nrows = sample_n,
+       header = has_header,
+       na.strings = na_strings,
+       showProgress = TRUE
+     ),
+     error = function(e) stop("Failed to read sample: ", e$message)
+   )
+ 
+   # Ensure sample has the same column order
+   if (!identical(names(sample_dt), col_names)) {
+     warning("Column names/order changed between header and sample; aligning by header.")
+     setcolorder(sample_dt, col_names)
+   }
+ 
+   # 3) Infer R classes and build a compact report
+   # Helper to get first non-NA example value
+   first_example <- function(x) {
+     idx <- which(!is.na(x))[1]
+     if (!length(idx)) return(NA_character_)
+     val <- x[idx]
+     # shorten long strings
+     val <- as.character(val)[1]
+     if (nchar(val) > 80) paste0(substr(val, 1, 77), "...")
+     else val
+   }
+ 
+   # Map R classes -> friendly types (and a ClickHouse-ish guess)
+   map_type <- function(cls, x) {
+     r_type <- if ("integer64" %in% cls) "integer64"
+       else if ("integer" %in% cls) "integer"
+       else if ("numeric" %in% cls) "numeric"
+       else if ("logical" %in% cls) "logical"
+       else if ("IDate" %in% cls) "Date"
+       else if ("POSIXct" %in% cls) "POSIXct"
+       else "character"
+ 
+     # naive CH mapping guess from sample
+     ch_type <- switch(
+       r_type,
+       "integer64" = "Int64/UInt64",
+       "integer"   = "Int32/UInt32",
+       "numeric"   = "Float64",
+       "logical"   = "UInt8",
+       "Date"      = "Date",
+       "POSIXct"   = "DateTime",
+       "character" = "String",
+       "String"
+     )
+     list(r_type = r_type, ch_type = ch_type)
+   }
+ 
+   # Build report
+   r_classes <- lapply(sample_dt, class)
+   n <- nrow(sample_dt)
+   na_pct <- vapply(sample_dt, function(col) round(mean(is.na(col)) * 100, 2), numeric(1))
+   uniq_n <- vapply(sample_dt, function(col) suppressWarnings(length(unique(col))), numeric(1))
+   examples <- vapply(sample_dt, first_example, character(1))
+ 
+   type_maps <- mapply(map_type, r_classes, sample_dt, SIMPLIFY = FALSE)
+   r_types  <- vapply(type_maps, `[[`, character(1), "r_type")
+   ch_types <- vapply(type_maps, `[[`, character(1), "ch_type")
+ 
+   report <- data.table(
+     column          = col_names,
+     r_class         = r_types,
+     clickhouse_hint = ch_types,
+     sample_rows     = n,
+     na_pct          = na_pct,
+     unique_in_sample= uniq_n,
+     example_value   = examples
+   )
+ 
+   # Optional write-out
+   if (!is.null(write_report_path)) {
+     fwrite(report, write_report_path)
+     message("Schema report written to: ", normalizePath(write_report_path, winslash = "/"))
+   }
+ 
+   return(report)
+ }
> 
> # ---------- How to run (your path) ----------
> schema_report <- inspect_csv_schema_dt(
+   file_path = "C:/Users/10130495/OneDrive - NTT DATA Business Solutions AG/Documents/Personal/Datakind/producers_direct.csv",
+   delimiter = ",",
+   has_header = TRUE,
+   sample_n = 200000,  # increase if you want stronger inference
+   write_report_path = "C:/Users/10130495/OneDrive - NTT DATA Business Solutions AG/Documents/Personal/Datakind/producers_direct_schema.csv"
+ )
File: C:/Users/10130495/OneDrive - NTT DATA Business Solutions AG/Documents/Personal/Datakind/producers_direct.csv
Size: 7,253,798,414
Schema report written to: C:/Users/10130495/OneDrive - NTT DATA Business Solutions AG/Documents/Personal/Datakind/producers_direct_schema.csv
> 
> print(schema_report)
                        column   r_class clickhouse_hint sample_rows na_pct unique_in_sample                                example_value
                        <char>    <char>          <char>       <int>  <num>            <num>                                       <char>
 1:                question_id   integer    Int32/UInt32      200000   0.00            64235                                      3849056
 2:           question_user_id   integer    Int32/UInt32      200000   0.00            28105                                       519124
 3:          question_language character          String      200000   0.00                4                                          nyn
 4:           question_content character          String      200000   0.00            61678 E ABA WEFARM OFFICES ZABO NIZISHANGWA NKAHI?
 5:             question_topic character          String      200000   8.23              137                                       cattle
 6:              question_sent   POSIXct        DateTime      200000   0.00            62108                          2017-11-22 12:25:03
 7:                response_id   integer    Int32/UInt32      200000   0.00           153710                                     20691011
 8:           response_user_id   integer    Int32/UInt32      200000   0.00            58332                                       200868
 9:          response_language character          String      200000   0.00                4                                          nyn
10:           response_content character          String      200000   0.00           151043                   E!23 Omubazi Ni Dudu Cipa'
11:             response_topic character          String      200000  62.42              142                                       tomato
12:              response_sent   POSIXct        DateTime      200000   0.00           146400                   2019-01-24 17:54:06.216221
13:         question_user_type character          String      200000   0.00                1                                       farmer
14:       question_user_status character          String      200000   0.00                4                                         live
15: question_user_country_code character          String      200000   0.00                4                                           ug
16:       question_user_gender character          String      200000  89.92                3                                         male
17:          question_user_dob      Date            Date      200000  86.83             3239                                   1992-04-28
18:   question_user_created_at   POSIXct        DateTime      200000   0.00            26222                          2017-11-18 13:09:11
19:         response_user_type character          String      200000   0.00                1                                       farmer
20:       response_user_status character          String      200000   0.00                4                                         live
21: response_user_country_code character          String      200000   0.00                3                                           ug
22:       response_user_gender character          String      200000  83.93                3                                       female
23:          response_user_dob      Date            Date      200000  79.54             7851                                   1985-09-06
24:   response_user_created_at   POSIXct        DateTime      200000   0.00            54854                          2017-05-09 09:19:33
                        column   r_class clickhouse_hint sample_rows na_pct unique_in_sample                                example_value
> # install.packages("data.table")  # run once
> suppressPackageStartupMessages(library(data.table))
> 
> generate_schema_report <- function(
+   file_path,
+   output_csv = NULL,
+   delimiter = ",",
+   has_header = TRUE,
+   sample_n = 200000,
+   na_strings = c("", "NA", "NaN", "NULL", "null")
+ ) {
+   # Normalize path
+   file_path <- normalizePath(file_path, winslash = "/", mustWork = TRUE)
+   if (!file.exists(file_path)) stop("File not found: ", file_path)
+   message("File: ", file_path)
+   message("Size: ", format(file.info(file_path)$size, big.mark = ","))
+ 
+   # Read header only
+   header_dt <- fread(file = file_path, sep = delimiter, nrows = 0L, header = has_header)
+   col_names <- names(header_dt)
+ 
+   # Sample a portion for inference
+   sample_dt <- fread(
+     file = file_path,
+     sep = delimiter,
+     nrows = sample_n,
+     header = has_header,
+     na.strings = na_strings,
+     showProgress = TRUE
+   )
+ 
+   # Map R types → ClickHouse types
+   map_type <- function(cls) {
+     if ("integer64" %in% cls) return("Int64")
+     if ("integer"   %in% cls) return("Int32")
+     if ("numeric"   %in% cls) return("Float64")
+     if ("logical"   %in% cls) return("UInt8")
+     if ("Date"      %in% cls) return("Date")
+     if ("POSIXct"   %in% cls) return("DateTime")
+     return("String")
+   }
+ 
+   # Build schema table
+   schema <- data.table(
+     column = col_names,
+     r_class = vapply(sample_dt, function(x) class(x)[1], character(1)),
+     clickhouse_type = vapply(sample_dt, function(x) map_type(class(x)), character(1))
+   )
+ 
+   # Write CSV output
+   if (is.null(output_csv)) {
+     output_csv <- file.path(dirname(file_path), "schema_report.csv")
+   }
+   fwrite(schema, output_csv)
+   message("✅
+ 
+ 
