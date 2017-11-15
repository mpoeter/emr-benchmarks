library(plyr)
library(cowplot)

load_data <- function(machine, name, exclude_reclaimers = c())
{
  filename <- sprintf("%s/%s.csv", machine, name)
  data <- read.csv(file=filename, head=TRUE, sep="\t")
  data <- data[!(data$reclaimer %in% exclude_reclaimers), ]
  data$reclaimer <- factor(revalue(data$reclaimer,
                                   warn_missing = FALSE,
                                   replace = c("static-HPBR"="HPBR",
                                               "dynamic-HPBR"="HPBR",
                                               "LFRC-padded"="LFRC",
                                               "LFRC-padded-20"="LFRC")),
                           c("LFRC","HPBR","EBR","NEBR","QSBR","stamp"))
  data
}

calc_data <- function(data, variables, col = "unit") {
  cdata <- ddply(data, .variables = variables,
                 .fun = function(d) {
                   N = length (d[[col]])
                   sd = sd(d[[col]])
                   c(N,
                     mean = mean(d[[col]]),
                     sd,
                     se = sd / sqrt(N)
                   )
                 }
  )
  cdata
}

color_palette <- function()
{
  c("LFRC" = "#999999",
    "HPBR" = "#D55E00",
    "EBR" = "#009E43",
    "NEBR" = "#0072B2",
    "QSBR" = "#E69F00",
    "stamp" = "#56B4E9")
}

bar_plot <- function(plot, title, x, y, palette = color_palette(), text_size=10)
{
  plot +
  geom_bar(position = position_dodge(width=0.9), width=0.8, stat="identity") +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), position=position_dodge(width=0.9), width=0.8) +
  scale_fill_manual(values = palette) +
  labs(title=title, x=x, y=y) +
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        text = element_text(size=text_size),
        legend.text = element_text(size=text_size),
        plot.title = element_text(size=text_size + 0.5),
        axis.text.x = element_text(size=text_size),
        axis.title.x = element_text(size=text_size),
        axis.text.y = element_text(size=text_size),
        axis.title.y = element_text(size=text_size)) +
  guides(fill=guide_legend(nrow=1, byrow=TRUE))
}

combine_plots <- function(p1, p2, p3, p4, row1_widths = c(1,1), row2_widths = c(1,1))
{
  legend <- get_legend(p1)
  plot_theme <- theme(legend.position='none', plot.margin = unit(c(0.05, 0.2, 0, 0), "cm"))
  p1 <- p1 + plot_theme
  p2 <- p2 + plot_theme
  p3 <- p3 + plot_theme
  p4 <- p4 + plot_theme
  
  r1 = plot_grid(p1, p4, ncol=2, nrow=1, rel_widths = row1_widths)
  r2 = plot_grid(p2, p3, ncol=2, nrow=1, rel_widths = row2_widths)
  legend <- plot_grid(NULL, legend, NULL, ncol=3)
  plot_grid(r1, r2, legend, ncol=1, nrow=3, rel_heights = c(12, 12, 2))
}