library(ggplot2)
library(plyr)
library(cowplot)
library(reshape2)

source("util.R")

read_file <- function(machine)
{
  filename <- sprintf("%s/stamp_results.csv", machine)
  data <- read.csv(file=filename, head=TRUE, sep="\t")
  data$push <- data$push_iterations
  data$remove_prev <- data$remove_prev_iterations
  data$remove_next <- data$remove_next_iterations
  data
}

plot_iterations <- function(machine, benchmark, params = "")
{
  data = read_file(machine)
  data = data[data$benchmark == benchmark, ]
  if (params != "")
    data = data[data$params == params, ]
  
  data <- data[,c('threads', 'push','remove_prev', 'remove_next')]
  data <- melt(data, id.vars='threads')
  
  cdata <- calc_data(data, c("threads", "variable"), col="value")
  cdata$threads <- as.ordered(cdata$threads)
  
  plot <- ggplot(data=cdata, aes(x = threads, y = mean, fill = variable))
  bar_plot(plot, title=machine, x="threads", y="mean iterations", palette = c("push" = "#999999",
                                                                              "remove_prev" = "#D55E00",
                                                                              "remove_next" = "#009E43"))
}

plot_iterations_all <- function(benchmark, params = "")
{
  p1 <- plot_iterations("AMD", benchmark, params)
  p2 <- plot_iterations("Intel", benchmark, params)
  p3 <- plot_iterations("XeonPhi", benchmark, params)
  p4 <- plot_iterations("Sparc", benchmark, params)
  combine_plots(p1, p2, p3, p4, row1_widths=c(8,16), row2_widths=c(13,15))
}

plot <- plot_iterations_all("queue")
ggsave("plots/stamp-queue.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_iterations_all("list", param="elements: 10; modify-fraction: 0.199219")
ggsave("plots/stamp-list-20.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_iterations_all("list", param="elements: 10; modify-fraction: 0.799805")
ggsave("plots/stamp-list-80.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_iterations_all("hash_map")
ggsave("plots/stamp-hash_map.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)

plot <- plot_iterations_all("guard_ptr")
ggsave("plots/stamp-guard_ptr.pdf", plot, width=240, height=120, units="mm", device=cairo_pdf)