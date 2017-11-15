library(ggplot2)

source("util.R")

read_file <- function(machine)
{
  filename <- sprintf("%s/LFRC_results.csv", machine)
  data <- read.csv(file=filename, head=TRUE, sep="\t")
  data$reclaimer <- factor(revalue(data$reclaimer, c("LFRC"="unpadded",
                                                     "LFRC-padded"="padded",
                                                     "LFRC-padded-20"="padded-20",
                                                     "LFRC-unpadded-20"="unpadded-20")),
                           c("unpadded","unpadded-20","padded", "padded-20"))
  data
}

plot_threads <- function(machine, benchmark, params = "", divisor=1, yaxis="mean ns/op")
{
  data = read_file(machine)
  data = data[data$benchmark == benchmark, ]
  if (params != "")
    data = data[data$params == params, ]

  data$unit = data[["ns.op"]] / divisor
  cdata <- calc_data(data, c("threads", "reclaimer"))
  cdata$threads <- as.ordered(cdata$threads)
  plot <- ggplot(data=cdata, aes(threads, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="threads", y=yaxis, palette = c("unpadded" = "#999999",
                                                                  "unpadded-20" = "#D55E00",
                                                                  "padded" = "#009E43",
                                                                  "padded-20" = "#0072B2"))
}

plot_threads_all <- function(benchmark, params = "", divisor=1000, yaxis=expression(paste("mean ", mu, "s/op")))
{
  p1 <- plot_threads("AMD", benchmark, params, divisor, yaxis)
  p2 <- plot_threads("Intel", benchmark, params, divisor, yaxis)
  p3 <- plot_threads("XeonPhi", benchmark, params, divisor, yaxis)
  p4 <- plot_threads("Sparc", benchmark, params, divisor, yaxis)
  combine_plots(p1, p2, p3, p4, row1_widths=c(8,16), row2_widths=c(13,15))
}

plot <- plot_threads_all("queue")
ggsave("plots/LFRC-queue.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.199219")
ggsave("plots/LFRC-list-20.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("list", param="elements: 10; modify-fraction: 0.799805")
ggsave("plots/LFRC-list-80.pdf", plot, width=240, height=120, units="mm")

plot <- plot_threads_all("hash_map", divisor=1000*1000, yaxis="mean ms/op")
ggsave("plots/LFRC-hash_map.pdf", plot, width=240, height=120, units="mm")
