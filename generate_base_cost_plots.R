library(ggplot2)

source("util.R")

read_file <- function(machine)
{
  data <-load_data(machine, "base_cost_results")
  levels(data$benchmark) <- c(levels(data$benchmark), "GuardPtr", "Queue", "List reads", "List writes")
  data$benchmark[data$params == "elements: 10; modify-fraction: 0.000000"]  <- "List reads"
  data$benchmark[data$params == "elements: 10; modify-fraction: 1.000000"]  <- "List writes"
  data$benchmark[data$benchmark == "queue"]  <- "Queue"
  data$benchmark[data$benchmark == "guard_ptr"]  <- "GuardPtr"
  data
}

plot_benchmarks <- function(machine, divisor=1, yaxis="mean ns/op")
{
  data <- read_file(machine)
  data <- data[data$benchmark != "hash_map", ]
  data$unit <- data[["ns.op"]] / divisor
  
  cdata <- calc_data(data, c("benchmark", "reclaimer"))
  plot <- ggplot(data=cdata, aes(benchmark, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="benchmark", y=yaxis)
}

plot_benchmarks_all <- function(divisor=1000, yaxis=expression(paste("mean ", mu, "s/op")))
{
  p1 <- plot_benchmarks("AMD", divisor, yaxis)
  p2 <- plot_benchmarks("Intel", divisor, yaxis)
  p3 <- plot_benchmarks("XeonPhi", divisor, yaxis)
  p4 <- plot_benchmarks("Sparc", divisor, yaxis)
  combine_plots(p1, p2, p3, p4)
}

plot <- plot_benchmarks_all()
ggsave("plots/base_costs.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)
