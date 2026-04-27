# Load required libraries
library(ape)
library(ggtree)
library(ggplot2)
library(dplyr)
library(tidyr)

# Set working directory
setwd("~/R/ABI")

# === Load gene table ===
gene_table <- read.table("GeneTable.tsv", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
colnames(gene_table) <- c("tip", "gene")
gene_table$species <- sub(".*\\.", "", gene_table$tip)

# Count genes per species
gene_counts <- gene_table %>%
  group_by(species, gene) %>%
  summarize(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = gene, values_from = count, values_fill = list(count = 0))

# Convert to matrix format
gene_counts_mat <- as.data.frame(gene_counts)
rownames(gene_counts_mat) <- gene_counts_mat$species
gene_counts_mat$species <- NULL

# === Load species tree ===
tree <- read.tree("Metazoa.nwk")

# Remove unwanted tips
#tree <- drop.tip(tree, tips_to_remove)

# === Load mapping file to get full species names ===
mapping <- read.table("Mapping.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# Create named vector for renaming tips
tip_label_map <- setNames(mapping$Organism_Name, mapping$Species_ID)

# Rename tip labels in the tree
tree$tip.label <- ifelse(tree$tip.label %in% names(tip_label_map),
                         tip_label_map[tree$tip.label],
                         tree$tip.label)

# Rename gene_counts_mat row names to match full names
rownames(gene_counts_mat) <- ifelse(rownames(gene_counts_mat) %in% names(tip_label_map),
                                    tip_label_map[rownames(gene_counts_mat)],
                                    rownames(gene_counts_mat))

# Ensure the order of gene_counts matches the tree
gene_counts_mat <- gene_counts_mat[tree$tip.label, , drop = FALSE]

# === Plot the tree with heatmap ===
p <- ggtree(tree, layout = "circular") +
  geom_tiplab(size = 2.5, offset = 0.6)

# Add heatmap (crown)
p_heat <- gheatmap(p, gene_counts_mat, 
                   offset = 19,
                   width = 0.2,
                   colnames = FALSE) +
  scale_fill_gradient(low = "white", high = "violet")
# Display the plot
print(p_heat)

# Save the plot
ggsave("ABI.pdf", p_heat, device ="pdf", dpi = 1000, width = 10, height = 10)
