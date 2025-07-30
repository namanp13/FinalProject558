FROM rstudio/plumber

RUN apt-get update -qq && apt-get install -y libssl-dev libcurl4-gnutls-dev libpng-dev libpng-dev pandoc

RUN R -e "install.packages(c('caret', 'readr', 'dplyr', 'plumber', 'ggplot2', 'randomForest'))"

COPY API.R API.R
COPY diabetes_012_health_indicators_BRFSS2015.csv diabetes_012_health_indicators_BRFSS2015.csv

EXPOSE 8000

ENTRYPOINT ["R", "-e", \
"pr <- plumber::plumb('API.R'); pr$run(host='0.0.0.0', port=8000)"]
