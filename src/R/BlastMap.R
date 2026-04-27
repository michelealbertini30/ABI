library(ape)
library(ggtree)

setwd("~/R/ABI")

tree <- read.tree("ABI.gt25.trim.faa.treefile.cf.tree")

tips_to_remove <- c("g25.Sman","g425.Lcha")
tree <- drop.tip(tree, tips_to_remove)


gene_family_data <- read.delim("GeneTable.tsv", header = TRUE, sep = "\t")
colnames(gene_family_data) <- c("Tip", "GeneFamily")


# Convert tree tip labels to a data frame
tip_labels <- data.frame(Tip = tree$tip.label)

# Merge with gene family data
merged_data <- merge(tip_labels, gene_family_data, by = "Tip", all.x = TRUE)

# Create a color palette (you can customize this palette)
gene_families <- unique(merged_data$GeneFamily)

colors <- c("ABI1" = "limegreen", 
            "ABI2" = "orange", 
            "ABI3" = "steelblue",
            "ABI" = "violet",
            NA = "white")

# Plot the tree
p <- ggtree(tree, layout = "circular")

# Add the gene family information to the tree plot
p <- p %<+% merged_data

## Color only Points on the Tips
p <- p + 
  geom_point2(aes(subset = isTip, x = x, y = y, color = GeneFamily), size = 0.8, shape = 15) +
  scale_color_manual(values = colors) +
  theme_tree2() +
  theme(legend.position = "right")

## Color the whole Branch
p <- p + 
  geom_tree(aes(color = GeneFamily), size = 0.3) +  # Color branches
  scale_color_manual(values = colors) +
  theme_tree2() +
  theme(legend.position = "right")

print(p)
ggsave("GeneTree_v1.pdf", p, device = "pdf", dpi = 1000, width = 10, height = 10)
