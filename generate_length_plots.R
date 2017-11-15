library(ggplot2)

source("util.R")

read_file <- function(machine, exclude)
{
  data <- load_data(machine, "length_results", exclude_reclaimers=append(exclude, c("LFRC-padded")))
  parse_params(data)
}

parse_params <- function(data)
{
  params <- data.frame(do.call('rbind', strsplit(as.character(data$params), "; ")))
  elems <- data.frame(do.call('rbind', strsplit(as.character(params$X1), ": ")))
  workload <- data.frame(do.call('rbind', strsplit(as.character(params$X2), ": ")))
  data$elements <- as.numeric(as.character(elems$X2))
  data$workload <- as.numeric(as.character(workload$X2))
  data
}

plot_workloads <- function(machine, threads, workload, divisor=1, yaxis="mean ns/op", exclude = c())
{
  data = read_file(machine, exclude)
  filter <- data$threads == threads & data$workload == workload
  data <- data[filter, ]

  data$unit = data[["ns.op"]] / divisor
  cdata <- calc_data(data, c("elements", "reclaimer"))
  cdata$elements <- as.ordered(cdata$elements)
  plot <- ggplot(data=cdata, aes(elements, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="elements", y=yaxis)
}

plot_lengths_all <- function(threads, workload, divisor=1000, yaxis=expression(paste("mean ", mu, "s/op")),
                             exclude = c())
{
  p1 <- plot_workloads("AMD", threads, workload, divisor, yaxis, exclude)
  p2 <- plot_workloads("Intel", threads, workload, divisor, yaxis, exclude)
  p3 <- plot_workloads("XeonPhi", threads, workload, divisor, yaxis, exclude)
  p4 <- plot_workloads("Sparc", threads, workload, divisor, yaxis, exclude)
  combine_plots(p1, p2, p3, p4)
}

plot <- plot_lengths_all(1, 0.0)
ggsave("plots/length-all-1-thread-0.0-workload.pdf", plot, width=240, height=120, units="mm")

plot <- plot_lengths_all(1, 0.5)
ggsave("plots/length-all-1-thread-0.5-workload.pdf", plot, width=240, height=120, units="mm")

plot <- plot_lengths_all(32, 0.0)
ggsave("plots/length-all-32-thread-0.0-workload.pdf", plot, width=240, height=120, units="mm")

plot <- plot_lengths_all(32, 0.0, exclude=c("LFRC-padded-20"))
ggsave("plots/length-all-32-thread-0.0-workload-no-LFRC.pdf", plot, width=240, height=120, units="mm")

plot <- plot_lengths_all(32, 0.5)
ggsave("plots/length-all-32-thread-0.5-workload.pdf", plot, width=240, height=120, units="mm")

plot <- plot_lengths_all(32, 0.5, exclude=c("LFRC-padded-20"))
ggsave("plots/length-all-32-thread-0.5-workload-no-LFRC.pdf", plot, width=240, height=120, units="mm")