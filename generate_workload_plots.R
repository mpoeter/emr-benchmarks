library(ggplot2)

source("util.R")

read_file <- function(machine, exclude)
{
  data <- load_data(machine, "workload_results", exclude_reclaimers=append(exclude, c("LFRC-padded")))
  parse_params(data)
}

parse_params <- function(data)
{
  params <- data.frame(do.call('rbind', strsplit(as.character(data$params), "; ")))
  elems <- data.frame(do.call('rbind', strsplit(as.character(params$X1), ": ")))
  workload <- data.frame(do.call('rbind', strsplit(as.character(params$X2), ": ")))
  data$elements <- as.numeric(as.character(elems$X2))
  data$workload <- round(as.numeric(as.character(workload$X2)) * 100) / 100
  data
}

plot_workloads <- function(machine, threads, elems, divisor=1, yaxis="mean ns/op", exclude = c())
{
  data <- read_file(machine, exclude)
  filter <- data$threads == threads & data$elements == elems
  data <- data[filter, ]
  data$unit <- data[["ns.op"]] / divisor
  cdata <- calc_data(data, c("workload", "reclaimer"))
  cdata$workload <- as.ordered(cdata$workload)
  plot <- ggplot(data=cdata, aes(workload, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="workload", y=yaxis)
}

plot_workloads_all <- function(threads, elems, divisor=1000, yaxis=expression(paste("mean ", mu, "s/op")),
                               exclude = c())
{
  p1 <- plot_workloads("AMD", threads, elems, divisor, yaxis, exclude)
  p2 <- plot_workloads("Intel", threads, elems, divisor, yaxis, exclude)
  p3 <- plot_workloads("XeonPhi", threads, elems, divisor, yaxis, exclude)
  p4 <- plot_workloads("Sparc", threads, elems, divisor, yaxis, exclude)
  combine_plots(p1, p2, p3, p4)
}

plot <- plot_workloads_all(1, 1)
ggsave("plots/workloads-1-thread-1-elem.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_workloads_all(32, 1)
ggsave("plots/workloads-32-thread-1-elem.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_workloads_all(32, 1, exclude=c("LFRC-padded-20"))
ggsave("plots/workloads-32-thread-1-elem-no-LFRC.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_workloads_all(1, 25)
ggsave("plots/workloads-1-thread-25-elem.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_workloads_all(32, 25)
ggsave("plots/workloads-32-thread-25-elem.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_workloads_all(32, 25, exclude=c("LFRC-padded-20"))
ggsave("plots/workloads-32-thread-25-elem-no-LFRC.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)