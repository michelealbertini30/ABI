library(ape)
library(ggtree)
library(dplyr)
library(stringr)

tree <- read.tree("ABI.gt25.trim.faa.treefile.cf.tree")
tree <- read.tree("ABI.gt25.trim.fna.treefile.cf.tree")

tree_df <- read.delim("GeneTableNew.tsv", header = TRUE, sep = "\t")
colnames(tree_df) <- c("Tip", "GeneFamily")

taxonomy_df <- read.delim("Taxonomy.tsv", header = TRUE, sep = "\t")

# Extract species code (last 4 characters after the dot) from 'Tip'
tree_df <- tree_df %>%
  mutate(Species_ID = str_extract(Tip, "[^.]+$"))

# Join with taxonomy table based on species ID
merged_df <- tree_df %>%
  left_join(taxonomy_df, by = "Species_ID")

# Optional: select and rename relevant columns
gene_family_data <- merged_df %>%
  select(Tip, Taxonomy = `Phylum`)

# View result
print(gene_family_data)


# Convert tree tip labels to a data frame
tip_labels <- data.frame(Tip = tree$tip.label)

# Merge with gene family data
merged_data <- merge(tip_labels, gene_family_data, by = "Tip", all.x = TRUE)

# Create a color palette (you can customize this palette)
gene_families <- unique(merged_data$Taxonomy)

colors <- c("Annelida" = "limegreen", 
            "Arthropoda" = "darkgreen", 
            "Chelicerata" = "yellow",
            "Cnidaria" = "violet",
            "Crustacea" = "orange",
            "Mollusca" = "darkblue",
            "Myriapoda" = "red",
            "Nematoda" = "gold",
            "Platyhelminthes" = "brown",
            "Porifera" = "darkviolet",
            "Vertebrata" = "steelblue",
            "Vertebrate" = "steelblue")

# Plot the tree
p <- ggtree(tree, layout = "circular")

# Add the gene family information to the tree plot
p <- p %<+% merged_data

p <- p + 
  geom_point2(aes(subset = isTip, x = x, y = y, color = Taxonomy), size = 1, shape = 15) +
  scale_color_manual(values = colors) +
  theme_tree2() +
  theme(legend.position = "right")

print(p)
ggsave("TaxonomyTree.png", p, dpi = 1000, width = 10, height = 10)
