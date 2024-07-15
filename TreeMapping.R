library(ape)
library(ggtree)

tree <- read.tree("ABI.trimal.fa.raxml.bestTree")
gene_family_data <- read.delim("Gene_Table.tsv", header = TRUE, sep = "\t")

# Convert tree tip labels to a data frame
tip_labels <- data.frame(Tip = tree$tip.label)

# Merge with gene family data
merged_data <- merge(tip_labels, gene_family_data, by = "Tip", all.x = TRUE)

# Create a color palette (you can customize this palette)
gene_families <- unique(merged_data$GeneFamily)

colors <- c("ABI_interactor_1" = "limegreen", 
            "ABI_interactor_1a" = "darkgreen", 
            "ABI_interactor_2" = "orange",
            "ABI_interactor_2a" = "gold",
            "ABI_gene_family_member_3" = "steelblue",
            "ABI_gene_family_member_3a" = "skyblue")

# Plot the tree
p <- ggtree(tree, layout = "circular")

# Add the gene family information to the tree plot
p <- p %<+% merged_data

p <- p + 
  geom_point2(aes(subset = isTip, x = x, y = y, color = GeneFamily), size = 1, shape = 15) +
  scale_color_manual(values = colors) +
  theme_tree2() +
  theme(legend.position = "right")

print(p)
