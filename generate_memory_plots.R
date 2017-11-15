library(ggplot2)
library(data.table)

source("util.R")

read_file <- function(machine)
{
  data <- load_data(machine, "memory_results")
  reshape_data(data)
}

reshape_data <- function(data)
{
  data <- melt(setDT(data), measure.vars=patterns("^memory_", "^runtime_", "^allocated_instances_", "^reclaimed_instances_"))
  data$memory <- data$value1 / (1024*1024)
  data$unreclaimed_objects <- data$value3 - data$value4
  data$variable <- as.numeric(data$variable)
  data$sample = data$variable + (data$trial - 1) * max(data$variable)
  data
}

plot_unreclaimed_nodes <- function(machine, benchmark, params="")
{
  data <- read_file(machine)
  filter <- data$benchmark == benchmark
  if (params != "")
    filter <- filter & data$params == params
  data <- data[filter, ]

  text_size <- 10
  plot <- ggplot(data=data, aes(x=sample, y=unreclaimed_objects)) +
    scale_fill_manual(values = color_palette()) +
    scale_colour_manual(values = color_palette()) +
    geom_smooth(aes(fill=reclaimer, colour=reclaimer), method="loess", span=0.025) +
    labs(title = sprintf("%s  (%d threads)", machine, data$threads[1]), x = "collected sample", y = "unreclaimed nodes") +
    theme(legend.position = "bottom",
          legend.title = element_blank(),
          text = element_text(size=text_size),
          legend.text = element_text(size=text_size),
          plot.title = element_text(size=text_size),
          axis.text.x = element_text(size=text_size),
          axis.title.x = element_text(size=text_size),
          axis.text.y = element_text(size=text_size),
          axis.title.y = element_text(size=text_size)) +
    guides(fill=guide_legend(nrow=1, byrow=TRUE))

  labely <- layer_scales(plot)$y$range$range[2] * 0.97
  for (tr in min(data$trial):max(data$trial))
  {
    samples <- data[data$trial == tr, ]
    rect <- data.frame(xmin=min(samples$sample), xmax=max(samples$sample), ymin=-Inf, ymax=Inf)
    plot <- plot +
      geom_rect(data=rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax),
                color="grey50",
                fill="grey30",
                alpha=0.05,
                size=0.15,
                inherit.aes = FALSE) +
      annotate("text", x = rect$xmin + (rect$xmax - rect$xmin)/2, y=labely, label=sprintf("trial %d", tr))
  }
  plot
}

plot_memory <- function(machine, benchmark, params="")
{
  data <- read_file(machine)
  filter <- data$benchmark == benchmark
  if (params != "")
    filter <- filter & data$params == params
  data <- data[filter, ]

  plot <- ggplot(data=data, aes(x=sample, y=memory)) +
    scale_fill_manual(values = color_palette()) +
    scale_colour_manual(values = color_palette()) +
    geom_smooth(aes(fill=reclaimer, colour=reclaimer), method="loess", span=0.025) +
    labs(title = machine, x = "sample", y = "resident set size (MB)") +
    theme(legend.position = "bottom",
          legend.title = element_blank(),
          legend.text = element_text(size=11),
          plot.title = element_text(size=11),
          axis.text.x = element_text(size=11),
          axis.title.x = element_text(size=11),
          axis.text.y = element_text(size=11),
          axis.title.y = element_text(size=11)) +
    guides(fill=guide_legend(nrow=1, byrow=TRUE))
}

plot_hash_map_runtime <- function(machine)
{
  data <- read_file(machine)
  data <- data[data$benchmark == "hash_map", ]

  data$unit = data[["ns.op"]] / 1000000
  cdata <- calc_data(data, c("trial", "reclaimer"))
  cdata$trial <- as.ordered(cdata$trial)
  plot <- ggplot(data=cdata, aes(trial, mean, fill=reclaimer))
  bar_plot(plot, title=machine, x="trial", y="mean ms/op")
}

plot_all <- function(benchmark, params="")
{
  p1 <- plot_unreclaimed_nodes("AMD", benchmark, params)
  p2 <- plot_unreclaimed_nodes("Intel", benchmark, params)
  p3 <- plot_unreclaimed_nodes("XeonPhi", benchmark, params)
  p4 <- plot_unreclaimed_nodes("Sparc", benchmark, params)

  legend <- get_legend(p1)
  plot_theme <- theme(legend.position='none')
  p1 <- p1 + plot_theme
  p2 <- p2 + plot_theme
  p3 <- p3 + plot_theme
  p4 <- p4 + plot_theme

  plot_grid(p1, p2, p3, p4, legend, ncol=1, nrow=5, rel_heights = c(8, 8, 8, 8, 1))
}

plot_all_hash_map_runtimes <- function()
{
  p1 <- plot_hash_map_runtime("AMD")
  p2 <- plot_hash_map_runtime("Intel")
  p3 <- plot_hash_map_runtime("XeonPhi")
  p4 <- plot_hash_map_runtime("Sparc")

  legend <- get_legend(p1)
  plot_theme <- theme(legend.position='none')
  p1 <- p1 + plot_theme
  p2 <- p2 + plot_theme
  p3 <- p3 + plot_theme
  p4 <- p4 + plot_theme

  r1 = plot_grid(p1, p4, ncol=2, nrow=1, rel_widths = c(1,1))
  r2 = plot_grid(p2, p3, ncol=2, nrow=1, rel_widths = c(1,1))
  legend <- plot_grid(NULL, legend, NULL, ncol=3)
  plot_grid(r1, r2, legend, ncol=1, nrow=3, rel_heights = c(12, 12, 2))
}

create_plots <- function()
{
  plot <- plot_all("hash_map")
  ggsave("plots/unreclaimed-objects-hash_map.pdf", plot, width=240, height=300, units="mm")

  plot <- plot_all("queue")
  ggsave("plots/unreclaimed-objects-queue.pdf", plot, width=240, height=300, units="mm")

  plot <- plot_all("list", params="elements: 10; modify-fraction: 0.199219")
  ggsave("plots/unreclaimed-objects-list-20.pdf", plot, width=240, height=300, units="mm")

  plot <- plot_all("list", params="elements: 10; modify-fraction: 0.799805")
  ggsave("plots/unreclaimed-objects-list-80.pdf", plot, width=240, height=300, units="mm")

  plot <- plot_all_hash_map_runtimes()
  ggsave("plots/unreclaimed-objects-hash_map-runtimes.pdf", plot, width=240, height=120, units="mm")
}

create_plots()