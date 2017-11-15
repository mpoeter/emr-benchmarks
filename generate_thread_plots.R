library(ggplot2)

source("util.R")

read_file <- function(machine, exclude)
{
  load_data(machine, "thread_results", exclude_reclaimers=exclude)
}

plot_threads <- function(machine, benchmark, params = "", divisor=1, yaxis="mean ns/op", exclude = c())
{
  data <- read_file(machine, exclude)
  filter <- data$benchmark == benchmark & data$threads != 2
  if (params != "")
    filter <- filter & data$params == params
  data <- data[filter, ]
  data$unit <- data[["ns.op"]] / divisor

  cdata <- calc_data(data, c("threads", "reclaimer"))
  cdata$threads <- as.ordered(cdata$threads)
  plot <- ggplot(data=cdata, aes(threads, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="threads", y=yaxis)
}

plot_threads_all <- function(benchmark, params = "", divisor=1000, yaxis=expression(paste("mean ", mu, "s/op")),
                             exclude = c())
{
  p1 <- plot_threads("AMD", benchmark, params, divisor, yaxis, exclude)
  p2 <- plot_threads("Intel", benchmark, params, divisor, yaxis, exclude)
  p3 <- plot_threads("XeonPhi", benchmark, params, divisor, yaxis, exclude)
  p4 <- plot_threads("Sparc", benchmark, params, divisor, yaxis, exclude)
  combine_plots(p1, p2, p3, p4, row1_widths=c(8,16), row2_widths=c(13,15))
}

plot <- plot_threads_all("queue")
ggsave("plots/threads-queue.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.199219")
ggsave("plots/threads-list-20.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.199219", exclude=c("LFRC-padded","LFRC-padded-20"))
ggsave("plots/threads-list-20-no-LFRC.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.799805")
ggsave("plots/threads-list-80.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.799805", exclude=c("LFRC-padded","LFRC-padded-20"))
ggsave("plots/threads-list-80-no-LFRC.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("hash_map", divisor=1000*1000, yaxis="mean ms/op")
ggsave("plots/threads-hash_map.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("hash_map", divisor=1000*1000, yaxis="mean ms/op", exclude=c("QSBR"))
ggsave("plots/threads-hash_map-no-QSBR.pdf", plot, width=240, height=120, units="mm")
